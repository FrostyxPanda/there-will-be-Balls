extends Node

var coins = 0

var theme_background_color = Color.WHITE

# 🎱 BALLS
var unlock_all = false
var total_ball_count = 40

var unlocked_balls = [0]

# 🎨 THEMES
var unlocked_themes = ["beach"]
var selected_theme = "beach"

# 🎲 BALL SELECTION
# -1 = random mode
var selected_ball = -1

# =========================
# GAME OVER DATA
# =========================

var last_score = 0
var last_survival_time = 0.0
var last_total_combos = 0
var last_highest_combo = 0

# 🪙 reward breakdown
var last_score_coins = 0
var last_time_coins = 0
var last_combo_coins = 0
var last_highest_combo_coins = 0

# 💰 total reward
var last_total_reward = 0


func get_unlocked_balls():

	if unlock_all:
		var all = []

		for i in range(total_ball_count):
			all.append(i)

		return all

	return unlocked_balls


func add_coins(amount):
	coins += amount


func unlock_ball(id):

	if id not in unlocked_balls:
		unlocked_balls.append(id)


func is_unlocked(id):
	return id in unlocked_balls


func set_selected_ball(id):
	selected_ball = id


func unlock_theme(name):

	if name not in unlocked_themes:
		unlocked_themes.append(name)
