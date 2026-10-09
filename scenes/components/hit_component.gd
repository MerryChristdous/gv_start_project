class_name HitComponent extends Area2D

@export var damage := 1
var is_active: bool = false

func _ready():
	# 初始禁用
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func activate() -> void:
	if is_active:
		return

	is_active = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	print("攻击检测已开启")

func deactivate() -> void:
	if not is_active:
		return
	
	is_active = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	print("攻击检测已关闭")
