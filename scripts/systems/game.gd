extends Node2D

func _ready():

	var theme_name = GameData.selected_theme

	var path = "res://themes/%s/%s_theme.tscn" % [
		theme_name,
		theme_name
	]

	load_theme(path)

func load_theme(path):

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

var current_theme_path = ""

func switch_theme(path):
	if path == current_theme_path:
		return

	current_theme_path = path
	load_theme(path)
