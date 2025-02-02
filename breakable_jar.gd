extends Node3D

@onready var outline = ResourceLoader.load("res://outline.material")
@onready var fake_mat = Material.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if ($Jar_CollisionMesh/JarWhole.material_overlay):
		$Jar_CollisionMesh/JarWhole.material_overlay = fake_mat

func _high_light():
	$Jar_CollisionMesh/JarWhole.material_overlay = outline

func _break():
	$Jar_CollisionMesh.process_mode = Node.PROCESS_MODE_DISABLED
	$Jar_CollisionMesh.visible = false
	$Pieces.visible = true
	$Pieces.process_mode = Node.PROCESS_MODE_INHERIT
	$SmashSound.play()
