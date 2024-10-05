extends AttackBase

@export var MaxBeamAngle : float = 30
@export var BeamControlMin : float = .3
@export var BeamControlMax : float = .6

func generate_path():
    path.curve = Curve3D.new()

    var center_pos = _segment.center.curve.get_closest_point(_start_pos)
    var center_dir = (center_pos - _start_pos).normalized()

    var end_path = _segment.walls.pick_random()
    if end_path == _segment:
        end_path = _segment.walls[(_segment.walls.find(_segment) + int(_segment.walls.size()/2.)) % _segment.walls.size()] 

    var start_dir = MyMath.rand_rotate_vector3(center_dir, 0, deg_to_rad(MaxBeamAngle))
    path.curve.add_point(_start_pos, Vector3.ZERO, start_dir * _start_pos.distance_to(center_pos) * randf_range(BeamControlMin, BeamControlMin))

    var end_pos = end_path.curve.get_closest_point(center_pos)
    var end_dir = MyMath.rand_rotate_vector3((center_pos - end_pos).normalized(), 0, deg_to_rad(MaxBeamAngle))
    end_pos -= end_dir * 10
    path.curve.add_point(end_pos, end_dir * end_pos.distance_to(center_pos) * randf_range(BeamControlMin, BeamControlMin), Vector3.ZERO)



func tesselate_path():
    var points = path.curve.tessellate_even_length()
    path.curve.clear_points()
    for p in points:
        path.curve.add_point(p)