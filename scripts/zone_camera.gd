# Archivo: zone_camera.gd
extends Area2D

@export var zone_camera: Camera2D
@export var default_camera: Camera2D

func _ready() -> void:
	if not zone_camera or not default_camera:
		push_warning("ZoneCamera: asigná Zone Camera y Default Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		zone_camera.enabled = true
		zone_camera.make_current()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		zone_camera.enabled = false  # opcional
