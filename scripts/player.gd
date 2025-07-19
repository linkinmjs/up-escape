extends CharacterBody2D

enum PlayerState {
	IDLE,
	FLYING
}

# Estado actual
var state: PlayerState = PlayerState.IDLE
var debug_visible := true

# Parámetros de movimiento
const ACCELERATION := 400.0           # aceleración horizontal
const DECELERATION := 300.0           # desaceleración horizontal
const MAX_SPEED_X := 200.0            # velocidad máxima horizontal
const MAX_SPEED_Y := 200.0            # velocidad máxima vertical
const GRAVITY := 500.0                # gravedad cuando no sube
const THRUST_ACCELERATION := 600.0    # aceleración al subir (ui_jump)

# Flags de input
var input_left := false
var input_right := false
var input_jump := false

func _enter_tree() -> void:
	# En caso de multiplayer, mantenemos autoridad
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): 
		return
	
	handle_input(delta)
	handle_state(delta)
	move_and_slide()
	update_debug_info()
	
func handle_input(delta: float) -> void:
	# Leer inputs
	input_left  = Input.is_action_pressed("ui_left")
	input_right = Input.is_action_pressed("ui_right")
	input_jump  = Input.is_action_pressed("ui_jump")
	
	# Toggle de debug
	if Input.is_action_just_pressed("ui_toggle_debug"):
		debug_visible = not debug_visible
		$DebugLabel.visible = debug_visible
	
	# Movimiento horizontal
	if input_left:
		velocity.x -= ACCELERATION * delta
	elif input_right:
		velocity.x += ACCELERATION * delta
	else:
		# desacelerar suavemente hacia 0
		if velocity.x > 0:
			velocity.x = max(velocity.x - DECELERATION * delta, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + DECELERATION * delta, 0)
	# Movimiento vertical
	if input_jump:
		velocity.y -= THRUST_ACCELERATION * delta
	else:
		velocity.y += THRUST_ACCELERATION * delta
	
	# Clamp de velocidades
	velocity.x = clamp(velocity.x, -MAX_SPEED_X, MAX_SPEED_X)
	velocity.y = clamp(velocity.y, -MAX_SPEED_Y, MAX_SPEED_Y)
	
	
func handle_state(delta: float) -> void:
	# Determinar estado según si nos movemos lo suficiente
	if velocity.length() > 10.0:
		if state != PlayerState.FLYING:
			state = PlayerState.FLYING
			# TODO: acá reproducir animación o sonido de vuelo
			if has_node("AnimatedSprite2D"):
				$AnimatedSprite2D.play("flying")
	else:
		if state != PlayerState.IDLE:
			state = PlayerState.IDLE
			# aquí animación o sonido de reposo
			if has_node("AnimatedSprite2D"):
				$AnimatedSprite2D.play("idle")

func update_debug_info() -> void:
	if not debug_visible:
		return
	var lines := []
	lines.append("STATE: %s" % PlayerState.keys()[state])
	lines.append("VEL: (%.1f, %.1f)" % [velocity.x, velocity.y])
	lines.append("POS: (%.0f, %.0f)" % [position.x, position.y])
	$DebugLabel.text = "\n".join(lines)
