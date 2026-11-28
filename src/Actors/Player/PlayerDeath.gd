extends Movement
class_name Death

onready var explosions = $"X Death Particles"
onready var background = $background_light
onready var collision: = get_parent().get_node("CollisionShape2D")
onready var collision_shape_2d: CollisionShape2D = $"../Enemy Collision Detector/CollisionShape2D"
onready var dash_shape: CollisionShape2D = $"../Enemy Collision Detector/DashShape"

var alpha: float = 0.0
var emitted_sound: bool = false
var game_paused: bool = false
var death_location: Vector2

# 캐릭터별 죽을 때 보이스 (캐릭터 루트 노드 이름 기준: X / Zero / Axl)
const DEATH_VOICES := {
	"X": "res://src/Actors/Player/DeathVoice/x_die.wav",
	"Zero": "res://src/Actors/Player/DeathVoice/zero_die.wav",
	"Axl": "res://src/Actors/Player/DeathVoice/axl_die.wav"
}
# 보이스가 폭발음(죽는 효과음)을 가리지 않도록 보이스는 줄이고, 보이스가 있는 캐릭터의 폭발음은 키운다
const DEATH_VOICE_VOLUME_DB := -10.0
const DEATH_SFX_BOOST_DB := 8.0
var _death_voice_stream = null


func play_sound_on_initialize():
	pass

func _ready() -> void :
	character.listen("zero_health", self, "_on_zero_health")
	var voice_path = DEATH_VOICES.get(character.name, "")
	if voice_path != "":
		_death_voice_stream = load(voice_path)
		var sfx_player = get_node_or_null("audioStreamPlayer")
		if sfx_player != null:
			sfx_player.volume_db += DEATH_SFX_BOOST_DB

func _Setup() -> void :
	Event.emit_signal("player_death")
	play_death_voice()
	death_location = global_position
	background.set_scale(Vector2(100, 40))
	GameManager.pause("PlayerDeath")
	emitted_sound = false
	game_paused = true
	alpha = 0
	character.current_health = 0
	character.deactivate()
	character.remove_invulnerability_shader()
	character.stop_all_movement()
	call_deferred("disable_collision")
	background.material.set_shader_param("Alpha", alpha)
	Log("finished Setup")

func play_death_voice() -> void :
	if _death_voice_stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.pause_mode = Node.PAUSE_MODE_PROCESS   # 죽는 순간의 정지 중에도 재생
	player.stream = _death_voice_stream
	player.bus = "Voice"
	player.volume_db = DEATH_VOICE_VOLUME_DB
	add_child(player)
	player.connect("finished", player, "queue_free")
	player.play()

func disable_collision() -> void :
	collision.disabled = true
	collision_shape_2d.disabled = true
	dash_shape.disabled = true

func _Update(delta):
	character.disable_floor_snap()
	character.global_position = death_location
	if timer > 1.5:
		alpha += delta * 2
		background.material.set_shader_param("Alpha", alpha)
	if timer > 5:
		background.set_scale(Vector2(400, 160))
		GameManager.on_death()

func _physics_process(delta: float) -> void :
	if executing and game_paused:
		timer += delta
		if timer > 0.5 and emitted_sound == false:
			GameManager.unpause("PlayerDeath")
			character.animatedSprite.visible = false
			play_sound(sound, false)
			emitted_sound = true
			game_paused = false
			background.visible = true
			var position_in_camera = GameManager.camera.get_nearest_position_inside_camera(global_position)
			if position_in_camera != global_position:
				death_location = position_in_camera
			else:
				explosions.emit()

func _StartCondition() -> bool:
	return false

func _EndCondition() -> bool:
	return false

func _on_zero_health() -> void :
	if active and not executing:
		if CharacterManager.both_alive:
			CharacterManager.both_alive = false
			CharacterManager.alive_team.erase(character.name)
			character.emit_signal("activate_revive")
			Event.emit_signal("character_switch")
			return
		else:
			CharacterManager.alive_team.erase(character.name)
		ExecuteOnce()

func is_high_priority() -> bool:
	return true
