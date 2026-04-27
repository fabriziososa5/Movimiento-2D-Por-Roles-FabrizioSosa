extends Node2D

func _ready():
	var anim = find_child("Foxy1", true, false)

	print(anim)

	if anim:
		anim.play("descansar")
	else:
		print("NO ENCONTRO EL Foxy1")
