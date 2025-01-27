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

var flash_light_active = false
var moving_flash = false

var has_key = false

var reading_note = false

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

		if not reading_note:
			_walk(delta)

			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)

			_handle_fov(delta)
			
			move_and_slide()
		
		if $Head/Camera3D/RayCast3D.is_colliding() and not reading_note:
			if $Head/Camera3D/RayCast3D.get_collider().is_in_group("Sitable"):
				$PlayerGui._set_label("press e to sit")
				if Input.is_action_just_pressed("interact"):
					_interact_sitable()
					#current_desk = $Head/Camera3D/RayCast3D.get_collider().get_parent()
					#position = current_desk.get_node("SitMarker").global_position
					#head.look_at(current_desk.get_node("ScreenMarker").global_position, Vector3.UP)
					#head.rotation.x = 0
					#head.rotation.z = 0
					#
					##camera.look_at(screenDir, Vector3.LEFT)
					#camera.rotation = Vector3.ZERO
					#is_sitting = true;
					#if current_desk._is_powered_on():
						#current_desk._grab_focus()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Powerable"):
				$PlayerGui._set_label("press e to toggle power")
				if Input.is_action_just_pressed("interact"):
					_interact_powerable()
					#if $Head/Camera3D/RayCast3D.get_collider().get_parent()._is_powered_on():
						#$Head/Camera3D/RayCast3D.get_collider().get_parent()._turn_off()
					#else:
						#$Head/Camera3D/RayCast3D.get_collider().get_parent()._turn_on()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Drawer"):
				var drawer = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				if drawer.is_locked:
					drawer._check_key(has_key)
				$PlayerGui._set_label(drawer.message)
				if Input.is_action_just_pressed("interact"):
					_interact_drawer(drawer)
					#if drawer.is_locked and has_key:
						#drawer._unlock()
					#else:
						#drawer._toggle_open()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Note"):
				var note = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				$PlayerGui._set_label("press e to read")
				if Input.is_action_just_pressed("interact"):
					$PlayerGui._read_note(note.text)
					reading_note = true
		elif reading_note:
			$PlayerGui._set_label("press e to drop note")
			if Input.is_action_just_pressed("interact"):
				$PlayerGui._close_note()
				reading_note = false
		else:
			$PlayerGui._set_label("")
			
		if Input.is_action_just_pressed("open_flash") and not reading_note:
			if not flash_light_active:
				$Flashlight2.visible = true
				flash_light_active = true
			else:
				flash_light_active = false
				$FlashAwayTimer.start()
		
		var current_maker
		if flash_light_active:
			if $Head/Camera3D/WallRay.is_colliding():
				current_maker = $Head/Camera3D/LiftMarker
			else:
				current_maker = $Head/Camera3D/HoldMarker
		else:
			current_maker = $Head/Camera3D/AwayMarker
		
		var thres = 0.01
		if $Flashlight2.global_position.distance_to(current_maker.global_position) > thres:
			$Flashlight2.global_position = $Flashlight2.global_position.lerp(current_maker.global_position, 20 * delta)

			$Flashlight2.rotation.x = lerp_angle($Flashlight2.rotation.x, current_maker.global_rotation.x, 20 * delta)
			$Flashlight2.rotation.y = lerp_angle($Flashlight2.rotation.y, current_maker.global_rotation.y, 20 * delta)
			$Flashlight2.rotation.z = lerp_angle($Flashlight2.rotation.z, current_maker.global_rotation.z, 20 * delta)
	else:
		$PlayerGui._set_label("press left shift to stand up")
		if Input.is_action_just_pressed("sprint"):
			position = current_desk.get_node("StandMarker").global_position
			is_sitting = false
			current_desk._release_focus()
	
	if is_on_floor() and not last_on_floor:
		_play_step_sound()
	
	last_on_floor = is_on_floor()

func _interact_sitable():
	current_desk = $Head/Camera3D/RayCast3D.get_collider().get_parent()
	position = current_desk.get_node("SitMarker").global_position
	head.look_at(current_desk.get_node("ScreenMarker").global_position, Vector3.UP)
	head.rotation.x = 0
	head.rotation.z = 0
	
	#camera.look_at(screenDir, Vector3.LEFT)
	camera.rotation = Vector3.ZERO
	is_sitting = true;
	if current_desk._is_powered_on():
		current_desk._grab_focus()

func _interact_powerable():
	if $Head/Camera3D/RayCast3D.get_collider().get_parent()._is_powered_on():
		$Head/Camera3D/RayCast3D.get_collider().get_parent()._turn_off()
	else:
		$Head/Camera3D/RayCast3D.get_collider().get_parent()._turn_on()

func _interact_drawer(drawer):
	if drawer.is_locked and has_key:
		drawer._unlock()
	else:
		drawer._toggle_open()

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


func _on_flash_away_timer_timeout() -> void:
	$Flashlight2.visible = false
