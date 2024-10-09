extends Control
var t = true
export var book = "book"
func _process(_delta):
	$Label.text = book
	var f = File.new()
	if f.file_exists("user://Downloads/" + book + ".png") and t == false:
		print("LOD")
		t = true
		var texture = ImageTexture.new()
		var image = Image.new()
		image.load("user://Downloads/" + book + ".png")
		texture.create_from_image(image)
		$Panel/Sprite.texture = texture
		$Panel.add_stylebox_override("panel",StyleBoxEmpty)
		$Label.hide()


func _on_Button_pressed():
	Global.current_book = book
	get_tree().change_scene("res://scenes/reader.tscn")


func _on_Timer_timeout():
	t = false
