extends Control

# tool ui textures
const TOOL_TEXTURES = {
	Enum.Tool.AXE: preload("res://graphics/icons/axe.png"),
	Enum.Tool.HOE: preload("res://graphics/icons/hoe.png"),
	Enum.Tool.WATER: preload("res://graphics/icons/water.png"),
	Enum.Tool.SWORD: preload("res://graphics/icons/sword.png"),
	Enum.Tool.FISH: preload("res://graphics/icons/fish.png"),
	Enum.Tool.SEED: preload("res://graphics/icons/wheat.png"),}
	
const SEED_TEXTURES = {
	Enum.Seed.CORN: preload("res://graphics/icons/corn.png"),
	Enum.Seed.PUMPKIN: preload("res://graphics/icons/pumpkin.png"),
	Enum.Seed.TOMATO: preload("res://graphics/icons/tomato.png"),
	Enum.Seed.WHEAT: preload("res://graphics/icons/wheat.png")}

var tool_texture_scene = preload("res://scenes/ui/tool_ui_texture.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_setup(Enum.Tool.values(), TOOL_TEXTURES, $ToolContainer)
	texture_setup(Enum.Seed.values(), SEED_TEXTURES, $SeedContainer)


func texture_setup(enum_list: Array, textures: Dictionary, containe: HBoxContainer) -> void:
	for enum_id in enum_list:
		var tool_texture = tool_texture_scene.instantiate()
		tool_texture.setup(enum_id,enum_id, textures[enum_id])
		containe.add_child(tool_texture)

func update_current_tool(target_cool: Enum.Tool):
	for texture in $ToolContainer.get_children():
		texture.highlight(target_cool == texture.tool_enum)
	$SeedContainer.set_visible(target_cool == Enum.Tool.SEED)
		
func update_current_seed(target_seed: Enum.Seed):
	
	for texture in $SeedContainer.get_children():
		texture.highlight(target_seed == texture.seed_enum)


	
	
