extends CharacterBody3D

var speed
const WALK_SPEED = 2.0
const SPRINT_SPEED = 3.0
const CROUCH_SPEED = 1.0
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

var is_crouching = false

var flash_light_active = false
var moving_flash = false
@onready var flash_forward_dir : Vector3 = Vector3(
	$Head/Camera3D/HoldMarker.global_rotation.x,
	$Head/Camera3D/HoldMarker.global_rotation.y,
	$Head/Camera3D/HoldMarker.global_rotation.z
)

var has_held_flash = false

var has_key = false

var has_wrench = false
var has_hammer = false
var has_held_hammer = false
var is_holding_hammer = false
var hammer_just_smashed = false

var reading_note = false

var ending = false

var smash_time = false

var note

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
		if $Head/Camera3D/FlashRay.is_colliding():
			$DebugPoint.global_position = $Head/Camera3D/FlashRay.get_collision_point()
		
		
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			_play_step_sound()

		if Input.is_action_pressed("sprint") and not is_crouching:
			speed = SPRINT_SPEED
		elif is_crouching:
			speed = CROUCH_SPEED
		else:
			speed = WALK_SPEED

		if not reading_note:
			_walk(delta)
			
			if Input.is_action_just_pressed("crouch"):
				is_crouching = !is_crouching
				if is_crouching:
					$AnimationPlayer.play("crouch")
				elif not is_crouching and not $CrouchCheck.is_colliding():
					$AnimationPlayer.play_backwards("crouch")
				else:
					is_crouching = true
					

			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)

			_handle_fov(delta)
			
			move_and_slide()
		
		if $Head/Camera3D/RayCast3D.is_colliding() and not reading_note:
			if $Head/Camera3D/RayCast3D.get_collider().is_in_group("Sitable"):
				$PlayerGui._set_label("press e to sit")
				$Head/Camera3D/RayCast3D.get_collider().get_parent()._high_light_chair()
				if Input.is_action_just_pressed("interact"):
					_interact_sitable()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Powerable"):
				$PlayerGui._set_label("press e to toggle power")
				$Head/Camera3D/RayCast3D.get_collider().get_parent()._high_light_computer()
				if Input.is_action_just_pressed("interact"):
					_interact_powerable()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Drawer"):
				var drawer = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				drawer._high_light_drawer()
				if drawer.is_locked:
					drawer._check_key(has_key)
				$PlayerGui._set_label(drawer.message)
				if Input.is_action_just_pressed("interact"):
					_interact_drawer(drawer)
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Note"):
				note = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				note._high_light_note()
				$PlayerGui._set_label("press e to read")
				if Input.is_action_just_pressed("interact"):
					note._play_pickup()
					$PlayerGui._read_note(note.text)
					reading_note = true
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Key"):
				if $Head/Camera3D/RayCast3D.get_collider().get_parent().visible:
					$Head/Camera3D/RayCast3D.get_collider().get_parent()._high_light_key()
					$PlayerGui._set_label("press e to pickup")
				if Input.is_action_just_pressed("interact"):
					has_key = true
					$Head/Camera3D/RayCast3D.get_collider().get_parent()._play_pickup()
					$Head/Camera3D/RayCast3D.get_collider().get_parent().visible = false
			elif  $Head/Camera3D/RayCast3D.get_collider().is_in_group("Button"):
				var button = $Head/Camera3D/RayCast3D.get_collider()
				button._highlight()
				if Input.is_action_just_pressed("interact"):
					button._press_button()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Wrench"):
				var wrench = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				wrench._high_light()
				$PlayerGui._set_label("press e to pickup")
				if Input.is_action_just_pressed("interact"):
					has_wrench = true
					wrench._play_pickup()
					wrench.visible = false
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Vent"):
				$Head/Camera3D/RayCast3D.get_collider().get_parent()._highlight()
				if has_wrench:
					$PlayerGui._set_label("press e to loosen nuts")
				else:
					$PlayerGui._set_label("need to find something to loosen the nuts")
				if Input.is_action_just_pressed("interact") and has_wrench:
					$Head/Camera3D/RayCast3D.get_collider().get_parent()._open_vent()
			elif $Head/Camera3D/RayCast3D.get_collider().is_in_group("Hammer"):
				var hammer = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				hammer._high_light()
				$PlayerGui._set_label("press e to pickup")
				if Input.is_action_just_pressed("interact"):
					has_hammer = true
					hammer._play_pickup()
					hammer.visible = false
			if $Head/Camera3D/RayCast3D.get_collider().is_in_group("Breakable"):
				var breakable = $Head/Camera3D/RayCast3D.get_collider().get_parent()
				breakable._high_light()
				if hammer_just_smashed:
					breakable._break()
		elif reading_note:
			$PlayerGui._set_label("press e to drop note")
			if Input.is_action_just_pressed("interact"):
				$PlayerGui._close_note()
				note._play_drop()
				reading_note = false
		else:
			$PlayerGui._set_label("")
			if not has_held_flash:
				$PlayerGui._set_label("press f to equip flashlight")
			if has_hammer and not has_held_hammer:
				$PlayerGui._set_label("press g to equip hammer")
			if smash_time:
				$PlayerGui._set_label("smash them all!!!")
			
		if Input.is_action_just_pressed("open_flash") and not reading_note:
			has_held_flash = true
			if not flash_light_active:
				$FlashOn.play()
				$FlashNode.visible = true
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
		if $FlashNode.global_position.distance_to(current_maker.global_position) > thres:
			$FlashNode.global_position = $FlashNode.global_position.lerp(current_maker.global_position, 20 * delta)

			if current_maker == $Head/Camera3D/HoldMarker:
				#$Flashlight2.global_position = collision.position
				var flash_dir = $FlashNode.global_position - $DebugPoint.global_position
				var old_rot = $FlashNode.rotation
				$FlashNode.look_at($DebugPoint.global_position)
				$FlashNode.rotation.x = lerp_angle(old_rot.x, $FlashNode.rotation.x, 20 * delta)
				$FlashNode.rotation.y = lerp_angle(old_rot.y, $FlashNode.rotation.y, 20 * delta)
				$FlashNode.rotation.z = lerp_angle(old_rot.z, $FlashNode.rotation.z, 20 * delta)
			else:
				$FlashNode.rotation.x = lerp_angle($FlashNode.rotation.x, current_maker.global_rotation.x, 20 * delta)
				$FlashNode.rotation.y = lerp_angle($FlashNode.rotation.y, current_maker.global_rotation.y, 20 * delta)
				$FlashNode.rotation.z = lerp_angle($FlashNode.rotation.z, current_maker.global_rotation.z, 20 * delta)
				
		if Input.is_action_just_pressed("toggle_hammer") and has_hammer and not reading_note:
			if not is_holding_hammer:
				#$FlashOn.play()
				$HammerNode.visible = true
				is_holding_hammer = true
				has_held_hammer = true
				$Head/Camera3D/HoldMarker.position.x = -abs($Head/Camera3D/HoldMarker.position.x)
				$Head/Camera3D/LiftMarker.position.x = -abs($Head/Camera3D/LiftMarker.position.x)
			else:
				is_holding_hammer = false
				$Head/Camera3D/HoldMarker.position.x = abs($Head/Camera3D/HoldMarker.position.x)
				$Head/Camera3D/LiftMarker.position.x = abs($Head/Camera3D/LiftMarker.position.x)
				$HammerAwayTimer.start()
		
		var current_hammer_marker
		if is_holding_hammer:
			current_hammer_marker = $Head/Camera3D/HammerHoldMarker
		else:
			current_hammer_marker = $Head/Camera3D/HammerAwayMarker
		
		if $HammerNode.global_position.distance_to(current_hammer_marker.global_position) > thres:
			$HammerNode.global_position = $HammerNode.global_position.lerp(current_hammer_marker.global_position, 20 * delta)
			
			$HammerNode.rotation.x = lerp_angle($HammerNode.rotation.x, current_hammer_marker.global_rotation.x, 20 * delta)
			$HammerNode.rotation.y = lerp_angle($HammerNode.rotation.y, current_hammer_marker.global_rotation.y, 20 * delta)
			$HammerNode.rotation.z = lerp_angle($HammerNode.rotation.z, current_hammer_marker.global_rotation.z, 20 * delta)
			
		if Input.is_action_just_pressed("smash") and is_holding_hammer:
			$AnimationPlayer.play("swing_hammer")
	else:
		$PlayerGui._set_label("press left shift to stand up")
		if Input.is_action_just_pressed("sprint"):
			position = current_desk.get_node("StandMarker").global_position
			is_sitting = false
			current_desk._release_focus()
			
			if flash_light_active:
				$FlashNode.visible = true
			if is_holding_hammer:
				$HammerNode.visible = true
	
	if is_on_floor() and not last_on_floor:
		_play_step_sound()
	
	last_on_floor = is_on_floor()
	
	hammer_just_smashed = false

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
		
	$FlashNode.visible = false
	$HammerNode.visible = false

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
	$FlashNode.visible = false
	$FlashOff.play()

func _hammer_just_smashed():
	hammer_just_smashed = true


func _on_hammer_away_timer_timeout() -> void:
	$HammerNode.visible = false

func _end_game():
	$PlayerGui._play_ending()
