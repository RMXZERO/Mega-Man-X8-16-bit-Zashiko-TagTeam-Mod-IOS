extends TeamBossDeath

onready var main = get_parent()
onready var desperation = $"../Desperation"
onready var battle_song: AudioStreamPlayer = $"../Intro/BattleSong"
var only_one_fight: bool = true
var awakened: bool = false
func _ready() -> void :
	._ready()
	only_one_fight = true
	awakened = false
	Event.listen("character_switch", self, "failed")
	Event.listen("character_switch_end", self, "failed")

func failed() -> void :
	only_one_fight = false

func _Setup():
	Event.emit_signal("enemy_kill", character)
	if not awakened:
		character.interrupt_all_moves()
		desperation.Initialize()
		desperation._Setup()
	else:
		battle_song.fade_out()
		._Setup()

func _Update(_delta: float):
	if not awakened:
		pass#dont explosion now
	else:
		._Update(_delta)
	
func _physics_process(_delta: float) -> void :
	if not awakened:
		smoke.emitting = false
		explosions.emitting = false
		$audioStreamPlayer2D.stop()
	else:
		._physics_process(_delta)
	
func _Interrupt():
	if not awakened:
		pass
	else:
		._Interrupt()

func achievement_check() -> void :
	if CharacterManager.fight_boss_2:
		return
	if main.only_x:
		Achievements.unlock("DEFEATEDOMEGAZEROXVER")
	else:
		Achievements.unlock("DEFEATEDOMEGAZERO")

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
