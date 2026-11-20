extends Node2D

var timer := 0.0
onready var boss_bar = $"Boss Bar"
onready var boss_hp: TextureProgress = $"Boss Bar/textureProgress"
onready var boss_hp_2: TextureProgress = $"Boss Bar/textureProgress2"
onready var boss_hp_3: TextureProgress = $"Boss Bar/textureProgress3"
onready var boss_steal: TextureProgress = $"Boss Bar/texturesteal"
onready var boss_steal_2: TextureProgress = $"Boss Bar/texturesteal2"
onready var boss_steal_3: TextureProgress = $"Boss Bar/texturesteal3"
onready var boss = get_parent()
onready var bossdeath = get_parent().get_node("BossDeath")
onready var hpsprite = $"."

export var have_2_bar: bool = false
export var have_3_bar: bool = false
var camera_position: Vector2
var boss_hp_filled := false
var boss_filling_hp := 0
var boss_2: bool = false
var set_new_position = 0
var self_int = 0
var alive_boss = 0
var death_boss = 0

var team_boss_name_death: bool = false
var team_boss_name2_death: bool = false
var team_boss_name3_death: bool = false
var team_boss_name4_death: bool = false
var team_boss_name5_death: bool = false
var team_boss_name6_death: bool = false
var team_boss_name7_death: bool = false
var team_boss_name8_death: bool = false
var team_boss_name9_death: bool = false

func _ready() -> void:
	Event.listen("is_boss_2", self, "boss_is_2")
	Event.listen("boss_2_death", self, "team_boss_is_death")
	boss_2 = false
	boss_bar.visible = false
	boss_hp_filled = false
	boss_filling_hp = 0
	
	alive_boss = 0
	death_boss = 0
	team_boss_name_death = true
	team_boss_name2_death = true
	team_boss_name3_death = true
	team_boss_name4_death = true
	team_boss_name5_death = true
	team_boss_name6_death = true
	team_boss_name7_death = true
	team_boss_name8_death = true
	team_boss_name9_death = true

func boss_is_2(boss_name) -> void:
	yield(get_tree().create_timer(0.001), "timeout")
	if boss_name == boss.name:
		boss_2 = true
		setup_boss_health()
	if bossdeath.team_boss_name != null:
		team_boss_name_death = false
	if bossdeath.team_boss_name2 != null:
		team_boss_name2_death = false
	if bossdeath.team_boss_name3 != null:
		team_boss_name3_death = false
	if bossdeath.team_boss_name4 != null:
		team_boss_name4_death = false
	if bossdeath.team_boss_name5 != null:
		team_boss_name5_death = false
	if bossdeath.team_boss_name6 != null:
		team_boss_name6_death = false
	if bossdeath.team_boss_name7 != null:
		team_boss_name7_death = false
	if bossdeath.team_boss_name8 != null:
		team_boss_name8_death = false
	if bossdeath.team_boss_name9 != null:
		team_boss_name9_death = false
	set_self_int()

func team_boss_is_death(boss_name) -> void :
	yield(get_tree().create_timer(0.001), "timeout")
	if bossdeath.team_boss_name == null and not team_boss_name_death:
		team_boss_name_death = true
	if bossdeath.team_boss_name2 == null and not team_boss_name2_death:
		team_boss_name2_death = true
	if bossdeath.team_boss_name3 == null and not team_boss_name3_death:
		team_boss_name3_death = true
	if bossdeath.team_boss_name4 == null and not team_boss_name4_death:
		team_boss_name4_death = true
	if bossdeath.team_boss_name5 == null and not team_boss_name5_death:
		team_boss_name5_death = true
	if bossdeath.team_boss_name6 == null and not team_boss_name6_death:
		team_boss_name6_death = true
	if bossdeath.team_boss_name7 == null and not team_boss_name7_death:
		team_boss_name7_death = true
	if bossdeath.team_boss_name8 == null and not team_boss_name8_death:
		team_boss_name8_death = true
	if bossdeath.team_boss_name9 == null and not team_boss_name9_death:
		team_boss_name9_death = true
	reset_self_int(boss_name)

func set_self_int() -> void :
	if bossdeath.team_boss_name == boss.name:
		self_int = 0
	if bossdeath.team_boss_name2 == boss.name:
		self_int = 1
	if bossdeath.team_boss_name3 == boss.name:
		self_int = 2
	if bossdeath.team_boss_name4 == boss.name:
		self_int = 3
	if bossdeath.team_boss_name5 == boss.name:
		self_int = 4
	if bossdeath.team_boss_name6 == boss.name:
		self_int = 5
	if bossdeath.team_boss_name7 == boss.name:
		self_int = 6
	if bossdeath.team_boss_name8 == boss.name:
		self_int = 7
	if bossdeath.team_boss_name9 == boss.name:
		self_int = 8
	set_boss_bar_position()

func reset_self_int(boss_name) -> void :
	if not boss_name == null:
		return
	if boss_name == null:
		death_boss += 1
	if self_int == 0:
		pass
	if self_int == 1:
		if bossdeath.team_boss_name == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 2:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 3:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null \
		or bossdeath.team_boss_name3 == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 4:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null \
		or bossdeath.team_boss_name3 == null \
		or bossdeath.team_boss_name4 == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 5:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null \
		or bossdeath.team_boss_name3 == null \
		or bossdeath.team_boss_name4 == null \
		or bossdeath.team_boss_name5 == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 6:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null \
		or bossdeath.team_boss_name3 == null \
		or bossdeath.team_boss_name4 == null \
		or bossdeath.team_boss_name5 == null \
		or bossdeath.team_boss_name6 == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 7:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null \
		or bossdeath.team_boss_name3 == null \
		or bossdeath.team_boss_name4 == null \
		or bossdeath.team_boss_name5 == null \
		or bossdeath.team_boss_name6 == null \
		or bossdeath.team_boss_name7 == null:
			self_int -= 1
			set_boss_bar_position()
			return
	elif self_int == 8:
		if bossdeath.team_boss_name == null \
		or bossdeath.team_boss_name2 == null \
		or bossdeath.team_boss_name3 == null \
		or bossdeath.team_boss_name4 == null \
		or bossdeath.team_boss_name5 == null \
		or bossdeath.team_boss_name6 == null \
		or bossdeath.team_boss_name7 == null \
		or bossdeath.team_boss_name8 == null:
			self_int -= 1
			set_boss_bar_position()
			return

func check_for_alive_boss() -> void :
	alive_boss = 0
	if bossdeath.team_boss_name9 != null:
		alive_boss += 1
	if bossdeath.team_boss_name8 != null:
		alive_boss += 1
	if bossdeath.team_boss_name7 != null:
		alive_boss += 1
	if bossdeath.team_boss_name6 != null:
		alive_boss += 1
	if bossdeath.team_boss_name5 != null:
		alive_boss += 1
	if bossdeath.team_boss_name4 != null:
		alive_boss += 1
	if bossdeath.team_boss_name3 != null:
		alive_boss += 1
	if bossdeath.team_boss_name2 != null:
		alive_boss += 1
	if bossdeath.team_boss_name != null:
		alive_boss += 1

func set_boss_bar_position() -> void :
	set_new_position = self_int * 16
	boss_bar.fading_out_postion = set_new_position

func _process(_delta: float) -> void:
	show_boss_health_and_weapon(_delta)
	timer += _delta
	camera_position = GameManager.camera.get_camera_screen_center()
	hpsprite.position.x = camera_position.x - boss.global_position.x - set_new_position
	hpsprite.position.y = camera_position.y - boss.global_position.y

func setup_boss_health() -> void:
	boss.get_node("Damage").connect("took_damage",boss_bar,"blink")

func show_boss_health_and_weapon(_delta) -> void:
	if boss_2:
		boss_bar.visible = true
		if not boss_hp_filled:
			fill_boss_hp(_delta)
		else:
			if have_3_bar:
				if boss.current_health < boss.max_health * 1/3:
					boss_hp.value = ceil((boss.current_health * 64)/ (boss.max_health) * 3)
					boss_hp_2.visible = false
					boss_hp_3.visible = false
					
					boss_steal_2.visible = false
					boss_steal_3.visible = false
				elif boss.current_health > boss.max_health * 1/3 and boss.current_health < boss.max_health * 2/3:
					boss_hp.value = 64
					boss_hp_2.value = ceil((boss.current_health * 64 - boss.max_health * 64*1/3)/ (boss.max_health) * 3)
					boss_hp_2.visible = true
					boss_hp_3.visible = false
					
					boss_steal_2.visible = boss_steal.visible
					boss_steal_3.visible = false
				elif boss.current_health > boss.max_health * 2/3:
					boss_hp.value = 64
					boss_hp_2.value = 64
					boss_hp_3.value = ceil((boss.current_health * 64 - boss.max_health * 64*2/3)/ (boss.max_health) * 3)
					boss_hp_2.visible = true
					boss_hp_3.visible = true
					
					boss_steal_2.visible = false
					boss_steal_3.visible = boss_steal.visible
			elif have_2_bar:
				if boss.current_health < boss.max_health * 1/2:
					boss_hp.value = ceil((boss.current_health * 64)/ (boss.max_health) * 2)
					boss_hp_2.visible = false
					boss_hp_3.visible = false
					
					boss_steal_2.visible = false
					boss_steal_3.visible = false
				elif boss.current_health > boss.max_health * 1/2:
					boss_hp.value = 64
					boss_hp_2.value = ceil((boss.current_health * 64 - boss.max_health * 64*1/2)/ (boss.max_health) * 2)
					boss_hp_2.visible = true
					boss_hp_3.visible = false
					
					boss_steal_2.visible = boss_steal.visible
					boss_steal_3.visible = false
			else:
				boss_hp.value = ceil((boss.current_health * 64)/ boss.max_health)
				boss_hp_2.visible = false
				boss_hp_3.visible = false
				
				boss_steal_2.visible = false
				boss_steal_3.visible = false
			if boss_hp.value <= 1 and boss.current_health > 1:
				boss_hp.value = 2

func fill_boss_hp(_delta):
	if boss_filling_hp <= 64:
		boss_hp.value = boss_filling_hp
	else:
		boss_hp.value = 64
	
	if have_3_bar:
		if boss_filling_hp - 64 > 0:
			boss_hp_2.visible = true
			boss_hp_2.value = boss_filling_hp - 64
		else:
			boss_hp_2.visible = false
			boss_hp_2.value = 0
		if boss_filling_hp - 128 > 0:
			boss_hp_3.visible = true
			boss_hp_3.value = boss_filling_hp - 128
		else:
			boss_hp_3.visible = false
			boss_hp_3.value = 0
	elif have_2_bar:
		if boss_filling_hp - 64 > 0:
			boss_hp_2.visible = true
			boss_hp_2.value = boss_filling_hp - 64
		else:
			boss_hp_2.visible = false
			boss_hp_2.value = 0
		boss_hp_3.visible = false
	else:
		boss_hp_2.visible = false
		boss_hp_3.visible = false
	
	if have_3_bar:
		if timer > 0.005:
			boss_filling_hp += 1
			$audioStreamPlayer.volume_db = -18
			$audioStreamPlayer.play()
			timer = 0
	elif have_2_bar:
		if timer > 0.01:
			boss_filling_hp += 1
			$audioStreamPlayer.volume_db = -18
			$audioStreamPlayer.play()
			timer = 0
	else:
		if timer > 0.015:
			boss_filling_hp += 1
			$audioStreamPlayer.volume_db = -18
			$audioStreamPlayer.play()
			timer = 0
	
	if boss_filling_hp >= 64:
		if have_3_bar:
			if boss_filling_hp >= 192:
				boss_hp_filled = true
		elif have_2_bar:
			if boss_filling_hp >= 128:
				boss_hp_filled = true
		else:
			boss_hp_filled = true

