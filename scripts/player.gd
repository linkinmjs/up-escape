extends CharacterBody2D

enum PlayerState {
	IDLE,
	IDLE_GROUND,
	FLYING,
	TAKEOFF,
	HURT,
	DEATH,
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

# Flags del player
var health := 100

func _enter_tree() -> void:
	# En caso de multiplayer, mantenemos autoridad
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): 
		return
	
	handle_input(delta)
	apply_physics(delta)
	handle_state()
	handle_sound()
	#handle_animation() #TODO
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

func handle_state() -> void:
	# Determinar estados
	match state:
		PlayerState.IDLE_GROUND:
			if input_jump:
				state = PlayerState.TAKEOFF
				$AnimatedSprite2D.play("takeoff")
				$TakeOffTimer.start()

		PlayerState.TAKEOFF:
		# tras un pequeño delay o al alcanzar cierta velocidad:
			#if velocity.y < 0:
				#state = PlayerState.IDLE
				#$AnimatedSprite2D.play("idle")
			pass
		PlayerState.IDLE:
			if input_left or input_right or input_jump:
				state = PlayerState.FLYING
			elif is_on_floor():
				state = PlayerState.IDLE_GROUND
				$AnimatedSprite2D.play("idle_ground")
		PlayerState.FLYING:
			if not(input_left or input_right or input_jump):
				state = PlayerState.IDLE
				$AnimatedSprite2D.play("idle")
			elif is_on_floor():
				state = PlayerState.IDLE_GROUND
				$AnimatedSprite2D.play("idle_ground")
		PlayerState.HURT:
			if health <= 0:
				state = PlayerState.DEATH
			pass
		PlayerState.DEATH:
			pass

func apply_physics(delta: float) -> void:
	# Movimiento horizontal:
	if input_left and not is_on_floor():
		velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED_X)
	elif input_right and not is_on_floor():
		velocity.x = min(velocity.x + ACCELERATION * delta,  MAX_SPEED_X)
	else:
		# desaceleración
		if velocity.x > 0:
			velocity.x = max(velocity.x - DECELERATION * delta, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + DECELERATION * delta, 0)
	
	# Movimiento vertical (según estado)
	match state:
		PlayerState.TAKEOFF:
			# durante el “arranque” sólo cae con gravedad
			velocity.y += GRAVITY * delta
		PlayerState.FLYING:
			if input_jump:
				velocity.y -= THRUST_ACCELERATION * delta
			else:
				velocity.y += GRAVITY * delta
		_:
			# IDLE, IDLE_GROUND, HURT, DEATH
			velocity.y += GRAVITY * delta
	
	# Clamp de velocidades
	velocity.x = clamp(velocity.x, -MAX_SPEED_X, MAX_SPEED_X)
	velocity.y = clamp(velocity.y, -MAX_SPEED_Y, MAX_SPEED_Y)

	move_and_slide()

func handle_sound() -> void:
	match state:
		PlayerState.IDLE_GROUND:
			_play_sound(1, 3)
			_stop_sound()
		PlayerState.IDLE:
			_play_sound(0.24, 2)
		PlayerState.FLYING:
			_play_sound(0.25, 2)
		PlayerState.TAKEOFF:
			_play_sound(0.15, 2)
		PlayerState.HURT:
			pass
		PlayerState.DEATH:
			pass


func _apply_damage(damage: int) -> void:
	print("Se recibió daño:" + str(damage))
	$HealthUI.visible = true
	health -= damage
	$HealthUI/TextureProgressBar.value = health

func _on_hurt_timer_timeout() -> void:
	$HealthUI.visible = false
	# tras el timer volvemos a un estado aéreo o suelo según corresponda
	if is_on_floor():
		state = PlayerState.IDLE_GROUND
		$AnimatedSprite2D.play("idle_ground")
	else:
		state = PlayerState.IDLE
		$AnimatedSprite2D.play("idle")

func _on_take_off_timer_timeout() -> void:
	print("timeout timer takeoff")
	state = PlayerState.FLYING
	$AnimatedSprite2D.play("flying")

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area)
	if area.is_in_group("trap") and state != PlayerState.HURT:
		_apply_damage(10)
		state = PlayerState.HURT
		$AnimatedSprite2D.play("hurt")
		$HurtTimer.start()

func _play_sound(pitch: float, type: int):
	#1: TakeOff
	#2: Flying
	#3: TurnOff
	match type:
		1: 
			$Sounds/TakeOff.pitch_scale = pitch
			$Sounds/TakeOff.play()
	match type:
		2: 
			$Sounds/Flying.pitch_scale = pitch
			$Sounds/Flying.play()
	match type:
		3: 
			$Sounds/TurnOff.pitch_scale = pitch
			$Sounds/TurnOff.play()
	
func _stop_sound():
	$Sounds/Flying.stop()

func update_debug_info() -> void:
	if not debug_visible:
		return
	var lines := []
	lines.append("STATE: %s" % PlayerState.keys()[state])
	lines.append("VEL: (%.1f, %.1f)" % [velocity.x, velocity.y])
	lines.append("POS: (%.0f, %.0f)" % [position.x, position.y])
	$DebugLabel.text = "\n".join(lines)
