extends X8OptionButton

# 옵션 메뉴의 "자동 차지(X)" ON/OFF 토글.
# 값은 기존 X 자동차지와 같은 CharacterManager.auto_charge 를 그대로 쓰므로
# 캐릭터/아머 설정 화면의 자동 차지 아이콘과 항상 같은 상태로 유지된다.

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
	CharacterManager.auto_charge = not CharacterManager.auto_charge
	if not CharacterManager.auto_charge:
		# 꺼질 때, 눌려 있는 것으로 남아 있는 가상 입력을 풀어준다
		Input.action_release("auto_charge")
	CharacterManager._save()
	display()

func display() -> void :
	if CharacterManager.auto_charge:
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
