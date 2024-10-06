extends RigidBody3D

@export var MinSpeed : float = 0
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

var _invert_controls = true
func _physics_process(delta):
    var pitch = 0
    var yaw = 0
    if _focused:
        pitch = Input.get_axis("input_down", "input_up")
        if not _invert_controls: pitch *= -1
        yaw = Input.get_axis("input_right", "input_left")

    angular_velocity += (global_basis.x * pitch + global_basis.y * yaw).normalized() * TurnAccel * delta
    linear_velocity = transform.basis.z * MinSpeed


func _on_hit() -> bool:
    if not _can_hit: return false

    invincibility_timer.start()
    print(_health)
    _health -= 1
    _can_hit = false

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

    await get_tree().create_timer(2).timeout

    get_parent().lose_game()


func _on_invincibility_timer_timeout():
    _can_hit = true

func _on_area_3d_area_entered(_area:Area3D):
    _on_hit()

func _on_area_3d_body_entered(_body:Node3D):
    _on_hit()

func _on_invert_controls_toggled(toggled_on:bool):
    _invert_controls = toggled_on
