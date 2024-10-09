extends Control

var base_url: String
var files_to_download: Array = []
var current_file_index: int = 0
var downloaded_files: Array = []  # To keep track of downloaded files

func _ready() -> void:
	var dir_access = Directory.new()
	if dir_access.open("user://Downloads") == OK:
		# First, delete all files and subdirectories in the Downloads directory
		dir_access.list_dir_begin(true, true) # Enable skipping of navigation dots and hidden files/folders
		
		var file_name = dir_access.get_next()
		while file_name != "":
			dir_access.remove(file_name)
			file_name = dir_access.get_next()
		
		dir_access.list_dir_end()
		dir_access.remove("user://Downloads")  # Remove the directory itself if empty

	# Now create the Downloads directory again
	dir_access.make_dir("user://Downloads")

func _on_submit_pressed() -> void:
	base_url = $Server_container/Server_IP.text
	$Timer.start()
	fetch_directory()

func fetch_directory() -> void:
	var run = HTTPRequest.new()
	$Library.add_child(run)
	run.connect("request_completed", self, "_on_request_completed")
	run.request(base_url)

func _on_request_completed(_result: int, response_code: int, _headers: Array, body: PoolByteArray) -> void:
	if response_code == 200:
		$Server_Container.hide()
		$Library.show()
		if files_to_download.size() == 0:  # If fetching directory
			var html_content = body.get_string_from_utf8()
			print(html_content)
			files_to_download = parse_html_for_files(html_content)
			current_file_index = 0  # Reset index for downloading
			download_next_file()  # Start downloading files
		else:  # If downloading files
			var last_file_name = files_to_download[current_file_index - 1]
			var file_path = "user://Downloads/" + last_file_name
			save_file(file_path, body, last_file_name)
			download_next_file()  # Move to the next file

func parse_html_for_files(html_content: String) -> Array:
	var files: Array = []
	
	# Simple regex to match .txt and .png files in HTML
	var regex = RegEx.new()
	regex.compile('href="([^"]*\\.(txt|png))"')
	
	var matches = regex.search_all(html_content)
	for matchs in matches:
		files.append(matchs.strings[1])  # Add the matched file name

	return files

func save_file(file_path: String, body: PoolByteArray, last_file_name: String) -> void:
	var file_access = File.new()
	if file_access.open(file_path, File.WRITE) == OK:
		file_access.store_buffer(body)
		file_access.close()
		add_to_library(last_file_name)  # Add to library only after successful download

func download_file(file_name: String) -> void:
	var url = base_url + file_name
	var run = HTTPRequest.new()
	$Library.add_child(run)
	run.connect("request_completed", self, "_on_request_completed")
	run.request(url)

func add_to_library(file_name: String) -> void:
	if file_name in downloaded_files:
		return  # Avoid adding duplicate entries
	if file_name.ends_with(".png"):
		return
	downloaded_files.append(file_name)  # Keep track of added files
	var book = load("res://scenes/book.tscn")
	var book_instance = book.instance()
	$Library/GridContainer.add_child(book_instance)
	book_instance.book = file_name.get_basename()

func download_next_file() -> void:
	if current_file_index < files_to_download.size():
		download_file(files_to_download[current_file_index])
		current_file_index += 1

func _on_quicklnk_1_pressed() -> void:
	base_url = "http://0.0.0.0:8000/"
	$Timer.start()
	fetch_directory()

func _on_timer_timeout() -> void:
	for child in $Library.get_children():
		if child is HTTPRequest:
			child.queue_free()

func _on_quicklnk_2_pressed() -> void:
	base_url = "http://192.168.12.143:8000/"
	$Timer.start()
	fetch_directory()

func _on_TextureButton_pressed():
	get_tree().change_scene("res://scenes/settings.tscn")
