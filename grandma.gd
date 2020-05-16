extends Node2D
class_name GrandMa

const LEFT = -1
const NONE = 0
const RIGHT = 1
const ANIM_TIME = {"idle": 1.0, "jump": 4.0, "jump_slide": 2.0, "slide": 1.0, "push": 1.0, "kick": 1.0, "fall": 1.0}
const CELL = Vector2(150, 150)

export var texture = Color("4a57c3") setget set_texture
onready var obj = $back
onready var sprite = $sprite

var grid_pos = Vector2(0.0, 0)# setget , get_player_position

var moving = NONE

func _ready():
#	Engine.time_scale = 1/3.0
	Time.connect("tick", self, "on_tick")

func on_tick(tick):
	grid_pos = Vector2(int(position.x / 150.0), -int(position.y / 150.0))
	$text.text = str(grid_pos)


func set_texture(value):
	texture = value
	check()

func get_player_position():
	return Vector2(int(position.x / 150.0), -int(position.y / 150.0))

func check():
	pass

var is_moving = false

func move(value = moving):
	moving = value
#	tw.ip(self, "position:x", position.x, (grid_pos.x+value/2.0)*CELL.x, Time.TICK)
#	grid_pos.x += value/2.0
	tw.ip(self, "position:x", position.x, (grid_pos.x+value/1.0)*CELL.x, Time.TICK)
	grid_pos.x += value/1.0
#	grid_pos.x += value/2.0

func down():
	jumping = true
	grid_pos.y = 0
	position.y = 0
	var type = "fall"
	sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
	sprite.play(type)
#	print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])
	yield(sprite, "animation_finished")
	type = "idle"
	sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
	sprite.play(type)
#	print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])
	yield(sprite, "animation_finished")
	jumping = false

func get_pos_after_x_tick(x):
	return grid_pos+ Vector2(x*moving/2.0, 0)

var jumping = false
func jump():
	
	if jumping:
		yield(Time.defer(), "completed")
		return
	jumping = true
	var type = "jump"
	sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
	sprite.play(type)
#	print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])
	yield(sprite, "animation_finished")
	if grid_pos.y > 0:
		moving = NONE
#		position.y += 150
#		grid_pos.y += 1
		down()
#		
	type = "idle"
	sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
	sprite.play(type)
	moving = NONE
	jumping = false
	
#	print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])

func win_jump():
	var limit = 3
	for i in range(0, limit):
		sprite.play("jump")
		yield(sprite, "animation_finished")

func jump_and_slide(dir, force):
	if jumping:
		yield(Time.defer(), "completed")
		return
	jumping = true
	var type = "jump_slide"
	sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
	sprite.play(type)
#	print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])
	yield(sprite, "animation_finished")
	if type == "jump_slide":
		grid_pos.y += 1
		type = "slide"
		sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
		sprite.play(type)
#		print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])
#		yield(sprite, "animation_finished")
		moving = dir
#		position.x += dir * 150
		position.y -= 150
	type = "idle"
	sprite.speed_scale = 1 / Time.TICK / ANIM_TIME[type]
	sprite.play(type)
#	print("start '%s' at %s (scale: %s)" % [type, Time.tick, sprite.speed_scale])
	yield(sprite, "animation_finished")
	jumping = false
	

#
#var _pushing = false
#var _dir
#func push(dir):
#	if _pushing:
#		return
#	_dir = dir
#	_pushing = true
#	var t = Time.TICK
##	yield(tw\
#	if true:
#		tw.ip(sprite, "scale", Vector2(1,1), Vector2(0.9, 1.1), t*0.3)
#		tw.ip(sprite, "scale", sprite.scale, Vector2(1, 1), t*0.5, tw.SINE, tw.INOUT, t*0.3)
#		yield(tw.ip(sprite, "position:x", sprite.position.x, sprite.position.x + 150 * dir, t*0.3, tw.CUBIC, tw.OUT, t*0.2),
#	"completed")
#	self.position.x += 150 * dir
##	print (position.x)
#	sprite.position.x = 0
#	if position.x > 740:
#		self.position.x = -450
#		yield(Time.wait(0.2), "completed")
#	_pushing = false
#
#
#func push_and_drop(dir):
#	jumping = true
#	var t = Time.TICK * 2
#	if (t > 0):
#		yield(tw\
#		.ip(sprite, "scale", Vector2(1,1), Vector2(0.9, 1.1), t*0.3)\
#		.ip(sprite, "scale", sprite.scale, Vector2(1, 1), t*0.5, tw.SINE, tw.INOUT, t*0.3)\
#		.ip(sprite, "position:x", sprite.position.x, sprite.position.x + 150 * dir, t*0.3, tw.CUBIC, tw.OUT, t*0.2),
#	"completed")
#	jumping = false
#	pass

func pause_in(ticks):
	for i in range(ticks):
		yield(Time, "tick")
	get_tree().paused = true
	yield(Time.wait(1), "completed")
	get_tree().paused = false
