extends RigidBody3D

@export var MinSpeed : float
@export var MaxSpeed : float

@export var TurnAccel : float

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