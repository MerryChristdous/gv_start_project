class_name HurtComponent extends Area2D

signal on_hurt(hit_component: HitComponent)

func _ready() -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	print("_on_area_entered")
	if area is not HitComponent:
		return
	on_hurt.emit(area)
	

func _on_area_exited(area: Area2D) -> void:
	print("_on_area_exited")
