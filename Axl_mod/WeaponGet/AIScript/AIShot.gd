extends PrimaryShotAxl

func get_action_just_pressed(_element) -> bool:
	if just_pressed:
		just_pressed = false
		return true
	return false
func get_action_pressed(_element) -> bool:
	return pressed
func get_action_just_released(_element) -> bool:
	return just_released

func set_current_weapon(weapon):
	current_weapon = weapon
	update_character_sprites()
	Log("Changed Weapon to " + current_weapon.name)
	Event.emit_signal("changed_weapon", current_weapon)
	next_shot_ready = false
	

var just_pressed: = false
var just_released: = false
var pressed: = false

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("fire_emulated"):
		just_pressed = true
		pressed = true
		just_released = false
	elif event.is_action_released("fire_emulated"):
		just_released = true
		pressed = false
		just_pressed = false

func change_gattling_sprites():
	if not character.pallette:
		current_weapon._gattling_sprites += 1
		if current_weapon._gattling_sprites > 4:
			current_weapon._gattling_sprites = 1
		if current_weapon._gattling_sprites == 1:
			animatedSprite.frames = current_weapon._gattling_1
		elif current_weapon._gattling_sprites == 2:
			animatedSprite.frames = current_weapon._gattling_2
		elif current_weapon._gattling_sprites == 3:
			animatedSprite.frames = current_weapon._gattling_3
		elif current_weapon._gattling_sprites == 4:
			animatedSprite.frames = current_weapon._gattling_4
	elif character.pallette:
		current_weapon._gattling_sprites += 1
		if current_weapon._gattling_sprites > 4:
			current_weapon._gattling_sprites = 1
		if current_weapon._gattling_sprites == 1:
			animatedSprite.frames = current_weapon._pallettegattling_1
		elif current_weapon._gattling_sprites == 2:
			animatedSprite.frames = current_weapon._pallettegattling_2
		elif current_weapon._gattling_sprites == 3:
			animatedSprite.frames = current_weapon._pallettegattling_3
		elif current_weapon._gattling_sprites == 4:
			animatedSprite.frames = current_weapon._pallettegattling_4
