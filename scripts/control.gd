extends Control
export var book = "book"
func _process(delta):
	$Panel/Label.text = book


func _on_Button_pressed():
	Global.current_book = book
	get_tree().change_scene("res://scenes/reader.tscn")
