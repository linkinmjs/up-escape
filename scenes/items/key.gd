extends Node2D

@export var key_number : int

func _process(delta: float) -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	GameManager.keys_obtained.append(key_number)
	if body.is_in_group("players"):
		queue_free()
