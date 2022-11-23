extends KinematicBody2D

const FRICTION : int = 15
const KNOCKBACK_SPEED = 200

var knockback : Vector2 = Vector2.ZERO

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * KNOCKBACK_SPEED
