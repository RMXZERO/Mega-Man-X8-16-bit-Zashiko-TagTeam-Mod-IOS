extends NewDoor

export  var open_signal: String = "boss_door_open"
var close_dooe = get_node_or_null("Close")
var fired_signal: bool = false

func _ready() -> void:
	CharacterManager.nightshade_zero_armor = false

func _on_Open_start(_ability_name) -> void :
	Event.emit_signal(open_signal)
	._on_Open_start(_ability_name)
	fired_signal = true

func _on_Explode_start(_ability_name) -> void :
	Event.emit_signal(open_signal)
	._on_Explode_start(_ability_name)
	CharacterManager.nightshade_zero_armor = true

func _on_noahspark_area2D_body_entered(body: Node) -> void :
	if not fired_signal and body.is_in_group("Player"):
		if close_dooe:
			close_dooe._on_signal()
		fired_signal = true
		GameManager.player.cutscene_deactivate()
		if GameManager.player.ride:
			GameManager.player.ride.stop_listening_to_inputs()
