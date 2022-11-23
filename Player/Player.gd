extends KinematicBody2D

export var ACCELERATION : int = 10
export var MAX_SPEED : int = 100
export var FRICTION : int = 15
export var ROLL_SPEED : int = 120

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity : Vector2 = Vector2.ZERO
var roll_vector : Vector2 = Vector2.RIGHT

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _process(_delta):
	match state:
		MOVE:
			move_state()
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state():
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	move()
	
	if Input.is_action_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_pressed("roll"):
		state = ROLL

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func move():
	velocity = move_and_slide(velocity)
