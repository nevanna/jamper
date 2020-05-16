extends Node

enum {
	LINEAR = Tween.TRANS_LINEAR,
	SINE = Tween.TRANS_SINE,
	CUBIC = Tween.TRANS_CUBIC,
	BACK = Tween.TRANS_BACK
}

enum {
	IN = Tween.EASE_IN,
	OUT = Tween.EASE_OUT,
	INOUT = Tween.EASE_IN_OUT,
	OUTIN = Tween.EASE_OUT_IN
}

const ANY=Engine

func ip(obj, prop, from, to, duration, trans=Tween.TRANS_LINEAR, easing=Tween.EASE_IN_OUT, delay=0) -> Tw:
	var tw = Tw.new()
	add_child(tw)
	tw.start()
	return tw.ip(obj, prop, from, to, duration, trans, easing, delay)

class Tw:
	extends Tween
	signal completed
	var timer
	var last_duration = -1
	
	func _ready():
		connect("tween_completed", self, "check")
		
	func check(object, key):
		yield(Time, "idle")
		if is_queued_for_deletion():
			return
		if tell() >= get_runtime():
			emit_signal("completed")
			yield(Time, "idle")
			if tell() >= get_runtime():
				queue_free()
	
	func ip(obj, prop, from, to, duration, trans=Tween.TRANS_LINEAR, easing=Tween.EASE_IN_OUT, delay=0):
		last_duration = duration
		interpolate_property(obj, prop, from, to, duration, trans, easing, delay)
		return self