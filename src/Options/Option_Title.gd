extends X8OptionButton

func setup() -> void :
	set_special_dialog(get_special_title())
	display()

func increase_value() -> void :
	set_special_dialog( not get_special_title())
	display()

func decrease_value() -> void :
	set_special_dialog( not get_special_title())
	display()

func set_special_dialog(value: bool) -> void :
	Configurations.set("TitleType", value)
	display()

func get_special_title():
	if Configurations.exists("TitleType"):
		return Configurations.get("TitleType")
	return false

func display():
	if get_special_title():
		display_value("메가맨")
	else:
		display_value("록맨")
