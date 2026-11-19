extends X8TextureButton

export  var pick_sound: NodePath

var char_name: String = ""
var can_start_game: bool = false
var game_started: bool = false


func set_player() -> void :
	CharacterManager.set_player_character(char_name)
	IGT.reset_rta()
	IGT.should_run_rta = true

onready var char_container = get_node_or_null("../../characters/panel/char_container")

func on_press() -> void :
	# 터치/클릭: 아직 시작 가능 상태가 아니면 ui_accept 와 같은 팀 선택 동작을 수행
	if not can_start_game:
		if not game_started and char_container != null:
			char_container.accept_selection()
		return
	if can_start_game:
		CharacterManager.started_fresh_game = true
		set_player()
		if CharacterManager.player_character == "Zero" and CharacterManager.team.size() == 1:
			CharacterManager.only_zero = true
		get_node(pick_sound).play()
		Event.emit_signal("fadeout_startmenu")
		strong_flash()
		menu.lock_buttons()
		menu.fader.duration = 0.0625
		menu.fader.SoftFadeOut()
		yield(menu.fader, "finished")
		GameManager.seen_dialogues.clear()
		go_to_next_scene()

func go_to_next_scene() -> void :
	GameManager.start_level("NoahsPark")

func already_finished_noahs_park() -> bool:
	return "finished_intro" in GameManager.collectibles
