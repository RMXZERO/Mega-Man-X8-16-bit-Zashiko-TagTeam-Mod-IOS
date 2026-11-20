extends BossDeath
class_name TeamBossDeath

export var team_death_dialogue : Resource
var use_death_dialogue: bool = false
var end_death_dialog: bool = false

export var use_reploid_death: bool = true
onready var nothing: Texture = preload("res://System/Android/Sprites/android_nothing.png")
onready var blue_screen: Texture = preload("res://src/Effects/Textures/blue_screen.png")
var explosion: bool = true
var not_self_end: bool = false
var already_end: bool = false
var team_boss_name = null
var team_boss_name2 = null
var team_boss_name3 = null
var team_boss_name4 = null
var team_boss_name5 = null
var team_boss_name6 = null
var team_boss_name7 = null
var team_boss_name8 = null
var team_boss_name9 = null

func _ready() -> void :
	._ready()
	not_self_end = false
	end_death_dialog = false
	explosion = true
	team_death_dialogue = CharacterManager._set_correct_dialogues(character.name + "_TeamBossDefeated", team_death_dialogue)
	Event.listen("is_boss_2", self, "have_boss_2")
	Event.listen("boss_2_death", self, "team_boss_is_death")
	Event.listen("character_switch_end", self, "refresh_team_death_dialogue")
	background.texture = nothing

func refresh_team_death_dialogue() -> void :
	team_death_dialogue = CharacterManager._set_correct_dialogues(character.name + "_TeamBossDefeated", team_death_dialogue)

func have_boss_2(boss_name) -> void :
	if team_boss_name8 != null and team_boss_name9 == null:
		team_boss_name9 = boss_name
		not_self_end = true
	if team_boss_name7 != null and team_boss_name8 == null:
		team_boss_name8 = boss_name
		not_self_end = true
	if team_boss_name6 != null and team_boss_name7 == null:
		team_boss_name7 = boss_name
		not_self_end = true
	if team_boss_name5 != null and team_boss_name6 == null:
		team_boss_name6 = boss_name
		not_self_end = true
	if team_boss_name4 != null and team_boss_name5 == null:
		team_boss_name5 = boss_name
		not_self_end = true
	if team_boss_name3 != null and team_boss_name4 == null:
		team_boss_name4 = boss_name
		not_self_end = true
	if team_boss_name2 != null and team_boss_name3 == null:
		team_boss_name3 = boss_name
		not_self_end = true
	if team_boss_name != null and team_boss_name2 == null:
		team_boss_name2 = boss_name
		not_self_end = true
	if team_boss_name == null:
		team_boss_name = boss_name
		not_self_end = true

func team_boss_is_death(boss_name) -> void :
	if boss_name == team_boss_name9:
		team_boss_name9 = null
	if boss_name == team_boss_name8:
		team_boss_name8 = null
	if boss_name == team_boss_name7:
		team_boss_name7 = null
	if boss_name == team_boss_name6:
		team_boss_name6 = null
	if boss_name == team_boss_name5:
		team_boss_name5 = null
	if boss_name == team_boss_name4:
		team_boss_name4 = null
	if boss_name == team_boss_name3:
		team_boss_name3 = null
	if boss_name == team_boss_name2:
		team_boss_name2 = null
	if boss_name == team_boss_name:
		team_boss_name = null
	is_self_end()
		
func is_self_end() -> void :
	if team_boss_name == null \
	and team_boss_name2 == null \
	and team_boss_name3 == null \
	and team_boss_name4 == null \
	and team_boss_name5 == null \
	and team_boss_name6 == null \
	and team_boss_name7 == null \
	and team_boss_name8 == null \
	and team_boss_name9 == null:
		not_self_end = false
		if CharacterManager.fight_boss_2:
			use_death_dialogue = true

func _Setup():
	Event.emit_signal("boss_2_death", character.name)
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	animate_boss_or_reploid()
	is_self_end()
	Event.emit_signal("enemy_kill", "boss")
	if not not_self_end:
		GameManager.start_end_cutscene()
	character.emit_signal("death")
	if pause_animation:
		sprite.playing = false
	else:
		sprite.pause_mode = Node.PAUSE_MODE_PROCESS
		pass
	touch_damage.active = false
	elapsed_explosion_time = 0.0
	background.scale.x = 100
	background.scale.y = 40
	if not not_self_end:
		GameManager.pause(character.name + name)
	freeze_moment = OS.get_ticks_msec()
	if not_self_end:
		background.texture = nothing
		already_end = true
	else:
		background.texture = blue_screen
	if not not_self_end and use_death_dialogue and CharacterManager.fight_boss_2 and team_death_dialogue != null and not seen_team_boss_dialog():
		team_boss_death_dialogue()

func _Update(_delta: float):
	delta = _delta
	
	if not explosion:
		elapsed_explosion_time = 0.0
		elapsed_alpha_time = 0.0
		elapsed_color_time = 0.0
		
	if character.get_node("animatedSprite").animation != death_animation and death_animation != "":
		character.get_node("animatedSprite").animation = death_animation
		character.play_animation(death_animation)
	
	if tempo > 0:
		elapsed_explosion_time += _delta
		
	if tempo == 1:
		if not already_end:
			set_background_alpha(tween_alpha(0.75, 5))
	
	if tempo == 2:
		if not already_end:
			tempo_change()
	if tempo == 3:
		if not already_end:
			darken -= _delta / 8
			sprite.material.set_shader_param("Darken", darken)
			set_background_color(tween_color(1, 7))

	if tempo == 4:
		if not already_end:
			tempo_change()
	if tempo == 5:
		if not already_end:
			set_background_color(tween_color(2))
			set_background_alpha(tween_alpha(1))
			darken -= _delta / 2
			sprite.material.set_shader_param("Darken", darken)
		
	if tempo == 6:
		if not emitted_fading_signal:
			emit_signal("start_fade")
			emitted_fading_signal = true
			background_alpha = 1
			
		if not already_end:
			sprite_alpha -= _delta / 4.5
			sprite.material.set_shader_param("Alpha", sprite_alpha)
		
	if not already_end:
		if sprite.material.get_shader_param("Alpha") <= 0.35:
			smoke.emitting = false
	
	
	if is_explosion_time_over():
		smoke.emitting = false
		if not already_end:
			emit_flash_signals()
		end_explosion(_delta)

func end_explosion(_delta):
	background.scale.x = 400
	background.scale.y = 160
	explosions.emitting = false
	sprite.visible = false
	reploid.visible = false
	if not already_end:
		background_alpha -= _delta / 1.7
		set_background_alpha(background_alpha)

func animate_boss_or_reploid() -> void :
	if death_animation != "":
		character.play_animation(death_animation)
	if use_reploid_death:
		if force_reploid_death or collectible in GameManager.collectibles:
			reploid.visible = true
			reploid.playing = true
			reploid.scale.x = sprite.scale.x
			character.animatedSprite.visible = false
			transform_audio.play()

func Initialize() -> void :
	executing = true
	timer = 0
	last_time_used = get_time()
	character.executing_moves.append(self)
	if not not_self_end:
		emit_signal("executed")

func _Interrupt():
	if not not_self_end and not already_end:
		GameManager.end_boss_death_cutscene()
	elapsed_explosion_time = 0.0
	elapsed_alpha_time = 0.0
	elapsed_color_time = 0.0
	tempo = 0
	darken = 1
	sprite_alpha = 1
	freeze_over = false
	explosion_over = false
	collectible()
	achievement_check()
	add_weapon_to_savedata()
	if defeated_flag != "none":
		GlobalVariables.add(defeated_flag, "defeated")
	Event.emit_signal("boss_2_death", null)
	get_parent().queue_free()

func team_boss_death_dialogue() -> void:
	loop_explosion_sound()
	GameManager.start_cutscene()
	GameManager.start_dialog(team_death_dialogue)
	GameManager.dialog_box.connect("dialog_concluded", self, "resume_boss_death")
	if is_instance_valid(GameManager.player):
		GameManager.player.get_node("animatedSprite").get_node("Talk").connect_talking()

func loop_explosion_sound() -> void:
	if not end_death_dialog:
		explosion = false
		$audioStreamPlayer2D.play()
		Tools.timer(10, "loop_explosion_sound", self)

func resume_boss_death() -> void:
	explosion = true
	end_death_dialog = true
	$audioStreamPlayer2D.play()
	GameManager.dialog_box.disconnect("dialog_concluded", self, "resume_boss_death")
	if is_instance_valid(GameManager.player):
		GameManager.player.get_node("animatedSprite").get_node("Talk").disconnect_talking()

func seen_team_boss_dialog() -> bool:
	return GameManager.was_dialogue_seen(team_death_dialogue)

func collectible():
	pass

func achievement_check() -> void :
	pass
