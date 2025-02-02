extends Node3D

signal unlocked
signal broken

var unlocked_done = false
var broken_done = false

@onready var desktops = [
	$Desktop1,
	$Desktop2,
	$Desktop3
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var all_unlocked = true
	for desktop in desktops:
		if not desktop._is_unlocked():
			all_unlocked = false
			break
	
	if all_unlocked and not unlocked_done:
		unlocked_done = true
		unlocked.emit()
		for desktop in desktops:
			desktop._display_mask()
			
	var all_broken = true
	for desktop in desktops:
		if not desktop.is_broken:
			all_broken = false
			break
	
	if all_broken and not broken_done:
		broken_done = true
		broken.emit()
