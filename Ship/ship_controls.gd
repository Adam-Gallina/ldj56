extends RigidBody3D

@export var MinSpeed : float
@export var MaxSpeed : float

@export var TurnAccel : float

@export var MaxHealth = 5
@onready var _health = MaxHealth
var _dead = false

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


func _on_hit() -> bool:
    if not _can_hit: return false

    invincibility_timer.start()
    _health -= 1

    $AlienPositions.show_alien()

    if _health <= 0:
        _death()

    return true

func _death():
    if _dead: return

    _dead = true
    $DeathAlienPositions.reveal()
    $CPUParticles3D.emitting = true
    $CPUParticles3D/MeshInstance3D.show()


func _on_invincibility_timer_timeout():
    _can_hit = true

func _on_area_3d_area_entered(_area:Area3D):
    _on_hit()

func _on_area_3d_body_entered(_body:Node3D):
    _on_hit()