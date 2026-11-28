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

BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.mmx.allinone.ios")
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
application/short_version="1.0.6"
application/version="1.0.6"
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
const SCROLL_SLOP = 3.0  # 이 거리(게임 좌표)보다 끌면 탭이 아니라 스크롤
const HIT_GROW = 1.5  # 버튼 터치 판정 배율 (그려진 크기 대비)
const BASE_SIZE = Vector2(398.0, 224.0)  # 게임 기준 해상도 (16:9)
const ASPECT_STRETCH = 0   # 비율 무시, 화면 전체로 늘림
const ASPECT_KEEP = 1      # 비율 유지 (양옆 검은 띠)
const ASPECT_WIDE = 2      # 화면 비율에 맞춰 가로로 더 넓게 보이게
const ASPECT_43 = 3        # 스테이지에서 좌우를 검게 가려 4:3 으로 (캐릭터 크기는 그대로)
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
var dbg_idle: float = 0.0          # 타이틀 메뉴에서 입력 없이 지난 시간
var dbg_armed: bool = true         # 한 번 토글하면, 다른 메뉴에 들어갔다 나올 때까지 다시 토글하지 않음
var dbg_visited: bool = false      # 토글한 뒤 하위 메뉴에 들어갔다 왔는지
const DEBUG_IDLE_SEC = 20.0
var toast_layer = null
var toast_label = null
var toast_left: float = 0.0
var press_pf: Dictionary = {}      # 액션별 눌린 시점의 물리 프레임
var press_if: Dictionary = {}      # 액션별 눌린 시점의 idle 프레임
var pending_release: Dictionary = {}  # 게임이 한 번도 못 본 채 떼어진 액션 (보류)
var last_extra: float = 0.0           # 마지막으로 반영한 '양옆 늘어난 폭의 절반'
var last_crop: bool = false           # 마지막으로 반영한 4:3 가림막 상태
var last_aspect: int = -1             # 마지막으로 적용한 stretch aspect
var crop_layer = null                 # 4:3 모드 가림막 레이어
var crop_rects: Array = []            # 가림막 (왼쪽, 오른쪽)
var scroll_node = null                # 손가락으로 끌어 스크롤 중인 ScrollContainer
var scroll_index: int = -1
var scroll_start: Vector2 = Vector2.ZERO
var scroll_origin: float = 0.0
var scroll_moved: bool = false
var scroll_drag_block: bool = false   # 스크롤하려고 끈 터치: 버튼 눌림으로 처리하지 않음
var hud_layers: Array = []            # HUD 레이어들 (4:3 모드에서 가림막 위로 올림)


func _ready() -> void:
	layer = 100
	pause_mode = Node.PAUSE_MODE_PROCESS
	if OS.get_name() == "iOS":
		TranslationServer.set_locale("ko")  # 한국어만 지원
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
	_debug_idle_tick(delta)
	timer -= delta
	if timer > 0.0:
		return
	timer = 0.15
	_apply_stretch()
	_update_layer_transform()
	_update_crop()
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


# ---- 4:3 모드: 스테이지에서 화면 좌우를 검게 가려서 4:3 으로 보이게 함 ----
# 세계 화면만 잘리고(캐릭터 크기는 그대로), HUD 는 가림막 위로 올려서 검은 띠 위에 그대로 보인다.
# 메뉴/일시정지 화면은 레이어가 더 위라서 잘리지 않는다.
func _crop_active() -> bool:
	return aspect_mode() == ASPECT_43 and _in_stage()


func _ensure_crop() -> void:
	if crop_layer != null:
		return
	crop_layer = CanvasLayer.new()
	crop_layer.layer = 1
	crop_layer.pause_mode = Node.PAUSE_MODE_PROCESS
	for i in range(2):
		var r = ColorRect.new()
		r.color = Color(0, 0, 0, 1)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.visible = false
		crop_layer.add_child(r)
		crop_rects.append(r)
	get_tree().root.call_deferred("add_child", crop_layer)


# 4:3 영역 양옆을 가리는 폭 (게임 좌표)
func _crop_bw() -> float:
	return (BASE_SIZE.x - BASE_SIZE.y * 4.0 / 3.0) * 0.5


# 카메라가 쓰는 화면 폭. 4:3 모드에서는 보이는 폭(4:3)만큼만 써서
# 카메라 한계 끝에서 캐릭터가 가림막(검은 띠) 안으로 들어가지 않게 한다
func camera_width() -> float:
	if _crop_active():
		return BASE_SIZE.y * 4.0 / 3.0
	return view_width()


# 이 레이어를 옮겨야 하는 양 (WIDE 모드의 가운데 정렬 + 4:3 모드에서 HUD 를 보이는 영역 안으로)
func _layer_extra(l) -> float:
	var e = wide_extra()
	if l != null and _crop_active() and hud_layers.has(l):
		e += _crop_bw()
	return e


func _update_crop() -> void:
	var on = _crop_active()
	if on:
		_ensure_crop()
	if crop_layer != null and crop_rects.size() == 2:
		var bw = _crop_bw()
		# 화면 바깥쪽으로 넉넉히 넓히고 안쪽도 조금 겹치게: 가장자리 반올림 틈으로 게임 화면이 비쳐 보이는 것 방지
		crop_rects[0].rect_position = Vector2(-32.0, -32.0)
		crop_rects[0].rect_size = Vector2(bw + 32.0 + 0.75, BASE_SIZE.y + 64.0)
		crop_rects[1].rect_position = Vector2(BASE_SIZE.x - bw - 0.75, -32.0)
		crop_rects[1].rect_size = Vector2(bw + 32.0 + 0.75, BASE_SIZE.y + 64.0)
		crop_rects[0].visible = on
		crop_rects[1].visible = on
	if on != last_crop:
		last_crop = on
		_refresh_wide()
	for l in hud_layers:
		if is_instance_valid(l):
			if on:
				l.layer = 2
			else:
				l.layer = 1


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
	if n is BaseButton:
		call_deferred("_release_mode_in_scroll", n)
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
	if l == crop_layer:
		return
	var hs = l.get_script()
	if hs != null and hs.resource_path == "res://src/Levels/HUD.gd" and not hud_layers.has(l):
		hud_layers.append(l)
	if l.is_in_group("wide_ui"):
		return
	if l.layer >= 120 and l.name != "AchievementsScreen":
		# CRT 같은 전체 화면 효과 레이어: 옮기지 않고 폭만 넓힌다
		# (업적 화면은 일시정지 메뉴 안에서 레이어 127 로 쓰이지만 메뉴라서 다른 메뉴처럼 가운데로 옮긴다)
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
	l.offset = base + Vector2(_layer_extra(l), 0.0)
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
	var par = c.get_parent()
	if par != null and par is CanvasLayer:
		s = _layer_extra(par)
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


# 스크롤 영역 안의 버튼은 '손가락을 뗄 때' 눌리게 한다 (누르는 순간 눌리면 끌어서 스크롤을 못 함)
func _release_mode_in_scroll(b) -> void:
	if not is_instance_valid(b) or not (b is BaseButton) or not b.is_inside_tree():
		return
	# 디버그 해금 버튼(타이틀 옵션): 원래 on_press 는 select_special 을 안 누르면 디버그를 꺼 버리므로
	# 해금 플래그를 꺼 두고, 타이틀에서 20초 동안 가만히 있으면 직접 켜고/끈다 (_debug_idle_tick)
	if b.get("able_to_unlock_debug") != null:
		b.able_to_unlock_debug = false
		return
	var p = b.get_parent()
	while p != null:
		if p is ScrollContainer:
			b.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			return
		p = p.get_parent()


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


# 안내 화면 -> 서명 -> 크레딧 -> 캡콤 로고 연출 -> 타이틀 까지는 화면 아무 곳이나 터치하면 넘어간다.
# (안드로이드판은 화면 전체 투명 버튼으로 하던 것을 iOS 에서는 지우기 때문에 여기서 대신 pause 입력을 보냄)
const TITLE_FLOW_SCENES = [
	"res://src/Title/DisclaimerScreen.tscn",
	"res://src/Title/IntroAlysson.tscn",
	"res://System/Screens/Title/CreditStartScreen.tscn",
]


# 타이틀의 난이도 선택 화살표(< >)를 탭했는지: 맞으면 난이도를 바꾸고 true
func _title_arrow_tap(p: Vector2) -> bool:
	for a in get_tree().get_nodes_in_group("ios_title_arrow"):
		if is_instance_valid(a) and a.is_visible_in_tree() and _button_has_point(a, p):
			var btn = a.get_parent()
			if btn != null and btn.has_method("ios_step_mode"):
				btn.ios_step_mode(int(a.get_meta("dir")))
			return true
	return false


func _title_flow_active() -> bool:
	var sc = get_tree().current_scene
	if sc == null:
		return false
	var f = sc.filename
	if TITLE_FLOW_SCENES.has(f):
		return true
	if f == "res://src/Title/IntroCapcom.tscn":
		# 타이틀 메뉴가 열리기 전(잠겨 있는 동안)만
		var mm = sc.get_node_or_null("MainMenu")
		if mm == null or mm.get("locked") != true:
			return false
		# 옵션/키설정/불러오기 같은 하위 메뉴가 열려 있으면 메인메뉴도 잠기는데, 이건 '연출 중'이 아님
		# (이때 터치마다 pause 를 보내면 옵션 메뉴가 바로 닫혀 버림)
		return not _submenu_open(mm)
	return false


# mm 아래에 열려 있는(active) 하위 X8Menu(옵션, 키 설정, 불러오기 등)가 있는지
func _submenu_open(mm: Node) -> bool:
	for c in mm.get_children():
		if _has_active_menu(c):
			return true
	return false


func _has_active_menu(n: Node) -> bool:
	if n is CanvasLayer and n.get("exit_action") != null and n.get("active") == true:
		return true
	for c in n.get_children():
		if _has_active_menu(c):
			return true
	return false


func _input(event: InputEvent) -> void:
	if OS.get_name() != "iOS":
		return
	dbg_idle = 0.0
	if event is InputEventScreenTouch:
		if event.pressed:
			scroll_drag_block = false
			if _title_flow_active():
				_send_action("pause", true)
				_send_action("pause", false)
				return
			var p = event.position
			if _title_arrow_tap(p):
				return
			var pp = _to_pad(p)
			var id = ""
			if shown:
				id = _find_control(pp)
			if id == "":
				_begin_scroll(event.index, p)
				_begin_tap(event.index, p)
				return
			var cap = {"control": id, "origin": id, "zone": "", "anchor": pp, "current": pp}
			if id == "stick":
				cap["zone"] = "stick"
				var sfc = _to_window(stick_frame)
				cap["anchor"] = sfc.position + sfc.size * 0.5  # 스틱 중심 고정
			captures[event.index] = cap
		else:
			if event.index == scroll_index:
				scroll_node = null
				scroll_index = -1
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
		if event.index == scroll_index and scroll_node != null and is_instance_valid(scroll_node):
			var dy = event.position.y - scroll_start.y
			if not scroll_moved and abs(dy) > SCROLL_SLOP:
				scroll_moved = true
				scroll_drag_block = true
				_clear_tap()
			if scroll_moved:
				scroll_node.scroll_vertical = int(round(scroll_origin - dy))
				get_tree().set_input_as_handled()
				return
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


# 손가락을 끌어 올리고 내리는 스크롤 (옵션/불러오기 같은 ScrollContainer)
func _find_scroll_at(node: Node, p: Vector2):
	if node == self:
		return null
	var kids = node.get_children()
	for i in range(kids.size() - 1, -1, -1):
		var f = _find_scroll_at(kids[i], p)
		if f != null:
			return f
	if node is ScrollContainer and node.is_visible_in_tree() and _button_has_point(node, p):
		var sb = node.get_v_scrollbar()
		if sb.max_value > sb.page + 1.0:
			return node
	return null


func _begin_scroll(index: int, p: Vector2) -> void:
	scroll_node = null
	scroll_index = -1
	scroll_moved = false
	var sc = _find_scroll_at(get_tree().root, p)
	if sc == null:
		return
	scroll_node = sc
	scroll_index = index
	scroll_start = p
	scroll_origin = float(sc.scroll_vertical)


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


# 타이틀 메뉴에서 20초 동안 아무 입력(터치 등) 없이 두면 디버그를 켠다. 다른 메뉴에 들어갔다 나와서
# 다시 20초 두면 이번엔 끈다. 화면 상단 가운데에 3초 알림.
func _debug_idle_tick(delta: float) -> void:
	if toast_left > 0.0:
		toast_left -= delta
		if toast_left <= 0.0 and toast_label != null:
			toast_label.visible = false
	var sc = get_tree().current_scene
	var mm = null
	if sc != null and sc.filename == "res://src/Title/IntroCapcom.tscn":
		mm = sc.get_node_or_null("MainMenu")
	if mm == null:
		dbg_idle = 0.0
		return
	if _submenu_open(mm):
		dbg_idle = 0.0
		dbg_visited = true  # 옵션/키 설정 같은 하위 메뉴에 들어감
		return
	if mm.get("locked") != false:
		dbg_idle = 0.0  # 타이틀 연출 중
		return
	if not dbg_armed:
		if dbg_visited:
			dbg_armed = true
			dbg_visited = false
		else:
			return
	dbg_idle += delta
	if dbg_idle < DEBUG_IDLE_SEC:
		return
	dbg_armed = false
	dbg_visited = false
	dbg_idle = 0.0
	var on = not GameManager.debug_enabled
	GameManager.debug_enabled = on
	if not on:
		Configurations.set("ShowDebug", false)
	_show_toast("디버그 켜짐" if on else "디버그 꺼짐")


func _show_toast(text: String) -> void:
	if toast_layer == null:
		toast_layer = CanvasLayer.new()
		toast_layer.layer = 120
		toast_layer.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(toast_layer)
		toast_label = Label.new()
		toast_label.align = Label.ALIGN_CENTER
		toast_label.valign = Label.VALIGN_CENTER
		toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var f = load("res://src/Fonts/menuFont.tres")
		if f != null:
			toast_label.add_font_override("font", f)
		toast_label.add_color_override("font_color", Color(1, 1, 1, 1))
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0.75)
		toast_label.add_stylebox_override("normal", sb)
		toast_layer.add_child(toast_label)
	toast_label.text = text
	var vs = get_viewport().get_visible_rect().size
	toast_label.rect_size = Vector2(120.0, 20.0)
	toast_label.rect_position = Vector2((vs.x - 120.0) * 0.5, 10.0)
	toast_label.visible = true
	toast_left = 3.0


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
	var dragged = scroll_drag_block
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var fired = tap_fired
	if is_instance_valid(b):
		if b.is_connected("pressed", self, "_on_tap_probe"):
			b.disconnect("pressed", self, "_on_tap_probe")
		if inside and not fired and not dragged and b.focus_mode != Control.FOCUS_NONE:
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
ASPECT_NUM = {"stretch": 0, "keep": 1, "wide": 2, "4:3": 3}
if ASPECT_DEFAULT not in ASPECT_NUM:
    sys.exit("[error] ASPECT_DEFAULT 는 wide / 4:3 / stretch / keep 중 하나여야 함: " + ASPECT_DEFAULT)


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
    order = [first] + [v for v in (2, 3, 0, 1) if v != first]
    _sub(opt, "var aspect_options = [0, 1]\n",
         "var aspect_options = [" + ", ".join(str(v) for v in order) + "]\n", "옵션 순환 목록")
    _sub(opt,
         "\t\tget_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, GameManager.Resolution)\n",
         "\t\tget_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, GameManager.Resolution)\n"
         "\telif aspect_value >= 2:\n"
         "\t\tget_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, IOSTouchOverlay.aspect(), GameManager.Resolution)\n",
         "WIDE 적용")
    _sub(opt,
         "\t\telif get_aspect_ratio() == 1:\n\t\t\tdisplay_value(\"KEEP_VALUE\")\n",
         "\t\telif get_aspect_ratio() == 1:\n\t\t\tdisplay_value(\"KEEP_VALUE\")\n"
         "\t\telif get_aspect_ratio() == 2:\n\t\t\tdisplay_value(\"WIDE\")\n",
         "WIDE 표시")
    _sub(opt,
         "\t\telif get_aspect_ratio() == 2:\n\t\t\tdisplay_value(\"WIDE\")\n",
         "\t\telif get_aspect_ratio() == 2:\n\t\t\tdisplay_value(\"WIDE\")\n"
         "\t\telif get_aspect_ratio() == 3:\n\t\t\tdisplay_value(\"4:3\")\n",
         "4:3 표시")
    _sub(opt, "func get_aspect_ratio():\n\treturn Configurations.get(\"Aspect\")\n",
         "func get_aspect_ratio():\n\treturn IOSTouchOverlay.aspect_mode()\n", "Aspect 기본값")

    # 4) 카메라: 화면 폭이 넓어진 만큼 카메라 한계 계산에 반영
    cam = "src/System/StateCamera.gd"
    _sub(cam, "const width: = 398\n", "var width: = 398.0   # iOS-PORT: 화면 폭 (WIDE 모드에서 넓어짐)\n", "width 상수 -> 변수")
    _sub(cam, "func _process(delta: float) -> void :\n\tvar new_pos: = global_position\n",
         "func _process(delta: float) -> void :\n\twidth = IOSTouchOverlay.camera_width()\n\tvar new_pos: = global_position\n",
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
    - 불러오기 슬롯: Loading.tscn 에서 스크롤 영역 위쪽 여백으로 직접 처리하므로 여기서는 건드리지 않음"""
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


# iOS 에서는 게임에 원래 들어있는 안드로이드용 터치 UI(System/Android)를 지운다.
# (엑박패드 UI 는 IOSTouchOverlay 가 담당. 둘이 같이 뜨면 화면이 겹치고 입력도 두 번 들어감)
# 숨기기만 하면 Area2D 조이스틱의 _input 이 계속 살아있으므로, 아예 노드를 지워 버린다.
# 단, 위쪽의 동그라미 퀵 버튼(weaponround = 무기 선택 링 + 가운데 reset_weapon 버튼)은 남긴다.
IOS_HIDE_MARK = "# iOS-PORT: 안드로이드 터치 UI 제거 (v2, 퀵 버튼 유지)"
OLD_HIDE_MARK = "# iOS-PORT: 안드로이드 터치 UI 제거"

KEY_GUARD = [
    "\t" + IOS_HIDE_MARK,
    "\tif OS.get_name() == \"iOS\":",
    "\t\tfor c in get_children():",
    "\t\t\tif c.name != \"weaponround\":",
    "\t\t\t\tc.queue_free()",
    "\t\tvar wr = get_node_or_null(\"weaponround\")",
    "\t\tif wr != null:",
    "\t\t\twr.position = Vector2(CharacterManager.weaponround_position_x * 0.1, CharacterManager.weaponround_position_y * 0.1)",
    "\t\tmodulate.a = 1.0",
    "\t\tvisible = true",
    "\t\treturn",
    "",
]
BTN_GUARD = [
    "\t" + IOS_HIDE_MARK,
    "\tif OS.get_name() == \"iOS\" and name != \"weaponcenter\":",
    "\t\tqueue_free()",
    "\t\treturn",
    "",
]
ANDROID_UI_SCRIPTS = {
    "System/Android/ShowControls.gd": KEY_GUARD,      # AndroidControls.tscn 의 Key (조이스틱/버튼 전체의 부모)
    "System/Android/AndroidControls.gd": BTN_GUARD,   # 각 씬(일시정지/컷신 등)의 Pause/Jump 터치 버튼
    "System/Android/button.gd": BTN_GUARD,
    "System/Android/AndroidKeyConfig.gd": BTN_GUARD,
}


def patch_hide_android_controls():
    for path, guard_lines in ANDROID_UI_SCRIPTS.items():
        if not os.path.exists(path):
            print(f"[warn] {path} 없음 - 건너뜀")
            continue
        src = read(path)
        if IOS_HIDE_MARK in src:
            print(f"[skip] {path} (이미 패치됨)")
            continue
        nl = "\r\n" if "\r\n" in src else "\n"
        # 이전 버전(퀵 버튼까지 지우던) 패치가 남아 있으면 먼저 걷어낸다
        src = re.sub(r"\t" + re.escape(OLD_HIDE_MARK) + r"\r?\n\tif OS\.get_name\(\) == \"iOS\":\r?\n\t\tqueue_free\(\)\r?\n\t\treturn\r?\n", "", src)
        m = re.search(r"^func _ready\(\)[^\n]*\n", src, re.M)
        if not m:
            print(f"[warn] {path}: _ready 를 찾지 못함 - 건너뜀")
            continue
        src = src[:m.end()] + nl.join(guard_lines) + src[m.end():]
        write(path, src)
        print(f"[ok]   {path}: iOS 에서는 터치 UI 제거 (퀵 버튼 유지)")


# 무기 선택 링(HotSwap): 캐릭터 기준으로 3x3 으로 뜨기 때문에 낮은 지형(화면 맨 아래)에 서 있으면
# 아래쪽 아이콘 3개가 화면 밖으로 나가 안 보인다. iOS 에서는 링 전체를 캐릭터 머리 위로 올리고,
# 그래도 화면 밖으로 나가면 화면 안쪽으로 밀어 넣는다.
# (아이콘/커서/선택 영역이 모두 같은 부모 아래라 같이 움직이므로 선택 동작은 그대로)
HOTSWAP_SCRIPTS = [
    "src/Options/HotSwap.gd",
    "Zero_mod/Player/Weapons/HotSwapZero.gd",
    "Axl_mod/HUD/HotSwapAxl.gd",
]
HOTSWAP_MARK = "# iOS-PORT: 무기 선택 링 화면 안으로"
HOTSWAP_CODE = """

# iOS-PORT: 무기 선택 링 화면 안으로
var _ios_base_pos = null
const _IOS_WHEEL_UP: float = 84.0  # 링 전체를 캐릭터 머리 위로 올리는 높이

func _process(_delta: float) -> void :
	if OS.get_name() != "iOS":
		return
	if _ios_base_pos == null:
		_ios_base_pos = position
	position = _ios_base_pos
	if modulate.a <= 0.01 or not is_visible_in_tree():
		return
	global_position += Vector2(0, - _IOS_WHEEL_UP)
	var vp = get_viewport()
	if vp == null:
		return
	var inv = vp.get_canvas_transform().affine_inverse()
	var vr = vp.get_visible_rect()
	var tl = inv.xform(vr.position)
	var br = inv.xform(vr.position + vr.size)
	var lo = Vector2(INF, INF)
	var hi = Vector2(-INF, -INF)
	for c in get_children():
		if c is Sprite and c.name != "cursor":
			var g = to_global(c.position)
			lo.x = min(lo.x, g.x)
			lo.y = min(lo.y, g.y)
			hi.x = max(hi.x, g.x)
			hi.y = max(hi.y, g.y)
	if lo.x == INF:
		return
	var half = 18.0
	var margin = 6.0
	var shift = Vector2.ZERO
	if hi.y + half > br.y - margin:
		shift.y = (br.y - margin) - (hi.y + half)
	elif lo.y - half < tl.y + margin:
		shift.y = (tl.y + margin) - (lo.y - half)
	if hi.x + half > br.x - margin:
		shift.x = (br.x - margin) - (hi.x + half)
	elif lo.x - half < tl.x + margin:
		shift.x = (tl.x + margin) - (lo.x - half)
	if shift != Vector2.ZERO:
		global_position += shift
"""


def patch_hotswap_onscreen():
    for path in HOTSWAP_SCRIPTS:
        if not os.path.exists(path):
            print(f"[warn] {path} 없음 - 건너뜀")
            continue
        src = read(path)
        if HOTSWAP_MARK in src:
            print(f"[skip] {path} (이미 패치됨)")
            continue
        if re.search(r"^func _process\(", src, re.M):
            print(f"[warn] {path}: 이미 _process 가 있어 건너뜀")
            continue
        nl = "\r\n" if "\r\n" in src else "\n"
        code = HOTSWAP_CODE.replace("\n", nl)
        write(path, src.rstrip() + nl + code)
        print(f"[ok]   {path}: 무기 선택 링을 화면 안으로 유지")


# 불러오기: 세이브 파일의 version 값이 "1.0.0.4" 와 정확히 같을 때만 내용을 적용하고 있어서,
# 다른 버전(PC 태그팀 모드 등)에서 가져온 세이브는 슬롯 목록에는 보이는데 눌러도 아무것도 안 불러와졌다.
# 필요한 데이터(collectibles / variables)가 들어있으면 버전이 달라도 적용한다.
def patch_save_version():
    path = "src/System/Savefile.gd"
    src = read(path)
    if "# iOS-PORT" in src:
        print(f"[skip] {path} (이미 패치됨)")
        return
    old = 'if game_data.has("version") and game_data["version"] == save_version:'
    new = ('# iOS-PORT: 세이브 버전이 달라도 필요한 데이터가 있으면 불러오기\n'
           '\tif game_data.has("collectibles") and game_data.has("variables") and typeof(game_data["variables"]) == TYPE_DICTIONARY:')
    if old not in src:
        print(f"[warn] {path}: 버전 비교 줄을 찾지 못함")
        return
    write(path, src.replace(old, new, 1))
    print(f"[ok]   {path}: 버전이 달라도 세이브 적용")


# 무기 선택 퀵 버튼(weaponround): Area2D 의 _input 이 화면 터치 좌표를 그대로 쓰기 때문에,
# 와이드 모드(폰처럼 가로로 긴 화면)에서 UI 레이어가 옆으로 밀려 있으면 버튼을 눌러도 반응하지 않는다.
# (태블릿은 4:3 이라 레이어가 안 밀려서 잘 됨) -> 터치 좌표를 캔버스 레이어 기준으로 바꿔서 비교
WEAPONROUND_MARK = "# iOS-PORT: 터치 좌표를 캔버스 레이어 기준으로"


def patch_weaponround_touch():
    path = os.path.join("System", "Android", "weaponround.gd")
    if not os.path.exists(path):
        print(f"[warn] {path} 없음 - 건너뜀")
        return
    src = read(path)
    if WEAPONROUND_MARK in src:
        print(f"[skip] {path} (이미 패치됨)")
        return
    n = src.count("event.position")
    if n == 0:
        print(f"[warn] {path}: event.position 을 찾지 못함 - 소스가 바뀌었는지 확인")
        return
    nl = "\r\n" if "\r\n" in src else "\n"
    src = src.replace("event.position", "_ios_pos(event)")
    src = src.rstrip() + nl + nl + WEAPONROUND_MARK + nl
    src += "func _ios_pos(event) -> Vector2:" + nl
    src += "\treturn get_canvas_transform().affine_inverse().xform(event.position)" + nl
    write(path, src)
    print(f"[ok]   {path}: 터치 좌표 보정 ({n}곳)")


# 한국어 번역에 빠진 키 보충 (ko-assets/System/KoExtra.gd 는 apply_korean 이 System/ 으로 복사해 줌)
def patch_ko_extra():
    if not os.path.exists(os.path.join("System", "KoExtra.gd")):
        print("[skip] System/KoExtra.gd 없음 (한국어 보충 번역 미적용)")
        return
    proj = read("project.godot")
    if "KoExtra=" in proj:
        print("[skip] project.godot (KoExtra 이미 등록됨)")
        return
    nl = "\r\n" if "\r\n" in proj else "\n"
    m = re.search(r"^\[autoload\]\s*$", proj, re.M)
    if not m:
        sys.exit("[error] project.godot에 [autoload] 섹션이 없음")
    line = 'KoExtra="*res://System/KoExtra.gd"'
    write("project.godot", proj[: m.end()] + nl + line + proj[m.end():])
    print("[ok]   project.godot += KoExtra autoload (한국어 보충 번역)")


# 타이틀 첫 버튼(새 게임)은 왼쪽/오른쪽 키로 난이도를 고르는데 터치로는 방법이 없음
# -> 버튼 양옆에 < > 화살표를 붙이고, 탭은 IOSTouchOverlay 가 처리 (난이도를 바꿀 수 있을 때만 보임)
GAMESTART_MARK = "# iOS-PORT: 터치 난이도 선택"  # v2: 삼각형 직접 그리기


def patch_title_difficulty_touch():
    path = os.path.join("src", "Options", "GameStartButton.gd")
    if not os.path.exists(path):
        print(f"[warn] {path} 없음 - 건너뜀")
        return
    if GAMESTART_MARK in read(path):
        print(f"[skip] {path} (이미 패치됨)")
        return
    _sub(path,
         "func _ready() -> void :\n\tbuild_mode_list()\n\tupdate_game_mode(CharacterManager.game_mode)\n",
         "func _ready() -> void :\n\tbuild_mode_list()\n\tupdate_game_mode(CharacterManager.game_mode)\n\t_ios_make_arrows()\n",
         "화살표 만들기")
    _sub(path,
         "func _process(_delta: float) -> void :\n\tif not has_focus() or CharacterManager.game_mode_set:\n",
         "func _process(_delta: float) -> void :\n\t_ios_update_arrows()\n\tif not has_focus() or CharacterManager.game_mode_set:\n",
         "화살표 갱신")
    src = read(path)
    nl = "\r\n" if "\r\n" in src else "\n"
    add = """

# iOS-PORT: 터치 난이도 선택
var ios_arrows: Array = []
# 화살표를 누르는 영역 폭과, 글자 끝에서 화살표 중심까지의 거리 (글자에 바짝 붙도록 작게)
const IOS_ARROW_W := 28.0
const IOS_ARROW_PAD := 10.0


func _ios_make_arrows() -> void:
	if OS.get_name() != "iOS":
		return
	for i in range(2):
		var a = Label.new()
		a.text = ""
		a.mouse_filter = Control.MOUSE_FILTER_STOP
		a.rect_size = Vector2(IOS_ARROW_W, 16.0)
		a.set_meta("dir", -1 if i == 0 else 1)
		a.add_to_group("ios_title_arrow")
		a.connect("draw", self, "_ios_draw_arrow", [a])
		add_child(a)
		ios_arrows.append(a)
	_ios_place_arrows()


# 지금 표시 중인 난이도 글자의 폭에 맞춰 화살표를 글자 양옆에 붙인다 (엑스 캐릭터에 닿지 않게)
func _ios_place_arrows() -> void:
	var half = 24.0
	var font = label.get_font("font")
	if font != null:
		half = font.get_string_size(label.text).x * 0.5
	var cx = rect_size.x * 0.5
	for a in ios_arrows:
		var d = int(a.get_meta("dir"))
		a.rect_position = Vector2(cx + d * (half + IOS_ARROW_PAD) - IOS_ARROW_W * 0.5, 0.0)


# 글자 대신 직접 삼각형으로 그림 (폰트에 < > 가 없거나 색이 묻혀도 항상 보이게)
func _ios_draw_arrow(a: Control) -> void:
	var d = int(a.get_meta("dir"))
	var c = a.rect_size * 0.5
	var h = 5.0
	var w = 4.0
	var pts = PoolVector2Array([
		c + Vector2(d * w, 0.0),
		c + Vector2(-d * w, -h),
		c + Vector2(-d * w, h)])
	a.draw_colored_polygon(pts, Color(1, 1, 1, 1))


func _ios_update_arrows() -> void:
	if ios_arrows.empty():
		return
	_ios_place_arrows()
	var show = modes.size() > 1
	var can = show and not CharacterManager.game_mode_set
	var idx = modes.find(CharacterManager.game_mode)
	for a in ios_arrows:
		a.visible = show
		if show:
			var d = int(a.get_meta("dir"))
			var ok = can and ((d < 0 and idx > 0) or (d > 0 and idx < modes.size() - 1))
			a.modulate = Color(1, 1, 1, 1.0 if ok else 0.25)


func ios_step_mode(d: int) -> void:
	if CharacterManager.game_mode_set:
		return
	var ni = modes.find(CharacterManager.game_mode) + d
	if ni < 0 or ni >= modes.size():
		return
	update_game_mode(modes[ni])
	_on_focus_entered()
""".replace("\n", nl)
    write(path, src.rstrip() + nl + add)
    print(f"[ok]   {path}: 터치용 난이도 화살표 추가")


def patch_title_version_text():
    """타이틀 오른쪽 아래 버전 글자를 바꾼다 (표시용 문자열이라 다른 곳에는 영향 없음)."""
    _sub(os.path.join("src", "Scripts", "GameManager.gd"),
         'var version: String = "Touch Mod After 3 Ver"',
         'var version: String = "All In One MOD"',
         "타이틀 버전 글자")


def patch_loading_slot_menu():
    """불러오기 슬롯: Loading.tscn 에 Pad 컨테이너가 한 단계 더 생겨서, 슬롯의 menu_path(위로 4칸)가
    불러오기 메뉴 본체가 아니라 Menu 컨트롤을 가리킴 -> 슬롯을 눌러도 loaded_end() 호출이 실패해 로드가 안 됨.
    Pad 가 있을 때만 위로 5칸으로 고친다."""
    scene = os.path.join("System", "Screens", "Loading", "Loading.tscn")
    slot = os.path.join("System", "Screens", "Loading", "SlotButton.tscn")
    if not (os.path.exists(scene) and os.path.exists(slot)):
        print("[warn] 불러오기 씬 없음 - 건너뜀")
        return
    if 'name="Pad"' not in read(scene):
        print("[skip] Loading.tscn: Pad 없음 - 슬롯 경로 그대로")
        return
    _sub(slot,
         'menu_path = NodePath("../../../..")',
         'menu_path = NodePath("../../../../..")',
         "슬롯 menu_path (Pad 때문에 한 칸 더 위로)")


def patch_scroll_touch():
    """끌어서 스크롤한 터치가 버튼 눌림(옵션 토글, 슬롯 불러오기)으로 처리되지 않게 막는다."""
    _sub(os.path.join("src", "Options", "Button.gd"),
         "func _on_pressed() -> void :\n\tif focus_mode == 0:\n\t\treturn\n",
         "func _on_pressed() -> void :\n\tif focus_mode == 0:\n\t\treturn\n\tif OS.get_name() == \"iOS\" and IOSTouchOverlay.scroll_drag_block:  # iOS-PORT\n\t\treturn\n",
         "끌어서 스크롤한 터치는 눌림 무시")
    _sub(os.path.join("System", "Screens", "Loading", "slot_load.gd"),
         "func _on_pressed() -> void :\n\tmodulate = Color(3, 3, 3, 1)\n",
         "func _on_pressed() -> void :\n\tif OS.get_name() == \"iOS\" and IOSTouchOverlay.scroll_drag_block:  # iOS-PORT\n\t\treturn\n\tmodulate = Color(3, 3, 3, 1)\n",
         "슬롯: 끌어서 스크롤한 터치는 눌림 무시")


# 언어: 한국어만 선택/사용 가능하게 한다.
# - project.godot 번역 목록에서 br / es / ja_JP / pr 제거 (영어(en)는 기본 대체 언어라 남겨 둠, 선택 목록에는 안 나옴)
# - 옵션 'Language' 는 한국어만 돌고, 예전에 저장된 다른 언어 설정이 있어도 한국어로 강제
LANG_REMOVE = ["br", "es", "ja_JP", "pr"]
LANG_MARK = "# iOS-PORT: 한국어만"


def patch_languages():
    # 1) 번역 목록에서 다른 언어 제거
    path = "project.godot"
    src = read(path)
    m = re.search(r"(translations=PoolStringArray\()(.*?)(\s*\))", src, re.S)
    if not m:
        print("[warn] project.godot 번역 목록을 찾지 못함")
    else:
        items = re.findall(r'"([^"]+)"', m.group(2))
        keep = [t for t in items
                if not any(t.endswith("real_translations." + l + ".translation") for l in LANG_REMOVE)]
        if keep == items:
            print("[skip] project.godot (다른 언어 이미 제거됨)")
        else:
            new = ", ".join('"' + t + '"' for t in keep)
            src = src[:m.start(2)] + " " + new + src[m.end(2):]
            write(path, src)
            print(f"[ok]   project.godot 번역 목록: {len(items)}개 -> {len(keep)}개 (" + ", ".join(l for l in LANG_REMOVE) + " 제거)")

    # 2) 옵션 Language: 한국어만
    path = "src/Options/Language.gd"
    src = read(path)
    if LANG_MARK in src:
        print(f"[skip] {path} (이미 패치됨)")
        return
    nl = "\r\n" if "\r\n" in src else "\n"
    old = "onready var locales := TranslationServer.get_loaded_locales()"
    if old not in src:
        print(f"[warn] {path}: locales 줄을 찾지 못함")
        return
    src = src.replace(old, LANG_MARK + " (선택 목록)" + nl + 'onready var locales := ["ko"]', 1)
    i = src.find("func get_current_language():")
    if i < 0:
        print(f"[warn] {path}: get_current_language 를 찾지 못함")
        return
    src = src[:i] + nl.join([
        "func get_current_language():",
        "\t" + LANG_MARK + ": 예전에 저장된 다른 언어 설정이 있어도 한국어",
        "\treturn \"ko\"",
        "",
    ])
    write(path, src)
    print(f"[ok]   {path}: 한국어만 선택 가능")


if __name__ == "__main__":
    if not os.path.exists("project.godot"):
        sys.exit("[error] 저장소 루트(project.godot가 있는 곳)에서 실행하세요")
    patch_character_manager()
    patch_spawner()
    patch_project_godot()
    patch_presets()
    patch_overlay()
    patch_hide_android_controls()
    patch_weaponround_touch()
    patch_title_difficulty_touch()
    patch_loading_slot_menu()
    patch_scroll_touch()
    patch_title_version_text()
    patch_hotswap_onscreen()
    patch_save_version()
    patch_stretch()
    patch_clear_color()
    apply_korean()
    patch_ko_extra()
    patch_languages()
    patch_tagteam_fonts()
    patch_tagteam_layout()
