extends Node2D

onready var floppa_armor_limit: = $"../../Limits/Floppa_Axl_Limit"
onready var floppa_blocking_wall: CollisionShape2D = $extracollisionShape2D

func _ready() -> void :
	on_block_event()
	unblock_wall()
	Event.connect("collected", self, "unblock_wall")
	Event.connect("alarm", self, "block_event")

func block_event() -> void :
	on_block_event()
	Event.disconnect("collected", self, "unblock_wall")

func unblock_wall(_n = null) -> void :
	Tools.timer(1.0,"unlock_wall",self)
	
func unlock_wall() -> void :
	if "axl_first_time" in GameManager.collectibles and "axl_second_time" in GameManager.collectibles:
		unlock_event()
	if "black_zero_armor" in GameManager.collectibles and "ultima_head" in GameManager.collectibles and "white_axl_armor" in GameManager.collectibles:
		unlock_event()

func on_block_event() -> void :
	floppa_armor_limit.disabled = true
	floppa_blocking_wall.set_deferred("disabled", false)

func unlock_event() -> void :
	floppa_armor_limit.disabled = false
	floppa_blocking_wall.set_deferred("disabled", true)
