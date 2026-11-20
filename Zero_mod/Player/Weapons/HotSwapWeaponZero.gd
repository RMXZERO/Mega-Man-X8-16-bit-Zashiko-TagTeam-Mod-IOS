extends Sprite

export  var weapon: Resource
onready var _select: AnimatedSprite = $"../select"
export  var selectable: = false
export  var already_selected: = false
onready var character = get_parent().get_parent().get_parent()
onready var choice: AudioStreamPlayer2D = $"../choice"

func _ready() -> void :
	_on_hotswap_opened()
	get_parent().connect("weapon_selected", self, "on_select")
	get_parent().connect("unselected_all", self, "unselect")
	Event.listen("refresh_hud", self, "_on_hotswap_opened")
	Event.listen("collected_zero_weapon", self, "_on_hotswap_opened")
	Event.listen("select_weapon", self, "false_select_icon")
	Event.connect("pause_menu_closed", self, "unselect")

func _on_hotswap_opened() -> void :
	modulate.a = 0.5
	if weapon.collectible in GameManager.collectibles:
		if get_parent().character == GameManager.player:
			make_selectable()
		else:
			remove_icon()
	else:
		deactivate()

func remove_icon() -> void :
	selectable = false
	texture = null

func deactivate() -> void :
	pass

func make_selectable() -> void :
	selectable = true
	texture = weapon.faded_icon
	pass

func false_select_icon(_sweapon) -> void :
	if selectable:
		already_selected = false

func on_select(sweapon) -> void :
	if selectable and sweapon != self:
		texture = weapon.faded_icon
		modulate.a = 0.5
		already_selected = false

func unselect() -> void :
	if selectable:
		texture = weapon.faded_icon
		modulate.a = 0.5
		already_selected = false
	if _select.visible:
		_select.visible = false

func select() -> void :
	var _animation = get_parent().get_parent().get_parent().get_animation()
	if _animation in character.saber_animations:
		if not "victory" in _animation:
			return
	texture = weapon.icon
	modulate.a = 1
	Event.emit_signal("select_weapon", weapon)
	_select.position = position
	_select.visible = true
	_select.frame = 0
	already_selected = true
	choice.play()

