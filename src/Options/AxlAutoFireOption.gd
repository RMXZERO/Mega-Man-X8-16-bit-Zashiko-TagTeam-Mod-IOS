extends X8OptionButton

# 옵션 메뉴의 "AXL AUTO FIRE" ON/OFF 토글.
# 값은 CharacterManager.axl_auto_attack 에 저장된다.

func setup() -> void :
	display()

func _on_focus_entered() -> void :
	._on_focus_entered()
	display()

func increase_value() -> void :
	toggle()

func decrease_value() -> void :
	toggle()

func toggle() -> void :
	CharacterManager.axl_auto_attack = not CharacterManager.axl_auto_attack
	if not CharacterManager.axl_auto_attack:
		Input.action_release("fire")
	CharacterManager._save()
	display()

func display() -> void :
	if CharacterManager.axl_auto_attack:
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
