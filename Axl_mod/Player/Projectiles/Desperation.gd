extends SimplePlayerProjectile

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

var horizontal_velocity: float = 400
var vertical_velocity: int = 0

var hitbox_rehit_time = 0.075
var desperation_speed = 400

onready var sfx_sound: AudioStreamPlayer = $sfx
var player_sound_vfx: bool = false

func _Update(delta: float) -> void :
	._Update(delta)
	
	play_sound()
	if CharacterManager.xdrive:
		destroy()
	
	if Input.is_action_pressed("move_up"):
		set_vertical_speed( - desperation_speed)
	elif Input.is_action_pressed("move_down"):
		set_vertical_speed(desperation_speed)
	else:
		set_vertical_speed(0)

	if Input.is_action_pressed("move_left"):
		set_horizontal_speed( - desperation_speed)
	elif Input.is_action_pressed("move_right"):
		set_horizontal_speed(desperation_speed)
	else:
		set_horizontal_speed(0)

func rotate_degrees(degrees : float) -> void:
	rotation_degrees = degrees

func _OnHit(_target_remaining_HP) -> void:
	$collisionShape2D.set_deferred("disabled", true)
	Tools.timer(hitbox_rehit_time, "rehit", self)

func deflect(_var) -> void :
	pass

func rehit() -> void :
	$collisionShape2D.set_deferred("disabled", false)

func play_sound() -> void :
	if not player_sound_vfx:
		player_sound_vfx = true
		sfx_sound.play()
		Tools.timer(0.05, "player_sound", self)
		Event.emit_signal("screenshake", 1)
		if is_instance_valid(GameManager.player) and GameManager.player.has_health():
			var player_special = GameManager.player.get_node_or_null("Special")
			if player_special:
				var player_giga = player_special.get_node_or_null("GigaCrash")
				if player_giga:
					player_giga.reduce_ammo(0.5)
					if player_giga.current_ammo <= 1:
						destroy()

func player_sound() -> void :
	player_sound_vfx = false

func destroy() -> void :
	CharacterManager.xdrive = true
	.destroy()

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

func _on_area2D_body_entered(body: Node) -> void :
	if active:
		if body.is_in_group("Enemies") or body.is_in_group("Bosses"):
			return
		if body.active:
			react(body)

func react(body: Node) -> void :
	call_deferred("deflect_projectile", body)

func deflect_projectile(body):
	if body.is_in_group("Enemy Projectile"):
		if body.has_method("_OnHit"):
			body._OnHit(self)
			return
		body.destroy()

