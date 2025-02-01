extends Node3D

@onready var outline = ResourceLoader.load("res://outline.material")
@onready var fake_mat = Material.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _high_light():
	$Model.material_overlay = outline

func _physics_process(delta: float) -> void:
	if ($Model.material_overlay):
		$Model.material_overlay = fake_mat

func _queue_free():
	queue_free()

func _play_pickup():
	$Pickup.play()
