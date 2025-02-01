extends Node2D

signal invalid_command
signal yay
signal bookcase_crash

var base_text : String
var warned = false

var commands : Dictionary = {
	"clear": "resets the screen",
	"help": "displays all commands",
	"ls": "lists all folders/files in current directory",
	"cd": "changes directory relative to current directory\n\texample: cd data\n\texample backwards: cd ..",
	"read": "reads and displays contents a file relative to current directory\n\texample: read data.txt",
	"run": "executes a given .exe file\n\texample: run program.exe"
}

@onready var date = Time.get_date_dict_from_system()

@onready var directory_structure : Dictionary = {
	"data": {
		"secret" : {
			"backup": {
				"//flog.txt": "DATE 1982/07/13: FILE CREATED \"C:/data/secret/password.txt\" BY USER ADMIN\nDATE 2006/04/20: FILE CREATED \"C:/data/IGIVEUP.txt\" BY USER ADMIN\nDATE " + str(date["year"]) + "/" + str(date["month"]) + "/" + str(date["day"]) + ": ADMIN LOGGED IN"
			},
			"//fleftpcpassword.txt": "track44"
		},
		"//figiveup.txt": "I've been stuck here for so long, I was just in my house when I suddenly fell through the floor. I don't even know what this place is, I found a room behind one of the bookcases that should keep me safe. But I feel like I'm not alone, I don't know how much longer I can survive."
	},
	"trash": {},
	"//freadme.txt": "PLEASE FILL OUT README"
}

var current_directory_array = []

var unlocked : bool = false
var password : String = "history59"

var powered_on : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_layer = 0
	base_text = $SubViewportContainer/SubViewport/Control/TextEdit.text
	#var text_length = $SubViewportContainer/SubViewport/Control/TextEdit.text.length()
	_set_caret_to_end()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_viewport() -> String:
	return $SubViewportContainer/SubViewport.get_path()

func _set_caret_to_end():
	var line_index = $SubViewportContainer/SubViewport/Control/TextEdit.get_line_count()
	var wrap_count = $SubViewportContainer/SubViewport/Control/TextEdit.get_line_wrap_count(line_index - 1)
	$SubViewportContainer/SubViewport/Control/TextEdit.set_caret_line(line_index, true, true, wrap_count)
	var column_count = $SubViewportContainer/SubViewport/Control/TextEdit.get_line(line_index - 1).length()
	$SubViewportContainer/SubViewport/Control/TextEdit.set_caret_column(column_count)

func _on_line_edit_text_changed(new_text: String) -> void:
	$SubViewportContainer/SubViewport/Control/TextEdit.text = base_text + new_text
	#var text_length = $SubViewportContainer/SubViewport/Control/TextEdit.text.length()
	_set_caret_to_end()
	#var line = $SubViewportContainer/SubViewport/Control/TextEdit.get_line_count()w


func _on_line_edit_text_submitted(new_text: String) -> void:
	new_text = new_text.strip_edges()
	var command_array = new_text.split(" ")
	if new_text == "":
		base_text = $SubViewportContainer/SubViewport/Control/TextEdit.text + "\n"
	elif new_text == "sudo rm -fr ./*":
		base_text += new_text + "\nfrench language pack removed\n"
		yay.emit()
	else:
		if command_array[0] == "clear":
			base_text = ""
		else:
			base_text += new_text
			if command_array[0] == "help":
				if command_array.size() > 1:
					if command_array[1] in commands.keys():
						base_text += "\n" + commands[command_array[1]] + "\n"
					else:
						base_text += "\ninvalid command: " + command_array[1] + "\ntype \"help\" to see list of commands\n"
						invalid_command.emit()
				else:
					base_text = $SubViewportContainer/SubViewport/Control/TextEdit.text + "\nlist of commands:\n"
					for key in commands.keys():
						base_text += key +"\n"
					base_text += "for more info try \"help <command>\", example: help read\n"
			elif command_array[0] == "cd":
				if command_array.size() == 2:
					if command_array[1] == "..":
						if current_directory_array.size() > 0:
							current_directory_array.pop_back()
						base_text += "\n"
					elif current_directory_array.size() == 0:
						var folder = command_array[1].lstrip("./")
						if folder in directory_structure.keys():
							current_directory_array.push_back(folder)
						else:
							base_text += "\ninvalid directory path"
							invalid_command.emit()
						base_text += "\n"
					else:
						var folder = command_array[1].lstrip("./")
						var current_directory_dict = directory_structure[current_directory_array[0]]
						for i in range(current_directory_array.size()):
							if i != 0:
								current_directory_dict = current_directory_dict[current_directory_array[i]]
						if folder in current_directory_dict:
							current_directory_array.push_back(folder)
						else:
							base_text += "\ninvalid directory path"
							invalid_command.emit()
						base_text += "\n"
				else:
					base_text += "\ninvalid use of cd\ncorrect usage \"cd <directory_path>\"\nexample: cd data\n"
					invalid_command.emit()
			elif command_array[0] == "ls":
				if current_directory_array.size() > 0:
					var current_directory_dict = directory_structure[current_directory_array[0]]
					for i in range(current_directory_array.size()):
						if i != 0:
							current_directory_dict = current_directory_dict[current_directory_array[i]]
					base_text += "\n"
					for entry in current_directory_dict.keys():
						var text = entry.lstrip("//f")
						base_text += text + "\n"
				else:
					base_text += "\n"
					for entry in directory_structure.keys():
						var text = entry.lstrip("//f")
						base_text += text + "\n"
			elif command_array[0] == "read":
				if command_array.size() == 2:
					if current_directory_array.size() > 0:
						var current_directory_dict = directory_structure[current_directory_array[0]]
						for i in range(current_directory_array.size()):
							if i != 0:
								current_directory_dict = current_directory_dict[current_directory_array[i]]
						if "//f" + command_array[1] in current_directory_dict.keys():
							base_text += "\n" + current_directory_dict["//f" + command_array[1]]
						else:
							base_text += "\ninvalid file path"
							invalid_command.emit()
					else:
						if "//f" + command_array[1] in directory_structure.keys():
							base_text += "\n" + directory_structure["//f" + command_array[1]]
						else:
							base_text += "\ninvalid file path"
							invalid_command.emit()
				else:
					base_text += "\ninvalid use of read\ncorrect usage \"read <file_path>\"\nexample: read data.txt"
					invalid_command.emit()
				base_text += "\n"
			elif command_array[0] == "run":
				if command_array.size() == 2:
					if current_directory_array.size() > 0:
						var current_directory_dict = directory_structure[current_directory_array[0]]
						for i in range(current_directory_array.size()):
							if i != 0:
								current_directory_dict = current_directory_dict[current_directory_array[i]]
						if "//p" + command_array[1] in current_directory_dict.keys():
							if not warned:
								base_text += "\nTHEY'RE WATCHING"
								warned = true
								bookcase_crash.emit()
						else:
							base_text+= "\ninvalid file path"
							invalid_command.emit()
					else:
						if "//p" + command_array[1] in directory_structure.keys():
							if not warned:
								base_text += "\nTHEY'RE WATCHING"
								warned = true
								bookcase_crash.emit()
						else:
							base_text += "\ninvalid file path"
							invalid_command.emit()
				else:
					base_text += "\ninvalid use of run\ncorrect usage \"run <file_path>\"\nexample: run game.exe"
					invalid_command.emit()
				base_text += "\n"
			else:
				base_text = $SubViewportContainer/SubViewport/Control/TextEdit.text + "\ninvalid command: " + command_array[0] + "\n"
				invalid_command.emit()
	base_text += "C:/"
	for folder in current_directory_array:
		base_text += folder + "/"
	base_text += "$ "
	$SubViewportContainer/SubViewport/Control/TextEdit.text = base_text
	$SubViewportContainer/SubViewport/Control/LineEdit.text = ""
	
	_set_caret_to_end()


func _on_password_input_text_submitted(new_text: String) -> void:
	$SubViewportContainer/SubViewport/Control/PanelContainer/VBoxContainer/PasswordInput.text = ""
	if new_text == password:
		$SubViewportContainer/SubViewport/Control/PanelContainer/VBoxContainer/PasswordInput.release_focus()
		$SubViewportContainer/SubViewport/Control/LineEdit.grab_focus()
		$SubViewportContainer/SubViewport/Control/PanelContainer.visible = false
		unlocked = true
	else:
		invalid_command.emit()
