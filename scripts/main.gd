extends Node

@onready var hud: CenterContainer = $CenterContainer

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _on_host_pressed() -> void:
	peer.create_server(3500, 4)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	_on_peer_connected()
	hud.hide()

func _on_join_pressed() -> void:
	peer.create_client("localhost", 3500) # Acá debemos ingresar los IPS
	multiplayer.multiplayer_peer = peer
	hud.hide()

func _on_peer_connected(id: int = 1):
	var player_scene = load("res://scenes/player/player.tscn")
	var player_instance = player_scene.instantiate()
	player_instance.name = str(id)
	find_child("PlayerSpawn").add_child(player_instance, true)
