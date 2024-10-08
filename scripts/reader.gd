extends Control

var book
var text_content = []
var current_page = 0
var pages = []
var font_size = 20
var max_words = 300
var config = ConfigFile.new()
var path = "user://settings.cfg"

func _ready():
	book = Global.current_book
	if config.load(path) == OK:
		if config.has_section("font"):
			font_size = config.get_value("font", "size", font_size)
			max_words = config.get_value("font", "maxword", max_words)
	var f = File.new()
	if f.open("user://Downloads/" + book + ".txt", File.READ) == OK:
		text_content = f.get_as_text().split(" ")
		f.close()
	pageify()
	if load_bookmark():
		current_page = load_bookmark()
	update_display()
	update_font()

func update_display():
	$Label.text = pages[current_page]

func update_font():
	var dynamic_font = DynamicFont.new()
	var dynamic_font_data = DynamicFontData.new()
	dynamic_font_data.font_path = "res://assets/OpenSans-Italic-VariableFont_wdth,wght.ttf"
	dynamic_font.font_data = dynamic_font_data
	dynamic_font.size = font_size
	$Label.add_font_override("font", dynamic_font)

func pageify():
	var page = ""
	var word_cnt = 0
	for word in text_content:
		if word_cnt < max_words:
			page += word + " "
			word_cnt += 1
		else:
			pages.append(page)
			page = word + " "
			word_cnt = 1
	if page != "":
		pages.append(page)

func next_page():
	if current_page < pages.size() - 1:
		current_page += 1
		update_display()
		save_bookmark()

func previous_page():
	if current_page > 0:
		current_page -= 1
		update_display()
		save_bookmark()

func save_bookmark():
	var file = File.new()
	var dir = "user://Bookmarks/"
	var path = dir + book + ".mrk"
	
	if not Directory.new().dir_exists(dir):
		Directory.new().make_dir_recursive(dir)

	file.open(path, File.WRITE)
	file.store_string(str(current_page))
	file.close()

func load_bookmark():
	var path = "user://Bookmarks/" + book + ".mrk"
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var saved_page = file.get_line().to_int()
		file.close()
		return saved_page
	return 0

func save_settings():
	config.set_value("font", "size", font_size)
	config.set_value("font", "maxword", max_words)
	config.save(path)

func _on_HSlider_value_changed(value):
	font_size = value
	update_font()
	save_settings()

func _on_max_words_slider_value_changed(value):
	max_words = value
	pageify()  # Recalculate pages with new max words
	update_display()
	save_settings()

func _on_left_pressed():
	previous_page()

func _on_right_pressed():
	next_page()
