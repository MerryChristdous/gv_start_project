extends Control


@onready var item_icon: TextureRect = $InnerBorder/ItemIcon
@onready var item_quantity: Label = $InnerBorder/ItemQuantity
@onready var details_panel: ColorRect = $DetailsPanel
@onready var item_name: Label = $DetailsPanel/ItemName
@onready var item_type: Label = $DetailsPanel/ItemType
@onready var item_effect: Label = $DetailsPanel/ItemEffect
@onready var usage_panel: ColorRect = $UsagePanel

var item = null
var slot_index: int = -1  # 初始值为 -1，由 set_item 赋值

# 拖拽相关
var _drag_data: Dictionary = {}
var _is_dragging: bool = false


func set_empty(index: int = -1):
	# 1. 清空核心数据引用（最重要！）
	item = null
	slot_index = index
	# 2. 清空所有显示控件
	item_icon.texture = null
	item_name.text = ""
	item_quantity.text = ""
	item_type.text = ""
	item_effect.text = ""
	
	 # 3. 隐藏所有面板（关键！）
	details_panel.visible = false
	usage_panel.visible = false

func set_item(new_item, index: int = -1):
	item = new_item
	slot_index = index
	# 使用 .get() 安全访问
	item_icon.texture = new_item.get("texture")
	item_name.text = str(new_item.get("name", ""))
	item_quantity.text = str(new_item.get("quantity", 1))
	item_type.text = str(new_item.get("type", ""))
	var effect = new_item.get("effect", "")
	item_effect.text = effect if effect != "" else ""
	
	
# ============================================
# 其他功能（悬停详情、丢弃按钮）
# ============================================



func _on_item_button_mouse_entered() -> void:
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true


func _on_item_button_mouse_exited() -> void:
	details_panel.visible = false
	
	
func _on_drop_button_pressed() -> void:
	if item != null:
		var drop_position = Inventory.player_node.global_position
		var direction = Inventory.player_node.last_direction
		var drop_offset = direction * 30
		Inventory.drop_item(item, drop_position + drop_offset)
		Inventory.remove_item(item["name"], item["type"])
		usage_panel.visible = false



# ============================================
# 鼠标事件处理（点击 + 拖拽）
# ============================================

func _on_gui_input(event: InputEvent) -> void:
	# --- 左键按下：启动拖拽 ---
	if event is InputEventMouseButton:
		# --- 左键按下 ---
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if item != null and slot_index != -1:
				start_drag()
		# --- 左键松开 ---
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			end_drag()


# ============================================
# 拖拽核心函数
# ============================================

func start_drag():
	_is_dragging = true
	
	# 保存拖拽数据
	_drag_data = {
		"source_index": slot_index,
		"item_data": item.duplicate(true),
		"source_slot": self
	}
	

	
	#force_drag(_drag_data, preview)
	
	# 原格子变半透明（视觉反馈）
	modulate = Color(1, 1, 1, 0.5)
	
	print(" start_drag  实例ID: ", get_instance_id())
	

func end_drag():
	print(" end_drag    实例ID: ", get_instance_id())
	_is_dragging = false
	_drag_data = {}
	# 恢复透明度
	modulate = Color(1, 1, 1, 1)
	
	Library.print_func()
	
# ============================================
# Godot 内置拖拽回调（由引擎自动调用）
# ============================================

# 引擎调用：返回拖拽数据
func _get_drag_data(at_position: Vector2) -> Variant:
	# 创建拖拽预览（幽灵图标）
	var preview = Control.new()
	preview.size = Vector2(64, 64)
	
	var preview_icon = TextureRect.new()
	preview_icon.texture = item.get("texture")
	preview_icon.stretch_mode = TextureRect.STRETCH_SCALE
	preview_icon.size = Vector2(50, 50)
	preview_icon.position = Vector2(4, 4)
	preview.add_child(preview_icon)
	
	# 设置预览并启动拖拽
	set_drag_preview(preview)
	Library.print_func()
	return _drag_data

# 引擎调用：判断能否在目标格子放下
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	
	# 检查数据格式
	if not data.has("source_index") or not data.has("item_data"):
		return false
	
	# 不能放到自己身上
	if data.get("source_slot") == self:
		return false
	

	
	# 检查源索引是否有效
	var source_index = data["source_index"]
	if source_index < 0 or source_index >= Inventory.inventory.size():
		return false
		

	return true

# 引擎调用：执行放下（交换或移动）
func _drop_data(at_position: Vector2, data: Variant) -> void:
	Library.print_func()
	
	var source_index = data["source_index"]
	print(source_index)
	var target_index = self.slot_index
	print(target_index)
	
	# 获取源格子和目标格子的数据
	var source_data = Inventory.inventory[source_index]
	var target_data = Inventory.inventory[target_index]
	
	# 执行交换
	Inventory.inventory[source_index] = target_data
	Inventory.inventory[target_index] = source_data
	
	
	var source_slot = data["source_slot"]
	if source_slot:
		source_slot.end_drag()
	
	
	# 触发 UI 刷新
	Inventory.inventory_update.emit()
	
