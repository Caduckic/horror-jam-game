extends CharacterBody3D

var speed
const WALK_SPEED = 2.0
const SPRINT_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01

const BOB_FREQ = 4.0
const BOB_AMP = 0.04
var t_bob = 0.0
var is_bob_positive = true

const BASE_FOV = 75
const FOV_CHANGE = 1.5

var is_sitting = false
var current_desk = null

var footstep_sounds = [
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_01.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_02.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_03.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_04.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_05.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_06.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_07.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_08.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_09.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_10.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_11.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_12.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_13.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_14.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_15.wav"),
	preload("res://sounds/foot_steps/Concrete_Trainers_FullStep_16.wav")
]
var last_footstep_index = 0

var last_on_floor : bool = false

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _walk(delta: float):
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)

func _handle_fov(delta: float):
	var walkVel = Vector2(velocity.x, velocity.z)
	var velocity_clamped = clamp(walkVel.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not is_sitting:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			_play_step_sound()

		if Input.is_action_pressed("sprint"):
			speed = SPRINT_SPEED
		else:
			speed = WALK_SPEED

		_walk(delta)

		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)

		_handle_fov(delta)
		
		move_and_slide()
		
		if $Head/Camera3D/RayCast3D.is_colliding():
			if $Head/Camera3D/RayCast3D.get_collider().is_in_group("Sitable"):
				$PlayerGui._set_label("press e to sit")
				if Input.is_action_just_pressed("interact"):
					current_desk = $Head/Camera3D/RayCast3D.get_collider().get_parent()
					position = current_desk.get_node("SitMarker").position
					var screenDir = (head.position - current_desk.get_node("ScreenMarker").position).normalized()
					head.look_at(screenDir, Vector3.UP)
					head.rotation.x = 0
					head.rotation.z = 0
					
					#camera.look_at(screenDir, Vector3.LEFT)
					camera.rotation = Vector3.ZERO
					is_sitting = true;
					if current_desk._is_powered_on():
						current_desk._grab_focus()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Powerable"):
				$PlayerGui._set_label("press e to toggle power")
				if Input.is_action_just_pressed("interact"):
					if $Head/Camera3D/RayCast3D.get_collider().get_parent()._is_powered_on():
						$Head/Camera3D/RayCast3D.get_collider().get_parent()._turn_off()
					else:
						$Head/Camera3D/RayCast3D.get_collider().get_parent()._turn_on()
		else:
			$PlayerGui._set_label("")
	else:
		$PlayerGui._set_label("press left shift to stand up")
		if Input.is_action_just_pressed("sprint"):
			position = current_desk.get_node("StandMarker").position
			is_sitting = false
			current_desk._release_focus()
	
	if is_on_floor() and not last_on_floor:
		_play_step_sound()
	
	last_on_floor = is_on_floor()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP

	if is_bob_positive and sin(time * BOB_FREQ) < 0:
		is_bob_positive = false
		_play_step_sound()
	elif not is_bob_positive and sin(time * BOB_FREQ) > 0:
		is_bob_positive = true

	return pos

func _play_step_sound():
	var next_index = randi_range(0, 15)
	while next_index == last_footstep_index:
		next_index = randi_range(0, 15)
	last_footstep_index = next_index
	$Footsteps.stream = footstep_sounds[next_index]
	$Footsteps.play()
