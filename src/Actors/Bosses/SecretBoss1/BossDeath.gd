extends AttackAbility
onready var explosion: AudioStreamPlayer2D = $explosion
onready var beam_out: AudioStreamPlayer2D = $beam_out
onready var sparks: AudioStreamPlayer2D = $sparks
export var dialogue : Resource
signal screen_flash
onready var battle_song: AudioStreamPlayer = $"../Intro/BattleSong"
onready var weapon = $red_weapon
var less_weapon: bool = false

func unlock_axl_white():
	if CharacterManager.player_character == "Axl":
		if is_instance_valid(GameManager.player):
			var axl = GameManager.player
			CharacterManager.white_axl_armor = true
			axl.equip_axl_white_parts()
			CharacterManager.set_axl_colors(axl.animatedSprite)
			var pause_node = get_tree().root.find_node("Pause", true, false)
			pause_node.character_menu_visibility()
			GameManager.add_collectible_to_savedata("white_axl_armor")
			achievement_check()
			if CharacterManager.game_mode >= 3:
				if CharacterManager.player_character == "Axl":
					if CharacterManager.only_axl and not Configurations.get("ShowDebug") and not CharacterManager.fight_boss_2 and not GameManager.used_cheats:
						Achievements.unlock("COLLECTCHEATERAXL")
						CharacterManager.floppa_axl_unlocked = true

func achievement_check() -> void :
	Achievements.unlock("COLLECTWHITEAXL")
	Savefile.save(Savefile.save_slot)

func _ready() -> void :
	dialogue = CharacterManager._set_correct_dialogues("Secret1Defeated", dialogue)
	character.listen("zero_health", self, "start")
	character.connect("intro_concluded", self, "fast_death")
	Event.listen("character_switch_end", self, "refresh_dialogue")
	
func refresh_dialogue() -> void :
	dialogue = CharacterManager._set_correct_dialogues("Secret1Defeated", dialogue)

func fast_death() -> void :
	less_weapon = true
	Tools.timer(44.0, "show_weapon", self)
	character.disconnect("intro_concluded", self, "fast_death")

func show_weapon() -> void :
	if not executing:
		less_weapon = false

func start() -> void :
	character.interrupt_all_moves()
	unlock_axl_white()
	ExecuteOnce()

func _Setup() -> void:
	if less_weapon:
		play_animation("defeat_fast")
	else:
		play_animation("defeat")
	animatedSprite.pause_mode = Node.PAUSE_MODE_PROCESS
	call_deferred("force_movement_regardless_of_direction", horizontal_velocity * -get_player_direction_relative())
	set_vertical_speed(-jump_velocity)
	explosion.play()
	emit_signals()
	battle_song.fade_out()
	refresh_dialogue()
	GlobalVariables.add("red_defeated", "defeated")

func emit_signals() -> void:
	character.emit_signal("death")
	Event.emit_signal("enemy_kill",character)
	GameManager.start_cutscene()
	GameManager.player.stop_charge()
	Tools.timer(0.5,"unfreeze",self,null,true)
	GameManager.pause("BossDefeat")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and timer > 0.1:
		if character.is_on_floor():
			turn_and_face_player()
			play_animation("defeat_land")
			force_movement(0)
			if less_weapon:
				weapon.visible = true
				weapon.frame = 0
				weapon.scale.x = get_facing_direction()
				Event.emit_signal("set_object", "red_weapon", global_position, weapon.scale.x)
			next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("defeat_loop")
		sparks.play()
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 1.5:
		start_dialog_or_go_to_attack_stage(4)

	elif attack_stage == 3:
		if seen_dialog():
			next_attack_stage()
			
	elif attack_stage == 4:
		play_animation("teleport")
		beam_out.play()
		sparks.stop()
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		animatedSprite.position.y -= 480 * delta
		if timer > 1.55:
			if less_weapon:
				Achievements.unlock("DEFEATEDREDTOOFAST")
			GameManager.end_boss_death_cutscene()
			next_attack_stage()
			emit_signal("screen_flash")
			character.destroy()

	elif attack_stage == 6:
		pass

func _Interrupt() -> void:
	push_error("Interrupted Red's Death")

func unfreeze() -> void:
	GameManager.unpause("BossDefeat")
	
func start_dialog_or_go_to_attack_stage(skip_dialog_stage := 0) -> void:
	if not seen_dialog():
		GameManager.start_dialog(dialogue)
		next_attack_stage()
	elif seen_dialog():
		go_to_attack_stage(skip_dialog_stage)

func seen_dialog() -> bool:
	return GameManager.was_dialogue_seen(dialogue)
