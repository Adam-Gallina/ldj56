extends RigidBody3D

@export var MinSpeed : float
@export var MaxSpeed : float

@export var TurnAccel : float

@onready var invincibility_timer : Timer = get_node('%InvincibilityTimer')
var _can_hit = true

var _focused = true

func set_focus(focus : bool):
    print('ship')
    _focused = focus

func _physics_process(delta):
    var pitch = 0
    var yaw = 0
    if _focused:
        pitch = Input.get_axis("input_down", "input_up")
        yaw = Input.get_axis("input_right", "input_left")

    angular_velocity += (transform.basis.x * pitch + Vector3.UP * yaw).normalized() * TurnAccel * delta
    # Messes up rotations about pivot...but you should never need to do that...
    rotation.z = 0
    
    linear_velocity = transform.basis.z * MinSpeed

func _on_area_3d_area_entered(area:Area3D):
    if not _can_hit: return

    print('Hit by ', area)
    invincibility_timer.start()

func _on_invincibility_timer_timeout():
    _can_hit = true


func _on_area_3d_body_entered(body:Node3D):
    print('body ', body)