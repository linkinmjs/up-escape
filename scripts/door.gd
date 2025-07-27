extends Node2D

@export var door_number: int
var status = "closed"

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if GameManager.keys_obtained.has(door_number) and status == "closed":
			print("open da door")
			open_door()

func open_door():
	status = "open"
	$AnimatedSprite2D.play("open")
	$StaticBody2D/CollisionShape2D.queue_free()
