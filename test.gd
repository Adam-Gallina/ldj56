extends Node3D

@onready var path_gen = get_node('Pathing')

func _ready():
    var s = path_gen.generate_new_segment(Vector3.ZERO, Vector3.MODEL_FRONT)
    for i in range(20):
        s = path_gen.generate_new_segment(s.end_pos, s.end_dir)