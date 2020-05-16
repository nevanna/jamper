extends Control

var png_path = "res://jumpers/%s.png"
var a = 0.3
onready var png = $field/png
onready var jumper = $field/png/jumper

var pic_size = Vector2(7,7)
onready var save = $save
var size_block= 150

var image

signal win
signal success
signal on_place
var table = []

onready var text = $"ts"
onready var btn = $Button

func _ready():
	prepare_png()
	create_table()


func prepare_png():
	get_picture()
	png.modulate.a = a

func get_picture():
	randomize()
	var nb = randi() % 2
#	var nb = randi() % 1
	var img_path = png_path % nb
	var img  = load(img_path)
	png.texture = img
#	print("COLOR")
	image = png.texture.get_data()
	image.lock()
	var col = image.get_pixel(1, 1)
#	print(col)
	var col_str = col.to_html(false)
#	print(col_str)

func get_existed_colors():
	var color_types : PoolColorArray
	var i = int(0)
	for _y in range(0,8):
		for _x in range(0,8):
			i += 1
			var col = image.get_pixel(_x,_y).to_html(false)
			if !_is_color_in_array(color_types, col):
#				where did i get this color? from (7:0)
				if col == "000000":
					continue
				color_types.append(col)
	return color_types
			

func _is_color_in_array(ar : PoolColorArray, color : Color) -> bool:
	for cl in ar:
		if cl == color:
			return true
	return false

func create_table():
	var plug = -1
	var i = int(0)
	while i < pic_size.y:
		var j = int(0)
		var raw = []
		while j < pic_size.x:
			raw.append(plug)
			j += 1
		table.append(raw)
		i += 1

func push(obj, force):
	obj.active = false
	yield(Time.wait(Time.TICK if force else Time.TICK*2), "completed")
#	print("print_stop")
	obj.tween.remove_all()
#	obj.position.x = 
	obj.position.x = round((obj.position.x)/75)*75
	obj.remove_from_group("square")
	print_table()
	var speed = obj.speed.y
	var dic = block_is_good(obj)
	if typeof(dic)  == TYPE_DICTIONARY && dic["bool"] == true:
		if is_full_jumper(table):
			print("win!")
			emit_signal("win")
#		print("run good")
		run_block(obj, dic)
		return true
	else:
#		print("run bad")
		run_bad_block(obj, dic)
		return false


func print_table():
	var i = int(0)
	print("Table")
	while i < 7:
		print(table[i])
		i += 1

func block_is_good(obj):
	var tmp_obj_pos_x = obj.position.x + obj.get_parent().position.x + 1080/2
	var column = int(tmp_obj_pos_x / size_block)
	var cell = what_cell_is_empty_in_column(column)
	return(__is_color_same(cell, obj))
	
func is_full_jumper(table):
	var i = int(0)
	while i < image.get_height():
		var j = int(0)
		while j < image.get_width():
			if typeof(table[i][j]) != TYPE_COLOR:
				return false
			j += 1
		i += 1
	return true
	
func what_cell_is_empty_in_column(column):
	var i = int(0)
	var count = int(0)
	while i < pic_size.y:
		if(column < 7):
			if typeof(table[i][column]) != TYPE_COLOR:
				return Vector2(column, i)
		i += 1
	return Vector2(column,i)
	

func __is_color_same(cell, obj):
	var dic = {
					"bool" : null, 
					"cell": {
								"x": null,
								"y": null
							}
		}

	if cell.y < 7:
		var _color_original = image.get_pixel(cell.x, cell.y).to_html()
		var _color_from_obj = obj.color.to_html()
		if _color_from_obj == _color_original:
			table[int(cell.y)][int(cell.x)] = Color(_color_from_obj)
			dic["bool"] = true
		else:
#			print("Velid color")
#			print(_color_original.is_valid_html_color())
			$color_r.color = Color(_color_original)
			dic["bool"] = false
	else:
		dic["bool"] = false
	dic["cell"]["x"] = int(cell.x)
	dic["cell"]["y"] = int(cell.y)
	
	return dic

func run_block(obj, dic):
	yield(Time.defer(), "completed")
#	print("in run")
	var start_pos = obj.position
	var prom = -1800 + 150/2 +  dic["cell"]["y"]*150 - obj.get_parent().position.y
	var end_pos = Vector2(start_pos.x, prom)
	var s = start_pos.y - end_pos.y
	var t = s / obj.speed.y
	tw.ip(obj, "position:y", start_pos.y, end_pos.y, t)
	yield(Time.wait(t), "completed")
	emit_signal("on_place")

func run_bad_block(obj, dic):
	yield(Time.defer(), "completed")
	var start_pos = obj.position
	var prom = -1800 + 150/2 +  dic["cell"]["y"]*150 - obj.get_parent().position.y
	var end_pos = Vector2(start_pos.x, prom)
	var s = start_pos.y - end_pos.y
	var t = s / obj.speed.y
	tw.ip(obj, "position:y", obj.position.y, end_pos.y, t)
	yield(Time.wait(t), "completed")
	destroy(obj)
	

func destroy(obj):
	tw.ip(obj, "scale:y", 1, 0.7, 0.2)
	yield(Time.wait(0.2), "completed")
	tw.ip(obj, "scale:y", 0.7, 1, 0.2)
	yield(Time.wait(0.2), "completed")
	tw.ip(obj, "scale", Vector2(1,1), Vector2(1.5, 1.5), 0.2)
	tw.ip(obj, "modulate:a", 1, 0.5, 0.2)
	yield(Time.wait(0.2), "completed")
	obj.queue_free()
