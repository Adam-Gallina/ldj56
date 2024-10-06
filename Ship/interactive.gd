extends StaticBody3D
class_name Interactive

signal on_interact(button:Node3D)

func interact():
    on_interact.emit(self)