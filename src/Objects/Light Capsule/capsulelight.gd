extends Light2D

onready var tween: = TweenController.new(self, false)


func _on_Capsule_lightning() -> void :
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "PitchBlack":
		visible = true
		tween.attribute("energy", 0.0, 1.0)
