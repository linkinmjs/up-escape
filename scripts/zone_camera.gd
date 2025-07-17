# Archivo: zone_camera.gd
extends Area2D

@export var zone_camera: Camera2D
@export var default_camera: Camera2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if default_camera:
			default_camera.current = false
		if zone_camera:
			zone_camera.make_current()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		if zone_camera:
			zone_camera.current = false
		if default_camera:
			default_camera.make_current()
