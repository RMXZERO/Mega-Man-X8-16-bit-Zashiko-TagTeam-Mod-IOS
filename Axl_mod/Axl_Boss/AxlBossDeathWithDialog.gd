extends AttackAbility
onready var explosion: AudioStreamPlayer2D = $explosion
onready var beam_out: AudioStreamPlayer2D = $beam_out
onready var damage: AudioStreamPlayer = $damage
onready var flash: AudioStreamPlayer2D = $flash
export var dialogue : Resource
export var collectible: String
signal screen_flash
onready var battle_song: AudioStreamPlayer = $"../Intro/BattleSong"
var chance = randf() * 100

func _ready() -> void :
	dialogue = CharacterManager._set_correct_dialogues("AxlDefeated", dialogue)
	Event.listen("character_switch_end", self, "refresh_dialogue")
	
func refresh_dialogue() -> void :
	dialogue = CharacterManager._set_correct_dialogues("AxlDefeated", dialogue)

func _Setup() -> void:
	chance = randf() * 100
	if chance >= 50:
		play_animation("damage")
	else:
		play_animation("damage_resist")
	animatedSprite.pause_mode = Node.PAUSE_MODE_PROCESS
	call_deferred("force_movement_regardless_of_direction", horizontal_velocity * -get_player_direction_relative())
	set_vertical_speed(-jump_velocity)
	explosion.play()
	damage.play()
	flash.play()
	emit_signals()
	battle_song.fade_out()

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
			play_animation("final")
			force_movement(0)
			next_attack_stage()
	
	elif attack_stage == 1:
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 1.0:
		start_dialog_or_go_to_attack_stage(4)

	elif attack_stage == 3:
		if seen_dialog():
			next_attack_stage()
			
	elif attack_stage == 4:
		play_animation("beam_out")
		beam_out.play()
		next_attack_stage()

	elif attack_stage == 5:
		if animatedSprite.animation == "beam_out" and animatedSprite.frame > 3:
			animatedSprite.position.y -= 420 * delta
			collectible()
		if timer > 1.55:
			GameManager.end_boss_death_cutscene()
			next_attack_stage()
			achievement_check()
			emit_signal("screen_flash")
			character.destroy()
	
	elif attack_stage == 6:
		pass

func _Interrupt() -> void:
	push_error("Interrupted Axl Boss Death")

func unfreeze() -> void:
	GameManager.unpause("BossDefeat")

func achievement_check() -> void :
	if collectible == "axl_saber_combo":
		if "axl_saber_combo" in GameManager.collectibles:
			Achievements.unlock("AXLBOSSDEFEATEDZERO")
		if not "axl_saber_combo" in GameManager.collectibles and CharacterManager.player_character == "X":
			Achievements.unlock("AXLBOSSDEFEATEDXNOSABER")

func collectible():
	if not collectible in GameManager.collectibles:
		if collectible == "axl_saber_combo" and CharacterManager.player_character == "Zero":
			GameManager.add_collectible_to_savedata(collectible)
			CharacterManager.axl_saber_combo = true
		elif collectible != "axl_saber_combo":
			GameManager.add_collectible_to_savedata(collectible)

func start_dialog_or_go_to_attack_stage(skip_dialog_stage := 0) -> void:
	if not seen_dialog():
		GameManager.start_dialog(dialogue)
		next_attack_stage()
	elif seen_dialog():
		go_to_attack_stage(skip_dialog_stage)

func seen_dialog() -> bool:
	return GameManager.was_dialogue_seen(dialogue)

