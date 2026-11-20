extends AttackAbility

export  var damage_reduction: = 0.5
var images: Array
const move_duration: = 0.5
export  var _slash: PackedScene
onready var tween: = TweenController.new(self, false)
onready var damage: Node2D = $"../Damage"
onready var damage_on_touch: Node2D = $"../DamageOnTouch"

onready var disappear: AudioStreamPlayer2D = $disappear
onready var victory: AudioStreamPlayer2D = $victory
onready var shot_sound: AudioStreamPlayer = $shot
onready var main = get_parent()
onready var boss_ai = get_parent().get_node("BossAI")

var deflects_before: int = 0
var play_sound_vfx: bool = false
var angry_music: bool = false
var l = 5

signal ready_for_stun

func _ready() -> void :
	angry_music = false

func _Setup() -> void :
	damage_reduction = CharacterManager.boss_damage_reduction
	character.emit_signal("damage_reduction", damage_reduction)
	turn_and_face_player()
	play_animation("victory")
	victory.play()
	play_sound_vfx = false
	main.use_desperation = 0
	l = 5 + CharacterManager.game_mode
	if not angry_music:
		character.get_node("Intro").angry_music()
		angry_music = true

func play_shot_sound() -> void :
	if not play_sound_vfx:
		play_sound_vfx = true
		create_slash()
		Tools.timer(0.05, "play_sound_again", self)

func play_sound_again() -> void :
	play_sound_vfx = false

func _Update(delta: float) -> void :
	process_gravity(delta)
	if animatedSprite.animation == "giga_attack_loop":
		play_shot_sound()
	
	if attack_stage == 0 and timer > 0.4:
		call_deferred("decay_speed", 1, 1.5)
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.85:
		play_animation("giga_attack_start")
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("giga_attack_loop")
		next_attack_stage()

	elif attack_stage == 3 and timer > l + 1:
		play_animation("giga_attack_end")
		emit_signal("ready_for_stun")
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		EndAbility()

func _Interrupt():
	character.emit_signal("damage_reduction", 1.0)
	._Interrupt()
	emit_signal("ready_for_stun")
	main.use_desperation = 10

func create_slash() -> void :
	var instance = _slash.instance()
	get_tree().current_scene.add_child(instance, true)
	instance.get_node("ShotHitbox").damage = 10
	instance.set_global_position(GameManager.get_player_position())
	
