extends Node3D
class_name PathGen

class TunnelSegment:
    var center : Path3D
    var walls : Array[Path3D] = []
    var start_pos : Vector3
    var start_dir : Vector3
    var end_pos : Vector3
    var end_dir : Vector3

    func queue_free():
        center.queue_free()
        for p in walls:
            p.queue_free()
        

@export var PathObject : PackedScene
@export var PathCount : int = 8
@onready var _dang = 2 * PI / PathCount
@export var PathRadius : float = 5
@export var PathSegmentLengthMin : float = 300
@export var PathSegmentLengthMax : float = 1000
@export var PathSegmentControlPercent : float = .3

var _segments : Array[TunnelSegment] = []
var _past_segments : Array[TunnelSegment] = []

@export var PathSegmentObject : PackedScene
@export var PathSegmentLength : float = 5


func _get_new_path_object() -> Path3D:
    var s = PathObject.instantiate()
    s.curve = Curve3D.new()
    add_child(s)

    return s


func increment_segment(segments_to_keep=2):
    generate_new_segment(_segments[-1].end_pos, _segments[-1].end_dir)
    _past_segments.insert(0, _segments.pop_front())

    while _past_segments.size() > segments_to_keep:
        _past_segments.pop_back().queue_free()

    return _segments[0]

func generate_new_segment(start_pos : Vector3, start_dir : Vector3):
    var s = generate_paths(start_pos, start_dir)
    _segments.append(s)
    generate_walls(s)

    return s


func generate_paths(start_pos : Vector3, start_dir : Vector3) -> TunnelSegment:
    var s : TunnelSegment = TunnelSegment.new()
    s.center = _get_new_path_object()
    for i in range(PathCount):
        s.walls.append(_get_new_path_object())

    var curve_length = randi_range(PathSegmentLengthMin, PathSegmentLengthMax)

    var c = Curve3D.new()
    s.start_pos = start_pos
    s.start_dir = start_dir
    c.add_point(s.start_pos, Vector3.ZERO, s.start_dir)
    s.end_pos = start_pos + start_dir * curve_length
    s.end_dir = start_dir
    c.add_point(s.end_pos, s.end_dir, Vector3.ZERO)
    var points = c.tessellate_even_length()
    
    var _main_follow : PathFollow3D = s.center.get_node('PathFollow3D')

    s.center.curve.clear_points()
    s.center.curve.add_point(points[0])
    s.center.curve.add_point(points[1])
    for i in range(1, points.size()-2):
        s.center.curve.add_point(points[i+1])

        _main_follow.progress += points[i-1].distance_to(points[i])
        var dir = _main_follow.global_basis.z
        var side = _main_follow.global_basis.x

        for p in s.walls:
            p.curve.add_point(points[i] + side * PathRadius)
            side = side.rotated(dir, _dang)

    return s

func generate_walls(segment : TunnelSegment):
    for p in segment.walls:
        var follow : PathFollow3D = p.get_node('PathFollow3D')
        follow.progress_ratio = 0

        while follow.progress_ratio < 1:
            var wall : Node3D = PathSegmentObject.instantiate()
            add_child(wall)
            wall.global_position = follow.global_position
            wall.look_at(segment.center.curve.get_closest_point(wall.global_position), -follow.transform.basis.z)

            follow.progress += PathSegmentLength
