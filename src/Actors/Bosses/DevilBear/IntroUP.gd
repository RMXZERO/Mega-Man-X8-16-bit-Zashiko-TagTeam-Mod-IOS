extends GenericIntro
onready var riding_vile: AnimatedSprite = $"../vile"
onready var flying_vile: AnimatedSprite = $"../flying_prop_vile"
onready var tween := TweenController.new(self,false)
onready var startup: AudioStreamPlayer2D = $"../startup"
onready var step: AudioStreamPlayer2D = $"../step"
onready var land: Particles2D = $"../land"
onready var traverse: AudioStreamPlayer2D = $"../flying_prop_vile/traverse"
onready var traverse2: AudioStreamPlayer2D = $"../flying_prop_vile/traverse2"
onready var punch: AudioStreamPlayer2D = $"../punch"
onready var wind: Sprite = $"../animatedSprite/wind"
onready var intro_song: AudioStreamPlayer = $IntroSong
onready var battle_song: AudioStreamPlayer = $BattleSong
onready var not_sound_change: = preload("res://Zero_mod/SFX/no_sound.ogg")
onready var intro_song_change: = preload("res://Zero_mod/SFX/djsigma_intro.ogg")
onready var intro_loop_change: = preload("res://Zero_mod/SFX/djsigma_loop.ogg")
onready var battle_song_change: = preload("res://src/Sounds/OST - AlternateVile - Intro.ogg")
onready var battle_loop_change: = preload("res://src/Sounds/OST - AlternateVile - Loop.ogg")

func prepare_for_intro() -> void:
	riding_vile.visible = false
	flying_vile.visible = false
	flying_vile.position.y = -160
	flying_vile.scale.x = -1
	play_animation("deactivated")

func connect_start_events() -> void:
	Log("Connecting boss door events")
	Event.listen("teleport_to_vileex",self,"prepare_for_intro")
	Event.listen("end_teleport_to_vileex",self,"execute_intro")
	Event.listen("end_teleport_to_vileex",self,"music")

func music() -> void:
	intro_song.stream = intro_song_change
	intro_song.loop.stream = intro_loop_change
	intro_song.loop.stream.loop = true
	intro_song.play()
	GameManager.add_collectible_to_savedata("vile_ex_seen")

func _ready() -> void:
	call_deferred("prepare_for_intro")
	collectible == "vile_ex_defeated"

func _Setup():
	._Setup()
	GameManager.start_cutscene()
	GameManager.dialog_box.emit_capsule_signal = false

func _Update(delta):
	process_gravity(delta)
	if attack_stage == 0 and timer > 1:
		turn_player_towards_boss()
		flying_vile.visible = true
		traverse.play_rp(0.05,0.82)
		traverse2.play()
		tween.create(Tween.EASE_OUT, Tween.TRANS_QUAD)
		tween.add_attribute("position:y",-40,1.5,flying_vile)
		tween.add_callback("next_attack_stage")
		next_attack_stage()
		
	#attack_stage == 1 is flying_vile descent
		
	elif attack_stage == 2:
		play_animation("activate")
		startup.play()
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("idle")
		tween.create(Tween.EASE_IN, Tween.TRANS_QUAD)
		tween.add_attribute("position:y",-0,0.5,flying_vile)
		tween.add_callback("next_attack_stage")
		next_attack_stage()
		
	#attack_stage == 4 is flying_vile descent
	
	elif attack_stage == 5:
		riding_vile.visible = true
		flying_vile.visible = false
		play_animation("recover")
		land.restart()
		step.play()
		traverse2.stop()
		start_dialog_or_go_to_attack_stage(7)
	
	elif attack_stage == 6:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 7:
		intro_song.stop()
		intro_song.fade_out()
		intro_song.stream = not_sound_change
		intro_song.get_node("loop").stream = not_sound_change
		intro_song.loop.stream.loop = false
		intro_song.base_volume = -80
		battle_song.stream = battle_song_change
		battle_song.get_node("loop").stream = battle_loop_change
		battle_song.loop.stream.loop = true
		battle_song.fade_in()
		battle_song.play()
		next_attack_stage()
		
	elif attack_stage == 8 and timer > 0.75:
		animatedSprite.speed_scale = 1.5
		play_animation("punch_1")
		punch.play_rp()
		wind.emit()
		Tools.timer(0.25,"second_punch",self)
		next_attack_stage()
		
	elif attack_stage == 9 and has_finished_last_animation():
		play_animation("punch_3")
		wind.emit()
		punch.play_rp(0.05,0.8)
		next_attack_stage()
		
	elif attack_stage == 10 and has_finished_last_animation():
		animatedSprite.speed_scale = 1
		play_animation("punch_end")
		next_attack_stage()
		
	elif attack_stage == 11 and timer > 0.5:
		play_animation("idle")
		GameManager.resume_character_inputs()
		EndAbility()

func second_punch():
	wind.emit()
	punch.play_rp()
	
