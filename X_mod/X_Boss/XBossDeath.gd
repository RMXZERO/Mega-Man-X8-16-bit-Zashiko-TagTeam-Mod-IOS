extends TeamBossDeath

onready var main = get_parent()
var only_one_fight: bool = true

var team_dialogue_x : Resource = preload("res://X_mod/X_Boss/Dialogue/Dialogs/TEAMBOSSDEFEATED_X_BOSS.tres")

func _ready() -> void :
	._ready()
	only_one_fight = true
	Tools.timer(1, "refresh_team_death_dialogue", self)
	Event.listen("character_switch", self, "failed")
	Event.listen("character_switch_end", self, "failed")

func refresh_team_death_dialogue() -> void :
	team_death_dialogue = team_dialogue_x

func failed() -> void :
	only_one_fight = false

func achievement_check() -> void :
	if main.only_x:
		Achievements.unlock("XBOSSDEFEATED")
	if main.only_zero:
		Achievements.unlock("XBOSSDEFEATEDZERO")
	if CharacterManager.player_character == "Axl":
		if only_one_fight and main.only_axl:
			Achievements.unlock("XBOSSDEFEATEDAXL")

func collectible():
	Event.emit_signal("show_life_steal_bar")
	if not only_one_fight:
		return
	if Configurations.get("ShowDebug"):
		return
	if GameManager.used_cheats:
		return
	if CharacterManager.fight_boss_2:
		return
	if CharacterManager.game_mode >= 3:
		if CharacterManager.player_character == "Zero":
			if CharacterManager.nightshade_zero_armor:
				if CharacterManager.awakened_zero_armor and CharacterManager.awakened_zero_full_power_max:
					return
				Achievements.unlock("COLLECTAWAKENEDZEROUP")
				CharacterManager.awakened_zero_unlocked = true
	CharacterManager._save()

