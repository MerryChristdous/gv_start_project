class_name PlantResource extends Resource

@export var plant_texture: Texture2D
@export var icon_texture: Texture2D
@export var grow_speed : float = 1.0
@export var plant_health : int = 3
@export var h_frames: int = 3
@export var death_max: int = 3
@export var name: String

var age : float
var death_count: int
signal plant_remove

func setup(seed_enum : Enum.Seed):
	#textexture 是 String（文件路径字符串），需要 load() 转换为 Texture2D 资源。
	plant_texture = load(Data.PLANT_DATA[seed_enum]['texture'])
	icon_texture = load(Data.PLANT_DATA[seed_enum]['icon_texture'])
	#grow_speed 是 float（数值），直接赋值即可。
	grow_speed = Data.PLANT_DATA[seed_enum]['grow_speed']
	h_frames = Data.PLANT_DATA[seed_enum]['h_frames']
	death_max = Data.PLANT_DATA[seed_enum]['death_max']
	name = Data.PLANT_DATA[seed_enum]['name']

func grow(plant_sprite: Sprite2D):
	age = min(age + grow_speed, h_frames)
	plant_sprite.frame = int(age)
	death_count = 0
	

func decay(plant: StaticBody2D):
	death_count += 1
	if death_count >= death_max:
		plant.death()
		plant_remove.emit()
		
		
func get_complete() -> bool:
	return age == h_frames
