extends Node

@export var cloud_scene: PackedScene

@onready var back_layer = $"../DynamicForeground/CloudsBack"
@onready var mid_layer = $"../DynamicForeground/CloudsMid"
@onready var front_layer = $"../DynamicForeground/CloudsFront"

var timer = 0.0

var arena_left = 108
var arena_right = 974

# ☁️ visible cloud band
var arena_top = 250
var arena_bottom = 650


func _process(delta):

	timer -= delta

	if timer <= 0:

		spawn_cloud()

		timer = randf_range(2.0, 5.0)


func spawn_cloud():

	print("Cloud spawned")

	var cloud = cloud_scene.instantiate()

	# 🌎 arena bounds
	cloud.arena_left = arena_left - 600
	cloud.arena_right = arena_right + 600

	# ☁️ random layer
	var layers = [
		back_layer,
		mid_layer,
		front_layer
	]

	var chosen = layers.pick_random()

	chosen.add_child(cloud)

	# ☁️ spawn height
	var spawn_y = randf_range(
		arena_top,
		arena_bottom
	)

	# 🌬️ all clouds move right → left
	cloud.direction = -1

	# ☁️ spawn offscreen right
	cloud.position = Vector2(
		arena_right + 200,
		spawn_y
	)

	# ☁️ default speed
	cloud.speed = randf_range(250, 500)

	# ☁️ layer depth settings
	match chosen.name:

		"CloudsBack":

			cloud.speed = randf_range(10, 30)

			cloud.scale *= 1.4

			cloud.modulate.a = 0.35

			cloud.target_alpha = randf_range(0.2, 0.35)


		"CloudsMid":

			cloud.speed = randf_range(25, 50)

			cloud.scale *= 1.0

			cloud.modulate.a = 0.5

			cloud.target_alpha = randf_range(0.35, 0.5)


		"CloudsFront":

			cloud.speed = randf_range(40, 70)

			cloud.scale *= 0.8

			cloud.modulate.a = 0.75

			cloud.target_alpha = randf_range(0.5, 0.8)
