extends X8TextureButton
class_name X8OptionButton

var active: bool = false
onready var value: Label = get_node_or_null("Value")

var frequency: float = 0.5
var timer: float = 0.0

const OptionArrow = preload("res://src/Options/OptionArrow.gd")
const ARROW_SIZE := Vector2(14, 11)
const ARROW_GAP := 3.0
var arrow_left = null
var arrow_right = null

func _ready() -> void :
	var _s = Savefile.connect("loaded", self, "setup")
	Event.listen("update_options", self, "setup")
	if uses_arrows():
		call_deferred("create_arrows")

# 터치로도 값을 줄일 수 있도록 값 양옆에 < > 화살표를 달 옵션이면 true 로 바꾼다
func uses_arrows() -> bool:
	return false

# 화살표가 비워둘 값 글자 자리 (자릿수)
func arrow_value_digits() -> int:
	return 3

func create_arrows() -> void :
	if value == null or arrow_left != null:
		return
	var font = value.get_font("font")
	var digit_w = font.get_string_size("0").x if font else 7.0
	var text_w = digit_w * arrow_value_digits()
	var right_edge = value.rect_position.x + value.rect_size.x
	var y = round((rect_size.y - ARROW_SIZE.y) / 2.0)

	arrow_left = OptionArrow.new()
	arrow_left.direction = - 1
	arrow_left.rect_size = ARROW_SIZE
	arrow_left.rect_position = Vector2(round(right_edge - text_w - ARROW_GAP - ARROW_SIZE.x), y)
	add_child(arrow_left)
	arrow_left.connect("step_requested", self, "on_arrow_step")

	arrow_right = OptionArrow.new()
	arrow_right.direction = 1
	arrow_right.rect_size = ARROW_SIZE
	arrow_right.rect_position = Vector2(round(right_edge + ARROW_GAP), y)
	add_child(arrow_right)
	arrow_right.connect("step_requested", self, "on_arrow_step")

func on_arrow_step(direction: int) -> void :
	if focus_mode == Control.FOCUS_NONE:
		return
	if not has_focus():
		silent = true
		grab_focus()
		silent = false
	flash()
	if direction < 0:
		decrease_value()
	else:
		increase_value()
	play_pick_sound()

func setup() -> void :
	pass

func _on_focus_exited() -> void :
	._on_focus_exited()
	active = false

func _on_focus_entered() -> void :
	._on_focus_entered()
	active = true

func on_press() -> void :
	strong_flash()
	increase_value()
	play_pick_sound()

func play_pick_sound() -> void :
	if not silent and menu:
		menu.play_pick_sound()
	silent = false

func _physics_process(delta: float) -> void :
	if active:
		timer += delta
		if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
			if frequency == 0.5:
				process_inputs()
			elif timer > frequency:
				process_inputs()
		else:
			timer = 0
			frequency = 0.5

func reduce_frequency() -> void :
	frequency = frequency * 0.8
	frequency = clamp(frequency, 0.04, 0.5)

func process_inputs() -> void :
	timer = 0
	if Input.is_action_pressed("ui_right"):
		flash()
		increase_value()
		play_pick_sound()
		reduce_frequency()
	elif Input.is_action_pressed("ui_left"):
		flash()
		decrease_value()
		play_pick_sound()
		reduce_frequency()
	elif Input.is_action_pressed("ui_accept"):
		flash()
		increase_value()
		play_sound()
		reduce_frequency()
	else:
		timer = 0
		frequency = 0.5

func increase_value() -> void :
	display_value("increased")

func decrease_value() -> void :
	display_value("decreased")

func display_value(new_value) -> void :
	if value:
		value.text = tr(str(new_value))
