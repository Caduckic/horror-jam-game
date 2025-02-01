extends Node3D

var computer1_password = "track44"
var computer2_password = "74here"
var computer3_password = "similar42"

@onready var date = Time.get_date_dict_from_system()

@onready var computer1_dir_structure : Dictionary = {
	"data": {
		"secret" : {
			"backup": {
				"//flog.txt": "DATE 1999/02/22: FILE CREATED \"C:/data/secret/storagepass.txt\" BY USER ADMIN\nDATE 2011/06/05: FILE CREATED \"C:/readme.txt\" BY USER ADMIN\nDATE 2017/01/02: FILE CREATED \"C:/data/coolstorybro.txt\" BY USER ADMIN\nDATE " + str(date["year"]) + "/" + str(date["month"]) + "/" + str(date["day"]) + ": ADMIN LOGGED IN"
			},
			"//fstoragepass.txt": "4412"
		},
		"//fcoolstorybro.txt": "This computer is in a library :)"
	},
	"trash": {},
	"//freadme.txt": "PLACEHOLDER TOPTEXT\n\nBOTTOMTEXT"
}

@onready var computer2_dir_structure : Dictionary = {
	"data": {
		"secret" : {
			"backup": {
				"//flog.txt": "DATE 1995/12/16: FILE CREATED \"C:/data/secret/yourenotalone.exe\" BY USER ADMIN\nDATE " + str(date["year"]) + "/" + str(date["month"]) + "/" + str(date["day"]) + ": ADMIN LOGGED IN"
			},
			"//pyourenotalone.exe": ""
		},
	},
	"bin": {},
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
	pass


func _on_door_pin_unlock_door() -> void:
	$StorageDoor._open_door()

func _knock_down_bookcase():
	$OpeningBookcase.global_position = $BookCaseFallMarker.global_position
	$OpeningBookcase.global_rotation = $BookCaseFallMarker.global_rotation
	$OpeningBookcase/FallNoise.play()


func _on_desktop_2_bookcase_crash() -> void:
	_knock_down_bookcase()
