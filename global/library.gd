extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
#把位置转换为网格坐标	
func position_to_gird(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / Data.TILE_SIZE), floor(pos.y / Data.TILE_SIZE))

func print_func():
	print(get_stack()[1]["function"])
