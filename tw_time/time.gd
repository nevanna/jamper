extends Node

signal idle
signal fixed
signal tick(n)

const FORMAT_SECONDS_FULL = 0 
const FORMAT_SECONDS_NORMAL = 1
const FORMAT_SECONDS_TINY = 2

func _ready():
	pass
#	pause_mode = Node.PAUSE_MODE_PROCESS
#	get_tree().connect("idle_frame", self, "emit_signal", ["idle"])
#	get_tree().connect("physics_frame", self, "emit_signal", ["fixed"])
	
func wait(time):
	yield(get_tree().create_timer(time), "timeout")
	
const TICK = 1/6.0 # Delta tick  !!! set 1.0 to slow test !!!
var time = 0.0
var tick = 0

var tmp = 0

func _process(delta):
#	print(delta)
	if get_tree().paused:
		return
	time += delta
	if tick*TICK < time: # new tick! u can update something
		tick += 1
		emit_signal("tick", tick)
		

# wait with respect paused branch 
# of current (at the moment of call) screen
#func pwait(time, repeat=false):
#	yield(defer(), "completed")
#	var elem = ui.get_top_screen()
#	if !elem:
#		return yield(wait(time), "completed")
#	var timer = Timer.new()
#	elem.add_child(timer)
#	timer.one_shot = true
#	timer.start(time)
#	if repeat:
#		return timer
#	else:
#		yield(timer, "timeout")
#		timer.queue_free()
	
func now():
	return OS.get_unix_time()

func defer():
	var d = _Deferred.new()
	yield(d.process(), "completed")

class _Deferred:
	extends Reference
	signal defer
	
	func process():
		call_deferred("emit_signal", "defer")
		yield(self, "defer")
