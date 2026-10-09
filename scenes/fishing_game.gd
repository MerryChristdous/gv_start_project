extends Node2D

const BITE_TIME_MIN: float = 3.0      # 最短上钩时间
const BITE_TIME_MAX: float = 5.0      # 最长上钩时间
const ESCAPE_TIME: float = 1.5        # 逃脱倒计时（秒）

const FISH_TEXTURES = [
	preload("res://graphics/icons/goldfish.png"),
	preload("res://graphics/icons/grayfish.png"),
	preload("res://graphics/icons/silverfish.png"),
]


var move_distance: float = 20.0   # 向上移动距离
var move_duration: float = 1.0    # 总时长
var start_alpha: float = 1.0       # 初始透明度
var end_alpha: float = 0.0         # 结束透明度



var is_fishing: bool
var has_bite: bool
var caught_fish: bool

func reset_bite_timer():
	$BiteTimer.wait_time = randf_range(BITE_TIME_MIN , BITE_TIME_MAX)
	$BiteTimer.start()
	$EscapeTimer.wait_time = ESCAPE_TIME

func start_fishing():
	reset_bite_timer()
	has_bite = false
	
func end_fishing():
	$BiteTimer.stop()
	$EscapeTimer.stop()
	if has_bite:
		get_fish()
		
func get_fish():
	
	$Control/FishBiteTip.hide()
	
	$Control/FishTexture.texture = FISH_TEXTURES.pick_random()
	var fish_size = randf_range(0.5, 1.0)
	$Control/FishTexture.scale = Vector2(fish_size,fish_size)
	$Control/FishTexture.show()
		
	# 重置位置和透明度

	$Control/FishTexture.modulate.a = start_alpha
	$Control/FishTexture.position = Vector2.ZERO
	
	# ✅ 使用 Tween 同时移动和淡出
	var tween = create_tween()
	
	# 并行执行：移动 + 淡出
	tween.set_parallel(true)
	
	# 向上移动
	tween.tween_property($Control/FishTexture, "position:y", position.y - move_distance, move_duration)
	
	# 淡出
	tween.tween_property($Control/FishTexture, "modulate:a", end_alpha, move_duration)
	
	# 完成后自动移除
	#tween.tween_callback(queue_free)

	

func _on_bite_timer_timeout() -> void:
	has_bite = true
	$Control/FishBiteTip.show()
	$EscapeTimer.start()

func _on_escape_timer_timeout() -> void:
	$Control/FishBiteTip.hide()
	has_bite = false
	reset_bite_timer()
	
