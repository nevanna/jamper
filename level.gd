extends Node2D

onready var grandma = $grandma
onready var field = $field

var is_need_to_jump = false
const DEBUG = true
const CELL = Vector2(150, 150)





func _ready():
	Time.connect("tick", self, "on_tick")
	var colors = field.get_existed_colors()
	field.connect("win", self, "win")
	print("colors")
	for cl in colors:
		print(cl.to_html(false))
	print("\n")
	$spawner1.queue_color = colors
	if DEBUG:
		$debug_tick.show()


func _input(e):
	if e is InputEventScreenTouch:
		if e.pressed:
			is_need_to_jump = true
	elif e is InputEventKey:
		if e.is_action_pressed("pause"):
				get_tree().paused = true
				yield(Time.wait(2), "completed")
				get_tree().paused = false
		elif e.is_action_pressed("jump"):
			is_need_to_jump = true


func on_tick(tick):
	$debug_tick.text = "%003.2f sec\n(%0004d tick)" % [tick*Time.TICK, tick]
	if  grandma.moving != 0:
		var p = grandma.get_pos_after_x_tick(1)
		if grandma.moving != 0:
			if p.x < 3.5 and p.x > -3.5: 
				grandma.move()
			elif p.y > 0:
				grandma.down()

	var squares = get_active_squares()
	for sq in squares:
		sq.get_pos()
	if is_need_to_jump:
		is_need_to_jump = false
		var jump_slide = null
		for sq in squares:
			if sq.y_pos != 0:
				continue
			print(GrandMa.ANIM_TIME.jump+GrandMa.ANIM_TIME.slide)
			if jump_slide == null and sq.get_pos_after_x_tick(GrandMa.ANIM_TIME.jump_slide) == grandma.grid_pos:
				jump_slide = {"dir": sq.direction, "force": false}
		if jump_slide:
#			pass
			grandma.jump_and_slide(jump_slide.dir.x, jump_slide.force)
		else:
			grandma.jump()
			push_block()
#
func push_block():
	var baba_pos = grandma.grid_pos
	var active = get_active_squares()
	for sq in active:
		if !sq.active or sq.get_pos().y <= baba_pos.y:
			continue
		var pos_1 = sq.get_pos_after_x_tick(0)
		var pos_2 = sq.get_pos_after_x_tick(1)
		if baba_pos.x == pos_1.x:
			field.push(sq, true)
		elif baba_pos.x == pos_2.x:
			field.push(sq, false)

#		if int(baba.y) != int(block.y): # and int(baba.x) == int(block.x):
#			yield(prepare_jump(sq), "completed")
#			field.push(sq)

func prepare_jump(sq):
	var bab = grandma.position.x
	var bl = sq.position.x + sq.get_parent().position.x
	var s = abs(bab - bl)
	var t = s / sq.speed.x
	tw.ip(grandma, "scale", Vector2(1,1), Vector2(0.1, 0.1), t/2)
	yield(Time.wait(t/2),"completed")
	tw.ip(grandma, "scale", Vector2(0.1,0.1), Vector2(1, 1), t/2)
	yield(Time.wait(t/2),"completed")



func get_active_squares():
	var arr = get_tree().get_nodes_in_group("square")
	return arr

func win():
	$win_label.show()
	grandma.win_jump()
	$spawner0.queue_color = PoolColorArray()
	$spawner1.queue_color = PoolColorArray()
	$spawner3.queue_color = PoolColorArray()
	var list_blocks = $spawner1.get_children()
	while list_blocks.sieze() != 1:
		var i = randi() % list_blocks.size()
		var el = list_blocks[i]
		if el is Node2D:
			el.explosion.emitting = true
		
		
	
	
	
#func _draw():
#	if DEBUG and OS.get_name() != "Android":
#		draw_line(Vector2(0, 120), Vector2(0, -1800), Color("808080ff"), 1, true)
#		for k in 1920/75:
#			for i in 1080/150:
#				for j in 2:
#					var x = 75+i*75
#					x *= 1 if j else -1
#					draw_line(Vector2(x,120), Vector2(x, -1800), Color("808080ff") if i % 2 else Color("a0ff8080"), (1 if i % 2 else 3), true)
#			var y = -75*k
#			draw_line(Vector2(-620,y), Vector2(620, y), Color("808080ff") if k % 2 else Color("a0ff8080"), (1 if k % 2 else 3), true)
