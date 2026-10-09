extends StaticBody2D

func interact(_player: Player):
	$AnimatedSprite2D.play("rain" if Data.forecast_rain else "sun")
	$Timer.start()

func _on_timer_timeout() -> void:
	$AnimatedSprite2D.play("default")
