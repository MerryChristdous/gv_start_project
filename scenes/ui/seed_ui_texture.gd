extends Control

var seed_enum: Enum.Seed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(new_seed_enum: Enum.Seed, main_texture: Texture2D):
	seed_enum = new_seed_enum
	$TextureRect.texture = main_texture
	
func highlight(selected: bool):
	var tween = create_tween()
	var target_size = Vector2(20, 20) if selected else Vector2(16, 16)
	tween.tween_property($TextureRect, "custom_minimum_size", target_size, 0.1)
