extends Node3D

@export_multiline var text = ""

@onready var outline = ResourceLoader.load("res://outline.material")
@onready var fake_mat = Material.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if ($Note.material_overlay):
		$Note.material_overlay = fake_mat
	
func _high_light_note():
	$Note.material_overlay = outline

func _play_pickup():
	$Pickup.play()

func _play_drop():
	$Drop.play()
