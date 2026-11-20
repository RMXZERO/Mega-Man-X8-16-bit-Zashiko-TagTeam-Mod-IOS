extends Node2D

var show_weapon: bool = false
var fight_lumine: bool = false

func _ready() -> void:
	Event.connect("set_object", self, "set_weapon_position")
	Event.connect("collected_zero_weapon", self, "collect_less_weapon")
	Event.connect("boss_start",self,"on_boss_start")

func collect_less_weapon() -> void:
	if show_weapon:
		visible = false
		if fight_lumine:
			Achievements.unlock("COLLECTSIGMABLADEINFIGHT")
		queue_free()

func on_boss_start(boss) -> void:
	if "Lumine" in boss.name:
		fight_lumine = true

func set_weapon_position(weapon_name, weapon_position, weapon_scale_x) -> void:
	show_weapon = true
	if name == "red_weapon" and name == weapon_name:
		visible = true
		position.x = weapon_position.x
		position.y = weapon_position.y
		scale.x = weapon_scale_x
	if name == "sigma_blade" and name == weapon_name:
		visible = true
		position.x = weapon_position.x
		scale.x = weapon_scale_x
		var sigma_blade = get_parent().get_node_or_null("Sigma-Blade")
		if sigma_blade:
			sigma_blade.position.x = weapon_position.x
			sigma_blade.position.y = position.y -16
			sigma_blade.visible = false
