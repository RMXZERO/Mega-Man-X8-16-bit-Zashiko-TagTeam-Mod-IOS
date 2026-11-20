extends Node2D

export var alia: bool = false

signal initialize
signal reset
signal start
signal flash
signal weapon_defined(weapon)


func _ready() -> void :
	Tools.timer(0.2, "initialize", self)
	if alia:
		$Armor/Alia.visible = true
		$Armor/Cannon.self_modulate = Color(1, 1, 1, 0)
		$Armor/FrontBShoulder.self_modulate = Color(1, 1, 1, 0)
		$Armor/FrontShoulder.self_modulate = Color(1, 1, 1, 0)
		$Armor/FrontArm.self_modulate = Color(1, 1, 1, 0)
		$Armor/Protector.self_modulate = Color(1, 1, 1, 0)
		$Armor/Head.self_modulate = Color(1, 1, 1, 0)
		$Armor/FrontShoulderBack.self_modulate = Color(1, 1, 1, 0)
		$Armor/Chest.self_modulate = Color(1, 1, 1, 0)
		$Armor/Hand.self_modulate = Color(1, 1, 1, 0)
		$Armor/BackBShoulder.self_modulate = Color(1, 1, 1, 0)
		$Armor/BackShoulder.self_modulate = Color(1, 1, 1, 0)
		$Armor/BackArm.self_modulate = Color(1, 1, 1, 0)
		$Armor/FrontFoot.self_modulate = Color(1, 1, 1, 0)
		$Armor/FrontLeg.self_modulate = Color(1, 1, 1, 0)
		$Armor/BackFoot.self_modulate = Color(1, 1, 1, 0)
		$Armor/BackLeg.self_modulate = Color(1, 1, 1, 0)
		$Armor/Ultimate.self_modulate = Color(1, 1, 1, 0)
		$Armor/Infinite.self_modulate = Color(1, 1, 1, 0)

func initialize() -> void :
	emit_signal("initialize")
	reset()
	Tools.timer(6.5, "start", self, null, true)
	Tools.timer(8.2, "flash", self, null, true)

func reset() -> void :
	emit_signal("reset")

func start() -> void :
	emit_signal("start")

func flash() -> void :
	emit_signal("flash")
	GameManager.pause("weapon_get")

func _on_Armor_defined_weapon(weapon) -> void :
	emit_signal("weapon_defined", weapon)
