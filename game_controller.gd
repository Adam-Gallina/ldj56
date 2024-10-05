extends Node3D

@onready var player : RigidBody3D = get_node('%PlayerShip')

@onready var path_gen : PathGen = get_node('%Pathing')
@export var ActiveSegments = 2
@export var ExtraSegments = 1
var _curr_segment : PathGen.TunnelSegment

@onready var attack_spawner : AttackSpawner = get_node('%AttackSpawner')
@export var StartAttackDelay : float = 1
@export var AttackDelayMin : float = 3
@export var AttackDelayMax : float = 6
@export var AttackSpawnDistMin : float = 50
@export var AttackSpawnDistMax : float = 200
var _next_attack : float

@onready var debris_spawner : DebrisSpawner = get_node('%DebrisSpawner')
@export var StartDebrisDelay : float = 1
@export var DebrisDelayMin : float = 5
@export var DebrisDelayMax : float = 10
@export var DebrisSpawnDist : float = 500
@export var DebrisWeightMin : int = 30
@export var DebrisWeightMax : int = 60
@export var DebrisRadiusMin : int = 60
@export var DebrisRadiusMax : int = 120
@export var MaxDebrisOffsetPercent : float = .75
var _next_debris : float

func _ready():
    generate_initial_paths()
    start_game()

func generate_initial_paths():
    _curr_segment = path_gen.generate_new_segment(Vector3.ZERO, Vector3.MODEL_FRONT)
    var s = _curr_segment
    for i in range(ActiveSegments + ExtraSegments-1):
        s = path_gen.generate_new_segment(s.end_pos, s.end_dir)
    
    for i in range(ActiveSegments):
        path_gen.increment_segment(ActiveSegments, ExtraSegments)

func get_segment_center_pos(offset) -> PathFollow3D:
    var curves = path_gen.get_active_segments()
    var c = 0

    # Compensate for player progress in current segment
    offset += curves[c].center.curve.get_closest_point(player.global_position).distance_to(curves[c].start_pos)

    var l = curves[c].center.curve.get_baked_length()
    while offset > l:
        offset -= l
        c += 1

        if c >= curves.size(): return null

        l = curves[c].center.curve.get_baked_length()
            
    var pf = curves[c].center.get_node('PathFollow3D')
    pf.progress_ratio = 0
    pf.progress += offset

    return pf


func start_game():
    _next_attack = StartAttackDelay

func _process(delta):
    if player.global_position.distance_to(_curr_segment.end_pos) < path_gen.PathRadius:
        _curr_segment = path_gen.increment_segment()

    _next_attack -= delta
    if _next_attack <= 0:
        var pf = get_segment_center_pos(randf_range(AttackSpawnDistMin, AttackSpawnDistMax))
        if pf != null:
            _next_attack = randf_range(AttackDelayMin, AttackDelayMax)
            var a = attack_spawner.get_attack(_curr_segment, pf, path_gen.PathSegmentLength/2)
            a.start_attack()

    _next_debris -= delta
    if _next_debris <= 0:
        var pf = get_segment_center_pos(DebrisSpawnDist)
        if pf != null:
            _next_debris = randf_range(DebrisDelayMin, DebrisDelayMax)
            var d = debris_spawner.generate_debris_field(randi_range(DebrisWeightMin, DebrisWeightMax), randi_range(DebrisRadiusMin, DebrisRadiusMax))
            pf.get_parent().add_child(d)

            var dir = pf.global_basis.x.rotated(pf.global_basis.z, randf_range(-PI, PI))
            d.global_position = pf.global_position + dir * path_gen.PathRadius * MaxDebrisOffsetPercent * randf()