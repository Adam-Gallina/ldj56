extends Camera3D

signal fov_anim_complete

@export_category('Camera')
@export var CamSpeed = .125
var curr_pan_mod = 1
@export var MinPitch = -90.
@export var MaxPitch = 90.
var pitch:
	set(val): get_parent().rotation.x = val
	get: return get_parent().rotation.x
var yaw:
	set(val): get_parent().rotation.y = val
	get: return get_parent().rotation.y

@onready var base_fov = fov

func _process(_delta):
	if Input.is_action_just_pressed('menu_pause'):
		#if Input.is_key_pressed(KEY_SHIFT): get_tree().quit()

		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

		await get_tree().create_timer(.35).timeout

		if Input.is_action_pressed('menu_pause'):
			get_tree().quit()

func set_camera(p:float, y:float):
	yaw = y
	if p < MinPitch: p = MinPitch
	elif p > MaxPitch: p = MaxPitch
	pitch = p

func _move_camera(dp:float, dy:float):
	yaw -= dy * CamSpeed * curr_pan_mod * PI / 180
	var p = pitch * 180 / PI - dp * CamSpeed * curr_pan_mod
	if p < MinPitch: p = MinPitch
	elif p > MaxPitch: p = MaxPitch
	pitch = p * PI / 180

func _input(event):
	if event is InputEventMouseMotion:
		_move_camera(event.relative.y, event.relative.x)


func set_fov_mod(val, duration, pan_mod=1): 
	_animate_fov(base_fov * val, duration)
	curr_pan_mod = pan_mod

func reset_fov(duration):
	set_fov_mod(1, duration)

func _animate_fov(val, duration):
	var start_val = fov
	var remaining = duration
	while remaining > 0:
		await get_tree().process_frame
		remaining -= get_process_delta_time()

		var t = 1 - remaining / duration
		fov = start_val + (val - start_val) * t
	fov = val
	
	fov_anim_complete.emit()
