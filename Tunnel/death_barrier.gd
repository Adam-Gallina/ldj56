extends Area3D

func _on_area_entered(area:Area3D):
	area.get_parent()._death()
