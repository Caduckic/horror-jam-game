extends CSGBox3D

@onready var outline = ResourceLoader.load("res://outline.material")

@export var button_char : String = "0"

var unlocked

signal button_pressed(char : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _press_button():
	button_pressed.emit(button_char)
	
func _highlight():
	if not unlocked:
		material_overlay = outline
