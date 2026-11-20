extends Spawner

export  var defeated_variable: String
export  var _debug_ignore_defeat: = true
export  var dialogue_override: Resource
export  var death_signal_emitter: NodePath
export  var respawn_after_beat_game: = false

var defeated = false

signal defeated
signal devilbear_defeated

func _ready() -> void :
	initialize()
	Event.connect("enemy_kill", self, "sigma_palace_vile_death")

func sigma_palace_vile_death(boss_name) -> void:
	if boss_name is String:
		if boss_name == "sigma_palace_vile":
			emit_devilbear_death()

func has_spawned() -> bool:
	return is_instance_valid(spawned_object)

func initialize(_d = null) -> void :
	if is_defeated():
		if _debug_ignore_defeat:
			print_debug("Respawning Vile even though he was defeated")
		else:
			active = false
			emit_death()
			emit_devilbear_death()
	else:
		connect("object_death", self, "on_defeated")

func on_object_death() -> void :
	has_spawned = false
	time_of_death = timer
	emit_signal("object_death")

func emit_devilbear_death() -> void :
	emit_signal("devilbear_defeated")

func emit_death() -> void :
	emit_signal("object_death")

func on_defeated() -> void:
	print_debug("setting defeated")
	if not "DevilBear" in spawned_object.name:
		GlobalVariables.set(defeated_variable, true)
	deactivate()
	emit_signal("defeated")

func should_spawn() -> bool:
	return not is_defeated() and not GameManager.is_on_screen(global_position) and GameManager.is_player_nearby(self)

func is_defeated() -> bool:
	if _debug_ignore_defeat:
		return false
	if respawn_after_beat_game and GameManager.has_beaten_the_game():
		return false
	defeated = GlobalVariables.get(defeated_variable)
	return defeated

func _on_VileDoor_finish() -> void :
	if defeated and not _debug_ignore_defeat:
		GameManager.player.start_listening_to_inputs()
		if death_signal_emitter:
			get_node(death_signal_emitter).emit_signal("object_death")

func setup_custom_variables() -> void :
	.setup_custom_variables()
	if dialogue_override:
		spawned_object.get_node("Intro").dialogue = dialogue_override
