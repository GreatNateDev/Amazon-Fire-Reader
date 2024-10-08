extends Control

var font_size = 20
var max_words = 100
var config = ConfigFile.new()
var path = "user://settings.cfg"

func _ready():
	if config.load(path) == OK:
		if config.has_section("font"):
			font_size = config.get_value("font", "size", font_size)
			max_words = config.get_value("font", "maxword", max_words)
	update_font()
	$fontsize.connect("value_changed", self, "_on_HSlider_value_changed")
	$maxwords.connect("value_changed", self, "_on_max_words_slider_value_changed")

func _on_HSlider_value_changed(value):
	font_size = value
	update_font()
	save_settings()

func _on_max_words_slider_value_changed(value):
	max_words = value
	save_settings()

func save_settings():
	config.set_value("font", "size", font_size)
	config.set_value("font", "maxword", max_words)
	config.save(path)

func update_font():
	var dynamic_font = DynamicFont.new()
	var dynamic_font_data = DynamicFontData.new()
	dynamic_font_data.font_path = "res://OpenSans-Italic-VariableFont_wdth,wght.ttf"
	dynamic_font.font_data = dynamic_font_data
	dynamic_font.size = font_size
	$fontsizelbl.add_font_override("font", dynamic_font)
	$maxwordslbl.add_font_override("font", dynamic_font)
