extends Panda

var only_x: bool = false
var only_zero: bool = false
var only_axl: bool = false
var use_desperation: float = 0
var useing_desperation: bool = false
var desperation_timer: float = 3

onready var boss_ai = get_node("BossAI")
onready var death = get_node("BossDeath")

onready var mantis = get_node("Mantis")
onready var panda = get_node("Panda")
onready var manowar = get_node("Manowar")
onready var trilobyte = get_node("Trilobyte")

onready var yeti = get_node("Yeti")
onready var sunflower = get_node("Sunflower")
onready var rooster = get_node("Rooster")
onready var antonion = get_node("Antonion")

onready var copysigma = get_node("CopySigma")
onready var vile = get_node("Vile")
onready var red = get_node("Red")
onready var serenade = get_node("Serenade")

onready var bullet = get_node("Bullet")
onready var diagonaldash = get_node("DiagonalDash")
onready var agilesaber = get_node("CopyDash")
onready var dvdattack = get_node("DvDAttack")

onready var afterimages2 = get_node("animatedSprite").get_node("afterImages2")
onready var afterimages3 = get_node("animatedSprite").get_node("afterImages3")
onready var hoverSprite: AnimatedSprite = animatedSprite.get_node("HoverEffect")
onready var y_offset_deafult: int = - 0
onready var x_offset: int = 0
onready var y_offset: int = y_offset_deafult
onready var extra_x_offset: int = 0
onready var extra_y_offset: int = 0
var land_position: Vector2

func _ready() -> void:
	Event.listen("enemy_kill", self, "false_desperation")
	only_x = false
	only_zero = false
	only_axl = false
	use_desperation = 0
	desperation_timer = CharacterManager.game_mode
	CharacterManager.set_axl_boss_no_damage_colors(animatedSprite)
	if CharacterManager.player_character == "X":
		only_x = true
	elif CharacterManager.player_character == "Axl":
		only_axl = true
		desperation_timer = CharacterManager.game_mode + 2
		CharacterManager.set_axl_boss_colors(animatedSprite)
	elif CharacterManager.player_character == "Zero":
		only_zero = true
		CharacterManager.set_axl_normal_colors(animatedSprite)
	else:
		only_x = true
	if Input.is_action_pressed("select_special"):
		CharacterManager.nightshade_zero_armor = true

func afterimages() -> void:
	afterimages2.active = true
	afterimages2.activate()
	if only_x:
		death.force_reploid_death = true
		death.use_reploid_death = true
	if only_zero and not "axl_saber_combo" in GameManager.collectibles:
		agilesaber.deactivate()
	if only_axl:
		agilesaber.deactivate()
	if not CharacterManager.nightshade_zero_armor:
		false_transform()
		false_extra_transform()
	if CharacterManager.nightshade_zero_armor:
		afterimages3.active = true
		afterimages3.activate()
		if only_axl:
			false_extra_transform()

func false_transform() -> void:
	mantis.deactivate()
	panda.deactivate()
	manowar.deactivate()
	trilobyte.deactivate()
	
	yeti.deactivate()
	sunflower.deactivate()
	rooster.deactivate()
	antonion.deactivate()

func false_extra_transform() -> void:
	copysigma.deactivate()
	vile.deactivate()
	red.deactivate()
	serenade.deactivate()

func end_other_ability() -> void:
	bullet.EndAbility()
	diagonaldash.EndAbility()
	agilesaber.EndAbility()
	dvdattack.EndAbility()

func _process(_delta: float) -> void:
	._process(_delta)
	get_offset()
	if use_desperation >= 9 - desperation_timer and \
	animatedSprite.animation != "rolling" and \
	animatedSprite.animation != "damage" and \
	animatedSprite.animation != "damage_resist" and \
	animatedSprite.animation != "death" and \
	animatedSprite.animation != "victory" and \
	animatedSprite.animation != "final" and \
	animatedSprite.animation != "beam_out" and \
	not is_executing("DeathWithDialog") and \
	not is_executing("Desperation") and \
	not useing_desperation and \
	is_on_floor():
		end_other_ability()
		interrupt_all_moves()
		use_desperation_now()
		useing_desperation = true

func use_desperation_now() -> void:
	var chance = randf() * 100
	chance = randf() * 100
	
	if all_use():
		reset_desperation()
	
	if is_between(chance, 0, 20):
		yeti_mantis()
	elif is_between(chance, 20, 40):
		sunflower_panda()
	elif is_between(chance, 40, 60):
		rooster_manowar()
	elif is_between(chance, 60, 80):
		antonion_trilobyte()
	elif is_between(chance, 80, 95):
		special_desperation()
	elif is_between(chance, 95, 100):
		special_desperation_2()

func reset_desperation() -> void:
	vile.already_use = false
	red.already_use = false
	trilobyte.already_use = false
	manowar.already_use = false
	panda.already_use = false
	mantis.already_use = false

func all_use() -> bool:
	if only_zero:
		return vile.already_use and red.already_use and trilobyte.already_use and manowar.already_use and panda.already_use and mantis.already_use
	else:
		return trilobyte.already_use and manowar.already_use and panda.already_use and mantis.already_use

func is_between(c, _min, _max) -> bool:
	return c > _min and c <= _max

func yeti_mantis() -> void:
	if yeti.already_use:
		if mantis.already_use:
			sunflower_panda()
		else:
			mantis.Initialize()
			mantis._Setup()
	else:
		yeti.Initialize()
		yeti._Setup()
		Event.emit_signal("enemy_kill", "boss_yeti")

func sunflower_panda() -> void:
	if sunflower.already_use:
		if panda.already_use:
			rooster_manowar()
		else:
			panda.Initialize()
			panda._Setup()
	else:
		sunflower.Initialize()
		sunflower._Setup()
		Event.emit_signal("enemy_kill", "boss_sunflower")

func rooster_manowar() -> void:
	if rooster.already_use:
		if manowar.already_use:
			antonion_trilobyte()
		else:
			manowar.Initialize()
			manowar._Setup()
	else:
		rooster.Initialize()
		rooster._Setup()
		Event.emit_signal("enemy_kill", "boss_rooster")

func antonion_trilobyte() -> void:
	if antonion.already_use:
		if trilobyte.already_use:
			special_desperation()
		else:
			trilobyte.Initialize()
			trilobyte._Setup()
	else:
		antonion.Initialize()
		antonion._Setup()
		Event.emit_signal("enemy_kill", "boss_antonion")

func special_desperation() -> void:
	if only_axl:
		yeti_mantis()
		return
	if red.already_use:
		if vile.already_use:
			if copysigma.already_use:
				yeti_mantis()
			else:
				copysigma.Initialize()
				copysigma._Setup()
				Event.emit_signal("enemy_kill", "boss_copysigma")
		else:
			vile.Initialize()
			vile._Setup()
	else:
		red.Initialize()
		red._Setup()

func special_desperation_2() -> void:
	if only_axl:
		yeti_mantis()
		return
	if serenade.already_use:
		special_desperation()
	else:
		serenade.Initialize()
		serenade._Setup()
		Event.emit_signal("enemy_kill", "boss_serenade")

func false_desperation(ability_name) -> void:
	if ability_name is String:
		if ability_name == "boss_yeti":
			yeti.deactivate()
			yeti.already_use = true
		if ability_name == "boss_sunflower":
			sunflower.deactivate()
			sunflower.already_use = true
		if ability_name == "boss_rooster":
			rooster.deactivate()
			rooster.already_use = true
		if ability_name == "boss_antonion":
			antonion.deactivate()
			antonion.already_use = true
		if ability_name == "boss_copysigma":
			copysigma.deactivate()
			copysigma.already_use = true
		if ability_name == "boss_serenade":
			serenade.deactivate()
			serenade.already_use = true

func get_offset() -> void:
	var current_animation = animatedSprite.animation
	var is_facing_left = animatedSprite.scale.x < 0
	extra_x_offset = 0
	extra_y_offset = 0
	match current_animation:
		"beam":
			x_offset = 0
			y_offset = - 9
		"beam_in":
			x_offset = 0
			y_offset = - 9
		"beam_equip":
			x_offset = 0
			y_offset = - 9
		"beam_equip_2":
			x_offset = 0
			y_offset = - 9
		"beam_equip_3":
			x_offset = 0
			y_offset = - 9
		"throw":
			x_offset = 0
			y_offset = - 9
		"throw_end":
			x_offset = 0
			y_offset = - 9
		"walk":
			x_offset = 0
			y_offset = - 2
		"slide":
			x_offset = 3
			y_offset = - 1
		"shot_slide":
			x_offset = 3
			y_offset = - 1
		"hover":
			x_offset = 0
			var hover_offset = 0
			if hoverSprite.frame == 0:
				hover_offset = 0
			if hoverSprite.frame == 1 or hoverSprite.frame == 3:
				hover_offset = - 1
			if hoverSprite.frame == 2:
				hover_offset = - 2
				
			y_offset = y_offset_deafult + hover_offset
			hoverSprite.offset.y = y_offset_deafult + hover_offset

		"shot_air":
			x_offset = 0
			var hover_offset = 0
			if hoverSprite.frame == 0:
				hover_offset = 0
			if hoverSprite.frame == 1 or hoverSprite.frame == 3:
				hover_offset = - 1
			if hoverSprite.frame == 2:
				hover_offset = - 2
			
			y_offset = y_offset_deafult + hover_offset
			hoverSprite.offset.y = y_offset_deafult + hover_offset

		"shot":
			x_offset = 0
			y_offset = y_offset_deafult
		_:
			x_offset = 0
			y_offset = y_offset_deafult
	animatedSprite.offset.x = x_offset + extra_x_offset
	animatedSprite.offset.y = y_offset + extra_y_offset
