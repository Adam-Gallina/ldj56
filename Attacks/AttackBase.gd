extends Node3D
class_name AttackBase

@export var AttackSegment : PackedScene
var _attack_segments : Array[PathFollow3D] = []
@export var AttackSegmentHeight : float
@export var AttackSegmentSpeed : float
var _attacking = false
@export var AttackDuration : float = 10

@onready var path : Path3D = get_node('Path3D')

var _segment : PathGen.TunnelSegment
func set_attack_segment(segment:PathGen.TunnelSegment):
	_segment = segment

var _start_pos : Vector3
func set_start_pos(pos : Vector3):
	_start_pos = pos


func generate_path():
	pass


func start_attack():
	_attack_segments.append(_spawn_attack_segment())
	_attacking = true


func _spawn_attack_segment() -> PathFollow3D:
	var s : PathFollow3D = AttackSegment.instantiate()
	path.add_child(s)
	s.progress_ratio = 0

	return s


func _process(delta):
	if not _attacking: return

	for i in range(_attack_segments.size()-1, -1, -1):
		_attack_segments[i].progress += AttackSegmentSpeed * delta
		if _attack_segments[i].progress_ratio >= 1:
			_attack_segments.pop_at(i).queue_free()

	if AttackDuration > 0 and _attack_segments[-1].progress >= AttackSegmentHeight:
		_attack_segments.append(_spawn_attack_segment())

	AttackDuration -= delta
	if AttackDuration <= 0 and _attack_segments.size() == 0:
		queue_free()
