extends Node2D

var play: bool = false
var team_boss_name = null
var team_boss_name2 = null
var team_boss_name3 = null
var team_boss_name4 = null
var team_boss_name5 = null
var team_boss_name6 = null
var team_boss_name7 = null
var team_boss_name8 = null
var team_boss_name9 = null

func _ready():
	Event.listen("show_life_steal_bar",self,"play_music")
	Event.listen("enemy_kill", self, "fade_out")
	Event.listen("is_boss_2", self, "have_boss_2")
	Event.listen("boss_2_death", self, "team_boss_is_death")
	CharacterManager.fight_boss_2 = false
	unlock_portal()
	play = false

func axl_boss_background():
	$"../SecretPortal3/final_background".visible = false
	$"../../SecretBossRoom/SecretBossTileset".visible = false
	$"../../SecretBossRoom/SecretBossBackgroundx5".visible = false
	if CharacterManager.player_character == "Axl":
		$"../SecretPortal3/final_background".visible = true
		$"../../../Limits/secret_room".position.y -= 16
	elif CharacterManager.player_character == "Zero":
		$"../../SecretBossRoom/SecretBossBackgroundx5".visible = true
	else:
		$"../../SecretBossRoom/SecretBossTileset".visible = true

func unlock_portal():
	if "x_defeated" in GameManager.collectibles and "zero_defeated" in GameManager.collectibles and "axl_defeated" in GameManager.collectibles:
		$".".animation = "default"
		$"../SecretPortal4".active = true
	else:
		$".".animation = "deactivated"
		$"../SecretPortal4".active = false
		
	if "axl_seen_x_boss" in GameManager.collectibles or "axl_seen" in GameManager.collectibles:
		$"../SecretPortal3/AEntrance".animation = "default"
		$"../SecretPortal3".active = true
	else:
		$"../SecretPortal3/AEntrance".animation = "deactivated"
		$"../SecretPortal3".active = false

func have_boss_2(boss_name) -> void :
	if team_boss_name8 != null and team_boss_name9 == null:
		team_boss_name9 = boss_name
	if team_boss_name7 != null and team_boss_name8 == null:
		team_boss_name8 = boss_name
	if team_boss_name6 != null and team_boss_name7 == null:
		team_boss_name7 = boss_name
	
	if team_boss_name5 != null and team_boss_name6 == null:
		team_boss_name6 = boss_name
	if team_boss_name4 != null and team_boss_name5 == null:
		team_boss_name5 = boss_name
	if team_boss_name3 != null and team_boss_name4 == null:
		team_boss_name4 = boss_name
	
	if team_boss_name2 != null and team_boss_name3 == null:
		team_boss_name3 = boss_name
	if team_boss_name != null and team_boss_name2 == null:
		team_boss_name2 = boss_name
	if team_boss_name == null:
		team_boss_name = boss_name

func team_boss_is_death(boss_name) -> void :
	if boss_name == team_boss_name9:
		team_boss_name9 = null
	if boss_name == team_boss_name8:
		team_boss_name8 = null
	if boss_name == team_boss_name7:
		team_boss_name7 = null
	if boss_name == team_boss_name6:
		team_boss_name6 = null
	if boss_name == team_boss_name5:
		team_boss_name5 = null
	if boss_name == team_boss_name4:
		team_boss_name4 = null
	if boss_name == team_boss_name3:
		team_boss_name3 = null
	if boss_name == team_boss_name2:
		team_boss_name2 = null
	if boss_name == team_boss_name:
		team_boss_name = null

func fight_2_boss():
	set_boss_2_position()
	CharacterManager.fight_boss_2 = true

func set_boss_2_position():
	$"../../SecretBossRoom/SecretBossSpawner2".position.x = 307
	$"../../SecretBossRoom/SecretBossSpawner3".position.x = 367

func play_music():
	if CharacterManager.fight_boss_2:
		if not play:
			play = true
			$BattleSong.loop.stream.loop = true
			$BattleSong.play()

func fade_out(_d = null):
	if team_boss_name == null \
	and team_boss_name2 == null \
	and team_boss_name3 == null \
	and team_boss_name4 == null \
	and team_boss_name5 == null \
	and team_boss_name6 == null \
	and team_boss_name7 == null \
	and team_boss_name8 == null \
	and team_boss_name9 == null \
	and play:
		$BattleSong.fade_out()
		Achievements.unlock("WEARETEAM")
