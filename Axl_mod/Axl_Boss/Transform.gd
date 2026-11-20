extends AttackAbility

const axl_sprites: Resource = preload("res://Axl_mod/Axl_Boss/axl_boss.tres")

export  var disable_after_usage: bool = false
export  var flip_animation: bool = false
export  var _desperation: NodePath
export  var _collider: NodePath
export  var boss_sprites: SpriteFrames
export  var weakness: String = ""
export  var weaknesses: Array = []
export  var new_position = -4

onready var main = get_parent()
onready var desperation = get_node(_desperation)
onready var transform_collider = get_node(_collider)
onready var tween: TweenController = TweenController.new(self, false)
onready var flash: Sprite = $"../flash"
onready var og_collider: CollisionShape2D = $"../collisionShape2D"
onready var transform_sfx: AudioStreamPlayer2D = $"../transform"
onready var damage_area: Area2D = $"../area2D"
onready var damage_og_collider: CollisionShape2D = $"../area2D/collisionShape2D"
onready var damage_transform_collider: CollisionShape2D = damage_area.get_node(transform_collider.name)
onready var damage: Node2D = $"../Damage"
onready var start_transform: AudioStreamPlayer2D = $"../start_transform"
onready var boss_stun: Node2D = $"../BossStun"
var already_use: bool = false

signal transformed
signal ended_transform


func _ready() -> void :
	desperation.connect("ability_end", self, "on_desperation_end")
	desperation.connect("executed", boss_stun, "deactivate")
	desperation.connect("ready_for_stun", boss_stun, "reactivate")
	desperation.call_deferred("connect_animation_finished_event")
	already_use = false

func _Setup() -> void :
	tween.method("set_horizontal_speed", character.get_horizontal_speed(), 0.0, 0.35)
	tween.method("set_vertical_speed", character.get_vertical_speed(), 0.0, 0.35)

func _Update(_delta: float) -> void :
	if attack_stage == 0:
		if animatedSprite.animation != "giga_attack_start":
			play_animation("giga_attack_start")
		if animatedSprite.animation == "giga_attack_start" and animatedSprite.frame >= 8:
			next_attack_stage()
		
	elif attack_stage == 1:
		start_transform.play()
		next_attack_stage()
		
	elif attack_stage == 2:
		change_frames(boss_sprites)
		CharacterManager.set_axl_normal_colors(animatedSprite)
		turn_and_face_player()
		setup_new_collider()
		desperation.Initialize()
		desperation._Setup()
		add_weakness()
		emit_signal("transformed")
		character.emit_signal("damage_reduction", 1.0)
		next_attack_stage()
		
	elif attack_stage == 3:
		#waiting_for_desperation_to_end
		pass
		
	elif attack_stage == 4:
		process_gravity(_delta)
		unstransform()
		if not character.is_on_floor():
			play_animation("fall")
		next_attack_stage()

	elif attack_stage == 5:
		process_gravity(_delta)
		if character.is_on_floor():
			EndAbility()

func unstransform():
	change_frames(axl_sprites)
	if main.only_axl:
		CharacterManager.set_axl_boss_colors(animatedSprite)
	elif main.only_zero:
		CharacterManager.set_axl_normal_colors(animatedSprite)
	else:
		CharacterManager.set_axl_boss_no_damage_colors(animatedSprite)
	turn_and_face_player()
	return_old_collider()
	remove_weakness()
	if character.is_on_floor():
		play_animation("recover")
	else:
		play_animation("fall")

func on_desperation_end(_discard = null):
	if executing:
		next_attack_stage()

func change_frames(new_frames: Resource) -> void :
	flash.start()
	transform_sfx.play()
	animatedSprite.change_frames(new_frames)
	animatedSprite.modulate = Color(6, 6, 6, 1)
	animatedSprite.position.y = new_position
	tween.attribute("modulate", Color.white, 0.8, animatedSprite)
	play_animation("idle")
	if flip_animation:
		animatedSprite.flip_h = not animatedSprite.flip_h

func _Interrupt():
	already_use = true
	main.useing_desperation = false
	main.use_desperation = 0
	boss_stun.reactivate()
	if animatedSprite.frames != axl_sprites:
		unstransform()
	animatedSprite.position.y = -4
	emit_signal("ended_transform")
	desperation.EndAbility()
	._Interrupt()
	if disable_after_usage:
		deactivate()

func add_weakness() -> void :
	for weakness in weaknesses:
		damage.add_weakness(weakness)

func remove_weakness() -> void :
	for weakness in weaknesses:
		damage.remove_weakness(weakness)

func setup_new_collider() -> void :
	og_collider.set_deferred("disabled", true)
	damage_og_collider.set_deferred("disabled", true)
	damage_og_collider.visible = false
	damage_transform_collider.set_deferred("disabled", false)
	damage_transform_collider.visible = true
	transform_collider.set_deferred("disabled", false)

func return_old_collider() -> void :
	og_collider.set_deferred("disabled", false)
	damage_og_collider.set_deferred("disabled", false)
	damage_og_collider.visible = true
	damage_transform_collider.set_deferred("disabled", true)
	damage_transform_collider.visible = false
	transform_collider.set_deferred("disabled", true)
