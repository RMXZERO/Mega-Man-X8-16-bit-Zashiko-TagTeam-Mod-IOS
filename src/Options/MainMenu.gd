extends X8Menu

onready var info: Label = $Menu / demo_02
onready var _gamestartbutton: X8TextureButton = $Menu / OptionHolder / GameStart
onready var _loadingbutton: X8TextureButton = $Menu / OptionHolder / Loading
onready var _optionsbutton: X8TextureButton = $Menu / OptionHolder / Options
onready var _keyconfigbutton: X8TextureButton = $Menu / OptionHolder / Keycfg
onready var _cursor: AnimatedSprite = $MegamanCursor
onready var Event_screen: TextureRect = $Menu / EVENT
onready var megaman: TextureRect = $Menu/MegaMan
onready var rockman: TextureRect = $Menu/RockMan

var _event_screen: Texture = null

func _input(event: InputEvent) -> void :
	if not locked:
		if event.is_action_pressed("pause"):
			var start_event: InputEventAction = InputEventAction.new()
			start_event.action = "ui_accept"
			start_event.pressed = true
			Input.parse_input_event(start_event)

func _ready() -> void :
	info.text = GameManager.version
	var _option = get_node_or_null("Menu/OptionHolder/Options/OptionsMenu")
	if _option:
		var _set_title = _option.get_node_or_null("Menu/scrollContainer/OptionHolder/Title Type/Button")
		if _set_title:
			var _s = _set_title.connect("focus_exited", self, "set_tltle")
	set_tltle()

func set_tltle() -> void :
	if rockman:
		rockman.visible = false
	if megaman:
		megaman.visible = false
	if Configurations.exists("TitleType"):
		if Configurations.get("TitleType"):
			if megaman:
				megaman.visible = true
		else:
			if rockman:
				rockman.visible = true

