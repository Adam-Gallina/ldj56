extends Node

func rand_rotate_vector3(v:Vector3, min_rad:float, max_rad:float) -> Vector3:
    var right = v.rotated(Vector3.UP, PI/2)
    var ret = v.rotated(right, randf_range(min_rad, max_rad))
    ret = ret.rotated(v, randf_range(-PI, PI))

    return ret