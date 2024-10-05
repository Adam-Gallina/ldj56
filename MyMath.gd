extends Node

func rand_rotate_vector3(v:Vector3=Vector3.FORWARD, min_rad:float=-PI, max_rad:float=PI) -> Vector3:
    var right = v.rotated(Vector3.UP, PI/2)
    var ret = v.rotated(right, randf_range(min_rad, max_rad))
    ret = ret.rotated(v, randf_range(-PI, PI))

    return ret

func sum(arr:Array):
    var total = 0
    for i in arr: total += i
    return total