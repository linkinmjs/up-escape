extends CharacterBody2D

@export var gravity: float = 800.0
@export var jump_force: float = -400.0
@export var max_jump_hold_time: float = 0.25 # para salto cargado

@export var walk_speed: float = 0.0 # JumpKing no tiene control horizontal

var jump_timer := 0.0
var is_charging_jump := false

func _ready() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Carga de salto
		if Input.is_action_pressed("ui_jump"):
			is_charging_jump = true
			jump_timer += delta
			jump_timer = min(jump_timer, max_jump_hold_time)
		elif is_charging_jump and Input.is_action_just_released("ui_jump"):
			# Ejecutar el salto cargado
			var power = jump_force * (jump_timer / max_jump_hold_time)
			velocity.y = power
			is_charging_jump = false
			jump_timer = 0.0
		else:
			# En suelo y sin saltar
			velocity.y = 0.0
			is_charging_jump = false
			jump_timer = 0.0

	# Mover personaje
	move_and_slide()
