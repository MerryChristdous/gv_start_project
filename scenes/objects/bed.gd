extends StaticBody2D

func interact(_player: Player):
	_player.day_change.emit()
