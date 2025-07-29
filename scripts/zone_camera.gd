extends Area2D

@export var zone_camera: Camera2D
@export var default_camera: Camera2D

func _ready() -> void:
	if not zone_camera or not default_camera:
		push_warning("ZoneCamera: asigná Zone Camera y Default Camera")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_multiplayer_authority(): return
	if not body.is_in_group("players"):     return

	zone_camera.enabled = true
	zone_camera.make_current()
	GameManager.current_cameras.append(zone_camera)
	print("Cámaras activas:", GameManager.current_cameras)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_multiplayer_authority(): return
	if not body.is_in_group("players"):     return

	zone_camera.enabled = false
	GameManager.current_cameras.erase(zone_camera)
	print("Cámaras tras salir:", GameManager.current_cameras)

	if GameManager.current_cameras.size() > 0:
		var cam = GameManager.current_cameras.back()
		cam.make_current()
	else:
		default_camera.make_current()
