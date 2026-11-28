extends Control
# 옵션 값 옆에 붙는 터치용 화살표 (< >)
# 누르면 한 칸, 계속 누르고 있으면 점점 빠르게 반복해서 값을 바꾼다 (키보드 좌우 길게 누르기와 같은 동작)

signal step_requested(direction)

export var direction: int = 1   # -1: 줄이기(<), 1: 늘리기(>)

const COLOR_NORMAL := Color(1, 1, 1, 1)
const COLOR_PRESSED := Color(0.984314, 1, 0.686275, 1)
const COLOR_SHADOW := Color(0.415686, 0.415686, 0.415686, 1)

var pressed_down: bool = false
var timer: float = 0.0
var frequency: float = 0.5


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	set_physics_process(false)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			start_hold()
		else:
			stop_hold()
		accept_event()

func start_hold() -> void :
	pressed_down = true
	timer = 0.0
	frequency = 0.5
	emit_signal("step_requested", direction)
	set_physics_process(true)
	update()

func stop_hold() -> void :
	pressed_down = false
	set_physics_process(false)
	update()

func _physics_process(delta: float) -> void :
	timer += delta
	if timer > frequency:
		timer = 0.0
		emit_signal("step_requested", direction)
		frequency = clamp(frequency * 0.8, 0.04, 0.5)

func _notification(what: int) -> void :
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		stop_hold()

# 폰트에 < > 글자가 있는지와 상관없이 픽셀로 직접 그린다 (4x7 크기)
func _draw() -> void :
	var main_color = COLOR_PRESSED if pressed_down else COLOR_NORMAL
	var ox = int((rect_size.x - 4) / 2)
	var oy = int((rect_size.y - 7) / 2)
	_draw_chevron(ox + 1, oy + 1, COLOR_SHADOW)
	_draw_chevron(ox, oy, main_color)

func _draw_chevron(ox: int, oy: int, color: Color) -> void :
	for i in range(7):
		var d = abs(3 - i)
		var x = d if direction < 0 else 3 - d
		draw_rect(Rect2(ox + x, oy + i, 2, 1), color)
