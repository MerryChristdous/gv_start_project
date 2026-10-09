extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var hotbar_container: HBoxContainer = $HotbarContainer




# 这个数组现在用来存放快捷栏格子的引用（方便快捷键操作）
var hotbar_slots: Array = []

func _ready() -> void:
	# 先创建所有格子（只创建一次）
	_create_all_slots()
	
	# 连接库存更新信号
	Inventory.inventory_update.connect(_on_inventory_update)
	
	# 初始填充数据
	_on_inventory_update()

# ============================================
# 创建所有格子（只在 _ready 里调用一次）
# ============================================
func _create_all_slots() -> void:
	# ----- 创建背包格子（30个）-----
	for i in range(Inventory.inventory.size()):
		var slot = Inventory.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
	
	# ----- 创建快捷栏格子（hotbar_size 个）-----
	# 先清空 hotbar_slots 数组
	hotbar_slots.clear()
	
	# 如果快捷栏容器里已经有子节点（比如在编辑器里手动放的），先清掉
	for child in hotbar_container.get_children():
		hotbar_container.remove_child(child)
		child.queue_free()
	
	# 动态创建指定数量的快捷栏格子
	for i in range(Inventory.hotbar_size):
		var slot = Inventory.inventory_slot_scene.instantiate()
		hotbar_container.add_child(slot)
		hotbar_slots.append(slot)  # 存入数组，方便快捷键操作

# ============================================
# 库存更新时：只刷新数据，不重建格子
# ============================================
func _on_inventory_update() -> void:
	# ----- 刷新背包格子（全部）-----
	var grid_slots = grid_container.get_children()
	for i in range(grid_slots.size()):
		var slot = grid_slots[i]
		var item_data = Inventory.inventory[i] if i < Inventory.inventory.size() else null
		
		if item_data != null:
			slot.set_item(item_data, i)  # 传入索引，方便点击时知道是第几格
		else:
			slot.set_empty(i)
	
	# ----- 刷新快捷栏格子（只刷新前 hotbar_size 个）-----
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i]
		var item_data = Inventory.inventory[i] if i < Inventory.inventory.size() else null
		
		if item_data != null:
			slot.set_item(item_data, i)
		else:
			slot.set_empty()
			
			
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key_index = event.keycode - KEY_1
		if key_index >= 0 and key_index < hotbar_slots.size():
			var slot = hotbar_slots[key_index]
			if slot.item != null and slot.slot_index != -1:
				# 使用物品
				pass
