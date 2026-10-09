extends StaticBody2D

@export var res: PlantResource
var coord: Vector2i
signal plant_death(coord: Vector2i)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(grid_coord: Vector2i, parent: Node2D, new_res: PlantResource, plant_death_func) -> void:
	position = Vector2(grid_coord.x + 0.5, grid_coord.y + 0.5) * Data.TILE_SIZE
	parent.add_child(self)
	coord = grid_coord
	res = new_res
	$ShakeSprite2D.texture = res.plant_texture
	plant_death.connect(plant_death_func)

func grow(watered: bool) -> void:
	if watered:
		res.grow($ShakeSprite2D)
	else:
		res.decay(self)
		
func death():
	plant_death.emit(coord)
	
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if res.get_complete():
		res.plant_remove.emit()
		$ShakeSprite2D.shake(0, 0.1, 0.3, death)
		
		
