extends Node3D

@onready var path_gen : PathGen = get_node('%Pathing')
@onready var player : RigidBody3D = get_node('%PlayerShip')

@export var ExtraSegments = 3
var _curr_segment : PathGen.TunnelSegment


func _ready():
    _curr_segment = path_gen.generate_new_segment(Vector3.ZERO, Vector3.MODEL_FRONT)
    var s = _curr_segment
    for i in range(ExtraSegments-1):
        s = path_gen.generate_new_segment(s.end_pos, s.end_dir)

func _process(_delta):
    if player.global_position.distance_to(_curr_segment.end_pos) < path_gen.PathRadius:
        _curr_segment = path_gen.increment_segment()
        print('new')