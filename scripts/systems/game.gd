extends Node2D

func _ready():
	load_theme("res://themes/beach/beach_theme.tscn")

func load_theme(path):

	for child in $World/ThemeContainer.get_children():
		child.queue_free()

	var theme = load(path).instantiate()

	$World/ThemeContainer.add_child(theme)


func apply_theme(theme: ThemeData):

	# 🎨 Borders
	$World/Visuals/Borders.default_color = theme.border_color

	# 🎵 Ambient audio (SAFE CHECK)
	if theme.ambient_sound != null:
		if $World.has_node("AmbientSFX"):
			var player = $World/AmbientSFX
			player.stream = theme.ambient_sound
			player.volume_db = theme.ambient_volume
			player.play()

var current_theme_path = ""

func switch_theme(path):
	if path == current_theme_path:
		return

	current_theme_path = path
	load_theme(path)
