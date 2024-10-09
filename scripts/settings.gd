extends Control
var button_pressed = false
var text_pressed = false
var font_size = 20
var max_words = 100
var background_color = Color(1, 1, 1)  # Default to white
var txt_color = Color(255,255,255)
var config = ConfigFile.new()
var path = "user://settings.cfg"

func _ready():
	if config.load(path) == OK:
		if config.has_section("font"):
			font_size = config.get_value("font", "size", font_size)
			max_words = config.get_value("font", "maxword", max_words)
			background_color = config.get_value("font", "background_color", background_color)
			txt_color = config.get_value("font","text_color",txt_color)
	update_font()
	update_background_color()
	$fontsize.connect("value_changed", self, "_on_HSlider_value_changed")
	$maxwords.connect("value_changed", self, "_on_max_words_slider_value_changed")
	$ColorPicker.connect("color_changed", self, "_on_color_picker_color_changed")
	$fontsize.value = font_size
	$maxwords.value = max_words

func _on_HSlider_value_changed(value):
	$fontsizelbl/value.text = str(value)
	font_size = value
	update_font()
	save_settings()

func _on_max_words_slider_value_changed(value):
	$maxwordslbl/value.text = str(value)
	max_words = value
	save_settings()

func _on_color_picker_color_changed(color):
	background_color = color
	update_background_color()
	save_settings()

func save_settings():
	config.set_value("font", "size", font_size)
	config.set_value("font", "maxword", max_words)
	config.set_value("font", "background_color", background_color)
	config.set_value("font","text_color",txt_color)
	config.save(path)

func update_font():
	var dynamic_font = DynamicFont.new()
	var dynamic_font_data = DynamicFontData.new()
	dynamic_font_data.font_path = "res://assets/OpenSans-Italic-VariableFont_wdth,wght.ttf"
	dynamic_font.font_data = dynamic_font_data
	dynamic_font.size = font_size
	$fontsizelbl.add_font_override("font", dynamic_font)
	$maxwordslbl.add_font_override("font", dynamic_font)

func update_background_color():
	$BackroundPanel.modulate = background_color
	save_settings()

func _on_x_pressed():
	get_tree().change_scene("res://scenes/Home Selection.tscn")

func update_txt_color():
	$text_color.add_color_override("font_color",txt_color)
	$text_color.add_color_override("font_color_hover",txt_color)
	$text_color.add_color_override("font_color_focus",txt_color)
	save_settings()
func _on_colorpickerx_toggled():
	if button_pressed == true:
		button_pressed = false
		$ColorPicker.hide()
		background_color = $ColorPicker.color
		update_background_color()
	elif button_pressed == false:
		button_pressed = true
		$ColorPicker.show()


func _on_text_color_pressed():
	if text_pressed == true:
		text_pressed = false
		$ColorPicker2.hide()
		txt_color = $ColorPicker2.color
	elif text_pressed == false:
		text_pressed = true
		$ColorPicker2.show()


func _on_ColorPicker2_color_changed(_color):
	update_txt_color()
