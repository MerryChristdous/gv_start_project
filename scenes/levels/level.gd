extends Node2D

var plant_scene = preload("res://scenes/objects/plant.tscn")
var plant_info_scene = preload("res://scenes/ui/plant_info.tscn")
var used_cells : Array[Vector2i]
@export var daytime_color: Gradient
@export var rain_color: Color
@export var volume_curve: Curve
@onready var daytransition_material = $Overlay/CanvasLayer/DayTransitionLayer.material
var is_level_restarting : bool = false
var raining: bool:
	set(value):
		raining = value
		$Layers/RainFloorParticles.emitting = value
		$Overlay/RainDropParticles.emitting = value
		$Music/Rain.playing = value
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_weather()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_daytime()
	_debug_grid_coord()
	_debug_input_keys()
	
func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	var grid_coord: Vector2i = Library.position_to_gird(pos)
	var has_soil = grid_coord in $Layers/SoilLayer.get_used_cells()
	match tool:
		Enum.Tool.HOE:
			# 在玩家所在的网格坐标生成土壤
			var cell = $Layers/GrassLayer.get_cell_tile_data(grid_coord) as TileData
			if cell and cell.get_custom_data("farmable"):
				$Layers/SoilLayer.set_cells_terrain_connect([grid_coord], 0, 0)
				if raining:
					spawn_soil_water(grid_coord)
		
		Enum.Tool.WATER:
			if has_soil:
				spawn_soil_water(grid_coord)
				
		Enum.Tool.FISH:
			#var cell = $Layers/WaterLayer.get_cell_tile_data(grid_coord) as TileData
			#if cell:
				
			if not grid_coord in $Layers/GrassLayer.get_used_cells():
				$Objects/Player.start_fishing()
			
				
				
		Enum.Tool.SEED:
			if has_soil and grid_coord not in used_cells:
				#生成作物数据资源
				var plant_res = PlantResource.new()
				plant_res.setup($Objects/Player.current_seed)
				#生成作物本体
				var plant = plant_scene.instantiate()
				plant.setup(grid_coord, $Objects, plant_res, on_plant_death)
				used_cells.append(grid_coord)
				#添加作物UI信息
				var plant_info = plant_info_scene.instantiate()
				plant_info.setup(plant_res)
				$Overlay/CanvasLayer/PlantInfoContainer.add_plant_info(plant_info)
				
				
		Enum.Tool.AXE, Enum.Tool.SWORD:
			pass
				
func _daytime() -> void:
	#当前时间点
	var daytime_point = 1 - ($Timers/DayTimer.time_left / $Timers/DayTimer.wait_time)
	#根据当前时间点设置天色
	var current_color = daytime_color.sample(daytime_point).lerp(rain_color, 0.5 if raining else 0.0)
	$Overlay/DayTimeColor.color = current_color
	#根据当前时间点设置背景音乐音量
	$Music/BGMusic.volume_db = volume_curve.sample(daytime_point)

func _debug_grid_coord() -> void:
	#测试用
	var pos = $Objects/Player.position + $Objects/Player.last_direction.normalized() * 16
	var grid_coord: Vector2i = Library.position_to_gird(pos)
	$Layers/DebugLayer.clear()
	$Layers/DebugLayer.set_cell(grid_coord, 3, Vector2i(0, 0))
	
func _debug_input_keys() -> void:
	if Input.is_action_just_pressed("day_change") and not is_level_restarting:
		day_restart()
		

#debug 鼠标点击事件
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("=== 点击事件调试 ===")
		var mouse_pos = get_global_mouse_position()
		print("点击位置: ", mouse_pos)
		
		# 递归遍历所有节点，打印能接收点击的
		_check_all_children(get_tree().current_scene, mouse_pos)

func _check_all_children(node: Node, mouse_pos: Vector2) -> void:
	# 如果是 Control 节点，检查鼠标是否在其范围内
	if node is Control:
		var control = node as Control
		# 只有可见且鼠标在范围内才打印
		if control.visible and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			var rect = Rect2(control.global_position, control.size)
			if rect.has_point(mouse_pos):
				print("  → Control节点: ", node.name, " (", node.get_class(), ")")
				print("     位置: ", control.position, " 大小: ", control.size)
				print("     mouse_filter: ", control.mouse_filter)
	
	# 递归检查所有子节点
	for child in node.get_children():
		_check_all_children(child, mouse_pos)

func day_restart():
	#关卡正在重置中
	is_level_restarting = true
	#开启关卡重置动画
	var tween = create_tween()
	tween.tween_property(daytransition_material, "shader_parameter/progress", 1.0, 1.0)
	#开始重置
	tween.tween_interval(0.5)
	tween.tween_callback(level_reset)
	#关闭关卡重置动画
	tween.tween_property(daytransition_material, "shader_parameter/progress", 0.0, 1.0)
	#关卡重置完毕
	tween.tween_callback(func():
		is_level_restarting = false)
	
func level_reset():
	$Timers/DayTimer.start()
	for tree in get_tree().get_nodes_in_group('Trees'):
		if tree.has_method("reset"):
			tree.reset()
	for plant in get_tree().get_nodes_in_group('Plants'):
		if plant.has_method("grow"):
			plant.grow(plant.coord in $Layers/SoilWaterLayer.get_used_cells())
	$Layers/SoilWaterLayer.clear()
	$Overlay/CanvasLayer/PlantInfoContainer.update_plants_info()
	
	raining = Data.forecast_rain
	random_weather()
	
	if raining:
		for soil_cell in $Layers/SoilLayer.get_used_cells():
			spawn_soil_water(soil_cell)
	
func on_plant_death(coord: Vector2i):
	used_cells.erase(coord)


func random_weather():
	Data.forecast_rain = [true, false].pick_random()
	
func spawn_soil_water(coord: Vector2i):
	$Layers/SoilWaterLayer.set_cell(coord, 0, Vector2i(randi_range(0, 2),0))


func _on_player_day_change() -> void:
	day_restart()

	
