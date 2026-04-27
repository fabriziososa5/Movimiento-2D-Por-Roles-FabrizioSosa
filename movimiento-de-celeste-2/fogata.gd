extends Node2D

func _ready():
	var anim = find_child("AnimatedSprite2D", true, false)

	print(anim)

	if anim:
		anim.play("fire")
	else:
		print("NO ENCONTRO EL AnimatedSprite2D")
