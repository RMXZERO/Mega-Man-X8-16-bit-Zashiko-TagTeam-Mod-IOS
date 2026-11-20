extends X8OptionButton

export  var legible_name: String
export  var description: String

onready var equip: AudioStreamPlayer = $"../../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../../choice"
onready var icon: TextureRect = $"icon"
onready var name_display: Label = $"../../../../Description/name"
onready var disc_display: Label = $"../../../../Description/disc"
onready var char_name: Label = $"../../../../CharacterName"

onready var hermes_holder: = get_parent().get_parent().get_node("hermes_holder/info")
onready var icarus_holder: = get_parent().get_parent().get_node("icarus_holder/info")
onready var ultimate_holder: = get_parent().get_parent().get_node("ultimate_holder/info")
onready var icon_gold: = get_node("icon_bg_gold")
onready var animated_sprite: AnimatedSprite = get_node("animatedSprite")
onready var infinite_icon: TextureRect = get_node("infinite_icon")

func _ready() -> void :
	._ready()
	if CharacterManager.infinite_x_activated:
		infinite_icon.show()
		icon_gold.show()
	else:
		infinite_icon.hide()
		icon_gold.hide()

func setup() -> void :
	pass

func _on_focus_entered() -> void :
	._on_focus_entered()
	display_info()

func on_press() -> void :
	if CharacterManager.infinite_x_unlocked:
		toggle_infinite_x()
		strong_flash()

func process_inputs() -> void :
	pass

func display_info() -> void :
	if CharacterManager.infinite_x_activated:
		name_display.text = tr("INFINITE_X_NAME")
		disc_display.text = tr("INFINITE_X_DISC")
	else:
		name_display.text = tr(legible_name)
		disc_display.text = tr(description)

func toggle_infinite_x() -> void :
	icon_gold.visible = not icon_gold.visible
	if icon_gold.visible:
		Tools.timer(0.075, "play", equip)
		icon_gold.show()
	else:
		Tools.timer(0.075, "play", unequip)
		icon_gold.hide()
	if ultimate_holder.icon_gold.visible and hermes_holder.icon_gold.visible and icarus_holder.icon_gold.visible:
		CharacterManager.infinite_x_activated = true
		if CharacterManager.infinite_x_activated:
			Tools.timer(0.075, "play", equip)
			char_name.text = "X (Infinite)"
			hermes_holder.infinite_icon.show()
			icarus_holder.infinite_icon.show()
			ultimate_holder.infinite_icon.show()
			hermes_holder.animated_sprite.frame = 0
			icarus_holder.animated_sprite.frame = 0
			ultimate_holder.animated_sprite.frame = 0
			display_info()
	else:
		CharacterManager.infinite_x_activated = false
		char_name.text = "X"
		hermes_holder.infinite_icon.hide()
		icarus_holder.infinite_icon.hide()
		ultimate_holder.infinite_icon.hide()
		display_info()
