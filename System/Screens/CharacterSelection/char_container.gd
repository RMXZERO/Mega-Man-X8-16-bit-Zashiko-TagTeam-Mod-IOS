extends HBoxContainer

onready var menu_frame: TextureRect = $"../../../Menu_Frame"
onready var left_panel: Control = menu_frame.get_node("Left")
onready var right_panel: Control = menu_frame.get_node("Right")
onready var char_face_frame: TextureRect = left_panel.get_node("char_face_frame")
onready var left_desc: RichTextLabel = left_panel.get_node("Description_Left")
onready var right_name: Label = right_panel.get_node("Name_Right")
onready var right_desc: RichTextLabel = right_panel.get_node("Description_Right")
onready var gamestart_button: = $"../../../Menu_Frame/GameStart"

onready var wireframes: Control = $"../../Wireframes"
onready var wireframe_x: TextureRect = wireframes.get_node("wireframe_X")
onready var wireframe_zero: TextureRect = wireframes.get_node("wireframe_Zero")
onready var wireframe_axl: TextureRect = wireframes.get_node("wireframe_Axl")
onready var wireframe_alia: TextureRect = wireframes.get_node("wireframe_Alia")
onready var wireframe_layer: TextureRect = wireframes.get_node("wireframe_Layer")
onready var wireframe_pallette: TextureRect = wireframes.get_node("wireframe_Pallette")

onready var face_x: TextureRect = char_face_frame.get_node("face_X")
onready var face_zero: TextureRect = char_face_frame.get_node("face_Zero")
onready var face_axl: TextureRect = char_face_frame.get_node("face_Axl")
onready var face_alia: TextureRect = char_face_frame.get_node("face_Alia")
onready var face_layer: TextureRect = char_face_frame.get_node("face_Layer")
onready var face_pallette: TextureRect = char_face_frame.get_node("face_Pallette")

onready var sprite_x: TextureRect = get_node("X")
onready var sprite_zero: TextureRect = get_node("Zero")
onready var sprite_axl: TextureRect = get_node("Axl")
onready var sprite_alia: TextureRect = get_node("Alia")
onready var sprite_layer: TextureRect = get_node("Layer")
onready var sprite_pallette: TextureRect = get_node("Pallette")

onready var game_start: X8TextureButton = menu_frame.get_node("GameStart")
onready var game_start_label: Label = game_start.get_node("text")
onready var game_start_label2: Label = game_start.get_node("text2")

onready var equip: AudioStreamPlayer = $"../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../choice"
onready var pick: AudioStreamPlayer = $"../../../../pick"

onready var x_base: Texture = preload("res://System/Screens/CharacterSelection/X.png")
onready var x_base_x8: Texture = preload("res://System/Screens/CharacterSelection/X_X8.png")
onready var x_icarus: Texture = preload("res://System/Screens/CharacterSelection/X_Icarus.png")
onready var x_hermes: Texture = preload("res://System/Screens/CharacterSelection/X_Hermes.png")
onready var x_ultimate: Texture = preload("res://System/Screens/CharacterSelection/X_Ultimate.png")
onready var x_infinite: Texture = preload("res://System/Screens/CharacterSelection/X_Infinite.png")

onready var face_x_normal: Texture = preload("res://System/Screens/CharacterSelection/face_X.png")
onready var face_icarus_x: Texture = preload("res://System/Screens/CharacterSelection/face_Icarus_Armor_X.png")
onready var face_hermes_x: Texture = preload("res://System/Screens/CharacterSelection/face_Hermes_Armor_X.png")
onready var face_ultimate_x: Texture = preload("res://System/Screens/CharacterSelection/face_Ultimate_Armor_X.png")
onready var face_infinite_x: Texture = preload("res://System/Screens/CharacterSelection/face_Infinite_X.png")

onready var axl_base: Texture = preload("res://System/Screens/CharacterSelection/Axl.png")
onready var axl_floppa: Texture = preload("res://System/Screens/CharacterSelection/Axl_Floppa.png")
onready var axl_cheat: Texture = preload("res://System/Screens/CharacterSelection/Axl_Cheat.png")
onready var axl_floppa_cheat: Texture = preload("res://System/Screens/CharacterSelection/Axl_Floppa_Cheat.png")

onready var face_axl_normal: Texture = preload("res://System/Screens/CharacterSelection/face_Axl.png")
onready var face_white_axl: Texture = preload("res://System/Screens/CharacterSelection/face_White_Axl.png")

onready var zero_base: Texture = preload("res://System/Screens/CharacterSelection/Zero.png")
onready var zero_awakened: Texture = preload("res://System/Screens/CharacterSelection/Zero_Awakened.png")
onready var zero_beta: Texture = preload("res://System/Screens/CharacterSelection/Zero_Beta.png")
onready var face_zero_normal: Texture = preload("res://System/Screens/CharacterSelection/face_Zero.png")
onready var face_black_zero: Texture = preload("res://System/Screens/CharacterSelection/face_Black_Zero.png")
onready var face_zero_awakened: Texture = preload("res://System/Screens/CharacterSelection/face_Zero_Awakened.png")

var x_armor: int = 0
var zero_armor: int = 0
var axl_armor: int = 0
var characters: Array = []
var animating: bool = false
var direction: String = ""

var no_char

var accept_pressed: float = 0
var accept_timer: float = 0.2



var x_left_desc: String = "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_1") + "[/color]\n" + tr("X_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_2") + "[/color]\n" + tr("X_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_3") + "[/color]\n" + tr("X_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_4") + "[/color]\n" + tr("X_LEFT_DESC_4")
var x_right_desc: String = "\n\n" + tr("X_RIGHT_DESC")

var zero_left_desc: String = "\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_1") + "[/color]\n" + tr("ZERO_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_2") + "[/color]\n" + tr("ZERO_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_3") + "[/color]\n" + tr("ZERO_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_4") + "[/color]\n" + tr("ZERO_LEFT_DESC_4")
var zero_right_desc: String = "\n\n" + tr("ZERO_RIGHT_DESC")

var axl_left_desc: String = "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_1") + "[/color]\n" + tr("AXL_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_2") + "[/color]\n" + tr("AXL_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_3") + "[/color]\n" + tr("AXL_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_4") + "[/color]\n" + tr("AXL_LEFT_DESC_4")
var axl_right_desc: String = "\n\n" + tr("AXL_RIGHT_DESC")

var alia_left_desc: String = "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_1") + "[/color]\n" + tr("ALIA_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_2") + "[/color]\n" + tr("ALIA_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_3") + "[/color]\n" + tr("ALIA_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_4") + "[/color]\n" + tr("ALIA_LEFT_DESC_4")
var alia_right_desc: String = "\n\n" + tr("ALIA_RIGHT_DESC")

var layer_left_desc: String = "\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_1") + "[/color]\n" + tr("LAYER_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_2") + "[/color]\n" + tr("LAYER_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_3") + "[/color]\n" + tr("LAYER_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_4") + "[/color]\n" + tr("LAYER_LEFT_DESC_4")
var layer_right_desc: String = "\n\n" + tr("LAYER_RIGHT_DESC")

var pallette_left_desc: String = "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_1") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_2") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_3") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_4") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_4")
var pallette_right_desc: String = "\n\n" + tr("PALLETTE_RIGHT_DESC")

signal switch_character(direction)

# 캐릭터를 선택(팀에 추가)할 때 재생되는 보이스, 캐릭터당 2개 중 랜덤
const SELECT_VOICES := {
	"X": ["res://System/Screens/CharacterSelection/Voices/x_start.wav", "res://System/Screens/CharacterSelection/Voices/x_start2.wav"],
	"Zero": ["res://System/Screens/CharacterSelection/Voices/zero_start.wav", "res://System/Screens/CharacterSelection/Voices/zero_start2.wav"],
	"Axl": ["res://System/Screens/CharacterSelection/Voices/axl_start.wav", "res://System/Screens/CharacterSelection/Voices/axl_start2.wav"]
}
# 파일별 음량 보정(dB): 선택/픽 효과음과 비슷한 크기가 되도록 측정해서 맞춘 값
const SELECT_VOICE_DB := {
	"res://System/Screens/CharacterSelection/Voices/x_start.wav": 0.0,
	"res://System/Screens/CharacterSelection/Voices/x_start2.wav": -1.2,
	"res://System/Screens/CharacterSelection/Voices/zero_start.wav": -1.5,
	"res://System/Screens/CharacterSelection/Voices/zero_start2.wav": -0.3,
	"res://System/Screens/CharacterSelection/Voices/axl_start.wav": -2.1,
	"res://System/Screens/CharacterSelection/Voices/axl_start2.wav": -2.0
}
const SELECT_VOICE_MASTER_DB := 0.0   # 선택 보이스 전체를 한꺼번에 키우거나 줄이고 싶을 때
var _select_voice_rng := RandomNumberGenerator.new()
var _select_voice_seeded: bool = false
var _select_voice_cache: Dictionary = {}

func update_text():
	x_left_desc = "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_1") + "[/color]\n" + tr("X_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_2") + "[/color]\n" + tr("X_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_3") + "[/color]\n" + tr("X_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("X_LEFT_TITLE_4") + "[/color]\n" + tr("X_LEFT_DESC_4")
	x_right_desc = "\n\n" + tr("X_RIGHT_DESC")

	zero_left_desc = "\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_1") + "[/color]\n" + tr("ZERO_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_2") + "[/color]\n" + tr("ZERO_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_3") + "[/color]\n" + tr("ZERO_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("ZERO_LEFT_TITLE_4") + "[/color]\n" + tr("ZERO_LEFT_DESC_4")
	zero_right_desc = "\n\n" + tr("ZERO_RIGHT_DESC")

	axl_left_desc = "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_1") + "[/color]\n" + tr("AXL_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_2") + "[/color]\n" + tr("AXL_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_3") + "[/color]\n" + tr("AXL_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("AXL_LEFT_TITLE_4") + "[/color]\n" + tr("AXL_LEFT_DESC_4")
	axl_right_desc = "\n\n" + tr("AXL_RIGHT_DESC")

	alia_left_desc = "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_1") + "[/color]\n" + tr("ALIA_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_2") + "[/color]\n" + tr("ALIA_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_3") + "[/color]\n" + tr("ALIA_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("ALIA_LEFT_TITLE_4") + "[/color]\n" + tr("ALIA_LEFT_DESC_4")
	alia_right_desc = "\n\n" + tr("ALIA_RIGHT_DESC")

	layer_left_desc = "\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_1") + "[/color]\n" + tr("LAYER_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_2") + "[/color]\n" + tr("LAYER_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_3") + "[/color]\n" + tr("LAYER_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("LAYER_LEFT_TITLE_4") + "[/color]\n" + tr("LAYER_LEFT_DESC_4")
	layer_right_desc = "\n\n" + tr("LAYER_RIGHT_DESC")

	pallette_left_desc = "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_1") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_1") + "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_2") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_2") +  "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_3") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_3") + "\n\n[color=#47a1fc]" + tr("PALLETTE_LEFT_TITLE_4") + "[/color]\n" + tr("PALLETTE_LEFT_DESC_4")
	pallette_right_desc = "\n\n" + tr("PALLETTE_RIGHT_DESC")

func _ready() -> void :
	Event.connect("translation_updated",self,"update_text")
	connect("switch_character", self, "switch_characters")
	characters.append(sprite_axl)
	characters.append(sprite_x)
	characters.append(sprite_zero)
	if Savefile.newgame_plus >= 1:
		characters.append(sprite_alia)
		characters.append(sprite_layer)
		characters.append(sprite_pallette)
	for child in characters:
		child.rect_min_size = Vector2(40, 48)
		child.modulate = Color("#2c2c2c")
		
	add_blank_char_as_child()
	
	CharacterManager.team = []
	set_menu_visibility()
	
	CharacterManager.ultimate_x_armor = false
	CharacterManager.infinite_x_activated = false
	if CharacterManager.use_old_sprite:
		sprite_x.texture = x_base
	else:
		sprite_x.texture = x_base_x8
	
	CharacterManager.black_zero_armor = false
	CharacterManager.awakened_zero_armor = false
	CharacterManager.custom_zero_armor = false
	CharacterManager.weaponget_zero = false
	CharacterManager.set_zeroX8_normal_colors(sprite_zero)
	if CharacterManager.betazero_activated:
		sprite_zero.texture = zero_beta
		CharacterManager.set_new_betazero_normal_colors(sprite_zero)

	CharacterManager.white_axl_armor = false
	CharacterManager.cheat_axl_activated = false
	CharacterManager.custom_axl_armor = false
	CharacterManager.set_axl_normal_colors(sprite_axl)
	if CharacterManager.floppa_axl_activated:
		sprite_axl.texture = axl_floppa
		CharacterManager.set_axl_floppa_colors(sprite_axl)

func hide_all_wireframes() -> void :
	wireframe_x.hide()
	wireframe_zero.hide()
	wireframe_axl.hide()
	wireframe_alia.hide()
	wireframe_layer.hide()
	wireframe_pallette.hide()
	face_x.hide()
	face_zero.hide()
	face_axl.hide()
	face_alia.hide()
	face_layer.hide()
	face_pallette.hide()
	$"../../../start_option/X".rect_position.x = 500
	$"../../../start_option/Zero".rect_position.x = 500
	$"../../../start_option/Axl".rect_position.x = 500

func set_menu_visibility() -> void :
	hide_all_wireframes()
	
	if "X" in characters[1].name:
		game_start.char_name = "X"
		wireframe_x.show()
		face_x.show()
		left_desc.bbcode_text = x_left_desc
		right_name.text = "X"
		right_desc.bbcode_text = x_right_desc
		$"../../../start_option/X".rect_position.x = 0
		
	if "Zero" in characters[1].name:
		game_start.char_name = "Zero"
		wireframe_zero.show()
		face_zero.show()
		left_desc.bbcode_text = zero_left_desc
		right_name.text = "Zero"
		right_desc.bbcode_text = zero_right_desc
		$"../../../start_option/Zero".rect_position.x = 0
		
	if "Axl" in characters[1].name:
		game_start.char_name = "Axl"
		wireframe_axl.show()
		face_axl.show()
		left_desc.bbcode_text = axl_left_desc
		right_name.text = "Axl"
		right_desc.bbcode_text = axl_right_desc
		$"../../../start_option/Axl".rect_position.x = 0
		
	if "Alia" in characters[1].name:
		game_start.char_name = "Alia"
		wireframe_alia.show()
		face_alia.show()
		left_desc.bbcode_text = alia_left_desc
		right_name.text = "Alia"
		right_desc.bbcode_text = alia_right_desc
	
	if "Layer" in characters[1].name:
		game_start.char_name = "Layer"
		wireframe_layer.show()
		face_layer.show()
		left_desc.bbcode_text = layer_left_desc
		right_name.text = "Layer"
		right_desc.bbcode_text = layer_right_desc
		
	if "Pallette" in characters[1].name:
		game_start.char_name = "Pallette"
		wireframe_pallette.show()
		face_pallette.show()
		left_desc.bbcode_text = pallette_left_desc
		right_name.text = "Pallette"
		right_desc.bbcode_text = pallette_right_desc
	
	if "none" in characters[1].name:
		face_axl.hide()
		face_zero.hide()
		face_x.hide()
		face_alia.hide()
		face_layer.hide()
		face_pallette.hide()
		left_desc.bbcode_text = ""
		right_name.text = ""
		right_desc.bbcode_text = ""
		
	switch_armor(0)
	update_game_start_label()
		
func update_game_start_label() -> void :
	if CharacterManager.team.size() == 0:
		game_start_label.text = "Select team"
		game_start_label2.text = ""
		return
		
	var char_name = "none"
	if "X" in characters[1].name:
		char_name = "X"
	elif "Zero" in characters[1].name:
		char_name = "Zero"
	elif "Axl" in characters[1].name:
		char_name = "Axl"
	elif "Alia" in characters[1].name:
		char_name = "Alia"
	elif "Layer" in characters[1].name:
		char_name = "Layer"
	elif "Pallette" in characters[1].name:
		char_name = "Pallette"
		
	var starting_char = CharacterManager.team[0]
	if char_name == starting_char:
		game_start_label.text = "Remove " + char_name
		game_start_label2.text = "from team"
	else:
		game_start_label.text = "Start as " + CharacterManager.team[0]
		if char_name == "none":
			game_start_label2.text = ""
		else:
			game_start_label2.text = "and " + char_name
		
func add_blank_char_as_child():
	var copy_character = characters[0].duplicate()
	add_child(copy_character)
	move_child(copy_character, characters.size())
	copy_character.rect_position = characters[ - 1].rect_position + Vector2(40, 0)
	no_char = copy_character
	no_char.name = "none"
	no_char.texture = null
	characters.append(no_char)

func _process(delta):
	if accept_pressed > 0:
		accept_pressed -= delta

func _input(event: InputEvent) -> void :
	if gamestart_button.game_started or animating:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			handle_touch(event.position)
		return
		
	if Input.is_action_just_pressed("move_right"):
		emit_signal("switch_character", "right")
	elif Input.is_action_just_pressed("move_left"):
		emit_signal("switch_character", "left")
		
	if Input.is_action_just_pressed("move_up"):
		switch_armor( - 1)
	elif Input.is_action_just_pressed("move_down"):
		switch_armor(1)
		
	if Input.is_action_just_pressed("ui_accept") and accept_pressed <= 0:
		accept_pressed = accept_timer
		toggle_current_character()

func get_current_char_name() -> String:
	var char_name = "none"
	if "X" in characters[1].name:
		char_name = "X"
	elif "Zero" in characters[1].name:
		char_name = "Zero"
	elif "Axl" in characters[1].name:
		char_name = "Axl"
	elif "Alia" in characters[1].name:
		char_name = "Alia"
	elif "Layer" in characters[1].name:
		char_name = "Layer"
	elif "Pallette" in characters[1].name:
		char_name = "Pallette"
	return char_name

# 선택/해제 (키보드 ui_accept 와 터치가 같이 사용)
func toggle_current_character() -> void:
	var char_name = get_current_char_name()

	if char_name in CharacterManager.team:
		unequip.play()
		CharacterManager.remove_player_from_team(char_name)
		characters[1].modulate = Color("#2c2c2c")
	elif not char_name == "none" and not char_name in CharacterManager.team:
		pick.play()
		play_select_voice(char_name)
		CharacterManager.add_player_to_team(char_name)
		characters[1].modulate = Color("#ffffff")

	update_game_start_label()

	if (CharacterManager.team.size() == CharacterManager.max_team_size) or (CharacterManager.team.size() == 1 and char_name == "none"):
		gamestart_button.can_start_game = true
		gamestart_button.game_started = true
		gamestart_button.on_press()

# 선택 보이스 재생 (마지막 캐릭터를 고르면 바로 게임이 시작되어 이 화면이 사라지므로,
# 플레이어를 화면 노드가 아닌 루트에 붙여서 소리가 끊기지 않게 한다)
func play_select_voice(char_name: String) -> void:
	if not SELECT_VOICES.has(char_name):
		return
	if not _select_voice_seeded:
		_select_voice_rng.randomize()
		_select_voice_seeded = true
	var paths: Array = SELECT_VOICES[char_name]
	var path: String = paths[_select_voice_rng.randi() % paths.size()]
	var stream = _select_voice_cache.get(path)
	if stream == null:
		stream = load(path)
		if stream == null:
			return
		_select_voice_cache[path] = stream
	var player := AudioStreamPlayer.new()
	player.pause_mode = Node.PAUSE_MODE_PROCESS
	player.stream = stream
	player.bus = "Voice"
	player.volume_db = SELECT_VOICE_DB.get(path, -4.0) + SELECT_VOICE_MASTER_DB
	get_tree().root.add_child(player)
	player.connect("finished", player, "queue_free")
	player.play()

# 터치: 가운데 캐릭터 = 선택/해제, 양옆 캐릭터 = 좌우 이동
func handle_touch(pos: Vector2) -> void:
	if not is_visible_in_tree() or characters.size() < 3:
		return
	if characters[1].get_global_rect().has_point(pos):
		if accept_pressed <= 0:
			accept_pressed = accept_timer
			toggle_current_character()
	elif characters[2].get_global_rect().has_point(pos):
		emit_signal("switch_character", "right")
	elif characters[0].get_global_rect().has_point(pos):
		emit_signal("switch_character", "left")

func has_icarus_armor() -> bool:
	var part: int = 0
	for piece in GameManager.collectibles:
		if "icarus" in piece:
			part += 1
	return part == 4

func has_hermes_armor() -> bool:
	var part: int = 0
	for piece in GameManager.collectibles:
		if "hermes" in piece:
			part += 1
	return part == 4

func has_ultimate_armor() -> bool:
	var part: int = 0
	for piece in GameManager.collectibles:
		if "ultima" in piece:
			part += 1
	return part == 4

func get_available_armors() -> PoolIntArray:
	var list: PoolIntArray = [0]
	if has_icarus_armor():
		list.append(1)
	if has_hermes_armor():
		list.append(2)
	if has_ultimate_armor():
		list.append(3)
	if CharacterManager.infinite_x_unlocked:
		list.append(4)
	return list

func get_available_zero_armors() -> PoolIntArray:
	var list: PoolIntArray = [0]
	if "black_zero_armor" in GameManager.collectibles:
		list.append(1)
	if "awakened_zero_armor" in GameManager.collectibles or CharacterManager.awakened_zero_unlocked:
		list.append(2)
	return list

func get_available_axl_armors() -> PoolIntArray:
	var list: PoolIntArray = [0]
	if "white_axl_armor" in GameManager.collectibles:
		list.append(1)
	if CharacterManager.floppa_axl_unlocked:
		list.append(2)
	return list

func switch_armor(dir) -> void :
	if right_name.text == "Zero":
		var available_armors: PoolIntArray = get_available_zero_armors()
		if available_armors.size() <= 1:
			return
			
		var current_index: int = available_armors.find(zero_armor)
		if current_index == - 1:
			current_index = 0
			
		var new_index: int = (current_index + dir) %available_armors.size()
		if new_index < 0:
			new_index += available_armors.size()
			
		zero_armor = available_armors[new_index]
		if zero_armor == 0:
			sprite_zero.texture = zero_base
			face_zero.texture = face_zero_normal
			CharacterManager.black_zero_armor= false
			CharacterManager.awakened_zero_armor = false
			CharacterManager.set_zeroX8_normal_colors(sprite_zero)
			if CharacterManager.betazero_activated:
				sprite_zero.texture = zero_beta
				CharacterManager.set_new_betazero_normal_colors(sprite_zero)
		elif zero_armor == 1:
			sprite_zero.texture = zero_base
			face_zero.texture = face_black_zero
			CharacterManager.black_zero_armor= true
			CharacterManager.awakened_zero_armor = false
			CharacterManager.set_black_zeroX8_colors(sprite_zero)
			if CharacterManager.betazero_activated:
				sprite_zero.texture = zero_beta
				CharacterManager.set_new_betazero_black_colors(sprite_zero)
		elif zero_armor == 2:
			sprite_zero.texture = zero_awakened
			face_zero.texture = face_zero_awakened
			CharacterManager.black_zero_armor= false
			CharacterManager.awakened_zero_armor = true
			CharacterManager.set_zeroX8_normal_colors(sprite_zero)
			if CharacterManager.betazero_activated:
				sprite_zero.texture = zero_awakened
				CharacterManager.set_new_betazero_normal_colors(sprite_zero)
			
		if CharacterManager.custom_zero_armor:
			CharacterManager.set_zeroX8_colors(sprite_zero)
		
	if right_name.text == "Axl":
		var available_armors: PoolIntArray = get_available_axl_armors()
		if available_armors.size() <= 1:
			return
			
		var current_index: int = available_armors.find(axl_armor)
		if current_index == - 1:
			current_index = 0
			
		var new_index: int = (current_index + dir) %available_armors.size()
		if new_index < 0:
			new_index += available_armors.size()
			
		axl_armor = available_armors[new_index]
		if axl_armor == 0:
			sprite_axl.texture = axl_base
			face_axl.texture = face_axl_normal
			CharacterManager.white_axl_armor = false
			CharacterManager.cheat_axl_activated = false
			CharacterManager.set_axl_normal_colors(sprite_axl)
			if CharacterManager.floppa_axl_activated:
				sprite_axl.texture = axl_floppa
				CharacterManager.set_axl_floppa_colors(sprite_axl)
		elif axl_armor == 1:
			sprite_axl.texture = axl_base
			face_axl.texture = face_white_axl
			CharacterManager.white_axl_armor = true
			CharacterManager.cheat_axl_activated = false
			CharacterManager.set_white_axl_colors(sprite_axl)
			if CharacterManager.floppa_axl_activated:
				sprite_axl.texture = axl_floppa
				CharacterManager.set_white_axl_floppa_colors(sprite_axl)
		elif axl_armor == 2:
			sprite_axl.texture = axl_cheat
			face_axl.texture = face_axl_normal
			CharacterManager.white_axl_armor = false
			CharacterManager.cheat_axl_activated = true
			CharacterManager.set_axl_normal_colors(sprite_axl)
			if CharacterManager.floppa_axl_activated:
				sprite_axl.texture = axl_floppa_cheat
				CharacterManager.set_axl_floppa_colors(sprite_axl)
			
		if CharacterManager.custom_axl_armor:
			CharacterManager.set_axl_colors(sprite_axl)
		
	if right_name.text == "X":
		var available_armors: PoolIntArray = get_available_armors()
		if available_armors.size() <= 1:
			return
			
		var current_index: int = available_armors.find(x_armor)
		if current_index == - 1:
			current_index = 0
			
		var new_index: int = (current_index + dir) %available_armors.size()
		if new_index < 0:
			new_index += available_armors.size()
			
		x_armor = available_armors[new_index]
		if x_armor == 0:
			sprite_x.texture = x_base_x8
			face_x.texture = face_x_normal
			GameManager.add_equip_exception("head")
			GameManager.add_equip_exception("body")
			GameManager.add_equip_exception("arms")
			GameManager.add_equip_exception("legs")
			CharacterManager.ultimate_x_armor = false
			CharacterManager.infinite_x_activated = false
		elif x_armor == 1:
			sprite_x.texture = x_icarus
			face_x.texture = face_icarus_x
			GameManager.reposition_collectible_in_savedata("icarus_head")
			GameManager.reposition_collectible_in_savedata("icarus_body")
			GameManager.reposition_collectible_in_savedata("icarus_arms")
			GameManager.reposition_collectible_in_savedata("icarus_legs")
			CharacterManager.ultimate_x_armor = false
			CharacterManager.infinite_x_activated = false
		elif x_armor == 2:
			sprite_x.texture = x_hermes
			face_x.texture = face_hermes_x
			GameManager.reposition_collectible_in_savedata("hermes_head")
			GameManager.reposition_collectible_in_savedata("hermes_body")
			GameManager.reposition_collectible_in_savedata("hermes_arms")
			GameManager.reposition_collectible_in_savedata("hermes_legs")
			CharacterManager.ultimate_x_armor = false
			CharacterManager.infinite_x_activated = false
		elif x_armor == 3:
			sprite_x.texture = x_ultimate
			face_x.texture = face_ultimate_x
			GameManager.reposition_collectible_in_savedata("ultima_head")
			GameManager.reposition_collectible_in_savedata("ultima_body")
			GameManager.reposition_collectible_in_savedata("ultima_arms")
			GameManager.reposition_collectible_in_savedata("ultima_legs")
			CharacterManager.ultimate_x_armor = true
			CharacterManager.infinite_x_activated = false
		elif x_armor == 4:
			sprite_x.texture = x_infinite
			face_x.texture = face_infinite_x
			GameManager.add_equip_exception("head")
			GameManager.add_equip_exception("body")
			GameManager.add_equip_exception("arms")
			GameManager.add_equip_exception("legs")
			CharacterManager.ultimate_x_armor = false
			CharacterManager.infinite_x_activated = true
			
		if x_armor > 0:
			GameManager.remove_equip_exception("head")
			GameManager.remove_equip_exception("body")
			GameManager.remove_equip_exception("arms")
			GameManager.remove_equip_exception("legs")
			
	apply_armor_to_all_characters()
	if not dir == 0:
		choice.play()

func apply_armor_to_all_characters() -> void :
	for _char in characters:
		if "X" in _char.name:
			match x_armor:
				0:
					if CharacterManager.use_old_sprite:
						_char.texture = x_base
					else:
						_char.texture = x_base_x8
				1:
					_char.texture = x_icarus
				2:
					_char.texture = x_hermes
				3:
					_char.texture = x_ultimate
				4:
					_char.texture = x_infinite
					
		if "Zero" in _char.name:
			if CharacterManager.betazero_activated:
				match zero_armor:
					0:
						_char.texture = zero_beta
					1:
						_char.texture = zero_beta
					2:
						_char.texture = zero_awakened
			else:
				match zero_armor:
					0:
						_char.texture = zero_base
					1:
						_char.texture = zero_base
					2:
						_char.texture = zero_awakened

		if "Axl" in _char.name:
			if CharacterManager.floppa_axl_activated:
				match axl_armor:
					0:
						_char.texture = axl_floppa
					1:
						_char.texture = axl_floppa
					2:
						_char.texture = axl_floppa_cheat
			else:
				match axl_armor:
					0:
						_char.texture = axl_base
					1:
						_char.texture = axl_base
					2:
						_char.texture = axl_cheat

func switch_characters(new_direction: String) -> void :
	if animating:
		return
	
	equip.play()
	animating = true
	direction = new_direction
	var animation_time: float = 0.2
	var copy_character: TextureRect
	
	if direction == "right":
		copy_character = characters[0].duplicate()
		add_child(copy_character)
		move_child(copy_character, characters.size())
		copy_character.rect_position = characters[ - 1].rect_position + Vector2(40, 0)
		characters.append(copy_character)
	else:
		copy_character = characters[ - 1].duplicate()
		add_child(copy_character)
		move_child(copy_character, 0)
		copy_character.rect_position = characters[0].rect_position - Vector2(40, 0)
		characters.insert(0, copy_character)
		
	for i in range(characters.size()):
		var tween: Tween = Tween.new()
		add_child(tween)
		
		var start_position: Vector2 = characters[i].rect_position
		var offset: int = 40
		if direction == "right":
			offset = - 40
			
		var target_position: Vector2 = start_position + Vector2(offset, 0)
		tween.interpolate_property(characters[i], "rect_position", start_position, target_position, animation_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		tween.connect("tween_completed", self, "_on_tween_completed")

func _on_tween_completed(object, key) -> void :
	if animating:
		animating = false
		if characters.size() > 3:
			if direction == "right":
				if characters[0].name == "Duplicate" or characters[0].get_index() == 0:
					remove_child(characters[0])
					characters.pop_front()
			else:
				if characters[ - 1].name == "Duplicate" or characters[ - 1].get_index() == characters.size() - 1:
					remove_child(characters[ - 1])
					characters.pop_back()
		set_menu_visibility()
