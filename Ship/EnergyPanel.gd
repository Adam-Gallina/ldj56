extends Node3D

@export var ButtonActive : StandardMaterial3D
@export var ButtonInactive : StandardMaterial3D

func _on_button_body_3d_on_interact(button:Node3D):
    if button.get_node('Model').material_override == ButtonActive:
        button.get_node('Model').material_override = ButtonInactive
    else:
        button.get_node('Model').material_override = ButtonActive
  