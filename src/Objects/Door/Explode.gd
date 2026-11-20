extends NewAbility

var exploded: = false
var hit_timer: int = 0
var hit_first: = false
var hit_second: = false
onready var animation = AnimationController.new($"../animatedSprite", self)
onready var particles: Particles2D = $"Explosion Particles"
onready var explosion: AudioStreamPlayer2D = $explosion_sound
onready var collider: CollisionShape2D = $"../collisionShape2D"

var hit_times: int = 0
var deflects: Array = [
	"RideArmorPunch", 
	"NovaStrikeCharged", 
	"GigaCrashCharged", 
	"GenmuzeroCharged", 
	"Genmuzerowave", 
	"Player_Desperation"
]

func _StartCondition() -> bool:
	return character.able_to_explode and not exploded

func _Setup() -> void :
	hit_timer = 0
	exploded = true
	$punch_detector.active = false
	collider.set_deferred("disabled", true)
	animation.play("open")
	explosion.play()
	particles.emitting = true
	Tools.timer(1.5, "stop_visuals", self)
	Event.emit_signal("screenshake", 2)

func stop_visuals() -> void :
	particles.emitting = false

func _on_punch_detector_body_entered(body) -> void :
	for deflect in deflects:
		if body.name == deflect:
			_on_signal()
			return
	
	if body.is_in_group("Player Projectile"):
		if "SqueezeBombCharged" in body.name:
			if "Charged_B" in body.name:
				on_saber_hit(5)
			else:
				on_squeezebomb_hit(1)
		elif "Juuhazan" in body.name:
			if "Charged" in body.name:
				on_saber_hit(2)
				if "Charged_C" in body.name:
					on_saber_hit(2)
			else:
				on_saber_hit(2)
		elif "BlastLaunchCharged" in body.name:
			body.deflect(self)
			on_blastLauncher_hit(1)
		elif "IntenseExplosion" in body.name:
			on_blastLauncher_hit(1)
		elif "Youdantotsu" in body.name:
			if "Charged" in body.name:
				on_saber_hit(2)
			else:
				on_saber_hit(1)
		else:
			body.deflect(self)

func on_saber_hit(amount: int) -> void :
	hit_times += amount
	on_flash_door()
	if hit_times >= 40:
		_on_signal()

func on_squeezebomb_hit(amount: int) -> void :
	hit_times += amount
	on_flash_door()
	if hit_times >= 2:
		_on_signal()

func on_blastLauncher_hit(amount: int) -> void :
	hit_times += amount
	on_flash_door()
	if hit_times >= 4:
		_on_signal()

func on_flash_door() -> void :
	var door_sprite = get_parent().get_node_or_null("animatedSprite")
	if door_sprite:
		door_sprite
		door_sprite.modulate = Color(100, 100, 100, 1)
		explosion.play()
		yield(get_tree().create_timer(0.1), "timeout")
		door_sprite.modulate = Color(1, 1, 1, 1)

func damage(_d, _s) -> float:
	return 1.0

func _on_bike_detector_body_entered(body: Node) -> void :
	if not exploded:
		if body.is_in_group("Props") and "RideChaser" in body.get_character().name:
			if abs(body.get_character().get_actual_horizontal_speed()) > 325:
				_on_signal()
				call_deferred("destroy_bike", body)

func destroy_bike(body):
	var bike = body.get_character()
	bike.set_actual_speed(bike.get_actual_speed() / 2)
	bike.current_health = 0
	bike.get_node("Death").emit_remains_particles()
	if bike.is_executing("Riden"):
		bike.get_node("Riden").force_eject()
	bike.force_end("Dash")
	bike.force_end("HyperDash")
	bike.set_direction( - bike.get_direction())
	
