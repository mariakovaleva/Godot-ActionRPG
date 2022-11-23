extends Node2D

func create_grass_effect():
	# Loading GrassEffect scene
	var GrassEffect = load("res://Effects/GrassEffect.tscn")
	# Instancing the GrassEffect scene
	var grassEffect = GrassEffect.instance()
	var world = get_tree().current_scene
	world.add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
