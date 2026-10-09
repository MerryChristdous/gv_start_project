extends PanelContainer

var res: PlantResource

func setup(new_res: PlantResource):
	res = new_res
	res.plant_remove.connect(queue_free)
	
	$HBoxContainer/IconTexture.texture = new_res.icon_texture
	$HBoxContainer/VBoxContainer/NameLabel.text = res.name
	
	$HBoxContainer/VBoxContainer/GrowthBar.max_value = res.h_frames
	$HBoxContainer/VBoxContainer/DeathBar.max_value = res.death_max
	
	update()
	
func update():
	$HBoxContainer/VBoxContainer/GrowthBar.value = res.age
	$HBoxContainer/VBoxContainer/DeathBar.value = res.death_count

		
