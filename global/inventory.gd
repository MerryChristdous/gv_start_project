extends Node

# 库存
var inventory = []
const INVENTORY_SIZE : int = 30

var hotbar_size = 10

var inventory_slot_scene = preload("res://scenes/ui/inventory_slot.tscn")
# 库存更新信号
signal inventory_update

#角色场景
var player_node : Node = null

func _ready() -> void:
	#初始化库存大小
	inventory.resize(INVENTORY_SIZE)
	
	
	
func add_item(new_item) -> bool:
	#1.遍历字典，寻找同样的物品
	for i in range(inventory.size()):
		var slot = inventory[i]
		if slot == null:
			continue
			
		if slot["type"] == new_item["type"] and slot["name"] == new_item["name"]:
			slot["quantity"] += new_item["quantity"]
			inventory_update.emit()
			return true
		else :
			continue
		
	#2.无同样物品，找空位
	for i in range(inventory.size()):
		if inventory[i] == null or inventory[i].is_empty():
			# 深拷贝存入
			inventory[i] = new_item.duplicate(true)
			# 浅拷贝存入
			#inventory[i] = new_item
			inventory_update.emit()
			return true
	
	return false

func remove_item(item_name, item_type) -> bool:
	for i in range(inventory.size()):
		var slot = inventory[i]
		if slot != null:
			if slot["type"] == item_type and slot["name"] == item_name:
				slot["quantity"] -= 1
				if slot["quantity"] <= 0:
					inventory[i] = null
					print("✅ 删除了物品: ", item_name, " 索引: ", i)
				else:
					print("✅ 减少数量: ", item_name, " 剩余: ", slot["quantity"])
				inventory_update.emit()
				return true
	print("❌ 未找到物品: ", item_name, " ", item_type)
	return false
	

func adjust_drop_position(position: Vector2) -> Vector2:
	var radius = 50.0
	var nearby_items = get_tree().get_nodes_in_group("items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position

func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	item_instance.global_position = adjust_drop_position(drop_position)
	var objects_parent = get_tree().current_scene.get_node("Objects/Items")
	if objects_parent:
		objects_parent.add_child(item_instance)
	else:
		get_tree().current_scene.add_child(item_instance)
	
	
	
func increase_inventroy_size():
	inventory_update.emit()


func set_player_reference(player):
	player_node = player
