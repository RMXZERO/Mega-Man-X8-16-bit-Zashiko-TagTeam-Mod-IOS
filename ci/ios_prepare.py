#!/usr/bin/env python3
"""iOS 빌드 전처리 (멱등). 저장소 루트에서 실행.

1) CharacterManager.gd : iOS를 모바일(터치) 플랫폼으로 취급
2) Character_Spawner.gd: 존재하지 않는 TouchControl.gd 경로 수정
3) project.godot       : iOS 내보내기에 필요한 PVRTC / ETC2 임포트 활성화
4) export_presets.cfg  : iOS 프리셋(preset.N) 추가
5) ko-assets/          : 한글판(exe)에서 추출한 한국어 번역/폰트를 저장소에 덮어쓰기 + 번역 목록에 ko 추가
"""
import shutil
import os
import re
import sys

BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.mmx8.allinone.ios")
TEAM_ID = os.environ.get("TEAM_ID", "AAAAAAAAAA")  # 서명 안 하므로 형식만 맞는 더미


def read(path):
    with open(path, "r", encoding="utf-8", newline="") as f:
        return f.read()


def write(path, text):
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)


def patch_character_manager():
    path = "System/CharacterManager.gd"
    src = read(path)
    if "# iOS-PORT" in src:
        print(f"[skip] {path} (이미 패치됨)")
        return
    nl = "\r\n" if "\r\n" in src else "\n"
    pat = re.compile(
        r"func is_Android\(\) -> bool:\s*\n\s*if OS\.get_name\(\) == \"Android\":\s*\n\s*return true\s*\n\s*return false\s*\n"
        r"func touch_controls_enabled\(\) -> bool:\s*\n\s*if is_Android\(\):\s*\n\s*return touch_controls\s*\n\s*return false",
        re.M,
    )
    new = nl.join([
        "# iOS-PORT: iOS도 모바일(터치) 플랫폼으로 취급 (스테이지 터치 UI는 IOSTouchOverlay 가 담당)",
        "func is_Android() -> bool:",
        "\tvar _os = OS.get_name()",
        "\treturn _os == \"Android\" or _os == \"iOS\"",
        "func touch_controls_enabled() -> bool:",
        "\tif OS.get_name() == \"iOS\":",
        "\t\treturn false",
        "\tif is_Android():",
        "\t\treturn touch_controls",
        "\treturn false",
    ])
    out, n = pat.subn(lambda m: new, src, count=1)
    if n != 1:
        sys.exit(f"[error] {path}: is_Android 블록을 찾지 못함 (소스가 바뀌었는지 확인)")
    write(path, out)
    print(f"[ok]   {path}")


def patch_spawner():
    path = "System/Character_Spawner.gd"
    src = read(path)
    old = 'res://Axl_mod/system/Android/TouchControl.gd'
    new = 'res://System/Android/TouchControl.gd'
    if old not in src:
        print(f"[skip] {path} (이미 패치됨/경로 없음)")
        return
    write(path, src.replace(old, new))
    print(f"[ok]   {path}")


def patch_project_godot():
    path = "project.godot"
    src = read(path)
    nl = "\r\n" if "\r\n" in src else "\n"
    m = re.search(r"^\[rendering\]\s*$", src, re.M)
    if not m:
        sys.exit("[error] project.godot에 [rendering] 섹션이 없음")
    want = ["vram_compression/import_pvrtc=true", "vram_compression/import_etc2=true"]
    add = [w for w in want if w.split("=")[0] not in src]
    if not add:
        print("[skip] project.godot (이미 설정됨)")
        return
    ins = m.end()
    src = src[:ins] + nl + nl.join(add) + src[ins:]
    write(path, src)
    print(f"[ok]   project.godot += {add}")


PRESET = """
[preset.{n}]

name="iOS"
platform="iOS"
runnable=true
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter="*.ase, *.aseprite, *.pdn, *.csv, *.txt, *.md, *.zip, *.dll, *.exe, *.ico, *.gif, *.world"
export_path=""
script_export_mode=1
script_encryption_key=""

[preset.{n}.options]

application/app_store_team_id="{team}"
application/identifier="{bundle}"
application/bundle_identifier="{bundle}"
icons/app_store_1024x1024="res://ci_icon_1024.png"
application/short_version="0.9.1"
application/version="0.9.1"
application/launch_screens_interpolation=0
application/targeted_device_family=2
orientation/portrait=false
orientation/landscape_left=true
orientation/landscape_right=true
"""


def patch_presets():
    path = "export_presets.cfg"
    src = read(path) if os.path.exists(path) else ""
    if re.search(r'^platform="iOS"', src, re.M):
        print("[skip] export_presets.cfg (iOS 프리셋 이미 있음)")
        return
    nums = [int(x) for x in re.findall(r"^\[preset\.(\d+)\]", src, re.M)]
    n = (max(nums) + 1) if nums else 0
    nl = "\r\n" if "\r\n" in src else "\n"
    block = PRESET.format(n=n, team=TEAM_ID, bundle=BUNDLE_ID).replace("\n", nl)
    write(path, src.rstrip() + nl + block)
    print(f"[ok]   export_presets.cfg += preset.{n} (iOS)")


def apply_korean():
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "ko-assets")
    root = os.path.normpath(root)
    if not os.path.isdir(root):
        print("[skip] ko-assets/ 없음 (한국어 미적용)")
        return
    n = 0
    for base, _, files in os.walk(root):
        for name in files:
            src = os.path.join(base, name)
            rel = os.path.relpath(src, root)
            os.makedirs(os.path.dirname(rel) or ".", exist_ok=True)
            shutil.copyfile(src, rel)
            n += 1
    print(f"[ok]   ko-assets: {n}개 파일 복사")
    # project.godot 번역 목록에 ko 추가
    path = "project.godot"
    src = read(path)
    ko = "res://src/Localization/real_translations.ko.translation"
    if ko in src:
        print("[skip] project.godot (ko 번역 이미 등록됨)")
        return
    m = re.search(r"(translations=PoolStringArray\()(.*?)(\s*\))", src, re.S)
    if not m:
        sys.exit("[error] project.godot에서 locale/translations 목록을 찾지 못함")
    body = m.group(2).rstrip()
    new = body + ', "' + ko + '"' if body.strip() else '"' + ko + '"'
    src = src[: m.start(2)] + new + src[m.end(2):]
    write(path, src)
    print("[ok]   project.godot += ko 번역")


OVERLAY_GD = r'''extends CanvasLayer
# iOS 가상 패드 (UnleashedRecompiled 의 XeniOS 스타일 레이아웃을 Godot 으로 옮김)
# - 왼쪽: 스틱 + D-패드 링 / 오른쪽: A B X Y / 위: LB RB BACK START / 양옆: LT RT
# - 캐릭터를 고른 뒤 스테이지(플레이어가 있을 때)에서만 표시, 메뉴에서는 화면을 직접 터치
# - 블루투스 컨트롤러가 연결되어 있으면 자동으로 숨김

const STICK_DEADZONE = 0.10
const STICK_ACTIVATION_RADIUS = 0.308
const STICK_DPAD_RING_RADIUS = 0.32
const WIDE_SCREEN_SAFE_MARGIN = 0.055
const DIGITAL_THRESHOLD = 0.25
const HIT_GROW = 1.5  # 버튼 터치 판정 배율 (그려진 크기 대비)
const BASE_SIZE = Vector2(398.0, 224.0)  # 게임 기준 해상도 (16:9)
const ASPECT_STRETCH = 0   # 비율 무시, 화면 전체로 늘림
const ASPECT_KEEP = 1      # 비율 유지 (양옆 검은 띠)
const ASPECT_WIDE = 2      # 화면 비율에 맞춰 가로로 더 넓게 보이게
const DEFAULT_ASPECT = __DEFAULT_ASPECT__

var stick_frame = Rect2(0.0265, 0.5353, 0.2470, 0.4095)

# [id, 표시 글자, 프레임(0~1), 연결할 게임 액션]
var buttons = [
	["back", "BACK", Rect2(0.390, 0.045, 0.080, 0.112), ["select"]],
	["start", "START", Rect2(0.495, 0.045, 0.085, 0.112), ["pause"]],
	["lb", "LB", Rect2(0.095, 0.168, 0.120, 0.112), ["weapon_select_left"]],
	["rb", "RB", Rect2(0.860, 0.168, 0.120, 0.112), ["weapon_select_right"]],
	["lt", "TAG", Rect2(0.095, 0.305, 0.120, 0.110), ["char_switch"]],  # TagTeam: 캐릭터 교체
	["rt", "RT", Rect2(0.860, 0.305, 0.120, 0.110), ["select_special"]],
	["y", "Y", Rect2(0.8263, 0.5329, 0.0845, 0.1495), ["alt_fire"]],
	["x", "X", Rect2(0.7572, 0.6623, 0.0845, 0.1495), ["fire", "ui_accept"]],
	["b", "B", Rect2(0.8954, 0.6623, 0.0845, 0.1495), ["dash", "ui_cancel"]],
	["a", "A", Rect2(0.8263, 0.7918, 0.0845, 0.1495), ["jump", "ui_accept"]],
]

var dir_actions = {
	"left": ["ui_left", "move_left"],
	"right": ["ui_right", "move_right"],
	"up": ["ui_up", "move_up"],
	"down": ["ui_down", "move_down"],
}

var canvas: Control
var font: Font
var captures: Dictionary = {}
var active: Dictionary = {}
var shown: bool = false
var timer: float = 0.0
var tap_index: int = -1
var tap_button = null
var tap_fired: bool = false
var press_pf: Dictionary = {}      # 액션별 눌린 시점의 물리 프레임
var press_if: Dictionary = {}      # 액션별 눌린 시점의 idle 프레임
var pending_release: Dictionary = {}  # 게임이 한 번도 못 본 채 떼어진 액션 (보류)
var last_extra: float = 0.0           # 마지막으로 반영한 '양옆 늘어난 폭의 절반'
var last_aspect: int = -1             # 마지막으로 적용한 stretch aspect


func _ready() -> void:
	layer = 100
	pause_mode = Node.PAUSE_MODE_PROCESS
	canvas = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	canvas.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	canvas.connect("draw", self, "_on_draw")
	font = canvas.get_font("font", "Label")
	Input.connect("joy_connection_changed", self, "_on_joy_changed")
	get_tree().connect("node_added", self, "_on_node_added")
	_apply_stretch()
	set_shown(false)
	_update_layer_transform()
	timer = 0.0


func _on_joy_changed(_device: int, _connected: bool) -> void:
	timer = 0.0


func _in_stage() -> bool:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("is_player_in_scene"):
		return gm.is_player_in_scene()
	return false


func _physics_process(_delta: float) -> void:
	_flush_releases()


func _process(delta: float) -> void:
	_flush_releases()
	timer -= delta
	if timer > 0.0:
		return
	timer = 0.15
	_apply_stretch()
	_update_layer_transform()
	var want_show = OS.get_name() == "iOS" and Input.get_connected_joypads().size() == 0 and _in_stage()
	if want_show != shown:
		set_shown(want_show)


# ---- 화면 비율 모드 (옵션 'Aspect Ratio') ----
# 0 = 늘리기(비율 무시) / 1 = 검은 띠 / 2 = 가로로 더 넓게
func aspect_mode() -> int:
	if OS.get_name() != "iOS":
		return ASPECT_KEEP
	var cfg = get_node_or_null("/root/Configurations")
	if cfg != null:
		var v = cfg.get("Aspect")
		if v != null:
			return int(v)
	return DEFAULT_ASPECT


# 다른 스크립트(GameManager 등)가 set_screen_stretch 에 넘길 비율 모드
func aspect() -> int:
	var m = aspect_mode()
	if m == ASPECT_STRETCH:
		return SceneTree.STRETCH_ASPECT_IGNORE
	if m == ASPECT_WIDE:
		# 16:9 보다 가로로 긴 화면(아이폰)에서만 넓힘. 4:3 같은 화면은 예전처럼 검은 띠
		# 타이틀/옵션/캐릭터 선택 같은 메뉴는 398x224(16:9) 기준으로만 만들어져 있어서 넓히면 어긋남
		# -> 스테이지(플레이어가 있을 때)에서만 넓히고, 메뉴는 예전처럼 16:9 + 검은 띠
		var win = OS.window_size
		if _in_stage() and win.y > 0.0 and win.x / win.y >= BASE_SIZE.x / BASE_SIZE.y - 0.001:
			return SceneTree.STRETCH_ASPECT_EXPAND
	return SceneTree.STRETCH_ASPECT_KEEP


func _apply_stretch() -> void:
	var a = aspect()
	if a == last_aspect:
		return
	last_aspect = a
	var mode = SceneTree.STRETCH_MODE_2D
	var cfg = get_node_or_null("/root/Configurations")
	if cfg != null and cfg.get("StretchMode"):
		mode = SceneTree.STRETCH_MODE_VIEWPORT
	get_tree().set_screen_stretch(mode, a, BASE_SIZE)


# 게임 화면의 가로 폭. WIDE 모드에서만 398 보다 넓어짐 (StateCamera 가 사용)
func view_width() -> float:
	if aspect_mode() == ASPECT_WIDE:
		return max(get_viewport().get_visible_rect().size.x, BASE_SIZE.x)
	return BASE_SIZE.x


# 양옆으로 늘어난 폭의 절반. UI 는 이만큼 옮겨서 예전 16:9 영역 가운데에 둔다
func wide_extra() -> float:
	return (view_width() - BASE_SIZE.x) * 0.5


# 이 레이어(패드)가 화면 위에 그려지는 방식을 모드에 맞게 보정
func _update_layer_transform() -> void:
	var sc = Vector2(1.0, 1.0)
	var off = Vector2.ZERO
	var mode = aspect_mode()
	if mode == ASPECT_STRETCH:
		# 늘리기 모드: 화면 전체가 가로로 늘어나므로 패드만 반대로 줄여서 예전 위치/모양 유지
		var win = OS.window_size
		if win.x > 0.0 and win.y > 0.0:
			var r = win.x / win.y
			var base_r = BASE_SIZE.x / BASE_SIZE.y
			if r > base_r:
				sc.x = base_r / r
			elif r < base_r:
				sc.y = r / base_r
		off = Vector2(BASE_SIZE.x * 0.5 * (1.0 - sc.x), BASE_SIZE.y * 0.5 * (1.0 - sc.y))
	elif mode == ASPECT_WIDE:
		off = Vector2(wide_extra(), 0.0)
	scale = sc
	offset = off
	if abs(wide_extra() - last_extra) > 0.01:
		_refresh_wide()


# ---- 넓은 화면(WIDE) 모드: 게임의 UI 를 16:9 영역 가운데로 ----
# 세계(스테이지)는 화면 전체로 넓어지고, HUD/메뉴/대화창은 지금까지처럼 가운데 16:9 영역에 그려진다.
func _on_node_added(n: Node) -> void:
	if n is CanvasLayer:
		if n != self and not (n is ParallaxBackground):
			call_deferred("_adopt_layer", n)
	elif n is Control:
		var p = n.get_parent()
		if p != null and p is CanvasLayer and p.is_in_group("wide_ui"):
			call_deferred("_adopt_control", n)


func _adopt_layer(l) -> void:
	if not is_instance_valid(l) or not (l is CanvasLayer):
		return
	if l.is_in_group("wide_ui"):
		return
	if l.layer >= 120:
		# CRT 같은 전체 화면 효과 레이어: 옮기지 않고 폭만 넓힌다
		for c in l.get_children():
			if c is ColorRect:
				c.rect_size = Vector2(view_width(), c.rect_size.y)
				if c.material is ShaderMaterial:
					c.material.set_shader_param("resolution", Vector2(view_width(), BASE_SIZE.y))
		return
	l.add_to_group("wide_ui")
	l.set_meta("wide_base", l.offset)
	_apply_layer(l)


func _apply_layer(l) -> void:
	var base = Vector2.ZERO
	if l.has_meta("wide_base"):
		base = l.get_meta("wide_base")
	l.offset = base + Vector2(wide_extra(), 0.0)
	for c in l.get_children():
		_adopt_control(c)


func _refresh_wide() -> void:
	last_extra = wide_extra()
	for l in get_tree().get_nodes_in_group("wide_ui"):
		if is_instance_valid(l):
			_apply_layer(l)


func _adopt_control(c) -> void:
	if not is_instance_valid(c) or not (c is Control):
		return
	var s = wide_extra()
	var done = 0.0
	if c.has_meta("wide_done"):
		done = c.get_meta("wide_done")
	var d = s - done
	if abs(d) < 0.01:
		return
	# 오른쪽/가운데 기준(앵커)으로 놓인 컨트롤은 화면이 넓어진 만큼 밀리므로, 원래 398 폭 기준 위치로 되돌린다
	if c.anchor_left != 0.0 or c.anchor_right != 0.0:
		c.margin_left -= c.anchor_left * 2.0 * d
		c.margin_right -= c.anchor_right * 2.0 * d
	if not c.has_meta("wide_done"):
		# 화면 전체를 덮는 색 상자(페이드/번쩍임/배경색)면 양옆 끝까지 넓힌다
		if c is ColorRect and c.rect_size.x >= BASE_SIZE.x - 2.0 and c.rect_size.y >= BASE_SIZE.y - 2.0:
			c.set_meta("wide_rect", true)
	if c.has_meta("wide_rect"):
		c.rect_position = Vector2(c.rect_position.x - d, c.rect_position.y)
		c.rect_size = Vector2(c.rect_size.x + 2.0 * d, c.rect_size.y)
	c.set_meta("wide_done", s)


# 화면(뷰포트) 터치 좌표 -> 패드 좌표 (위 레이어 변환의 역변환)
func _to_pad(p: Vector2) -> Vector2:
	return Vector2((p.x - offset.x) / scale.x, (p.y - offset.y) / scale.y)


func set_shown(v: bool) -> void:
	shown = v
	canvas.visible = v
	if not v:
		captures.clear()
		_apply()


func _space() -> Rect2:
	var s = BASE_SIZE
	var margin = 0.0
	if (s.x / s.y) > 1.9:
		margin = s.x * WIDE_SCREEN_SAFE_MARGIN
	return Rect2(margin, 0.0, s.x - margin * 2.0, s.y)


func _to_window(frame: Rect2) -> Rect2:
	var sp = _space()
	return Rect2(sp.position.x + frame.position.x * sp.size.x, sp.position.y + frame.position.y * sp.size.y, frame.size.x * sp.size.x, frame.size.y * sp.size.y)


func _pill_contains(r: Rect2, p: Vector2, grow: float) -> bool:
	var radius = min(r.size.x, r.size.y) * 0.5
	var c = r.position + r.size * 0.5
	var hx = max(r.size.x * 0.5 - radius, 0.0)
	var hy = max(r.size.y * 0.5 - radius, 0.0)
	var dx = max(abs(p.x - c.x) - hx, 0.0)
	var dy = max(abs(p.y - c.y) - hy, 0.0)
	var rr = radius * grow
	return dx * dx + dy * dy <= rr * rr


func _find_control(p: Vector2) -> String:
	var best = ""
	var best_d = 1.0e20
	for b in buttons:
		var r = _to_window(b[2])
		if _pill_contains(r, p, HIT_GROW):
			var d = p.distance_squared_to(r.position + r.size * 0.5)
			if d < best_d:
				best_d = d
				best = b[0]
	if best != "":
		return best
	if _stick_area_has(p):
		return "stick"
	return ""


# 이전 위치에서 지금 위치까지 손가락이 지나간 길을 훑어 마지막으로 지난 버튼을 찾는다.
# (폰에서 빠르게 문지르면 드래그 이벤트가 듬성듬성 와서 버튼 위를 건너뛰기 때문)
func _find_button_on_path(a: Vector2, b: Vector2) -> String:
	var found = ""
	var steps = int(ceil(a.distance_to(b) / 4.0))
	if steps < 1:
		steps = 1
	for i in range(1, steps + 1):
		var id = _find_button_id(a.linear_interpolate(b, float(i) / float(steps)))
		if id != "":
			found = id
	return found


func _find_button_id(p: Vector2) -> String:
	var best = ""
	var best_d = 1.0e20
	for b in buttons:
		var r = _to_window(b[2])
		if _pill_contains(r, p, HIT_GROW):
			var d = p.distance_squared_to(r.position + r.size * 0.5)
			if d < best_d:
				best_d = d
				best = b[0]
	return best


# 스틱 터치 영역: 기존처럼 고정된 스틱 위치(stick_frame) 안에서만 시작
func _stick_area_has(p: Vector2) -> bool:
	return _to_window(stick_frame).has_point(p)


func _stick_zone(sf: Rect2, p: Vector2) -> String:
	var c = sf.position + sf.size * 0.5
	var ring = min(sf.size.x, sf.size.y) * STICK_DPAD_RING_RADIUS
	var d = p - c
	if d.length() <= ring:
		return "stick"
	if abs(d.x) > abs(d.y):
		if d.x > 0.0:
			return "right"
		return "left"
	if d.y > 0.0:
		return "down"
	return "up"


func _stick_delta(sf: Rect2, cap: Dictionary) -> Vector2:
	var outer = min(sf.size.x, sf.size.y) * STICK_ACTIVATION_RADIUS
	var delta = cap["current"] - cap["anchor"]
	if delta.length() > outer:
		delta = delta.normalized() * outer
	return delta


func _stick_vector(sf: Rect2, cap: Dictionary) -> Vector2:
	var outer = min(sf.size.x, sf.size.y) * STICK_ACTIVATION_RADIUS
	var n = _stick_delta(sf, cap) / outer
	var mag = n.length()
	if mag < STICK_DEADZONE or mag <= 0.0:
		return Vector2.ZERO
	var rescaled = clamp((mag - STICK_DEADZONE) / (1.0 - STICK_DEADZONE), 0.0, 1.0)
	return n / mag * rescaled


func _input(event: InputEvent) -> void:
	if OS.get_name() != "iOS":
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			var p = event.position
			var pp = _to_pad(p)
			var id = ""
			if shown:
				id = _find_control(pp)
			if id == "":
				_begin_tap(event.index, p)
				return
			var cap = {"control": id, "origin": id, "zone": "", "anchor": pp, "current": pp}
			if id == "stick":
				cap["zone"] = "stick"
				var sfc = _to_window(stick_frame)
				cap["anchor"] = sfc.position + sfc.size * 0.5  # 스틱 중심 고정
			captures[event.index] = cap
		else:
			if event.index == tap_index:
				_end_tap(event.position)
			if captures.has(event.index):
				var cr = captures[event.index]
				if cr["control"] != "stick":
					var rid = _find_button_on_path(cr["current"], _to_pad(event.position))
					if rid != "" and rid != cr["control"]:
						cr["control"] = rid
						_apply()  # 눌림을 먼저 반영 (떼는 건 게임이 한 번 본 뒤에 처리됨)
			captures.erase(event.index)
		_apply()
	elif event is InputEventScreenDrag:
		if captures.has(event.index):
			var cp = captures[event.index]
			var dp = _to_pad(event.position)
			var prev = cp["current"]
			cp["current"] = dp
			if cp["control"] != "stick":
				var nid = _find_button_on_path(prev, dp)
				if nid != "" and nid != cp["control"]:
					cp["control"] = nid  # 누른 채 문질러서 다른 버튼 위로 이동
			_apply()


# 메뉴의 화살표 같은 X8 버튼을 직접 눌렀을 때: 기본 마우스 에뮬레이션으로 눌리지 않으면 대신 눌러 줌
func _find_button_at(node: Node, p: Vector2):
	if node == self:
		return null
	var kids = node.get_children()
	for i in range(kids.size() - 1, -1, -1):
		var found = _find_button_at(kids[i], p)
		if found != null:
			return found
	if node is TextureButton and node.has_method("on_press") and not node.disabled and node.focus_mode != Control.FOCUS_NONE:
		if node.is_visible_in_tree() or _hidden_hit_area_ok(node):
			if _button_has_point(node, p):
				return node
	return null


# 캐릭터 선택 화면의 좌우 화살표 버튼은 씬에서 숨겨져(visible=false) 있어 터치를 못 받음.
# 부모 화면이 보이는 동안에는 숨겨진 상태 그대로 터치 영역으로 사용한다.
func _hidden_hit_area_ok(node: Node) -> bool:
	if node.name != "next_player" and node.name != "prev_player":
		return false
	if node.get("direction") == null:
		return false
	var parent = node.get_parent()
	return parent != null and parent is CanvasItem and parent.is_visible_in_tree()


func _button_has_point(b, p: Vector2) -> bool:
	var local = b.get_global_transform_with_canvas().affine_inverse().xform(p)
	return Rect2(Vector2.ZERO, b.rect_size).has_point(local)


func _begin_tap(index: int, p: Vector2) -> void:
	_clear_tap()
	var b = _find_button_at(get_tree().root, p)
	if b == null:
		return
	tap_index = index
	tap_button = b
	tap_fired = false
	b.connect("pressed", self, "_on_tap_probe")


func _on_tap_probe() -> void:
	tap_fired = true


func _clear_tap() -> void:
	if tap_button != null and is_instance_valid(tap_button):
		if tap_button.is_connected("pressed", self, "_on_tap_probe"):
			tap_button.disconnect("pressed", self, "_on_tap_probe")
	tap_index = -1
	tap_button = null


func _end_tap(p: Vector2) -> void:
	var b = tap_button
	if b == null or not is_instance_valid(b):
		_clear_tap()
		return
	var inside = _button_has_point(b, p)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var fired = tap_fired
	if is_instance_valid(b):
		if b.is_connected("pressed", self, "_on_tap_probe"):
			b.disconnect("pressed", self, "_on_tap_probe")
		if inside and not fired and b.focus_mode != Control.FOCUS_NONE:
			if b.is_visible_in_tree():
				b.grab_focus()
			b.emit_signal("pressed")
	if tap_button == b:
		tap_index = -1
		tap_button = null


func _want_dir(want: Dictionary, dir: String) -> void:
	for a in dir_actions[dir]:
		want[a] = true


func _apply() -> void:
	var want = {}
	for i in captures.keys():
		var cap = captures[i]
		if cap["control"] == "stick":
			var z = cap["zone"]
			if z == "stick":
				var v = _stick_vector(_to_window(stick_frame), cap)
				if v.x < -DIGITAL_THRESHOLD:
					_want_dir(want, "left")
				elif v.x > DIGITAL_THRESHOLD:
					_want_dir(want, "right")
				if v.y < -DIGITAL_THRESHOLD:
					_want_dir(want, "up")
				elif v.y > DIGITAL_THRESHOLD:
					_want_dir(want, "down")
			elif z != "":
				_want_dir(want, z)
		else:
			for b in buttons:
				if b[0] == cap["control"] or b[0] == cap.get("origin", ""):
					for a in b[3]:
						want[a] = true
	for a in active.keys():
		if not want.has(a):
			_send_action(a, false)
			active.erase(a)
	for a in want.keys():
		if not active.has(a):
			_send_action(a, true)
			active[a] = true
	if canvas:
		canvas.update()


# Input.action_press() 는 폴링(is_action_pressed)만 바꾸고 _input(event) 로는 이벤트가 안 간다.
# Pause.gd 등은 event.is_action_pressed() 를 쓰므로 InputEventAction 을 직접 주입한다.
# (parse_input_event 는 액션 상태도 같이 갱신하므로 폴링 방식 코드도 그대로 동작)
func _send_action(a: String, pressed: bool) -> void:
	if pressed:
		if pending_release.has(a):
			pending_release.erase(a)
			_inject(a, false)
		press_pf[a] = Engine.get_physics_frames()
		press_if[a] = Engine.get_idle_frames()
		_inject(a, true)
	else:
		if _seen_by_game(a):
			_inject(a, false)
		else:
			pending_release[a] = true


# 눌린 뒤 물리 프레임과 idle 프레임이 각각 한 번 이상 지났는지 (is_action_just_pressed 가 true 를 볼 기회가 있었는지)
func _seen_by_game(a: String) -> bool:
	if not press_pf.has(a):
		return true
	return Engine.get_physics_frames() > press_pf[a] and Engine.get_idle_frames() > press_if[a]


func _flush_releases() -> void:
	if pending_release.empty():
		return
	for a in pending_release.keys():
		if _seen_by_game(a):
			pending_release.erase(a)
			_inject(a, false)


func _inject(a: String, pressed: bool) -> void:
	var ev = InputEventAction.new()
	ev.action = a
	ev.pressed = pressed
	if pressed:
		ev.strength = 1.0
	else:
		ev.strength = 0.0
	Input.parse_input_event(ev)


func _white(alpha: float) -> Color:
	return Color(1, 1, 1, clamp(alpha, 0.0, 1.0))


func _capsule(r: Rect2) -> PoolVector2Array:
	var radius = min(r.size.x, r.size.y) * 0.5
	var c = r.position + r.size * 0.5
	var sx = max(r.size.x * 0.5 - radius, 0.0)
	var sy = max(r.size.y * 0.5 - radius, 0.0)
	var pts = PoolVector2Array()
	var n = 16
	if sx > 0.0:
		for i in range(n + 1):
			var a1 = -PI * 0.5 + PI * float(i) / float(n)
			pts.append(c + Vector2(sx, 0) + Vector2(cos(a1), sin(a1)) * radius)
		for j in range(n + 1):
			var a2 = PI * 0.5 + PI * float(j) / float(n)
			pts.append(c - Vector2(sx, 0) + Vector2(cos(a2), sin(a2)) * radius)
	elif sy > 0.0:
		for k in range(n + 1):
			var a3 = PI * float(k) / float(n)
			pts.append(c + Vector2(0, sy) + Vector2(cos(a3), sin(a3)) * radius)
		for m in range(n + 1):
			var a4 = PI + PI * float(m) / float(n)
			pts.append(c - Vector2(0, sy) + Vector2(cos(a4), sin(a4)) * radius)
	else:
		for q in range(n * 2):
			var a5 = TAU * float(q) / float(n * 2)
			pts.append(c + Vector2(cos(a5), sin(a5)) * radius)
	return pts


func _label(text: String, r: Rect2, col: Color) -> void:
	if font == null:
		return
	var size_px = min(r.size.x, r.size.y) * 0.42
	if text.length() > 2:
		size_px = min(r.size.x, r.size.y) * 0.30
	var k = size_px / font.get_height()
	var w = font.get_string_size(text).x * k
	var c = r.position + r.size * 0.5
	var baseline = c.y + (font.get_ascent() - font.get_height() * 0.5) * k
	canvas.draw_set_transform(Vector2(c.x - w * 0.5, baseline), 0.0, Vector2(k, k))
	canvas.draw_string(font, Vector2.ZERO, text, col)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _on_draw() -> void:
	if not shown:
		return
	var bw = 0.6
	var sf = _to_window(stick_frame)
	var c = sf.position + sf.size * 0.5
	for i0 in captures.keys():
		if captures[i0]["control"] == "stick":
			c = captures[i0]["anchor"]
	var base_size = min(sf.size.x, sf.size.y)
	var radius = base_size * 0.5
	var ring = base_size * STICK_DPAD_RING_RADIUS
	canvas.draw_circle(c, radius, _white(0.10))
	canvas.draw_arc(c, radius, 0.0, TAU, 48, _white(0.38), bw, true)
	canvas.draw_arc(c, ring, 0.0, TAU, 48, _white(0.20), bw, true)
	var pressed_zones = {}
	var knob = c
	for i in captures.keys():
		var cap = captures[i]
		if cap["control"] == "stick":
			knob = c + _stick_delta(sf, cap)
			var sv = _stick_vector(sf, cap)
			if sv.x < -DIGITAL_THRESHOLD:
				pressed_zones["left"] = true
			elif sv.x > DIGITAL_THRESHOLD:
				pressed_zones["right"] = true
			if sv.y < -DIGITAL_THRESHOLD:
				pressed_zones["up"] = true
			elif sv.y > DIGITAL_THRESHOLD:
				pressed_zones["down"] = true
	var arrow_dist = (radius + ring) * 0.5
	var arrow_size = (radius - ring) * 0.3
	var dirs = {"up": Vector2(0, -1), "down": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)}
	for key in dirs.keys():
		var dir = dirs[key]
		var tip = c + dir * (arrow_dist + arrow_size)
		var base = c + dir * (arrow_dist - arrow_size)
		var side = Vector2(-dir.y, dir.x) * arrow_size
		var alpha = 0.45
		if pressed_zones.has(key):
			alpha = 0.85
		canvas.draw_colored_polygon(PoolVector2Array([tip, base + side, base - side]), _white(alpha))
	var knob_r = base_size * 0.14
	canvas.draw_circle(knob, knob_r, _white(0.18))
	canvas.draw_arc(knob, knob_r, 0.0, TAU, 32, _white(0.72), bw, true)
	var held = {}
	for i2 in captures.keys():
		held[captures[i2]["control"]] = true
		if captures[i2].has("origin"):
			held[captures[i2]["origin"]] = true
	for b in buttons:
		var r = _to_window(b[2])
		var is_held = held.has(b[0])
		var pts = _capsule(r)
		var fill_a = 0.08
		var line_a = 0.32
		var text_a = 0.85
		if is_held:
			fill_a = 0.35
			line_a = 0.80
			text_a = 1.0
		canvas.draw_colored_polygon(pts, _white(fill_a))
		pts.append(pts[0])
		canvas.draw_polyline(pts, _white(line_a), bw, true)
		_label(b[1], r, _white(text_a))
'''


def patch_overlay():
    path = os.path.join("System", "IOSTouchOverlay.gd")
    write(path, OVERLAY_GD.replace("__DEFAULT_ASPECT__", str(ASPECT_NUM[ASPECT_DEFAULT])))
    print(f"[ok]   {path} (iOS 가상 패드)")
    proj = read("project.godot")
    if "IOSTouchOverlay=" in proj:
        print("[skip] project.godot (IOSTouchOverlay 이미 등록됨)")
        return
    nl = "\r\n" if "\r\n" in proj else "\n"
    m = re.search(r"^\[autoload\]\s*$", proj, re.M)
    if not m:
        sys.exit("[error] project.godot에 [autoload] 섹션이 없음")
    line = 'IOSTouchOverlay="*res://System/IOSTouchOverlay.gd"'
    proj = proj[: m.end()] + nl + line + proj[m.end():]
    write("project.godot", proj)
    print("[ok]   project.godot += IOSTouchOverlay autoload")


# 기본 화면 모드: wide(가로로 더 넓게) / stretch(화면 전체로 늘림) / keep(검은 띠).
# 빌드할 때 환경변수 ASPECT_DEFAULT 로 바꿀 수 있음 (게임 옵션 'Aspect Ratio' 에서도 바꿀 수 있음)
ASPECT_DEFAULT = os.environ.get("ASPECT_DEFAULT", "wide").strip().lower()
ASPECT_NUM = {"stretch": 0, "keep": 1, "wide": 2}
if ASPECT_DEFAULT not in ASPECT_NUM:
    sys.exit("[error] ASPECT_DEFAULT 는 wide / stretch / keep 중 하나여야 함: " + ASPECT_DEFAULT)


def _sub(path, old, new, label):
    """정확히 한 번 나오는 문자열을 바꿈 (줄바꿈 형식 유지, 이미 적용됐으면 건너뜀)."""
    src = read(path)
    nl = "\r\n" if "\r\n" in src else "\n"
    old = old.replace("\n", nl)
    new = new.replace("\n", nl)
    if new in src:
        print(f"[skip] {path}: {label} (이미 적용됨)")
        return
    if src.count(old) != 1:
        print(f"[warn] {path}: {label} 위치를 찾지 못함 ({src.count(old)}곳) - 소스가 바뀌었는지 확인")
        return
    write(path, src.replace(old, new))
    print(f"[ok]   {path}: {label}")


def patch_stretch():
    """iOS: 화면 양옆 검은 띠 제거.
    wide    : 화면 폭만큼 세계를 가로로 더 넓게 보여 줌 (UI/패드는 예전 16:9 영역 그대로)
    stretch : 비율 무시하고 화면 전체로 늘림 (패드는 예전 모양/위치 유지)
    keep    : 예전처럼 검은 띠
    """
    # 1) project.godot 기본 비율 (wide 는 오버레이가 시작 직후 적용하므로 keep 으로 둠)
    want = "ignore" if ASPECT_DEFAULT == "stretch" else "keep"
    proj = read("project.godot")
    new = re.sub(r'^(window/stretch/aspect=)"[a-z_]+"', r'\1"' + want + '"', proj, flags=re.M)
    if new != proj:
        write("project.godot", new)
        print(f'[ok]   project.godot window/stretch/aspect = "{want}"')
    else:
        print("[skip] project.godot (stretch aspect 이미 설정됨 / 해당 줄 없음)")

    # 2) 코드 안에서 keep 으로 되돌리는 곳 -> 오버레이가 정한 값 사용
    for path in ["src/Scripts/GameManager.gd", "src/Options/Stretch_Mode.gd"]:
        src = read(path)
        if "SceneTree.STRETCH_ASPECT_KEEP" in src:
            write(path, src.replace("SceneTree.STRETCH_ASPECT_KEEP", "IOSTouchOverlay.aspect()"))
            print(f"[ok]   {path}: STRETCH_ASPECT_KEEP -> IOSTouchOverlay.aspect()")
        else:
            print(f"[skip] {path} (이미 적용됨)")

    # 3) 옵션 'Aspect Ratio': 값 2(WIDE) 추가, 기본값은 ASPECT_DEFAULT
    opt = "src/Options/Fullscreen.gd"
    first = ASPECT_NUM[ASPECT_DEFAULT]
    order = [first] + [v for v in (2, 0, 1) if v != first]
    _sub(opt, "var aspect_options = [0, 1]\n",
         "var aspect_options = [" + ", ".join(str(v) for v in order) + "]\n", "옵션 순환 목록")
    _sub(opt,
         "\t\tget_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, GameManager.Resolution)\n",
         "\t\tget_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, GameManager.Resolution)\n"
         "\telif aspect_value == 2:\n"
         "\t\tget_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, IOSTouchOverlay.aspect(), GameManager.Resolution)\n",
         "WIDE 적용")
    _sub(opt,
         "\t\telif get_aspect_ratio() == 1:\n\t\t\tdisplay_value(\"KEEP_VALUE\")\n",
         "\t\telif get_aspect_ratio() == 1:\n\t\t\tdisplay_value(\"KEEP_VALUE\")\n"
         "\t\telif get_aspect_ratio() == 2:\n\t\t\tdisplay_value(\"WIDE\")\n",
         "WIDE 표시")
    _sub(opt, "func get_aspect_ratio():\n\treturn Configurations.get(\"Aspect\")\n",
         "func get_aspect_ratio():\n\treturn IOSTouchOverlay.aspect_mode()\n", "Aspect 기본값")

    # 4) 카메라: 화면 폭이 넓어진 만큼 카메라 한계 계산에 반영
    cam = "src/System/StateCamera.gd"
    _sub(cam, "const width: = 398\n", "var width: = 398.0   # iOS-PORT: 화면 폭 (WIDE 모드에서 넓어짐)\n", "width 상수 -> 변수")
    _sub(cam, "func _process(delta: float) -> void :\n\tvar new_pos: = global_position\n",
         "func _process(delta: float) -> void :\n\twidth = IOSTouchOverlay.view_width()\n\tvar new_pos: = global_position\n",
         "매 프레임 폭 갱신")
    _sub(cam,
         "func get_boundary_position_left() -> float:\n\treturn custom_limits_left + float(width) / 2\n"
         "func get_boundary_position_right() -> float:\n\treturn custom_limits_right - float(width) / 2\n",
         "func get_boundary_position_left() -> float:\n"
         "\tif width > 398.0 and custom_limits_right - custom_limits_left < width:\n"
         "\t\treturn (custom_limits_left + custom_limits_right) / 2.0\n"
         "\treturn custom_limits_left + float(width) / 2\n"
         "func get_boundary_position_right() -> float:\n"
         "\tif width > 398.0 and custom_limits_right - custom_limits_left < width:\n"
         "\t\treturn (custom_limits_left + custom_limits_right) / 2.0\n"
         "\treturn custom_limits_right - float(width) / 2\n",
         "화면보다 좁은 방은 가운데 고정")
    _sub(cam,
         "\tif is_over_left_limit(pos):\n\t\tpos.x = custom_limits_left + float(width) / 2\n"
         "\telif is_over_right_limit(pos):\n\t\tpos.x = custom_limits_right - float(width) / 2\n",
         "\tif is_over_left_limit(pos):\n\t\tpos.x = get_boundary_position_left()\n"
         "\telif is_over_right_limit(pos):\n\t\tpos.x = get_boundary_position_right()\n",
         "가장 가까운 카메라 위치 계산")


def patch_clear_color():
    """프로젝트 기본 배경색(회색 4c4c4c)을 검정으로: 타이틀/옵션 등에서 비는 영역이 회색으로 보이는 것 방지."""
    proj = read("project.godot")
    if "environment/default_clear_color" in proj:
        print("[skip] project.godot (기본 배경색 이미 설정됨)")
        return
    nl = "\r\n" if "\r\n" in proj else "\n"
    m = re.search(r"^\[rendering\]\s*$", proj, re.M)
    if not m:
        sys.exit("[error] project.godot에 [rendering] 섹션이 없음")
    proj = proj[: m.end()] + nl + "environment/default_clear_color=Color( 0, 0, 0, 1 )" + proj[m.end():]
    write("project.godot", proj)
    print("[ok]   project.godot += 기본 배경색 검정")



def patch_tagteam_fonts():
    """TagTeam 모드는 옛 폰트 파일명(Xclassicfont/X8bitmapfont)을 쓰므로,
    ko-assets 의 한글 비트맵 폰트를 그 이름으로도 복사하고 menuFont 높이를 맞춘다 (멱등)."""
    fonts = "src/Fonts"
    pairs = [("xclassicfontfinal.fnt", "Xclassicfont.fnt"),
             ("x8bitmapfontfinal.fnt", "X8bitmapfont.fnt")]
    for src_name, dst_name in pairs:
        src = os.path.join(fonts, src_name)
        dst = os.path.join(fonts, dst_name)
        if not os.path.exists(src):
            print(f"[warn] {src} 없음 - ko-assets 적용 순서 확인")
            continue
        shutil.copyfile(src, dst)
        print(f"[ok]   {dst} <- {src}")
    _sub(os.path.join(fonts, "menuFont.tres"), "height = 8.0\n", "height = 14.0\n", "menuFont 높이 8 -> 14")



def patch_tagteam_layout():
    """한글 폰트에 맞춰 태그팀 소스의 글자 위치를 보정한다 (멱등).
    - 옵션 화면: 글자 세로 오프셋을 iOS 원본 값(-7->-4, -9->-6)으로, 첫 줄이 잘리지 않게 위쪽 여백 추가
    - 불러오기 슬롯: 맨 윗줄(난이도/NEW GAME+)이 스크롤 영역에 잘리지 않게 아래로 이동"""
    opt = "src/Options/Options.tscn"
    if os.path.exists(opt):
        src = read(opt)
        nl = "\r\n" if "\r\n" in src else "\n"
        if "TopPad" in src:
            print(f"[skip] {opt}: 글자 위치 보정 (이미 적용됨)")
        else:
            n7 = src.count("margin_top = -7.0")
            n9 = src.count("margin_top = -9.0")
            src = src.replace("margin_top = -7.0", "margin_top = -4.0").replace("margin_top = -9.0", "margin_top = -6.0")
            hold = '[node name="Language" type="Control" parent="Menu/scrollContainer/OptionHolder"]'
            pad = ('[node name="TopPad" type="Control" parent="Menu/scrollContainer/OptionHolder"]' + nl +
                   "margin_right = 200.0" + nl + "rect_min_size = Vector2( 200, 0 )" + nl +
                   "mouse_filter = 2" + nl + nl)
            if src.count(hold) == 1:
                src = src.replace(hold, pad + hold)
            else:
                print(f"[warn] {opt}: Language 노드 위치를 찾지 못함 - 위쪽 여백 생략")
            write(opt, src)
            print(f"[ok]   {opt}: 글자 오프셋 보정 (-7 {n7}곳, -9 {n9}곳) + 위쪽 여백")
        _sub(opt,
             "margin_left = 96.0\nmargin_top = 31.0\nmargin_right = 346.0\nmargin_bottom = 194.0",
             "margin_left = 96.0\nmargin_top = 28.0\nmargin_right = 346.0\nmargin_bottom = 198.0",
             "스크롤 영역 확장")
    slot = "System/Screens/Loading/SlotButton.tscn"
    if os.path.exists(slot):
        _sub(slot, "margin_left = -129.0\nmargin_top = -27.0\nmargin_right = 131.0\nmargin_bottom = -13.0",
             "margin_left = -129.0\nmargin_top = -21.0\nmargin_right = 131.0\nmargin_bottom = -7.0", "난이도 줄 아래로")
        _sub(slot, "margin_left = -14.0\nmargin_top = -27.0\nmargin_right = 130.0\nmargin_bottom = -13.0",
             "margin_left = -14.0\nmargin_top = -21.0\nmargin_right = 130.0\nmargin_bottom = -7.0", "NEW GAME+ 줄 아래로")


if __name__ == "__main__":
    if not os.path.exists("project.godot"):
        sys.exit("[error] 저장소 루트(project.godot가 있는 곳)에서 실행하세요")
    patch_character_manager()
    patch_spawner()
    patch_project_godot()
    patch_presets()
    patch_overlay()
    patch_stretch()
    patch_clear_color()
    apply_korean()
    patch_tagteam_fonts()
    patch_tagteam_layout()
