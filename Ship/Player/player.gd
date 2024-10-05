extends Node3D

@onready var interactionRayCast : RayCast3D = get_node('%InteractionRayCast')

var _last_interaction

func _update_interaction(new_interaction):
    if _last_interaction != null:
        _last_interaction.set_focus(false)
    new_interaction.set_focus(true)
    _last_interaction = new_interaction


func _process(delta):
    if interactionRayCast.is_colliding():
        var target = interactionRayCast.get_collider()
        if target is Interactive and Input.is_action_just_pressed('input_select'):
            _update_interaction(target.InteractionTarget)