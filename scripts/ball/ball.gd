extends RigidBody2D

@onready var sprite = $Visuals/Sprite2D
@onready var tag_sfx = $TagSFX
@onready var pop_sfx = $PopSFX

var is_pulsing = false
var unlocked = GameData.get_unlocked_balls()

# =========================
# ATLAS SETTINGS
# =========================
var atlas_cols = 10
var atlas_rows = 8
var cell_size = 32

# =========================
# MOVEMENT SETTINGS
# =========================
var speed = 500
var direction = Vector2.ZERO
var rotation_speed = 0.05

var tagged = false

func _ready():
	add_to_group("ball")

	if sprite == null:
		print("ERROR: Sprite2D not found")
		return

	setup_visual()
	setup_movement()

# =========================
# VISUAL SELECTION
# =========================
func setup_visual():

	randomize()

	var chosen_id

	if GameData.selected_ball == -1:
		var unlocked = GameData.get_unlocked_balls()

		if unlocked.size() == 0:
			unlocked = [0]

		chosen_id = unlocked[randi() % unlocked.size()]
	else:
		chosen_id = GameData.selected_ball

	var col = chosen_id % atlas_cols
	var row = chosen_id / atlas_cols

	sprite.set_region_enabled(true)
	sprite.region_rect = Rect2(
		col * cell_size,
		row * cell_size,
		cell_size,
		cell_size
	)

	var base_scale = 3.0
	var variation = randf_range(0.95, 1.05)

	sprite.scale = Vector2(base_scale * variation, base_scale * variation)

	angular_velocity = randf_range(-5, 5)

# =========================
# MOVEMENT (FIXED ANGLES)
# =========================
func setup_movement():

	# Choose left or right
	var horizontal_dir = 1 if randf() < 0.5 else -1

	# Controlled angle range (tighter = more consistent feel)
	var angle_deg = randf_range(30, 50)

	# Apply direction using rotation (cleaner + more reliable)
	var direction = Vector2.RIGHT.rotated(deg_to_rad(angle_deg))

	# Flip horizontally if needed
	direction.x *= horizontal_dir

	# Force downward movement
	direction.y = abs(direction.y)

	linear_velocity = direction * speed

	# Disable gravity
	gravity_scale = 0
	

func _physics_process(delta):

	# Keep constant speed
	if linear_velocity.length() != speed:
		linear_velocity = linear_velocity.normalized() * speed

	# Rotate based on movement direction
	rotation += rotation_speed * sign(linear_velocity.x) * (linear_velocity.length() / speed)

# =========================
# TAG SYSTEM
# =========================
func try_tag(player):

	if tagged:
		return

	var vertical_buffer = 50

	if player.global_position.y > global_position.y - vertical_buffer:
		return

	var horizontal_diff = abs(player.global_position.x - global_position.x)

	if horizontal_diff < 50:
		tag()

@onready var glow = $Visuals/Glow

func tag():
	tagged = true
	add_to_group("tagged")
	
	tag_sfx.pitch_scale = randf_range(0.9, 1.2)
	tag_sfx.play()

	start_pulse()

	get_tree().call_group("player", "on_ball_tagged")

func start_pulse():

	if is_pulsing:
		return

	is_pulsing = true

	while tagged:

		# Bright phase
		sprite.modulate = Color(1.6, 1.4, 0.4)
		glow.modulate = Color(2.0, 1.8, 0.5)
		await get_tree().create_timer(0.1).timeout

		# Dim phase
		sprite.modulate = Color(1.2, 1.0, 0.2)
		glow.modulate = Color(2.0, 1.8, 0.5)
		await get_tree().create_timer(0.1).timeout

func pop():
	if tagged:

		var sfx = pop_sfx.duplicate()
		get_parent().add_child(sfx)

		sfx.global_position = global_position
		sfx.pitch_scale = randf_range(0.8, 1.2)
		sfx.play()

		# 🔥 free the ball immediately
		queue_free()

		# 🔥 clean up sound AFTER it finishes (without blocking)
		sfx.finished.connect(func(): sfx.queue_free())
