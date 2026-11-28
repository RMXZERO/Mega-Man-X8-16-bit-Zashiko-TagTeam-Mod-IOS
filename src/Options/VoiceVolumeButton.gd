extends "res://src/Options/VolumeButton.gd"
# 보이스 음량 옵션: 음량 / 효과음 옵션과 같은 방식 (양옆 < > 버튼, 좌우 키로 조절)
# 보이스는 "Voice" 오디오 버스로 재생되고, 이 옵션이 그 버스의 음량을 조절한다.

const NAME_KEY := "VOICE_OPTION"
# 번역 파일(.translation)을 다시 만들지 않아도 되도록 실행 중에 직접 등록한다
# (비트맵 폰트에 글자가 없을 수 있는 일본어는 영어로 표시)
const NAMES := {
	"en": "Voice Volume",
	"ko": "보이스 음량",
	"es": "Volumen de las Voces",
	"pr": "Volume das Vozes",
	"br": "Volume das Vozes",
	"ja_JP": "Voice Volume"
}

func _ready() -> void :
	register_translations()
	._ready()
	refresh_option_name()

func register_translations() -> void :
	if Engine.has_meta("voice_option_translations"):
		return
	Engine.set_meta("voice_option_translations", true)
	for locale in NAMES:
		var t = Translation.new()
		t.locale = locale
		t.add_message(NAME_KEY, NAMES[locale])
		t.add_message("Voice Volume", NAMES[locale])
		TranslationServer.add_translation(t)

# 씬이 로드될 때는 번역이 아직 등록되기 전이라 이름 라벨을 한 번 다시 번역시킨다
func refresh_option_name() -> void :
	var label = get_parent().get_node_or_null("OptionName")
	if label:
		label.text = ""
		label.text = NAME_KEY
