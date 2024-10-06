extends Node3D
class_name PathGen

class TunnelSegment:
    var center : Path3D
    var walls : Array[Path3D] = []
    var effects : Array[CPUParticles3D]
    var start_pos : Vector3
    var start_dir : Vector3
    var end_pos : Vector3
    var end_dir : Vector3
    var path_length : float

    func activate_particles():
        for i in effects:
            i.emitting = true
            i.get_node('Background').emitting = true
    
    func deactivate_particles():
        for i in effects:
            i.emitting = false
            i.get_node('Background').emitting = false

    func queue_free():
        center.queue_free()
        for p in walls:
            p.queue_free()
        for e in effects:
            e.queue_free()
        

@export var PathObject : PackedScene
@export var PathCount : int = 8
@onready var _dang = 2 * PI / PathCount
@export var PathRadius : float = 40
@export var PathSegmentLengthMin : float = 400
@export var PathSegmentLengthMax : float = 700
@export var PathSegmentControlPercentMin : float = .5
@export var PathSegmentControlPercentMax : float = .7
@export var MaxPathSegmentAngle : float = 60
@export var MaxPathSegmentControlAngle : float = 45

var _future_segments : Array[TunnelSegment] = []
var _active_segments : Array[TunnelSegment] = []
var _past_segments : Array[TunnelSegment] = []

func get_active_segments() -> Array[TunnelSegment]: return _active_segments

@export var PathSegmentObject : PackedScene
@export var PathSegmentLength : float = 5


func _get_new_path_object() -> Path3D:
    var s = PathObject.instantiate()
    s.curve = Curve3D.new()
    add_child(s)

    return s


func increment_segment(create_new=true,active_segments=3, segments_to_keep=2):
    if create_new:
        generate_new_segment(_future_segments[-1].end_pos, _future_segments[-1].end_dir)
    if _future_segments.size() > 0:
        var new_segment = _future_segments.pop_front()
        new_segment.activate_particles()
        _active_segments.append(new_segment)

    if _active_segments.size() > active_segments:
        var old_segment = _active_segments.pop_front()
        old_segment.deactivate_particles()
        _past_segments.insert(0, old_segment)

        while _past_segments.size() > segments_to_keep:
            _past_segments.pop_back().queue_free()

    print(_future_segments.size(), ' ', _active_segments.size(), ' ', _past_segments.size())

    return _active_segments[0]

func generate_new_segment(start_pos : Vector3, start_dir : Vector3, end_pos : Vector3 = Vector3.ZERO, end_dir : Vector3 = Vector3.ZERO):
    var s = generate_paths(start_pos, start_dir, end_pos, end_dir)
    _future_segments.append(s)
    generate_walls(s)

    return s


func generate_paths(start_pos : Vector3, start_dir : Vector3, end_pos : Vector3 = Vector3.ZERO, end_dir : Vector3 = Vector3.ZERO) -> TunnelSegment:
    var s : TunnelSegment = TunnelSegment.new()
    s.center = _get_new_path_object()
    for i in range(PathCount):
        s.walls.append(_get_new_path_object())

    if end_pos == Vector3.ZERO:
        # Move in roughly same direction, but bias towards forwards
        var dir = (start_dir * 5 + Vector3.MODEL_FRONT).normalized()
        var target_dir = MyMath.rand_rotate_vector3(dir, 0, deg_to_rad(MaxPathSegmentAngle))

        s.path_length = randf_range(PathSegmentLengthMin, PathSegmentLengthMax)
        end_pos = start_pos + target_dir * s.path_length
    else:
        s.path_length = start_pos.distance_to(end_pos)

    if end_dir == Vector3.ZERO:
        var dir = -end_pos.direction_to(start_pos)
        end_dir = MyMath.rand_rotate_vector3(dir, 0, deg_to_rad(MaxPathSegmentControlAngle))        

    var c = Curve3D.new()
    s.start_pos = start_pos
    s.start_dir = start_dir
    c.add_point(s.start_pos, Vector3.ZERO, s.start_dir * s.path_length * randf_range(PathSegmentControlPercentMin, PathSegmentControlPercentMax))
    s.end_pos = end_pos
    s.end_dir = end_dir
    c.add_point(s.end_pos, -s.end_dir * s.path_length * randf_range(PathSegmentControlPercentMin, PathSegmentControlPercentMax), Vector3.ZERO)
    var points = c.tessellate_even_length()
    
    var _main_follow : PathFollow3D = s.center.get_node('PathFollow3D')

    s.center.curve.clear_points()
    for i in points:
        s.center.curve.add_point(i)

    for i in range(1, points.size()):
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
            segment.effects.append(wall)

            follow.progress += PathSegmentLength
