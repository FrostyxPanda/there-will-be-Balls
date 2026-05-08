extends Node

@export var cloud_scene: PackedScene

@onready var back_layer = $"../DynamicForeground/CloudsBack"
@onready var mid_layer = $"../DynamicForeground/CloudsMid"
@onready var front_layer = $"../DynamicForeground/CloudsFront"

var timer = 0.0
var arena_left = 108
var arena_right = 974
var arena_top = 260
var arena_bottom = 1000

func _process(delta):

	timer -= delta

	if timer <= 0:

		spawn_cloud()

		timer = randf_range(2.0, 5.0)

func spawn_cloud():

	var cloud = cloud_scene.instantiate()
	
	cloud.arena_left = arena_left - 600
	cloud.arena_right = arena_right + 600
	


	# random layer
	var layers = [back_layer, mid_layer, front_layer]
	var chosen = layers.pick_random()

	chosen.add_child(cloud)

	# spawn position
	var spawn_y = randf_range(arena_top, arena_bottom)

	if cloud.direction == -1:
	# spawn on right
		cloud.position = Vector2(arena_right, spawn_y)
	else:
	# spawn on left
		cloud.position = Vector2(arena_left, spawn_y)
		cloud.direction = [-1, 1].pick_random()
		
	cloud.speed = randf_range(150, 250)

	# layer depth settings
	match chosen.name:

		"CloudsBack":
			cloud.speed = randf_range(10, 60)
			cloud.scale *= 1.4
			cloud.modulate.a = 0.3
			cloud.target_alpha = randf_range(0.15, 0.35)

		"CloudsMid":
			cloud.speed = randf_range(25, 80)
			cloud.scale *= 0.9
			cloud.modulate.a = 0.5
			cloud.target_alpha = randf_range(0.3, 0.5)

		"CloudsFront":
			cloud.speed = randf_range(35, 70)
			cloud.scale *= 0.7
			cloud.modulate.a = 0.8
			cloud.target_alpha = randf_range(0.5, 0.8)
		
