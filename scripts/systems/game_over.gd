extends Control




func _ready():

	# =========================
	# THEME BACKGROUND
	# =========================

	var theme_name = GameData.selected_theme

	$Background.modulate = Color.ORANGE


	# =========================
	# MAIN STATS
	# =========================

	$Panel/VBoxContainer/ScoreRow/ScoreLabel.text = (
		"Score: " + str(GameData.last_score)
	)

	$Panel/VBoxContainer/TimeRow/TimeLabel.text = (
		"Time: " +
		str(int(GameData.last_survival_time)) + "s"
	)

	$Panel/VBoxContainer/ComboRow/ComboLabel.text = (
		"Combos: " +
		str(GameData.last_total_combos)
	)

	$Panel/VBoxContainer/HighestComboRow/HighestComboLabel.text = (
		"Highest Combo: " +
		str(GameData.last_highest_combo)
	)


	# =========================
	# REWARD LABELS
	# =========================

	$Panel/VBoxContainer/ScoreRow/ScoreRewardLabel.text = (
		"+" + str(GameData.last_score_coins)
	)

	$Panel/VBoxContainer/TimeRow/TimeRewardLabel.text = (
		"+" + str(GameData.last_time_coins)
	)

	$Panel/VBoxContainer/ComboRow/ComboRewardLabel.text = (
		"+" + str(GameData.last_combo_coins)
	)

	$Panel/VBoxContainer/HighestComboRow/HighestComboRewardLabel.text = (
		"+" + str(GameData.last_highest_combo_coins)
	)


	# =========================
	# TOTAL REWARD
	# =========================

	$Panel/VBoxContainer/CoinsLabel.text = (
		"Coins Earned: " +
		str(GameData.last_total_reward)
	)



# =========================
# RETRY
# =========================

func _on_retry_button_pressed():

	Engine.time_scale = 1.0

	get_tree().change_scene_to_file(
		"res://scenes/game/game.tscn"
	)



# =========================
# MAIN MENU
# =========================

func _on_menu_button_pressed():

	Engine.time_scale = 1.0

	get_tree().change_scene_to_file(
		"res://scenes/main_menu.tscn"
	)
