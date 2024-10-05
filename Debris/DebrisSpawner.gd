extends Node3D
class_name DebrisSpawner

@export var Debris : Array[PackedScene]
## Chance compared to other debris
@export var DebrisChance : Array[int]
@export var DebrisWeights : Array[int]

@export var DebrisScaleMin : float
@export var DebrisScaleMax : float
@export var DebrisVelocityMin : float
@export var DebrisVelocityMax : float
@export var DebrisAngularMin : float
@export var DebrisAngularMax : float

@onready var _total_debris_chance = MyMath.sum(DebrisChance)

func _add_random_debris() -> int:
    var r = randi() % _total_debris_chance
    var i = -1
    while r > 0:
        i += 1
        r -= DebrisChance[i]

    return i

func _randomize_debris(scene:PackedScene) -> RigidBody3D:
    var d : RigidBody3D = scene.instantiate()

    var s = randf_range(DebrisScaleMin, DebrisScaleMax)
    d.get_child(0).scale = Vector3(s,s,s)

    var dir = MyMath.rand_rotate_vector3()
    d.linear_velocity = dir * randf_range(DebrisVelocityMin, DebrisVelocityMax)

    var ang = MyMath.rand_rotate_vector3()
    d.angular_velocity = ang * randf_range(DebrisAngularMin, DebrisAngularMax)

    return d


func generate_debris_field(total_weight:int, radius:float) -> Node3D:
    var debris = Node3D.new()

    while total_weight > 0:
        var i = _add_random_debris()

        total_weight -= DebrisWeights[i]

        var d = _randomize_debris(Debris[i])
        d.position = MyMath.rand_rotate_vector3() * radius * randf()
        debris.add_child(d)

    return debris