extends Control

@onready var base = $Base
@onready var knob = $Knob

var max_distance = 50.0
var output = Vector2.ZERO

var active = false
var touch_index = -1


func _ready():
	add_to_group("joystick")

	base.visible = false
	knob.visible = false


func _input(event):

	# 👆 Touch start
	if event is InputEventScreenTouch:

		if event.pressed and not active and event.position.x < get_viewport_rect().size.x * 0.5:

			active = true
			touch_index = event.index

			base.global_position = event.position - base.size / 2
			knob.global_position = event.position - knob.size / 2

			base.visible = true
			knob.visible = true

		elif not event.pressed and event.index == touch_index:

			active = false
			touch_index = -1

			output = Vector2.ZERO

			base.visible = false
			knob.visible = false

	# 👆 Drag
	elif event is InputEventScreenDrag:

		if active and event.index == touch_index:

			var center = base.global_position + base.size / 2

			var offset = event.position - center

			if offset.length() > max_distance:
				offset = offset.normalized() * max_distance

			knob.global_position = center + offset - knob.size / 2

			output = offset / max_distance

			if output.length() < 0.15:
				output = Vector2.ZERO
