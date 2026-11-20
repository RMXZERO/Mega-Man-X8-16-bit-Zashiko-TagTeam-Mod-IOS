extends TouchScreenButton

var pause_position_x = CharacterManager.pause_position_x * 0.1 + 19
var pause_position_y = CharacterManager.pause_position_y * 0.1 + 7

var jump_position_x = CharacterManager.jump_position_x * 0.1 + 19
var jump_position_y = CharacterManager.jump_position_y * 0.1 + 19
var dash_position_x = CharacterManager.dash_position_x * 0.1 + 19
var dash_position_y = CharacterManager.dash_position_y * 0.1 + 19

var fire_position_x = CharacterManager.fire_position_x * 0.1 + 19
var fire_position_y = CharacterManager.fire_position_y * 0.1 + 19
var alt_fire_position_x = CharacterManager.alt_fire_position_x * 0.1 + 19
var alt_fire_position_y = CharacterManager.alt_fire_position_y * 0.1 + 19

var special_position_x = CharacterManager.special_position_x * 0.1 + 19
var special_position_y = CharacterManager.special_position_y * 0.1 + 19
var switch_position_x = CharacterManager.switch_position_x * 0.1 + 19
var switch_position_y = CharacterManager.switch_position_y * 0.1 + 19

var dash_jump_position_x = CharacterManager.dash_jump_position_x * 0.1 + 19
var dash_jump_position_y = CharacterManager.dash_jump_position_y * 0.1 + 19
var dash_fire_position_x = CharacterManager.dash_fire_position_x * 0.1 + 19
var dash_fire_position_y = CharacterManager.dash_fire_position_y * 0.1 + 19

var weapon_left_position_x = CharacterManager.weapon_left_position_x * 0.1 + 28
var weapon_left_position_y = CharacterManager.weapon_left_position_y * 0.1 + 19
var weapon_right_position_x = CharacterManager.weapon_right_position_x * 0.1 + 28
var weapon_right_position_y = CharacterManager.weapon_right_position_y * 0.1 + 19

var joystick_position_x = CharacterManager.joystick_position_x * 0.1
var joystick_position_y = CharacterManager.joystick_position_y * 0.1

var weaponround_position_x = CharacterManager.weaponround_position_x * 0.1
var weaponround_position_y = CharacterManager.weaponround_position_y * 0.1

func _ready() -> void :
	control_position()

func control_position() -> void :
	$Pause.position.x = pause_position_x
	$Pause.position.y = pause_position_y
	$Jump.position.x = jump_position_x
	$Jump.position.y = jump_position_y
	$Dash.position.x = dash_position_x
	$Dash.position.y = dash_position_y
	$Fire.position.x = fire_position_x
	$Fire.position.y = fire_position_y
	$AltFire.position.x = alt_fire_position_x
	$AltFire.position.y = alt_fire_position_y
	$dashjump.position.x = dash_jump_position_x
	$dashjump.position.y = dash_jump_position_y
	$dashaltfire.position.x = dash_fire_position_x
	$dashaltfire.position.y = dash_fire_position_y
	$Switch.position.x = switch_position_x
	$Switch.position.y = switch_position_y
	$Special.position.x = special_position_x
	$Special.position.y = special_position_y
	$WeaponPrev.position.x = weapon_left_position_x
	$WeaponPrev.position.y = weapon_left_position_y
	$WeaponNext.position.x = weapon_right_position_x
	$WeaponNext.position.y = weapon_right_position_y
	$joystick.position.x = joystick_position_x
	$joystick.position.y = joystick_position_y
	$weaponround.position.x = weaponround_position_x
	$weaponround.position.y = weaponround_position_y





