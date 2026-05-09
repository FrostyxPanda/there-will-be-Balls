extends Node2D
class_name ThemeData

# 🎨 VISUALS
var border_color: Color = Color.WHITE
var background_color: Color = Color.BLACK
var accent_color: Color = Color.WHITE
var combo_color: Color = Color.WHITE

# 🌫️ ATMOSPHERE
var ambient_color: Color = Color(1, 1, 1)
var ambient_volume: float = -12.0

# 🎵 AUDIO (SAFE DEFAULTS)
var ambient_sound: AudioStream = null
var music_track: AudioStream = null

func _ready():

	border_color = Color("#F4E2B5")

	music_track = preload("res://audio/Music_Atmosphere/lofi leap.mp3")

	ambient_sound = preload("res://audio/Music_Atmosphere/Cymatics - LIFE - Ocean w Distant Music.wav")
	
