@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""

var scene_path: String = "res://scenes/objects/inventory_item.tscn"

# onready关键字可以延迟场景初始化
@onready var icon_sprite: Sprite2D = $Sprite2D
@export var can_pickup: bool = true

var player_in_range = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture


func pickup_item():
	var item = {
		"quantity": 1,
		"type": item_type,
		"name": item_name,
		"texture": item_texture,
		"effect": item_effect,
		"scene_path": scene_path,
	}
	
	if Inventory.player_node:
		var success = Inventory.add_item(item)
		if success:
			self.queue_free()
		else:
			print("❌ 背包已满，无法拾取: ", item_name)

func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_texture = data["texture"]
	item_effect = data["effect"]
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		if can_pickup:
			pickup_item()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
