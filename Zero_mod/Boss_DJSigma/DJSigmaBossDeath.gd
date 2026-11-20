extends TeamBossDeath

onready var main = get_parent()
onready var battle_song: AudioStreamPlayer = $"../Intro/BattleSong"
var only_one_fight: bool = true

func _ready() -> void :
	._ready()
	only_one_fight = true
	Event.listen("character_switch", self, "failed")
	Event.listen("character_switch_end", self, "failed")

func failed() -> void :
	only_one_fight = false

func _Setup():
	Event.emit_signal("enemy_kill", character)
	battle_song.fade_out()
	main.end_vrius()
	._Setup()

func _Update(_delta: float):
	._Update(_delta)
	
func _physics_process(_delta: float) -> void :
	._physics_process(_delta)
	
func _Interrupt():
	._Interrupt()

func achievement_check() -> void :
	if CharacterManager.fight_boss_2:
		return
	Achievements.unlock("DEFEATEDDJSIGMA")

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
		pass
	CharacterManager._save()
