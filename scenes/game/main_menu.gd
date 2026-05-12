extends Control



# =========================
# READY
# =========================

func _ready():

	# ensure fade starts invisible
	$Fade.modulate.a = 0



# =========================
# PLAY
# =========================

func _on_play_button_pressed():

	# play fade animation
	$AnimationPlayer.play("fade_out")

	# wait for animation to finish
	await $AnimationPlayer.animation_finished

	# change to game scene
	get_tree().change_scene_to_file(
		"res://scenes/game/game.tscn"
	)



# =========================
# CUSTOMIZE
# =========================

func _on_customize_button_pressed():

	print("Customize Menu")



# =========================
# SETTINGS
# =========================

func _on_settings_button_pressed():

	print("Settings Menu")



# =========================
# CREDITS
# =========================

func _on_credits_button_pressed():

	print("Credits Menu")
