extends Node3D
class_name AttackSpawner

@export var Attacks : Array[PackedScene]
## Chance to use attack compared to other attacks
@export var AttackChance : Array[int]

func _get_rand_attack() -> AttackBase:
	var a = Attacks[0].instantiate()
	add_child(a)
	return a

func get_attack(segment:PathGen.TunnelSegment, pf:PathFollow3D, max_attack_offset:float):
	var start_wall = segment.walls.pick_random()
	var spf : PathFollow3D = start_wall.get_node('PathFollow3D')
	spf.progress_ratio = pf.progress_ratio

	var center_dir = (pf.global_position - spf.global_position).normalized()
	var forward_dir = spf.global_basis.z

	var start_pos = spf.global_position 
	start_pos += center_dir.cross(forward_dir) * randf_range(-max_attack_offset, max_attack_offset)
	start_pos -= forward_dir * 10

	var a : AttackBase = _get_rand_attack()
	a.set_attack_segment(segment)
	a.set_start_pos(start_pos)

	a.generate_path()

	return a
