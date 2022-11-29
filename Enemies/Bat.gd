extends KinematicBody2D

const EnemyHurtSound = preload("res://Enemies/EnemyHurtSound.tscn")

export var FRICTION: int = 4
export var KNOCKBACK_SPEED: int = 150
export var MAX_SPEED: int = 75
export var ACCELERATION: int = 15
export var WANDER_RANGE: int = 3
const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn") 

enum {
	IDLE,
	WANDER,
	CHASE
}

const RANDOM_STATES = [IDLE, WANDER]

var velocity: Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO
var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController

func _ready():
	state = pick_random_state()

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			seek_player()
			try_wander()			
		WANDER:
			seek_player() 
			var target = wander_controller.target_position
			var distance = global_position.distance_to(target)
			if distance > 1:
				accelerate_to(target)
			else:
				state = IDLE
			try_wander()			
		CHASE:
			var player = player_detection_zone.player
			if player:
				accelerate_to(player.global_position)
			else:
				state = IDLE
	sprite.flip_h = velocity.x < 0
	
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * KNOCKBACK_SPEED
	
	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_SPEED
	hurtbox.create_hit_effect()
	var enemy_hurt_sound = EnemyHurtSound.instance()
	get_tree().current_scene.add_child(enemy_hurt_sound)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func pick_random_state():
	var n: int = len(RANDOM_STATES)
	var r: int = int(rand_range(0, n))
	return RANDOM_STATES[r]

func try_wander():
	if wander_controller.get_time_left() == 0 and state != CHASE:
		state = pick_random_state()
		wander_controller.start_wander_timer(rand_range(2,4))

func accelerate_to(point):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
