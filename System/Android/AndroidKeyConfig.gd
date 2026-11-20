extends Area2D

onready var main = $"."
onready var outline = $outline
onready var max_distance = $Deadzone.shape.radius
export  var deadzone = 1

export  var _action: String
export  var _action2: String
export  var _action3: String
export  var config: bool = false
export  var use_action2: bool = false
export  var use_action3: bool = false
var touch_id = null
var dash_jump: bool = false

func _ready():
	if _action2 == "dash":
		Event.listen("gameplay_start", self, "activate")

func activate():
	if is_instance_valid(GameManager.player):
		GameManager.player.connect("land",self,"release_dash")
		GameManager.player.connect("wallslide",self,"release_dash")
		GameManager.player.connect("ride",self,"release_dash")
	if is_instance_valid(GameManager.inactive_player):
		GameManager.inactive_player.connect("land",self,"release_dash")
		GameManager.inactive_player.connect("wallslide",self,"release_dash")
		GameManager.inactive_player.connect("ride",self,"release_dash")

func release_dash():
	if _action2 == "dash" and Input.is_action_pressed("dash") and dash_jump:
		if Configurations.exists("TouchEnable") and Configurations.get("TouchEnable"):
			if is_instance_valid(GameManager.player):
				Input.action_release("dash")
				dash_jump = false

func _input(event):
	if event is InputEventScreenTouch:
		var distance = event.position.distance_to(outline.global_position)
		if event.pressed:
			if config:
				if distance < max_distance and touch_id == null:
					touch_id = event.index
			elif not config:
				if distance < max_distance/5 and touch_id == null:
					touch_id = event.index
					if not config and distance < max_distance/5:
						Input.action_press(_action)
						if use_action2:
							if _action2 == "dash" and Input.is_action_pressed("dash"):
								pass
							else:
								Input.action_press(_action2)
								if _action2 == "dash" and Input.is_action_pressed("dash"):
									dash_jump = true
						if use_action3:
							yield(get_tree().create_timer(0.001), "timeout")
							Input.action_press(_action3)
						self.modulate.a = 0.7
		elif not event.pressed:
			if touch_id == event.index:
				touch_id = null
				if not config and distance < max_distance/5:
					Input.action_release(_action)
					if use_action2:
						if _action2 == "dash" and Input.is_action_pressed("dash"):
							pass
						else:
							Input.action_release(_action2)
					if use_action3:
						Input.action_release(_action3)
					self.modulate.a = 0.5
	elif event is InputEventScreenDrag and touch_id == event.index:
		var distance = event.position.distance_to(outline.global_position)
		if config:
			main.global_position = outline.global_position + (event.position - outline.global_position).clamped(max_distance)




