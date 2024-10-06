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


@export var WinDist = 1000
@onready var _remaining_dist = WinDist
@export var MaxDifficultyScale : float = .5
@export var DifficultyScaleStart = 1000
@export var DifficultyScaleEnd = 1000

func _ready():
    generate_initial_paths()

func generate_initial_paths():
    _curr_segment = path_gen.generate_new_segment(Vector3.ZERO, Vector3.MODEL_FRONT)
    var s = _curr_segment
    _remaining_dist -= s.path_length
    for i in range(ExtraSegments-1):
        s = path_gen.generate_new_segment(s.end_pos, s.end_dir)
        _remaining_dist -= s.path_length
    
    for i in range(ActiveSegments):
        path_gen.increment_segment(true, ActiveSegments, ExtraSegments)

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

var _playing = false
func start_game():
    $StartMenu.hide()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    $Door.open(2)

    player.MinSpeed = 25
    await get_tree().create_timer(1).timeout

    player.MinSpeed = 100
    _next_attack = StartAttackDelay
    _playing = true

func restart_game():
    get_tree().reload_current_scene()
    print('??')

func lose_game():
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    $DeathMenu.show()

func win_game():
    await get_tree().create_timer(1).timeout
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    $WinMenu.show()


var _moved_door = false
func _process(delta):
    if not _playing: return

    if player.global_position.distance_to(_curr_segment.end_pos) < path_gen.PathRadius:
        if _remaining_dist <= 0 and _moved_door:
            win_game()

        _curr_segment = path_gen.increment_segment(_remaining_dist > 0, ActiveSegments, ExtraSegments)
        
        if _remaining_dist <= 0 and not _moved_door:
            $Door.global_position = _curr_segment.end_pos
            $Door.look_at(_curr_segment.end_pos - _curr_segment.end_dir)
            _moved_door = true

        _remaining_dist -= _curr_segment.path_length
    

    var difficulty_scale
    if WinDist - _remaining_dist < DifficultyScaleStart:
        difficulty_scale = 1
    elif _remaining_dist < DifficultyScaleEnd:
        difficulty_scale = 1
    else:
        difficulty_scale = (1 - MaxDifficultyScale) * (_remaining_dist + DifficultyScaleStart) / (WinDist)
    print(difficulty_scale)

    _next_attack -= delta
    if _next_attack <= 0:
        var pf = get_segment_center_pos(randf_range(AttackSpawnDistMin, AttackSpawnDistMax))
        if pf != null:
            _next_attack = randf_range(AttackDelayMin, AttackDelayMax) * difficulty_scale
            var a = attack_spawner.get_attack(_curr_segment, pf, path_gen.PathSegmentLength/2)
            a.start_attack()

    _next_debris -= delta
    if _next_debris <= 0:
        var pf = get_segment_center_pos(DebrisSpawnDist)
        if pf != null:
            _next_debris = randf_range(DebrisDelayMin, DebrisDelayMax) * difficulty_scale
            var d = debris_spawner.generate_debris_field(randi_range(DebrisWeightMin, DebrisWeightMax), randi_range(DebrisRadiusMin, DebrisRadiusMax))
            pf.get_parent().add_child(d)

            var dir = pf.global_basis.x.rotated(pf.global_basis.z, randf_range(-PI, PI))
            d.global_position = pf.global_position + dir * path_gen.PathRadius * MaxDebrisOffsetPercent * randf()