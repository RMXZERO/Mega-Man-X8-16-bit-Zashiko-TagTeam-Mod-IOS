extends Node2D

onready var extra_armor_limit: = $"../../Limits/Extra_Zero_Limit"
onready var extra_blocking_wall: CollisionShape2D = $extracollisionShape2D

func _ready() -> void :
	on_block_event()
	unblock_wall()
	Event.connect("collected", self, "unblock_wall")
	Event.connect("pitch_black_energized", self, "unlock_event")
	Event.connect("alarm", self, "block_event")

func block_event() -> void :
	on_block_event()
	Event.disconnect("collected", self, "unblock_wall")
	Event.disconnect("pitch_black_energized", self, "unlock_event")

func unblock_wall(_n = null) -> void :
	Tools.timer(1.0,"unlock_wall",self)
	
func unlock_wall() -> void :
	if "axl_first_time" in GameManager.collectibles and "axl_second_time" in GameManager.collectibles:
		unlock_event()

func on_block_event() -> void :
	extra_armor_limit.disabled = true
	extra_blocking_wall.set_deferred("disabled", false)

func unlock_event() -> void :
	extra_armor_limit.disabled = false
	extra_blocking_wall.set_deferred("disabled", true)
