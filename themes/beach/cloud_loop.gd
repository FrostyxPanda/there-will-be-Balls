extends Sprite2D

@export var speed_min := 30.0
@export var speed_max := 90.0

var speed := 40.0


func _ready():

	var screen_size = get_viewport().get_visible_rect().size

	# ☁️ random speed
	speed = randf_range(
		speed_min,
		speed_max
	)

	# ☁️ random scale
	scale *= randf_range(0.7, 1.5)

	# ☁️ random transparency
	modulate.a = randf_range(0.2, 0.8)

	# ☁️ random starting position
	position.x = randf_range(
		-300,
		screen_size.x + 300
	)

	position.y = randf_range(
		screen_size.y * 0.1,
		screen_size.y * 0.6
	)



func _process(delta):

	position.x -= speed * delta

	var screen_size = get_viewport().get_visible_rect().size

	# ☁️ loop back to right side
	if position.x < -500:

		position.x = screen_size.x + randf_range(
			100,
			500
		)

		position.y = randf_range(
			screen_size.y * 0.1,
			screen_size.y * 0.6
		)
