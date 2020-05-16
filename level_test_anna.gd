extends "res://level.gd"

func _ready():
	var field = $field
	field.connect("win", self, "_win")
	var sq = []
	var tmpl ="square%s"
	var i = int(0)
	while i < 52:
		var path = tmpl % String(i)
		sq.append(get_node(path))
		i += 1
		
	for obj in sq:
		field.push(obj)
		yield(Time.wait(0.7), "completed")

func _win():
	print("WIN")
	print("WIN")
	print("WIN")
