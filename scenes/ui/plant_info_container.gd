extends Control

func add_plant_info(new_plant_info: PanelContainer):
	$MarginContainer/ScrollContainer/VBoxContainer.add_child(new_plant_info)
	

	

func update_plants_info():
	for plant_info in $MarginContainer/ScrollContainer/VBoxContainer.get_children():
		plant_info.update()
