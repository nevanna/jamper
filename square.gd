tool
extends Node2D

const SIZE = Vector2(-150, -150)

export var color = Color(1,1,1)

export var active = true

export var speed = Vector2(450, 450)

var pos = Vector2(0,0) setget ,get_pos

var tween

var direction:Vector2
var y_pos
var start_tick = 0
var start_pos = Vector2.ZERO

onready var explosion = $explosion

func _ready():
	explosion.emitting = false
	var col = explosion.process_material.color_ramp.gradient.colors
	col.set(0, self.color)

func get_pos_after_x_tick(x):
	return start_pos + Vector2(direction.x * (Time.tick - start_tick + x)*0.5, 0)

func get_pos():
	var pos = start_pos + Vector2(direction.x * (Time.tick - start_tick)*0.5, 0)
	update_pos_text(pos)
	return pos

func update_pos_text(pos):
	$label.text = str(pos)

func _draw():
	draw_rect(Rect2(-SIZE*0.5, SIZE), color, true)