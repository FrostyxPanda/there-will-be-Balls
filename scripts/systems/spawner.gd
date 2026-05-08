extends Node2D

@export var ball_scene: PackedScene

var base_delay = 1.8
var min_delay = 0.6

var current_delay = base_delay
var spawn_timer = 0.0

var difficulty_timer = 0.0

var max_balls = 6

func _process(delta):

	# 🟢 Always update timers
	spawn_timer -= delta
	difficulty_timer += delta

	# 🟢 Handle spawning
	if spawn_timer <= 0:
		spawn_pattern()
		spawn_timer = current_delay

	# 🟢 Gradual speed-up (independent of spawn)
	current_delay = max(min_delay, current_delay - delta * 0.005)

	# 🟢 Increase max balls every 10 seconds
	if difficulty_timer > 10:
		difficulty_timer = 0
		max_balls += 1
		max_balls = min(max_balls, 12)   # 👈 I reduced cap for control


func spawn_pattern():

	var ball_count = get_tree().get_nodes_in_group("ball").size()

	if ball_count >= max_balls:
		return

	var roll = randf()

	# 🎯 SINGLE (dominant)
	if roll < 0.60:
		spawn()

	# ⚡ DOUBLE (rare)
	elif roll < 0.80:
		spawn()
		await get_tree().create_timer(0.25).timeout
		spawn()

	# 🔥 BURST (very rare)
	else:
		for i in range(3):
			spawn()
			await get_tree().create_timer(0.2).timeout


func spawn():

	var ball = ball_scene.instantiate()

	# ===== ARENA BOUNDS (adjust if needed) =====
	var left_bound = 100
	var right_bound = 980

	var buffer = 200  # 👈 tweak this (80–120 is ideal)

	var x = randf_range(left_bound + buffer, right_bound - buffer)
	var y = 325

	ball.position = Vector2(x, y)

	get_parent().add_child(ball)
