extends GenericIntro

onready var main = get_parent()
onready var boss_2_bar = get_parent().get_node("HPSprite").get_node("Boss Bar")
onready var tween: TweenController = TweenController.new(self, false)
onready var battle_song: AudioStreamPlayer = $BattleSong
export  var bar: Texture
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

onready var sfx_dj_teleport: AudioStreamPlayer = get_parent().get_node("dj_teleport")
onready var sfx_sigma_intro: AudioStreamPlayer = get_parent().get_node("sigma_intro")
onready var cape: AnimatedSprite = animatedSprite.get_node_or_null("capeSprite")

const sprite_y := -4.0

func connect_start_events() -> void :
	Event.listen("teleport_to_dj_sigma", self, "prepare_for_intro")
	Event.listen("end_teleport_to_dj_sigma", self, "execute_intro")
	
func _ready() -> void :
	call_deferred("prepare_for_intro")
	Event.listen("character_talking", self, "talk")

func prepare_for_intro() -> void :
	make_invisible()
	animatedSprite.modulate.r = 0.4
	animatedSprite.modulate.g = 0
	animatedSprite.modulate.b = 0.75

func talk(character):
	if executing:
		if character == "DJSigma":
			play_animation_once("intro_land")
		else:
			play_animation_once("intro_land")

func _Setup():
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false
	make_visible()
	animatedSprite.modulate.r = 0.4
	animatedSprite.modulate.g = 0
	animatedSprite.modulate.b = 0.75
	turn_player_towards_boss()
	play_animation("intro")
	GameManager.add_collectible_to_savedata("dj_sigma_seen")

func _Update(delta):
	if attack_stage == 0:
		turn_player_towards_boss()
		turn_and_face_player()
		sfx_dj_teleport.play()
		next_attack_stage()
		
	if attack_stage == 1:
		if animatedSprite.modulate.r < 1:
			animatedSprite.modulate.r += delta * 0.4
		if animatedSprite.modulate.g < 1:
			animatedSprite.modulate.g += delta * 0.6
		if animatedSprite.modulate.b < 1:
			animatedSprite.modulate.b += delta * 0.2
		if animatedSprite.animation == "intro" and animatedSprite.frame >= 20:
			set_vertical_speed(50)
		if character.is_on_floor():
			play_animation_again("intro_land")
			next_attack_stage()
		
	if attack_stage == 2 and has_finished_last_animation():
		make_visible()
		start_dialog_or_go_to_attack_stage(4)

	if attack_stage == 3:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 4:
		play_animation("intro_finish")
		Event.emit_signal("call_fade_out_battle")
		next_attack_stage()

	elif attack_stage == 5:
		if animatedSprite.animation == "intro_finish" and animatedSprite.frame >= 5:
			cape.visible = true
			cape.position.x += 400 * delta
			cape.position.y -= 400 * delta
		if has_finished_last_animation():
			if not CharacterManager.fight_boss_2:
				battle_song.loop.stream.loop = true
				battle_song.fade_in()
				battle_song.play()
			sfx_sigma_intro.play()
			next_attack_stage()

	elif attack_stage == 6 and timer > 1.0:
		if not CharacterManager.fight_boss_2:
			Event.emit_signal("set_boss_bar", bar)
			Event.emit_signal("boss_health_appear", character)
		if CharacterManager.fight_boss_2:
			boss_2_bar.set_boss_bar(bar)
			Event.emit_signal("is_boss_2", character.name)
		next_attack_stage()

	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("idle")
		cape.visible = false
		cape.position.x = 0
		cape.position.y = 0
		next_attack_stage()

	elif attack_stage == 8 and timer > 1.2:
		EndAbility()

