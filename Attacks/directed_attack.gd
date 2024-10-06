extends AttackBase

@export var MaxBeamAngle : float = 30
@export var BeamControlMin : float = .3
@export var BeamControlMax : float = .6

@export var BeamTargetingOffsetMin = 20
@export var BeamTargetingOffsetMax = 40

func generate_path():
    path.curve = Curve3D.new()

    var center_pos = _segment.center.curve.get_closest_point(_start_pos)
    var center_dir = (center_pos - _start_pos).normalized()

    var end_path = _segment.walls.pick_random()
    #if end_path == _start or abs(_segment.walls.find(_segment) - _segment.walls.find(end_path)) == 1:
    #    end_path = _segment.walls[(_segment.walls.find(_segment) + int(_segment.walls.size()/2.)) % _segment.walls.size()] 

    var start_dir = MyMath.rand_rotate_vector3(center_dir, 0, deg_to_rad(MaxBeamAngle))
    path.curve.add_point(_start_pos, Vector3.ZERO, start_dir * _start_pos.distance_to(center_pos) * randf_range(BeamControlMin, BeamControlMin))

    


    var end_pos = get_tree().root.get_node('Node3D/PlayerShip').global_position + center_dir * randf_range(BeamTargetingOffsetMin, BeamTargetingOffsetMax)
    var end_dir = MyMath.rand_rotate_vector3((center_pos - end_pos).normalized(), 0, deg_to_rad(MaxBeamAngle))
    end_pos -= end_dir * 10
    path.curve.add_point(end_pos, end_dir * end_pos.distance_to(center_pos) * randf_range(BeamControlMin, BeamControlMin), Vector3.ZERO)
