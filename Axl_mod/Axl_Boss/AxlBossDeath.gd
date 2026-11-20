extends TeamBossDeath

export var alternate_death_dialogue : Resource
onready var main = get_parent()
onready var deathdialog = $"../DeathWithDialog"
var only_one_fight: bool = true
var team_dialogue_axl : Resource = preload("res://Axl_mod/Axl_Boss/Dialogue/Dialogs/TEAMBOSSDEFEATED_AXL.tres")
var team_dialogue_axl_boss : Resource = preload("res://Axl_mod/Axl_Boss/Dialogue/Dialogs/TEAMBOSSDEFEATED_AXL_BOSS.tres")
var team_dialogue_alternate_axl : Resource = preload("res://Axl_mod/Axl_Boss/Dialogue/Dialogs/TEAMBOSSDEFEATED_ALTERNATE_AXL.tres")

func _ready() -> void :
	._ready()
	only_one_fight = true
	Tools.timer(1, "refresh_team_death_dialogue", self)
	alternate_death_dialogue = CharacterManager._set_correct_dialogues("AlternateAxlDefeated", alternate_death_dialogue)
	Event.listen("character_switch_end", self, "refresh_alternate_dialogue")
	Event.listen("character_switch", self, "failed")
	Event.listen("character_switch_end", self, "failed")

func refresh_team_death_dialogue() -> void :
	team_death_dialogue = team_dialogue_axl
	if main.only_x:
		team_death_dialogue = team_dialogue_axl_boss
		#if CharacterManager.player_character == "X":
		#if CharacterManager.player_character == "Zero":
		#if CharacterManager.player_character == "Axl":
	if main.only_zero:
		team_death_dialogue = team_dialogue_axl
	if main.only_axl:
		team_death_dialogue = team_dialogue_alternate_axl

func refresh_alternate_dialogue() -> void :
	alternate_death_dialogue = CharacterManager._set_correct_dialogues("AlternateAxlDefeated", alternate_death_dialogue)

func failed() -> void :
	only_one_fight = false

func _Setup():
	Event.emit_signal("enemy_kill", "copysigma")
	if main.only_zero and not CharacterManager.fight_boss_2:
		character.interrupt_all_moves()
		deathdialog.Initialize()
		deathdialog._Setup()
		print("Is true axl death without explosion")
	elif main.only_axl and not CharacterManager.fight_boss_2:
		._Setup()
		if not seen_alternate_dialog():
			alternate_axl_death_dialogue()
	else:
		._Setup()

func _Update(_delta: float):
	if main.only_zero and not CharacterManager.fight_boss_2:
		pass#Not use explosion end
	else:
		._Update(_delta)
	
func _physics_process(_delta: float) -> void :
	if main.only_zero and not CharacterManager.fight_boss_2:
		smoke.emitting = false
		explosions.emitting = false
		$audioStreamPlayer2D.stop()
	else:
		._physics_process(_delta)
	
func _Interrupt():
	emit_signal("screen_flash")
	if main.only_zero and not CharacterManager.fight_boss_2:
		pass#Not use explosion end
	elif main.only_zero and CharacterManager.fight_boss_2:
		end_without_collect_axl_defeated()
	elif main.only_x:
		end_without_collect_axl_defeated()
	elif main.only_axl:
		._Interrupt()

func end_without_collect_axl_defeated():
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
	#add_weapon_to_savedata()
	Event.emit_signal("boss_2_death", null)
	get_parent().queue_free()

func achievement_check() -> void :
	if CharacterManager.fight_boss_2:
		return
	if main.only_x:
		Achievements.unlock("AXLBOSSDEFEATED")
	if main.only_axl:
		Achievements.unlock("AXLBOSSDEFEATEDAXL")

func collectible():
	if not only_one_fight:
		return
	if Configurations.get("ShowDebug"):
		return
	if GameManager.used_cheats:
		return
	if CharacterManager.fight_boss_2:
		return
	if CharacterManager.game_mode >= 3:
		if CharacterManager.player_character == "Axl":
			if CharacterManager.nightshade_zero_armor:
				if not CharacterManager.cheat_axl_activated:
					Achievements.unlock("COLLECTCHEATERAXL")
					CharacterManager.floppa_axl_unlocked = true
	CharacterManager._save()

func alternate_axl_death_dialogue() -> void:
	loop_explosion_sound()
	GameManager.start_cutscene()
	GameManager.start_dialog(alternate_death_dialogue)
	GameManager.dialog_box.connect("dialog_concluded", self, "resume_alternate_axl_death")
	if is_instance_valid(GameManager.player):
		GameManager.player.get_node("animatedSprite").get_node("Talk").connect_talking()

func resume_alternate_axl_death() -> void:
	explosion = true
	end_death_dialog = true
	$audioStreamPlayer2D.play()
	GameManager.dialog_box.disconnect("dialog_concluded", self, "resume_alternate_axl_death")
	if is_instance_valid(GameManager.player):
		GameManager.player.get_node("animatedSprite").get_node("Talk").disconnect_talking()

func seen_alternate_dialog() -> bool:
	return GameManager.was_dialogue_seen(alternate_death_dialogue)
