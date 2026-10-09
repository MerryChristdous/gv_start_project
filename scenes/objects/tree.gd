extends StaticBody2D

const apple_texture = preload("res://graphics/plants/apple.png")
var stump_sence = preload("res://scenes/objects/stump.tscn")

@onready var sprite_2d: Sprite2D = $ShakeSprite2D
@onready var shake_material = sprite_2d.material
@export var max_health := 3
var current_health = max_health

func _ready() -> void:
	$HurtComponent.on_hurt.connect(_on_hurt)
	create_apples(randi_range(1, 3))
	$ShakeSprite2D.frame = [0,1].pick_random()

#生成苹果
func create_apples(num: int) -> void:
	var apple_makers = $AppleSpawnPositions.get_children().duplicate(true)
	for i in num:
		var pos_maker : Marker2D = apple_makers.pop_at(randi_range(0, apple_makers.size() -1))
		var apple_sprite = Sprite2D.new()
		apple_sprite.texture = apple_texture
		apple_sprite.position = pos_maker.position
		$Apples.add_child(apple_sprite)
		
func get_apple() -> void:
	if $Apples.get_children():
		$Apples.get_children().pick_random().queue_free()
	
func _on_hurt(hit_component: HitComponent) -> void:
	shake_material.set_shader_parameter("shake_intensity", 1)
	get_apple()
	current_health -= hit_component.damage
	if current_health <= 0:
		_death()
		return
	await get_tree().create_timer(0.2).timeout
	shake_material.set_shader_parameter("shake_intensity", 0)

func _death():
	var stump = stump_sence.instantiate()
	stump.position = position
	get_parent().add_child(stump)
	queue_free()
	
func reset():
	for apple in $Apples.get_children():
		apple.queue_free()
	create_apples(randi_range(1, 3))
	current_health = max_health
