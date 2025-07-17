extends CharacterBody2D

enum PlayerState {
	IDLE,
	CHARGING,
	JUMPING,
	FALLING,
	SPLAT
}

var state : PlayerState = PlayerState.IDLE
var debug_visible := true

# Movimiento
const GRAVITY := 800.0
const MAX_FALL_SPEED := 600.0
const MOVE_SPEED := 100.0

# Salto cargado
var jump_power := 0.0
const JUMP_POWER_STEP := 3.0
const MAX_JUMP_POWER := 2.0
const MIN_JUMP_POWER := 0.3
const MAX_JUMP_HEIGHT := 250.0

# Dirección
var direction := 0  # -1 (izq), 0 (neutral), 1 (der)

# Estados
var is_grounded := false

# Inputs
var left := false
var right := false
var jump := false

func _physics_process(delta: float) -> void:
	print("vel:", velocity, " grounded:", is_on_floor())
	handle_input(delta)
	handle_state(delta)
	apply_gravity(delta)
	move_character()

func handle_input(delta: float) -> void:
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")
	jump = Input.is_action_pressed("ui_jump")

	if left:
		direction = -1
	elif right:
		direction = 1
	else:
		direction = 0

	if state == PlayerState.IDLE and jump and is_grounded:
		state = PlayerState.CHARGING
	
	if is_grounded and state == PlayerState.IDLE:
		velocity.x = direction * MOVE_SPEED
	elif is_grounded and direction == 0:
		velocity.x = 0

	if state == PlayerState.CHARGING:
		velocity.x = 0
		if jump:
			jump_power += JUMP_POWER_STEP * delta
			if jump_power >= MAX_JUMP_POWER:
				start_jump()
		else:
			start_jump()
			
	if Input.is_action_just_pressed("ui_toggle_debug"):
		debug_visible = !debug_visible
		$DebugLabel.visible = debug_visible

func start_jump():
	var power = clamp(jump_power, MIN_JUMP_POWER, MAX_JUMP_POWER)
	jump_power = 0.0
	state = PlayerState.JUMPING
	velocity.y = -MAX_JUMP_HEIGHT * power
	velocity.x = direction * 80.0

func apply_gravity(delta: float) -> void:
	if state in [PlayerState.FALLING, PlayerState.JUMPING, PlayerState.IDLE]:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED

func move_character() -> void:
	print("Move Character")
	move_and_slide()
	is_grounded = is_on_floor()

func handle_state(delta: float) -> void:
	if state == PlayerState.JUMPING and velocity.y > 0:
		state = PlayerState.FALLING

	if state == PlayerState.FALLING and is_grounded:
		if abs(velocity.y) > 550:
			state = PlayerState.SPLAT
			$AnimationPlayer.play("splat")
			$splat_timer.start()
		else:
			state = PlayerState.IDLE

	if state == PlayerState.SPLAT and $splat_timer.is_stopped():
		state = PlayerState.IDLE

func _on_splat_timer_timeout() -> void:
	state = PlayerState.IDLE

# WIP
func update_debug_info() -> void:
	var lines := []
	lines.append("STATE: %s" % PlayerState.keys()[state])
	lines.append("VEL: (%.1f, %.1f)" % [velocity.x, velocity.y])
	lines.append("POS: (%.0f, %.0f)" % [position.x, position.y])
	lines.append("GROUND: %s" % is_grounded)
	lines.append("DIR: %d" % direction)
	lines.append("JUMP_PWR: %.2f" % jump_power)

	$DebugLabel.text = "\n".join(lines)
