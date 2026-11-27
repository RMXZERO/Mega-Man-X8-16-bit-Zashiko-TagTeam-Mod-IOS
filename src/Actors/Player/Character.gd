extends AbilityUser
class_name Character

onready var wallcheck_left: = $_raycasts.get_node("Wallcheck Left")
onready var wallcheck_left2: = $_raycasts.get_node("Wallcheck Left2")
onready var wallcheck_left3: = $_raycasts.get_node("Wallcheck Left3")
onready var wallcheck_right: = $_raycasts.get_node("Wallcheck Right")
onready var wallcheck_right2: = $_raycasts.get_node("Wallcheck Right2")
onready var wallcheck_right3: = $_raycasts.get_node("Wallcheck Right3")
onready var cast_left = [wallcheck_left, wallcheck_left2, wallcheck_left3]
onready var cast_right = [wallcheck_right, wallcheck_right2, wallcheck_right3]

onready var walljumpcast_left: = $_raycasts.get_node("WallJumpCast Left")
onready var walljumpcast_left2: = $_raycasts.get_node("WallJumpCast Left2")
onready var walljumpcast_left3: = $_raycasts.get_node("WallJumpCast Left3")
onready var walljumpcast_right: = $_raycasts.get_node("WallJumpCast Right")
onready var walljumpcast_right2: = $_raycasts.get_node("WallJumpCast Right2")
onready var walljumpcast_right3: = $_raycasts.get_node("WallJumpCast Right3")
onready var jumpcast_left = [walljumpcast_left, walljumpcast_left2, walljumpcast_left3]
onready var jumpcast_right = [walljumpcast_right, walljumpcast_right2, walljumpcast_right3]
onready var low_jumpcasts = [walljumpcast_left3, walljumpcast_right3]

onready var collisor: = $"Enemy Collision Detector".get_node("CollisionShape2D")

onready var shot_position: = get_node("Shot Position")

var listening_to_inputs: bool = true
var emitted_land: bool = false
var last_time_dashed: float = 0.0
var last_wall_at_position: Vector2
var full_alpha: bool = true
var set_alert: bool = false
var is_shooting: bool = false
var colors: Array = []
var debug_position_y: float = 0.0
var should_die_to_spikes: bool = true
var spike_invincibility: bool = false
var alpha_alway_1: bool = false
var can_eject: bool = true

signal headbump
signal land
signal cutscene_deactivate
signal ride(prop)
signal eject(prop)
signal force_movement
signal stop_forced_movement(forcer)
signal melee_hit(enemy)
signal jump

# TeamMod stuff
signal character_switch_out
signal character_switch_in
signal activate_revive
var is_current_player: bool = false
var is_executing_special: bool = false
var last_hit_time: float = 0.0
var num_equipped_hearts

func check_for_char_switch_input() -> void :
	if get_action_just_pressed("char_switch"):
		if can_switch():
			Event.emit_signal("character_switch")

func can_switch() -> bool :
	return is_current_player and CharacterManager.switch_timer <= 0 and CharacterManager.team.size() > 1 and CharacterManager.both_alive and not is_executing_special

func max_out_air_abilities() -> void :
	var airjump = get_node_or_null("AirJump")
	var airdash = get_node_or_null("AirDash")
	var hover = get_node_or_null("Hover")
	
	if airjump != null:
		airjump.current_air_jumps = 0
	if airdash != null:
		airdash.airdash_count = 0
	if hover != null:
		hover.current_air_jumps = 0

	set_horizontal_speed(0)
####

func interrupt_all_moves():
	.interrupt_all_moves()
	
	if not is_executing("Forced"):
		if is_on_floor():
			animatedSprite.play("recover")
		else:
			animatedSprite.play("fall")

func _ready() -> void :
	connect_cutscene_events()
	num_equipped_hearts = 0
	if not self.name in CharacterManager.alive_team:
		CharacterManager.alive_team.append(self.name)
	max_health = CharacterManager.starting_max_health
	current_health = max_health

func connect_cutscene_events() -> void :
	Event.listen("end_cutscene_start", self, "deactivate")
	Event.listen("cutscene_start", self, "stop_listening_to_inputs")
	Event.listen("stage_rotate", self, "stop_listening_to_inputs")
	Event.listen("cutscene_over", self, "cutscene_activate")

func _process(_delta: float) -> void :
	update_facing_direction()
	if not is_current_player:
		global_position = GameManager.player.global_position
		direction = GameManager.player.direction
		

func _physics_process(delta: float) -> void :
	if is_current_player:
		var actual_delta = delta
		last_hit_time += delta
		if time_stop_active:
			last_hit_time += GameManager.true_delta
			actual_delta = GameManager.true_delta
		check_if_should_set_alpha_to_1()
		check_for_headbump()
		check_for_land(actual_delta)
		check_for_low_health()
		check_for_dash()
		check_for_char_switch_input()
		if has_control() and IGT.should_run:
			IGT.in_game_timer += actual_delta
			IGT.stage_timer += actual_delta

func cutscene_activate() -> void :
	if not is_executing("Ride"):
		activate()






func spike_touch() -> void :
	if is_current_player and should_instantly_die() and not is_invulnerable() and not spike_invincibility:
		if CharacterManager.game_mode <= - 1 or not should_die_to_spikes:
			emit_signal("damage", 1, self)
			return
		zero_health_team()

func lava_touch() -> void :
	if is_current_player and should_instantly_die() and not spike_invincibility:
		if CharacterManager.game_mode <= - 1 or not should_die_to_spikes:
			if not is_invulnerable():
				emit_signal("damage", 1, self)
			return
		zero_health_team()

func void_touch() -> void :
	zero_health_team()

func zero_health_team() -> void :
	current_health = 0
	CharacterManager.both_alive = false
	CharacterManager.alive_team = []
	emit_signal("zero_health")
	if is_instance_valid(GameManager.inactive_player):
		GameManager.inactive_player.current_health = 0
		GameManager.inactive_player.emit_signal("zero_health")
	if is_instance_valid(GameManager.player):
		GameManager.player.current_health = 0
		GameManager.player.emit_signal("zero_health")

func should_instantly_die() -> bool:
	return not is_executing("Ride")

func ride(ride: Node) -> void :
	if is_current_player:
		emit_signal("ride", ride)

func eject(ride: Node) -> void :
	emit_signal("eject", ride)

func force_movement(_forcer = null) -> void :
	emit_signal("force_movement")
	
func stop_forced_movement(forcer = null) -> void :
	emit_signal("stop_forced_movement", forcer)

func activate() -> void :
	if is_current_player:
		start_listening_to_inputs()
		Log("Active")
	else:
		deactivate()

func hide() -> void :
	visible = false

func show() -> void :
	visible = true

func deactivate() -> void :
	stop_listening_to_inputs()
	stop_shot()
	Log("not active")

func stop_shot() -> void :
	for ability in executing_moves:
		if ability.name == "Shot":
			ability.EndAbility()

func make_invisible() -> void :
	Log("invisible")
	animatedSprite.visible = false

func make_visible() -> void :
	Log("visible")
	animatedSprite.visible = true

func stop_listening_to_inputs() -> void :
	Log("not listening to inputs")
	listening_to_inputs = false

func cutscene_deactivate() -> void :
	stop_listening_to_inputs()
	emit_signal("cutscene_deactivate")
	if GameManager.player.ride:
		GameManager.player.ride.stop_listening_to_inputs()

func start_listening_to_inputs() -> void :
	if GameManager.get_state() != "Cutscene":
		Log("listening to inputs")
		listening_to_inputs = true

func get_executing_moves() -> void :
	for move in moveset:
		if move.CheckForPressed():
			try_execution(move)

func has_control() -> bool:
	if listening_to_inputs:
		return true


	return false

func check_for_dash() -> void :
	if get_action_just_pressed("dash"):
		Event.emit_signal("input_dash")

func check_if_should_set_alpha_to_1() -> void :
	if invulnerability < 0 and not has_invulnerability_from_skills() and not full_alpha or alpha_alway_1:
		remove_invulnerability_shader()
		full_alpha = true

func has_invulnerability_from_skills() -> bool:
	return toggleable_invulnerabilities.size() > 0

func check_for_low_health() -> void :
	if has_health():
		if is_low_health() and not set_alert:
			animatedSprite.material.set_shader_param("Alert", 1)
			set_alert = true
		elif not is_low_health() and set_alert:
			animatedSprite.material.set_shader_param("Alert", 0)
			set_alert = false

func is_invulnerable() -> bool:
	if not active:
		return true
	else:
		return .is_invulnerable()

func add_invulnerability(ability_name) -> void :
	if not ability_name in toggleable_invulnerabilities:
		toggleable_invulnerabilities.append(ability_name)
		apply_invulnerability_shader()

func remove_invulnerability(ability_name) -> void :
	toggleable_invulnerabilities.erase(ability_name)
	if not is_invulnerable():
		remove_invulnerability_shader()

func apply_invulnerability_shader() -> void :
		animatedSprite.material.set_shader_param("Alpha", 0.5)
		full_alpha = false

func remove_invulnerability_shader() -> void :
		animatedSprite.material.set_shader_param("Alpha", 1)
		full_alpha = true

func check_for_headbump() -> void :
	if is_on_ceiling():
		emit_signal("headbump")

func check_for_land(delta: float) -> void :
	if is_on_floor():
		if not emitted_land:
			emitted_land = true
			time_since_on_floor = 0
			emit_signal("land")
	else:
		time_since_on_floor = time_since_on_floor + delta
		if emitted_land:
			emitted_land = false

func is_colliding_with_wall() -> int:
	for cast in cast_right:
		if check_for_normal(cast, - 1):
			return 1
	for cast in cast_left:
		if check_for_normal(cast, 1):
			return - 1
	return 0

func is_colliding_with_wall_except_feet() -> int:
	var right = [wallcheck_right, wallcheck_right2]
	var left = [wallcheck_left, wallcheck_left2]
	for cast in right:
		if check_for_normal(cast, - 1):
			return 1
	for cast in left:
		if check_for_normal(cast, 1):
			return - 1
	return 0

func is_colliding_with_both_walls() -> bool:
	var collision = 0
	for cast in cast_right:
		if check_for_normal(cast, - 1):
			collision += 1
	for cast in cast_left:
		if check_for_normal(cast, 1):
			collision += 1
	return collision == 2

func is_in_reach_for_walljump() -> int:
	for cast in jumpcast_right:
		if check_for_normal(cast, - 1):
			return 1
	for cast in jumpcast_left:
		if check_for_normal(cast, 1):
			return - 1
	return 0

func check_for_normal(cast, normal: int, angle_range: float = 0.25) -> bool:
	return cast.is_colliding() and cast.get_collision_normal().x > normal - angle_range and cast.get_collision_normal().x < normal + angle_range

func get_pressed_axis() -> int:
	var axis = 0
	if get_action_pressed("move_left"):
		axis = axis - 1
	if get_action_pressed("move_right"):
		axis = axis + 1
	return axis

func get_just_pressed_axis() -> int:
	var axis = 0
	if has_just_pressed_left():
		axis = axis - 1
	if has_just_pressed_right():
		axis = axis + 1
	return axis

func has_just_pressed_left() -> bool:
	return get_action_just_pressed("move_left")

func has_just_pressed_right() -> bool:
	return get_action_just_pressed("move_right")

func set_animation_layer(layer):
	if animatedSprite.frames != layer:
		animatedSprite.frames = layer

func get_animation_layer() -> String:
	return animatedSprite.frames

func send_debug_info() -> String:
	var text: = ""
	text += print_position()
	text += print_speed()
	text += print_states()
	return text

func print_hp() -> String:
	var text: = "HP:"
	for unit in current_health:
		text += "l"
	return text

func print_position() -> String:
	var x_pos = stepify(position.x, 0.01)
	var y_pos = stepify(position.y, 0.01)
	return "X:" + str(x_pos) + "\nY:" + str(y_pos)

func print_speed() -> String:
	var x_speed = stepify(final_velocity.x, 0.1)
	var y_speed = stepify(final_velocity.y, 0.1)
	return "\nH Spd:" + str(x_speed) + "\nV Spd:" + str(y_speed)

func print_states() -> String:
	var text: = ""
	var total_states: = ""
	for state in moveset:
		if state.executing:
			text += state.name.left(1)
			if total_states.length() > 0:
				total_states += ", "
			total_states += state.name
		else:
			text += "."
	var final_text: = "\nState: " + str(total_states) + "\n" + text
	return final_text

var analog_deadzone = 0.1
func get_left_analog_direction():
	if listening_to_inputs:
		if InputMap.has_action("move_left") or InputMap.has_action("move_right") or InputMap.has_action("move_up") or InputMap.has_action("move_down"):
			InputMap.action_set_deadzone("move_left", analog_deadzone)
			InputMap.action_set_deadzone("move_right", analog_deadzone)
			InputMap.action_set_deadzone("move_up", analog_deadzone)
			InputMap.action_set_deadzone("move_down", analog_deadzone)

			var left_stick_x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
			var left_stick_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			
			var analog_direction = Vector2(left_stick_x, left_stick_y)
			analog_direction = analog_direction.normalized()
				
			return analog_direction
		return Vector2.ZERO
	else:
		return false

func get_right_analog_direction():
	if listening_to_inputs:
		InputMap.action_set_deadzone("analog_left", analog_deadzone)
		InputMap.action_set_deadzone("analog_right", analog_deadzone)
		InputMap.action_set_deadzone("analog_up", analog_deadzone)
		InputMap.action_set_deadzone("analog_down", analog_deadzone)

		var right_stick_x = Input.get_action_strength("analog_left") - Input.get_action_strength("analog_right")
		var right_stick_y = Input.get_action_strength("analog_down") - Input.get_action_strength("analog_up")
		
		var analog_direction = Vector2(right_stick_x, right_stick_y)
		analog_direction = analog_direction.normalized()
			
		return analog_direction
	return Vector2.ZERO

func get_action_just_pressed(action) -> bool:
	if listening_to_inputs:
		return Input.is_action_just_pressed(action)
	return false

func get_action_pressed(action) -> bool:
	if listening_to_inputs:
		return Input.is_action_pressed(action)
	return false

func get_action_strength(action) -> float:
	if listening_to_inputs:
		return Input.get_action_strength(action)
	return 0.0

func get_action_just_released(action) -> bool:
	if listening_to_inputs:
		return Input.is_action_just_released(action)
	return false

func hit(_body: Node) -> void :
	emit_signal("melee_hit", _body)


# ---- 자동 입력 보조 (제로 AUTO ATTACK / X AUTO CHARGE) ----
# 아래 두 함수는 CharacterManager._physics_process 에서 호출된다.
# (autoload 가 플레이어보다 먼저 처리되므로, 넣어 준 입력을 같은 프레임의 능력들이 확실히 인식한다)
const AUTO_ATTACK_RANGE_X: float = 60.0   # 제로 중심 ~ 적 충돌영역 가장자리까지 허용 거리
const AUTO_ATTACK_RANGE_UP: float = 45.0
const AUTO_ATTACK_RANGE_DOWN: float = 25.0
const AUTO_ATTACK_INTERVAL: float = 0.12
const AUTO_ATTACK_HOLD: float = 0.05      # fire 를 눌러 두는 시간 (물리 프레임 3개쯤)
var _auto_attack_pressed: bool = false
var _auto_attack_hold: float = 0.0
var _auto_attack_cd: float = 0.0
var _auto_window_anim: String = ""
var auto_charge_block_basic: float = 0.0
var _fire_was_down: bool = false
var _auto_charge_was_on: bool = false

func is_zero_player() -> bool:
	return get_node_or_null("SaberCharge") != null

func check_zero_auto_attack(delta: float) -> void:
	if _auto_attack_pressed:
		_auto_attack_hold -= delta
		if _auto_attack_hold <= 0.0:
			Input.action_release("fire")
			_auto_attack_pressed = false
		return
	if not is_zero_player():
		return
	if not CharacterManager.zero_auto_attack:
		return
	if not listening_to_inputs or not has_health():
		return
	if Input.is_action_pressed("fire"):
		return
	# 콤보 이어치기: 베는 중 "다음 타 입력 구간"이 열리면 그때 맞춰 한 번 더 누른다.
	# (일정 간격으로만 누르면 구간을 놓쳐서 1타에서 끊김)
	var combo = null
	for combo_name in ["SaberCombo", "SaberJump"]:
		var c = get_node_or_null(combo_name)
		if c != null and c.get("executing") and c.has_method("is_in_buffer_window") and c.is_in_buffer_window():
			combo = c
			break
	if combo != null:
		var anim: String = animatedSprite.animation
		if anim != _auto_window_anim:
			if get_auto_attack_direction() != 0:
				_auto_window_anim = anim
				Input.action_press("fire")
				_auto_attack_pressed = true
				_auto_attack_hold = AUTO_ATTACK_HOLD
				_auto_attack_cd = AUTO_ATTACK_INTERVAL
				return
	else:
		_auto_window_anim = ""
	_auto_attack_cd -= delta
	if _auto_attack_cd > 0.0:
		return
	var target_dir: int = get_auto_attack_direction()
	if target_dir != 0 and not is_on_floor() and target_dir != get_facing_direction():
		# 공중(점프 중)에서는 돌아서지 않고, 앞에 있는 적만 공격한다
		return
	if target_dir != 0:
		# 적이 등 뒤에만 있으면 그쪽으로 돌아선 뒤 공격한다 (베는 도중에는 돌지 않음)
		if target_dir != get_facing_direction() and not _is_in_saber_animation():
			set_direction(target_dir, true)
		Input.action_press("fire")
		_auto_attack_pressed = true
		_auto_attack_hold = AUTO_ATTACK_HOLD
		_auto_attack_cd = AUTO_ATTACK_INTERVAL

func _is_boss(body) -> bool:
	if body.is_in_group("Bosses"):
		return true
	for child in body.get_children():
		if child is BossDamage:
			return true
	return false

# 공격 가능한 대상인지: 비활성 적은 제외 (보스는 따로 처리)
func _is_attackable_target(body) -> bool:
	for child in body.get_children():
		if child is EnemyDamage and not child.active:
			return false
	return true

# CollisionShape2D 하나를 월드 좌표 Rect2 로 바꾼다. 지원 안 하는 모양이면 빈 Rect2(크기 0).
func _shape_node_rect(shape_node) -> Rect2:
	var sh = shape_node.shape
	var xf: Transform2D = shape_node.global_transform
	if sh is RectangleShape2D:
		var e: Vector2 = sh.extents
		var pts = [Vector2(-e.x, -e.y), Vector2(e.x, -e.y), Vector2(e.x, e.y), Vector2(-e.x, e.y)]
		return _points_rect(pts, xf)
	if sh is CircleShape2D:
		var r: float = sh.radius
		return _points_rect([Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)], xf)
	if sh is CapsuleShape2D:
		var hh: float = sh.height * 0.5 + sh.radius
		var rr: float = sh.radius
		return _points_rect([Vector2(-rr, -hh), Vector2(rr, -hh), Vector2(rr, hh), Vector2(-rr, hh)], xf)
	if sh is ConvexPolygonShape2D:
		return _points_rect(Array(sh.points), xf)
	if sh is ConcavePolygonShape2D:
		return _points_rect(Array(sh.segments), xf)
	return Rect2()

func _points_rect(pts: Array, xf: Transform2D) -> Rect2:
	if pts.empty():
		return Rect2()
	var first: Vector2 = xf.xform(pts[0])
	var min_p: Vector2 = first
	var max_p: Vector2 = first
	for pt in pts:
		var w: Vector2 = xf.xform(pt)
		min_p = Vector2(min(min_p.x, w.x), min(min_p.y, w.y))
		max_p = Vector2(max(max_p.x, w.x), max(max_p.y, w.y))
	return Rect2(min_p, max_p - min_p)

func _area_union_rect(area, rect: Rect2, found: bool) -> Array:
	if area == null or not is_instance_valid(area):
		return [rect, found]
	for shape_node in area.get_children():
		if not (shape_node is CollisionShape2D) or shape_node.disabled or shape_node.shape == null:
			continue
		var r: Rect2 = _shape_node_rect(shape_node)
		if r.size == Vector2.ZERO:
			continue
		if found:
			rect = rect.merge(r)
		else:
			rect = r
			found = true
	return [rect, found]

# 적/보스의 피격 범위를 월드 좌표 Rect2 로 구한다.
# 보스는 피격 영역들(area2D, 데미지 노드 안 영역, DamageDetector 등)과 스프라이트 크기를 모두 합친다.
func _get_enemy_rect(_enemy_damage, body: Node2D) -> Rect2:
	var rect := Rect2(body.global_position - Vector2(4, 4), Vector2(8, 8))
	var found := false
	var areas := [body.get_node_or_null("area2D"), body.get_node_or_null("DamageDetector")]
	var boss: bool = _is_boss(body)
	for child in body.get_children():
		if child is BossDamage:
			if child.custom_hitbox != null:
				areas.append(child.custom_hitbox)
			for sub in child.get_children():
				if sub is Area2D:
					areas.append(sub)
	for a in areas:
		var res: Array = _area_union_rect(a, rect, found)
		rect = res[0]
		found = res[1]
	if boss:
		var sr: Rect2 = _sprite_rect(body)
		if sr.size != Vector2.ZERO:
			if found:
				rect = rect.merge(sr)
			else:
				rect = sr
				found = true
	return rect

# 보스 본체 스프라이트가 현재 차지하는 영역 (덩치 큰 보스의 충돌영역이 작게 잡힌 경우 보완)
func _sprite_rect(body) -> Rect2:
	var spr = body.get_node_or_null("animatedSprite")
	if spr == null or not (spr is AnimatedSprite) or spr.frames == null:
		return Rect2()
	if not spr.frames.has_animation(spr.animation):
		return Rect2()
	var tex = spr.frames.get_frame(spr.animation, spr.frame)
	if tex == null:
		return Rect2()
	var sz: Vector2 = tex.get_size()
	var sc: Vector2 = spr.global_scale
	var size := Vector2(sz.x * abs(sc.x), sz.y * abs(sc.y))
	var center: Vector2 = spr.global_position + Vector2(spr.offset.x * sc.x, spr.offset.y * sc.y)
	if spr.centered:
		return Rect2(center - size * 0.5, size)
	return Rect2(center, size)

# 공격 범위 안에 적이 있으면 공격할 방향(1/-1)을, 없으면 0 을 돌려준다.
# 여러 적이 범위에 있으면 "먼저 범위에 들어온 적"을 계속 우선 공격하고,
# 그 적이 사라지거나 범위를 벗어나야 다음 적으로 넘어간다.
var _auto_target = null

func get_auto_attack_direction() -> int:
	var dir: int = get_facing_direction()
	var px: float = global_position.x
	var py: float = global_position.y
	var in_range := []   # [ [키 노드, 방향], ... ]
	var checked := []
	var nodes := []
	nodes.append_array(get_tree().get_nodes_in_group("Enemies"))
	nodes.append_array(get_tree().get_nodes_in_group("Bosses"))
	for node in nodes:
		if not is_instance_valid(node):
			continue
		var body = node
		if node is EnemyDamage:
			body = node.character
		if not is_instance_valid(body) or not (body is Node2D):
			continue
		if checked.has(body):
			continue
		checked.append(body)
		if body.has_method("has_health") and not body.has_health():
			continue
		# 보스는 상태(활성/피격가능)나 화면 기준점 검사를 하지 않고 범위만 본다
		# (보스마다 피격 상태를 따로 껐다 켜서 이 검사가 오히려 감지를 막음)
		var is_boss: bool = _is_boss(body)
		if not is_boss:
			if not _is_attackable_target(body):
				continue
			if not GameManager.is_on_screen(body.global_position):
				continue
		var rect: Rect2 = _get_enemy_rect(null, body)
		var gap_x: float = 0.0
		if px < rect.position.x:
			gap_x = rect.position.x - px
		elif px > rect.end.x:
			gap_x = px - rect.end.x
		if gap_x > AUTO_ATTACK_RANGE_X:
			continue
		# 세로: 제로 공격 범위 띠와 적 영역이 겹치는지
		if rect.end.y < py - AUTO_ATTACK_RANGE_UP or rect.position.y > py + AUTO_ATTACK_RANGE_DOWN:
			continue
		var side: int = dir   # 겹쳐 있으면 지금 보는 방향 그대로
		if px < rect.position.x:
			side = 1
		elif px > rect.end.x:
			side = -1
		in_range.append([body, side])
	if in_range.empty():
		_auto_target = null
		return 0
	# 이미 노리던 적이 아직 범위에 있으면 그 적을 계속 노린다
	if _auto_target != null and is_instance_valid(_auto_target):
		for entry in in_range:
			if entry[0] == _auto_target:
				return entry[1]
	# 아니면 가장 먼저 등록된 적(그룹 순서 = 등장 순서)을 새 목표로
	_auto_target = in_range[0][0]
	return in_range[0][1]

func check_x_auto_charge(delta: float) -> void:
	if auto_charge_block_basic > 0.0:
		auto_charge_block_basic -= delta
	# 게임 중(옵션 메뉴 등)에 자동 차지가 켜지거나 꺼진 순간, 차지가 쓰는 입력(fire/auto_charge)을
	# 새 설정으로 바꾸고 auto_charge 입력을 한 번 떼어, 아래에서 새로 눌린 것으로 인식되게 한다
	if CharacterManager.auto_charge != _auto_charge_was_on:
		_auto_charge_was_on = CharacterManager.auto_charge
		var _charge_node = get_node_or_null("Charge")
		if _charge_node != null and _charge_node.has_method("reset_input"):
			_charge_node.reset_input()
		Input.action_release("auto_charge")
	# 공격 버튼 "방금 눌림"을 프레임 타이밍에 의존하지 않고 직접 판별한다
	var fire_down: bool = Input.is_action_pressed("fire")
	var fire_just: bool = fire_down and not _fire_was_down
	_fire_was_down = fire_down
	if not CharacterManager.auto_charge or CharacterManager.ultimate_buster or CharacterManager.weaponget:
		return
	if is_zero_player() or not has_node("Charge"):
		return
	if not listening_to_inputs or is_executing("Ride"):
		return
	if fire_down:
		# 공격 버튼을 누르는 동안은 자동 차지를 풀어서 모아 둔 차지샷이 나가게 한다
		if fire_just:
			var charge = get_node("Charge")
			if charge.has_method("get_charge_level") and charge.get_charge_level() >= 1:
				# 차지가 모인 상태면 기본탄은 막고 차지샷만 내보낸다
				auto_charge_block_basic = 0.25
		if Input.is_action_pressed("auto_charge"):
			Input.action_release("auto_charge")
	elif not Input.is_action_pressed("auto_charge"):
		Input.action_press("auto_charge")
