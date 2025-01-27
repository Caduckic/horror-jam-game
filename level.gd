extends Node3D

var computer1_password = "secret1"
var computer2_password = "secret2"
var computer3_password = "secret3"

@onready var computer1_dir_structure : Dictionary = {
	"data": {
		"secret" : {
			"empty": {},
			"//fmiddlecomputerpass.txt": computer2_password
		},
		"//fcoolstorybro.txt": "This computer is in a library :)"
	},
	"bin": {},
	"//freadme.txt": "PLACEHOLDER TOPTEXT\n\nBOTTOMTEXT"
}

@onready var computer2_dir_structure : Dictionary = {
	"data": {
		"secret" : {
			"empty": {},
			"//fmiddlecomputerpass.txt": computer2_password
		},
		"//fcoolstorybro.txt": "This computer is in a library :)"
	},
	"bin": {},
	"//freadme.txt": "PLACEHOLDER TOPTEXT\n\nBOTTOMTEXT"
}

@onready var computer3_dir_structure : Dictionary = {
	"data": {
		"secret" : {
			"empty": {},
			"//fmiddlecomputerpass.txt": computer2_password
		},
		"//fcoolstorybro.txt": "This computer is in a library :)"
	},
	"bin": {},
	"//freadme.txt": "PLACEHOLDER TOPTEXT\n\nBOTTOMTEXT"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DesktopContainer/Desktop1._set_password(computer1_password)
	$DesktopContainer/Desktop1._set_directory_structure(computer1_dir_structure)
	$DesktopContainer/Desktop2._set_password(computer2_password)
	$DesktopContainer/Desktop2._set_directory_structure(computer2_dir_structure)
	$DesktopContainer/Desktop3._set_password(computer3_password)
	$DesktopContainer/Desktop3._set_directory_structure(computer3_dir_structure)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
	if Input.is_action_just_pressed("fullscreen_toggle"):
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
