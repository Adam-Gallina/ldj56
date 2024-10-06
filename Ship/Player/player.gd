extends Node3D

@onready var interactionRayCast : RayCast3D = get_node('%InteractionRayCast')


func _process(_delta):
    if interactionRayCast.is_colliding():
        var target = interactionRayCast.get_collider()
        if target is Interactive and Input.is_action_just_pressed('input_select'):
            target.interact()