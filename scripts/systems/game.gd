extends Node2D

var current_theme_path = ""


func _ready():

	var theme_name = GameData.selected_theme

	var path = "res://themes/%s/%s_theme.tscn" % [
		theme_name,
		theme_name
	]
	
	current_theme_path = path

	load_theme(path)


func load_theme(path):

	if not ResourceLoader.exists(path):
		print("Theme missing: ", path)
		return

	for child in $World/ThemeContainer.get_children():
		child.queue_free()

	var theme = load(path).instantiate()

	$World/ThemeContainer.add_child(theme)

	apply_theme(theme)


func apply_theme(theme: ThemeData):

	# 🎨 Borders
	$World/Visuals/Borders.default_color = theme.border_color

	# 🎵 Music
	if theme.music_track != null:

		$Audio/MusicPlayer.stream = theme.music_track
		$Audio/MusicPlayer.play()

	# 🌊 Ambient
	if theme.ambient_sound != null:

		$Audio/AmbientPlayer.stream = theme.ambient_sound
		$Audio/AmbientPlayer.play()


func switch_theme(path):

	if path == current_theme_path:
		return

	current_theme_path = path

	load_theme(path)


func _on_retry_button_pressed():

	Engine.time_scale = 1.0

	get_tree().paused = false

	get_tree().reload_current_scene()


func _on_menu_button_pressed():
	
	Engine.time_scale = 1.0

	get_tree().paused = false

	# TEMPORARY
	get_tree().reload_current_scene()

	# LATER:
	# get_tree().change_scene_to_file(
	# 	"res://menus/main_menu.tscn"
	# )
