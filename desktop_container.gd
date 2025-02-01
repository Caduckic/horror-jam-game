extends Node3D

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
	
	if all_unlocked:
		print("OOOO SPOOKY")
		for desktop in desktops:
			desktop._turn_off()
