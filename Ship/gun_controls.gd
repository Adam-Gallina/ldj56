extends Node3D

@export var RotationSpeed : float
@export var MissRange : float = 50
@export var GunOrigins : Array[Node3D]

@onready var gunCamPivot : Node3D = get_node('%GunCamPivot')
@onready var gunRayCast : RayCast3D = get_node('%GunRayCast')

var _focused = false

func set_focus(focus : bool):
    print('gun')
    _focused = focus

func _physics_process(delta):
    var pitch = 0
    var yaw = 0
    if _focused:
        pitch = Input.get_axis("input_down", "input_up")
        yaw = Input.get_axis("input_right", "input_left")

        gunCamPivot.rotation.x += pitch * RotationSpeed * delta
        gunCamPivot.rotation.y += yaw * RotationSpeed * delta
    
        if Input.is_action_pressed("input_action"):
            # Fire
            pass

    var gunTarget : Vector3
    if gunRayCast.is_colliding():
        #gunTarget = gunRayCast.get_collider().get_child(gunRayCast.get_collider_shape()).global_position
        gunTarget = gunRayCast.get_collider().global_position
    else:
        gunTarget = gunCamPivot.global_position + gunCamPivot.global_basis.z * MissRange

    for i in GunOrigins:
        i.look_at(gunTarget)