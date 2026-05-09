extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D
@onready var jump_dust = $JumpDust
@onready var run_dust = $RunDust
@onready var landing_dust = $LandingDust
@onready var dash_dust = $DashDust
@onready var score_label = get_tree().get_first_node_in_group("score_label")
@onready var combo_label = get_tree().get_first_node_in_group("combo_label")
@onready var jump_sfx = $JumpSFX
@onready var jump_sfx2 = $JumpSFX2
@onready var dash_sfx = $DashSFX
@onready var land_sfx = $LandSFX
@onready var death_sfx = $DeathSFX
@onready var death_sfx2 = $DeathSFX2

# =========================
# SCORE / COMBO
# =========================
var combo = 0
var score = 0
var was_on_floor = false
var previous_y = 0.0
var combo_cleared = false

# =========================
# DASH
# =========================
var dash_speed = 900
var dash_time = 0.12
var dash_cooldown = 0.4

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dash_recovering = false

# =========================
# MOVEMENT
# =========================
const SPEED = 700
const ACCEL = 6000
const FRICTION = 6000

const JUMP_FORCE = -900
const GRAVITY = 1800
const FALL_MULTIPLIER = 1.3
const JUMP_CUT_MULTIPLIER = 0.25

const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS

var has_landed = false
var is_dead = false

# =========================
# READY
# =========================
func _ready():
	add_to_group("player")
	was_on_floor = true

# =========================
# COMBO / SCORE
# =========================
func on_combo_cleared(amount):

	var combo_score = 0
	for i in range(1, amount + 1):
		combo_score += i

	score += combo_score
	score_label.text = "Score: " + str(score)
	
	GameData.add_coins(amount)
	
	if amount <= 0:
		return

	show_combo_text(amount)

func show_combo_text(amount):

	if amount < 2:
		return

	var texts = ["Nice","Awesome","Excellent","Extreme","Absurd","Outlandish","Unstoppable","GODLIKE"]
	var colors = [
		Color.WHITE,
		Color.YELLOW,
		Color.ORANGE,
		Color(1,0.5,0),
		Color.RED,
		Color(1,0,1),
		Color.CYAN,
		Color(0.6,0.2,1)
	]

	var index = clamp(amount - 2, 0, texts.size() - 1)

	combo_label.visible = true
	combo_label.text = texts[index] + " x" + str(amount)
	combo_label.modulate = colors[index]

	var base_scale = 1.4 + (index * 0.15)
	combo_label.scale = Vector2(base_scale, base_scale)

	await get_tree().create_timer(0.1).timeout
	combo_label.scale = Vector2(1,1)

	if amount >= 5:
		shake_screen(6 + index * 2)

	await get_tree().create_timer(0.4).timeout
	combo_label.visible = false

func on_ball_tagged():
	combo += 1

	if combo < 2:
		return

	var texts = ["Nice","Awesome","Excellent","Extreme","Absurd","Outlandish","Unstoppable","GODLIKE"]
	var colors = [
		Color.WHITE,
		Color.YELLOW,
		Color.ORANGE,
		Color(1,0.5,0),
		Color.RED,
		Color(1,0,1),
		Color.CYAN,
		Color(0.6,0.2,1)
	]

	var index = clamp(combo - 2, 0, texts.size() - 1)

	combo_label.visible = true
	combo_label.text = texts[index] + " x" + str(combo)
	combo_label.modulate = colors[index]

	var current_combo = combo
	combo_label.scale = Vector2(1.25, 1.25)
	await get_tree().create_timer(0.06).timeout

	if combo == current_combo:
		combo_label.scale = Vector2(1,1)

func shake_screen(intensity):

	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return

	for i in range(5):
		camera.offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(0.02).timeout

	camera.offset = Vector2.ZERO

# =========================
# PHYSICS
# =========================
func _physics_process(delta):
	if is_dead:
		return

	previous_y = global_position.y

	# =========================
	# DASH INPUT
	# =========================
	dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		start_dash()

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			is_dash_recovering = true

	# =========================
	# MOVEMENT
	# =========================
	handle_gravity(delta)
	handle_jump()

	if not is_dashing:
		handle_movement(delta)

	if is_dash_recovering:
		velocity.x = move_toward(velocity.x, 0, 4000 * delta)
		if abs(velocity.x) < 40:
			is_dash_recovering = false

	move_and_slide()

	# =========================
	# FLOOR CHECK (ONLY HERE)
	# =========================
	var on_floor = is_on_floor()

	# =========================
	# LANDING DETECTION (FIXED)
	# =========================
	if not was_on_floor and on_floor:

		if not combo_cleared:

			combo_cleared = true
			
			land_sfx.pitch_scale = randf_range(0.9, 1.0)
			land_sfx.play()

			play_dust(landing_dust)

			if combo > 0:
				on_combo_cleared(combo)

			await get_tree().create_timer(0.05).timeout
			clear_tagged()

			if combo >= 2:
				await combo_end_animation()

			combo = 0

	# update state AFTER check
	was_on_floor = on_floor
	
	if not on_floor:
		combo_cleared = false

	# =========================
	# OTHER SYSTEMS
	# =========================
	check_for_tags()
	update_animation()
	update_run_dust() 

# =========================
# DASH
# =========================
func start_dash():

	var input_dir = Input.get_axis("move_left", "move_right")

	# fallback to current movement
	if input_dir == 0:
		input_dir = sign(velocity.x)

	# 🚫 NO MOVEMENT → cancel dash completely
	if abs(input_dir) < 0.2:
		return

	# 🔊 play sound ONLY on successful dash
	dash_sfx.pitch_scale = randf_range(0.95, 1.05)
	dash_sfx.play()

	# 💨 dash dust
	play_dust(dash_dust)
	dash_dust.flip_h = input_dir < 0
	dash_dust.speed_scale = 1.5

	is_dashing = true
	dash_timer = dash_time
	dash_cooldown_timer = dash_cooldown

	velocity.x += input_dir * dash_speed

# =========================
# TAG SYSTEM
# =========================
func check_for_tags():
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		ball.try_tag(self)

func clear_tagged():
	get_tree().call_group("tagged", "pop")

# =========================
# MOVEMENT
# =========================
func handle_gravity(delta):
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * FALL_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta
	else:
		jumps_left = MAX_JUMPS

func handle_jump():
	if Input.is_action_just_pressed("jump") and jumps_left > 0:

		velocity.y = JUMP_FORCE
		jumps_left -= 1

		# 🎧 Base jump sound (always plays)
		jump_sfx.pitch_scale = randf_range(0.9, 1.1)

		# 🎯 Ground vs Air differentiation
		if jumps_left == MAX_JUMPS - 1:
			# Ground jump
			jump_sfx2.pitch_scale = randf_range(0.95, 1.05)
			jump_sfx2.play()
		else:
			# Air jump → lighter feel
			jump_sfx.pitch_scale = randf_range(1.3, 1.4)

		jump_sfx.play()

		# 🎨 Dust visibility
		if jumps_left == MAX_JUMPS - 1:
			jump_dust.modulate.a = 0.7
		else:
			jump_dust.modulate.a = 0.35

		play_dust(jump_dust)

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

func handle_movement(delta):

	var direction = Input.get_axis("move_left", "move_right")

	var joystick = get_tree().get_first_node_in_group("joystick")

	if joystick:
		direction += joystick.output.x

	direction = clamp(direction, -1, 1)

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * SPEED,
			ACCEL * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * delta
		)

var current_anim = ""

func update_animation():

	if is_dead:
		return

	# Flip character
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0

	var new_anim = ""

	# DASH FIRST (highest priority)
	if is_dashing:
		if not is_on_floor():
			new_anim = "jump"
		else:
			new_anim = "run"

		anim.speed_scale = 2.0
	else:
		anim.speed_scale = 1.0

		# AIR
		if not is_on_floor():
			new_anim = "jump"

		# GROUND
		elif abs(velocity.x) > 50:
			new_anim = "run"

		else:
			new_anim = "idle"

	# Only change if different (IMPORTANT)
	if current_anim != new_anim:
		current_anim = new_anim
		anim.play(new_anim)

func play_dust(dust_node):

	dust_node.visible = true
	dust_node.play("dust")

	await dust_node.animation_finished

	dust_node.visible = false

func update_run_dust():

	if is_on_floor() and abs(velocity.x) > 50:

		if not run_dust.visible:
			run_dust.visible = true
			run_dust.play("dust")

		run_dust.flip_h = velocity.x < 0
		run_dust.speed_scale = 1.0

	else:
		run_dust.visible = false

# =========================
# COMBO END ANIMATION
# =========================
func combo_end_animation():

	var start_scale = combo_label.scale
	var duration = 0.25
	var t = 0.0

	while t < duration:
		t += get_process_delta_time()
		var ratio = t / duration

		combo_label.scale = start_scale.lerp(Vector2(0.6,0.6), ratio)
		combo_label.modulate.a = lerp(1.0,0.0,ratio)

		await get_tree().process_frame

	combo_label.visible = false
	combo_label.modulate.a = 1.0
	combo_label.scale = Vector2(1,1)

# =========================
# DEATH
# =========================
func _on_hitbox_body_entered(body):
	print("HIT:", body.name)

	if body.is_in_group("ball"):
		die()

func die():
	if is_dead:
		return

	is_dead = true
	
	death_sfx.play()
	death_sfx2.play()

	anim.play("death")
	anim.speed_scale = 1.0

	print("GAME OVER")

	await get_tree().create_timer(0.6).timeout

	Engine.time_scale = 0.2
	await get_tree().create_timer(0.3).timeout

	get_tree().paused = true
