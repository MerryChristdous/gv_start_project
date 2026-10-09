
extends CharacterBody2D

class_name Player

const SPEED := 100
var direction: Vector2
var last_direction : Vector2
var can_move: bool = true


@onready var animation_tree: AnimationTree = $Animation/AnimationTree
@onready var move_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/ToolStateMachine/playback")
@onready var fish_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/FishStateMachine/playback")

@onready var inventory_ui: CanvasLayer = $InventoryUI
@onready var inventory_hotbar: CanvasLayer = $InventoryHotbar


@export var current_tool: Enum.Tool = Enum.Tool.HOE
var current_seed: Enum.Seed = Enum.Seed.TOMATO
var current_state: Enum.State = Enum.State.DEFAULT:
	set(value):
		current_state = value
		$Label.text = Enum.State.keys()[value]
		
		
@onready var tool_sounds = {
	Enum.Tool.AXE: $Sounds/Axe,
	Enum.Tool.HOE: $Sounds/Hoe,
	Enum.Tool.WATER: $Sounds/Water,
	Enum.Tool.SWORD: $Sounds/Sword,
	Enum.Tool.FISH: $Sounds/Fish,
	Enum.Tool.SEED: $Sounds/Seed,
}
		
		
		

signal tool_use(tool: Enum.Tool, pos: Vector2)
signal day_change

func _ready() -> void:
	Inventory.set_player_reference(self)
	$ToolUI.update_current_tool(current_tool)
	$ToolUI.update_current_seed(current_seed)
# --- 生命周期函数 ---
func _physics_process(delta: float) -> void:
	
		# 1. 读取输入
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
		
	match current_state:
		Enum.State.DEFAULT:
			if can_move:
					#获取停止移动之前的方向，但是只记录一个坐标的上的向量，放置x+y 引起位置偏移
				if direction:
					last_direction = Vector2(sign(direction.x), 0) if abs(direction.x) >= abs(direction.y) else Vector2(0, sign(direction.y))
					$RayCast2D.target_position = last_direction * 20
					
					if $Sounds/StepSoundTimer.is_stopped():
						$Sounds/StepSoundTimer.start()
				else:
					$Sounds/StepSoundTimer.stop()
					
				# 2. 逻辑层：根据当前状态决定行为
				update_player_state(direction, delta)
	
				# 3. 表现层：将逻辑状态同步给动画树（告知动画系统应该播放什么动画）
				update_animation_parameters(direction)
			
		Enum.State.FISHING:
			get_fishing_input()
			
		Enum.State.BUILDING:
			pass
		
		Enum.State.SHOP:
			pass
			
		


	
	
# --- 逻辑层 (Logic Layer) ---
func update_player_state(input_direction: Vector2, _delta: float):
	# 移动逻辑
	velocity = input_direction * SPEED
	move_and_slide()
	get_basic_input()
			


	


# --- 表现层 (Animation Layer) ---
func update_animation_parameters(input_direction: Vector2):
	# 1. 更新混合空间位置（如果当前状态需要移动）
	# 这里的更新频率不依赖于状态，总是保持最新，让动画树自己决定用哪个值
	# 但在状态切换时，应该保证新状态也有正确的 blend_position
	if input_direction != Vector2.ZERO:
		move_state_machine.travel('Walk')
		var direction_animation = Vector2(round(input_direction.x),round(input_direction.y))
		# 只在有输入时才更新，避免动画树的 blend_position 突然归零导致视觉抖动
		animation_tree.set("parameters/MoveStateMachine/Idle/blend_position", direction_animation)
		animation_tree.set("parameters/MoveStateMachine/Walk/blend_position", direction_animation)
		animation_tree.set("parameters/FishStateMachine/Fishing/blend_position", direction_animation)
		animation_tree.set("parameters/FishStateMachine/FishEnd/blend_position", direction_animation)
		#更新工具混合动画
		for tool in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = "parameters/ToolStateMachine/"+ tool + "/blend_position"
			animation_tree.set(animation_name, direction_animation)
	else:
		move_state_machine.travel('Idle')
		
func get_basic_input():
	#按下互动键
	if Input.is_action_just_pressed("action"):
		if not $RayCast2D.get_collider():
			tool_state_machine.travel(Data.TOOL_STATE_ANIMATIONS[current_tool])
			animation_tree.set("parameters/ToolOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else: 
			$RayCast2D.get_collider().interact(self)
	#按下工具切换键
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis( "tool_backward", "tool_forward")
		current_tool = posmod(current_tool + int(dir), Enum.Tool.size()) as Enum.Tool
		$ToolUI.update_current_tool(current_tool)
	#按下种子切换键	
	if Input.is_action_just_pressed("seed_forward"):
		if current_tool == Enum.Tool.SEED:
			current_seed = posmod(current_seed + 1, Enum.Seed.size()) as Enum.Seed
			$ToolUI.update_current_seed(current_seed)
	#打开库存UI		
	if Input.is_action_just_pressed("inventory_ui"):
		inventory_ui.visible = !inventory_ui.visible
		inventory_hotbar.visible = !inventory_ui.visible

func _on_animation_tree_animation_started(_anim_name: StringName) -> void:
	can_move = false
	print(_anim_name + "    start   ")
	$Sounds/StepSoundTimer.stop()
func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true
	$HitComponent.position = Vector2(0, 0)
	$HitComponent.deactivate()
	print(_anim_name + "   finished   ")
func tool_use_emit() -> void:
	
	tool_use.emit(current_tool, position + last_direction * 16)
	tool_sounds[current_tool].play()
	match current_tool:
		Enum.Tool.AXE:
			$HitComponent.activate()
			$HitComponent.position = last_direction * 10
			
			
	
func start_fishing():
	current_state = Enum.State.FISHING
	fish_state_machine.travel("Fishing")
	$FishingGame.start_fishing()

	
	$Animation/AnimationTree.set("parameters/FishingBlend/blend_amount", 1)
	
func get_fishing_input():
	if Input.is_action_just_pressed("action"):
		fish_state_machine.travel("FishEnd")
		
		
func fish_end_emit():
	
	$Animation/AnimationTree.set("parameters/FishingBlend/blend_amount", 0)
	current_state = Enum.State.DEFAULT
	$FishingGame.end_fishing()


func _on_step_sound_timer_timeout() -> void:
	$Sounds/Step.play()
