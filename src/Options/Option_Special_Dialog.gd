extends X8OptionButton

func setup() -> void :
	set_special_dialog(get_special_dialog())
	display()

func increase_value() -> void :
	set_special_dialog( not get_special_dialog())
	display()

func decrease_value() -> void :
	set_special_dialog( not get_special_dialog())
	display()

func set_special_dialog(value: bool) -> void :
	Configurations.set("SpecialDialog", value)
	display()

func get_special_dialog():
	if Configurations.exists("SpecialDialog"):
		return Configurations.get("SpecialDialog")
	return false

func display():
	if get_special_dialog():
		display_value("ON_VALUE")
	else:
		display_value("OFF_VALUE")
