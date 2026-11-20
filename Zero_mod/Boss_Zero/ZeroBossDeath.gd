extends TeamBossDeath

onready var main = get_parent()
var only_one_fight: bool = true
var team_dialogue_zero : Resource = preload("res://Zero_mod/Boss_Zero/Dialogue/Dialogs/TEAMBOSSDEFEATED_ZERO.tres")
var team_dialogue_omega_zero : Resource = preload("res://Zero_mod/Boss_Zero/Dialogue/Dialogs/TEAMBOSSDEFEATED_OMEGA_ZERO.tres")
var team_dialogue_fake_zero : Resource = preload("res://Zero_mod/Boss_Zero/Dialogue/Dialogs/TEAMBOSSDEFEATED_FAKE_ZERO.tres")

func _ready() -> void :
	._ready()
	only_one_fight = true
	Tools.timer(1, "refresh_team_death_dialogue", self)
	Event.listen("character_switch", self, "failed")
	Event.listen("character_switch_end", self, "failed")

func refresh_team_death_dialogue() -> void :
	team_death_dialogue = team_dialogue_zero
	if main.only_x:
		team_death_dialogue = team_dialogue_zero
	if main.only_zero:
		team_death_dialogue = team_dialogue_omega_zero
	if main.only_axl:
		team_death_dialogue = team_dialogue_fake_zero

func failed() -> void :
	only_one_fight = false

func achievement_check() -> void :
	if main.only_x:
		if CharacterManager.player_character == "X":
			Achievements.unlock("ZERODEFEATED")
	if main.only_zero and only_one_fight:
		if CharacterManager.player_character == "Zero":
			Achievements.unlock("ZERODEFEATEDZERO")
	if CharacterManager.player_character == "Axl":
		if only_one_fight and main.only_axl:
			Achievements.unlock("ZERODEFEATEDAXL")

func collectible():
	if "X" in CharacterManager.alive_team:
		GameManager.add_collectible_to_savedata("ultima_head")
		GameManager.add_collectible_to_savedata("ultima_body")
		GameManager.add_collectible_to_savedata("ultima_arms")
		GameManager.add_collectible_to_savedata("ultima_legs")
		Achievements.unlock("COLLECTULTIMATEX")
		Savefile.save(Savefile.save_slot)
		CharacterManager._save()
	if not only_one_fight:
		return
	if Configurations.get("ShowDebug"):
		return
	if GameManager.used_cheats:
		return
	if CharacterManager.fight_boss_2:
		return
	if CharacterManager.game_mode >= 3:
		if CharacterManager.player_character == "X":
			if CharacterManager.nightshade_zero_armor:
				if not CharacterManager.infinite_x_activated:
					Achievements.unlock("COLLECTINFINITEX")
					CharacterManager.infinite_x_unlocked = true
	CharacterManager._save()

