extends Node
onready var boss_spawner: Node2D = $"../Objects/BossSpawner"
var player_final_position: Vector2
onready var tween: = TweenController.new(self, false)
onready var leftmost_viable_pos: Position2D = $"../Scenery/leftmost_viable_pos"
onready var rightmost_viable_pos: Position2D = $"../Scenery/rightmost_viable_pos"

func _ready() -> void :
	player_final_position = boss_spawner.global_position
	player_final_position.x -= 100
	Event.connect("boss_death_screen_flash", self, "on_screen_flash")
	Event.connect("lumine_death", self, "on_lumine_death")
	Event.connect("boss_start",self,"on_boss_start")

var moved_player_after_sigma: = false
var executing_sigma: bool = false

func on_boss_start(boss) -> void:
	if "Sigma" in boss.name and not executing_sigma:
		executing_sigma = true
		Event.disconnect("boss_start",self,"on_boss_start")
	if "DJSigma" in boss.name:
		executing_sigma = false
		Event.disconnect("boss_start",self,"on_boss_start")

func on_lumine_death():
	Tools.timer(4, "move_player", self)
		
func on_screen_flash():
	if not moved_player_after_sigma and executing_sigma:
		moved_player_after_sigma = true
		move_player()

func move_player() -> void :
	if player_needs_to_be_moved():
		move_player_to_final_position()
	else:
		GameManager.player.set_direction(1)
		
		
func move_player_to_final_position():
	var player = GameManager.player
	player.force_movement()
	player.set_direction(get_direction())
	player.play_animation("walk")
	tween.attribute("position:x", player_final_position.x, get_travel_duration(), player)
	tween.add_callback("finished_player_movement")

func finished_player_movement():
	var player = GameManager.player
	player.play_animation("recover")
	player.set_direction(1)
	player.stop_forced_movement()
	Tools.timer_p(0.035, "set_direction", player, 1)

func get_direction() -> int:
	if GameManager.get_player_position().x > player_final_position.x:
		return - 1
	return 1

func get_travel_duration() -> float:
	return (GameManager.get_player_position().distance_to(player_final_position)) / 90.0

func player_needs_to_be_moved() -> bool:
	return GameManager.get_player_position().x > rightmost_viable_pos.global_position.x or GameManager.get_player_position().x < leftmost_viable_pos.global_position.x

