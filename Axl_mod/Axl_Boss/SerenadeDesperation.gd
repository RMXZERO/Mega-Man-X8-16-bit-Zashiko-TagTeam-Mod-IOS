extends AttackAbility

onready var tween := TweenController.new(self,false)
onready var flash: Sprite = $flash
export var _holy_death : PackedScene
export var projectile : PackedScene
var holy_death : Node2D
onready var space: Node = $"../Space"
onready var smoke_creator: Node = $SmokeCreator
onready var vfx: Node = $vfx
onready var windspark: Sprite = $windspark
onready var flash_2: Sprite = $flash2
onready var golden_particles: Particles2D = $golden_particles
onready var golden_particles_2: Particles2D = $golden_particles2
onready var vertical_flash: Sprite = $VerticalFlash

onready var up: AnimatedSprite = $"../animatedSprite/up"
onready var up_back: AnimatedSprite = $"../animatedSprite/up/back"
onready var down: AnimatedSprite = $"../animatedSprite/down"
onready var down_back: AnimatedSprite = $"../animatedSprite/down/back"

const interval := 3.0
var first_death := true
signal screen_flash
signal true_death
signal ready_for_stun
var end_holy_death: bool = false
var use_holy_death: bool = false

func _ready() -> void :
	._ready()
	get_parent().listen("zero_health", self, "end_holy_death")

func _Setup():
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	Tools.timer(0.1, "attack_stage_1", self)
	up.unhide()
	up_back.unhide()
	down.unhide()
	down_back.unhide()

func attack_stage_1() -> void :
	go_to_attack_stage(1)

func _Update(delta):
	if attack_stage == 1:
		process_gravity(delta)
		if character.is_on_floor() and timer > 0.1:
			play_animation("revive")
			turn_and_face_player()
			decay_speed_regardless_of_direction()
			next_attack_stage()
	
	elif attack_stage == 2 and timer > 1.0:
		play_animation("lotus_start")
		create_smoke()
		golden_particles.emitting = true
		screenshake()
		Tools.timer(1, "screenshake", self)
		Tools.timer(2, "screenshake", self)
		Tools.timer(3, "screenshake", self)
		vfx.activate()
		set_vertical_speed(-30)
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		decay_vertical_speed_regardless_of_direction(4)
		play_animation("lotus")
		next_attack_stage()

	elif attack_stage == 4 and timer > 2.4:
		play_animation("unleash_start")
		queue_balls()
		vertical_flash.start()
		golden_particles.emitting = false
		golden_particles_2.emitting = true
		flash.start()
		Tools.timer(0.15,"start",flash_2)
		Tools.timer(0.35,"start",flash_2)
		screenshake()
		start_holy_death()
		vfx.deactivate()
		vfx.visible = false
		windspark.emit()
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		play_animation("unleash")
		Tools.timer(1,"screenshake",self)
		Tools.timer(2,"screenshake",self)
		next_attack_stage()
	
	elif attack_stage == 6 and timer > 3.9:
		golden_particles.emitting = false
		golden_particles_2.emitting = false
		smoke_end()
		up.hide()
		up_back.hide()
		down.hide()
		down_back.hide()
		EndAbility()

func _Interrupt():
	smoke_end()
	golden_particles.emitting = false
	golden_particles_2.emitting = false
	up.hide()
	up_back.hide()
	down.hide()
	down_back.hide()
	._Interrupt()

func start_holy_death():
	holy_death = _holy_death.instance()
	character.get_parent().add_child(holy_death)
	end_holy_death = false
	use_holy_death = true
	Tools.timer(0.1, "activate", holy_death)
	Tools.timer(5.0, "holy_death", self)

func holy_death():
	if not end_holy_death:
		Tools.timer(5.0, "holy_death", self)
		Tools.timer(0.1, "activate", holy_death)

func end_holy_death():
	if use_holy_death:
		golden_particles.emitting = false
		golden_particles_2.emitting = false
		end_holy_death = true
		holy_death.deactivate()

func queue_balls():
	var i = 0
	while i < 20:
		Tools.timer(0.1 + (0.1*i),"create_ball",self)
		i += 1

func create_ball():
	if executing:
		var ball = projectile.instance()
		var center = space.center + Vector2(0,0)
		get_tree().current_scene.add_child(ball)
		ball.position = global_position + Vector2(0,-8)
		ball.move(center + Vector2(rand_range(-160,160),rand_range(-30,100)))
		ball.z_index = 0
		ball.modulate.a = 0.5
		Tools.timer_p(0.15,"set_z_index",ball,15)
		Tools.timer_p(0.15,"set_modulate",ball,Color.white)

func create_smoke():
	smoke_creator.activate()

func smoke_end():
	smoke_creator.deactivate()
