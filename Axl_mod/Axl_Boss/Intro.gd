extends GenericIntro

onready var main = get_parent()

onready var tween: TweenController = TweenController.new(self, false)
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var song: AudioStreamPlayer = $song
onready var song2: AudioStreamPlayer = $song2
onready var dmg: Node2D = $"../Damage"
onready var damage: Node2D = $"../DamageOnTouch"
export  var bar: Texture
export  var bar2: Texture
export  var bar3: Texture
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")
onready var boss_ai = get_parent().get_node("BossAI")
onready var boss_2_bar = get_parent().get_node("HPSprite").get_node("Boss Bar")

var time_offset: float = 0.0
var amplitude: float = 2.0
var speed: float = 0.5
var beam_speed: float = 420
var angry_music: bool = false
var demake_music: bool = false

const sprite_y := -4.0
onready var beam_in: AudioStreamPlayer2D = $beam_in

var beam_in_resets := 0.20
var reset_sprite_pos := -200

func connect_start_events() -> void :
	Event.listen("teleport_to_secretboss", self, "prepare_for_intro")
	Event.listen("end_teleport_to_secretboss", self, "execute_intro")
	
func _ready() -> void :
	call_deferred("prepare_for_intro")
	call_deferred("set_music")
	Event.listen("character_talking", self, "talk")
	call_deferred("play_animation", "beam")
	angry_music = false

func set_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if Configurations.exists("SongRemix"):
			if Configurations.get("SongRemix"):
				if CharacterManager.player_character == "Axl":
					battle_song.stream = remix.no_sound
					battle_song.get_node("loop").stream = remix._lumine1_loop
				elif CharacterManager.player_character == "Zero":
					battle_song.stream = remix.alternate_intro_enhanced
					battle_song.get_node("loop").stream = remix.alternate_loop_enhanced
				else:
					battle_song.stream = remix._boss_intro
					battle_song.get_node("loop").stream = remix._boss_loop
				song.stream = remix._lumine_appears
				song2.stream = remix._boss_demo_demake
				demake_music = true
			else:
				if CharacterManager.player_character == "Axl":
					battle_song.stream = remix.original_lumine_battle_song
					battle_song.get_node("loop").stream = remix.original_lumine_battle_loop
				elif CharacterManager.player_character == "Zero":
					battle_song.stream = remix.alternate_intro_enhanced
					battle_song.get_node("loop").stream = remix.alternate_loop_enhanced
				song.stream = remix._original_lumine_appears
				song2.stream = remix._boss_demo
				demake_music = false
	song.stream.loop = true
	song2.stream.loop = true

func angry_music():
	if not angry_music:
		main.desperation_timer += 1
		angry_music = true
		if CharacterManager.fight_boss_2:
			return
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		battle_song.fade_out()
		battle_song.loop.stream.loop = false
		battle_song.stop()
		if demake_music:
			if main.only_x:
				battle_song.stream = remix._bossangry_intro
				battle_song.get_node("loop").stream = remix._bossangry_loop
			if main.only_zero:
				battle_song.stream = remix.z3_x_vs_zero_intro_enhanced
				battle_song.get_node("loop").stream = remix.z3_x_vs_zero_loop_enhanced
			if main.only_axl:
				battle_song.stream = remix._lumine2_intro
				battle_song.get_node("loop").stream = remix._lumine2_intro
		else:
			if main.only_x:
				battle_song.stream = remix.original_angry_battle_song
				battle_song.get_node("loop").stream = remix.original_angry_battle_loop
			if main.only_zero:
				battle_song.stream = remix.original_x_vs_zero_intro
				battle_song.get_node("loop").stream = remix.original_x_vs_zero_loop
			if main.only_axl:
				battle_song.stream = remix.original_seraph_lumine_battle_song
				battle_song.get_node("loop").stream = remix.original_seraph_lumine_battle_loop
		battle_song.loop.stream.loop = true
		battle_song.play()
		battle_song.fade_in()

func prepare_for_intro() -> void :
	animatedSprite.position = Vector2(0,-256)
	animatedSprite.frame = 0

func beam_in():
	make_visible()
	play_animation("idle")
	tween.create()
	tween.set_sequential()
	while beam_in_resets > 0.0:
		tween.add_attribute("position:y",sprite_y,0.05 + beam_in_resets,animatedSprite)
		tween.add_callback("reset_sprite_to_top")
		beam_in_resets -= .01
	tween.add_attribute("position:y",sprite_y,0.01,animatedSprite)
	tween.callback("attack_stage_5")

func reset_sprite_to_top():
	animatedSprite.position.y = reset_sprite_pos
	reset_sprite_pos += 11
	reset_sprite_pos = clamp(reset_sprite_pos,-200,-1)

func talk(character):
	if executing:
		if character == "Axl_Boss":
			play_animation_once("talk")
		else:
			play_animation_once("idle")

func _Setup():
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	Tools.timer(1.0, "attack_stage_1", self)
	turn_player_towards_boss()
	GameManager.add_collectible_to_savedata("axl_seen")
	if not CharacterManager.fight_boss_2:
		if CharacterManager.player_character == "Axl":
			song.play()
		else:
			if not CharacterManager.player_character == "Zero":
				song2.play()

func attack_stage_1() -> void :
	go_to_attack_stage(1)

func attack_stage_5() -> void :
	go_to_attack_stage(5)

func _Update(delta):
	if attack_stage == 0 and timer > 0.5:
		if main.only_axl:
			set_vertical_speed(200)
	
	elif attack_stage == 1 and timer > 0.5:
		set_vertical_speed(0)
		main.afterimages()
		turn_player_towards_boss()
		turn_and_face_player()
		if not main.only_axl:
			if main.only_zero and not CharacterManager.fight_boss_2:
				battle_song.loop.stream.loop = true
				battle_song.play()
			play_animation_once("beam")
			tween_attribute("position:y", sprite_y, speed, animatedSprite)
			beam_in.play()
			next_attack_stage()
		else:
			play_animation("attack_start")
			beam_in()
			timer = 0
	
	elif attack_stage == 2:
		if animatedSprite.position.y >= -4:
			set_vertical_speed(beam_speed)
			if character.is_on_floor():
				play_animation_again("beam_in")
				next_attack_stage()
	
	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("beam_equip")
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		if not CharacterManager.fight_boss_2:
			play_animation("beam_equip_2")
		if CharacterManager.fight_boss_2:
			play_animation("beam_equip_3")
		next_attack_stage()
		
	elif attack_stage == 5 and has_finished_last_animation():
		if not CharacterManager.fight_boss_2:
			play_animation("idle")
			start_dialog_or_go_to_attack_stage(7)
		if CharacterManager.fight_boss_2:
			if not main.only_axl:
				play_animation("beam_equip_3")
			if CharacterManager.weaponget:
				go_to_attack_stage(7)
		
	elif attack_stage == 6:
		animatedSprite.position.y = -4
		if not CharacterManager.fight_boss_2:
			if seen_dialog():
				next_attack_stage()
		if CharacterManager.fight_boss_2:
			go_to_attack_stage(7)

	elif attack_stage == 7 and timer > 0.6:
		if not main.only_axl:
			play_animation("victory")
		song.stop()
		song2.stop()
		if not CharacterManager.fight_boss_2:
			if not main.only_zero:
				if CharacterManager.game_mode >= 2:
					angry_music()
				else:
					battle_song.loop.stream.loop = true
					battle_song.play()
		next_attack_stage()

	elif attack_stage == 8 and has_finished_last_animation():
		if not CharacterManager.fight_boss_2:
			if main.only_x:
				Event.emit_signal("set_boss_bar", bar2)
			elif main.only_zero:
				Event.emit_signal("set_boss_bar", bar)
			elif main.only_axl:
				Event.emit_signal("set_boss_bar", bar3)
			Event.emit_signal("boss_health_appear", character)
		if CharacterManager.fight_boss_2:
			if main.only_x:
				boss_2_bar.set_boss_bar(bar2)
			elif main.only_zero:
				boss_2_bar.set_boss_bar(bar)
			elif main.only_axl:
				boss_2_bar.set_boss_bar(bar3)
			Event.emit_signal("is_boss_2", character.name)
		if CharacterManager.nightshade_zero_armor:
			character.max_health = 1024
			character.current_health = 1024
		next_attack_stage()

	elif attack_stage == 9 and timer > 1.2:
		character.get_node("Space").define_arena()
		main.land_position = global_position
		EndAbility()
