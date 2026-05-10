extends Node2D

@export var speed = 40.0

@onready var sprite = $Sprite2D

# ☁️ Cloud texture pool
var cloud_textures = [
	preload("res://assets/themes/beach/clouds/cloud-2.png"),
	preload("res://assets/themes/beach/clouds/cloud-5.png"),
	preload("res://assets/themes/beach/clouds/cloud-7.png"),
	preload("res://assets/themes/beach/clouds/cloud-10.png"),
	preload("res://assets/themes/beach/clouds/cloud-21.png"),
	preload("res://assets/themes/beach/clouds/cloud-23.png"),
	preload("res://assets/themes/beach/clouds/cloud-25.png"),
	preload("res://assets/themes/beach/clouds/cloud-27.png"),
	preload("res://assets/themes/beach/clouds/cloud-31.png"),
	preload("res://assets/themes/beach/clouds/cloud-43.png"),
]
var direction = -1
var arena_left = 0
var arena_right = 1080
var target_alpha = 0.6

func _ready():

	# 🎨 Random cloud image
	sprite.texture = cloud_textures.pick_random()

	# 🌫️ Slight variation
	scale *= randf_range(0.8, 1.4)

	modulate.a = 0.0

	target_alpha = randf_range(0.3, 0.8)

func _process(delta):

	# ☁️ movement
	position.x += speed * direction * delta

	modulate.a = 1.0

	# 🗑️ cleanup
	if global_position.x < arena_left - 400:
		queue_free()

	if global_position.x > arena_right + 400:
		queue_free()
