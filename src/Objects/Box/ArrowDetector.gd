extends Area2D

onready var sprite: AnimatedSprite = $"../animatedSprite"
onready var hit: AudioStreamPlayer2D = $hit

var active: bool = true
var hit_times: int = 0

signal destroyed

func blink() -> void :
	sprite.material.set_shader_param("Flash", 1)
	Tools.timer(0.033, "unblink", self)

func unblink() -> void :
	sprite.material.set_shader_param("Flash", 0)

func _on_ArrowDetector_body_entered(body: Node) -> void :
	if active:
		if "DarkArrowCharged" in body.name:
			on_darkarrow_hit(3)
			body._OnHit(0)
		elif "DarkArrow" in body.name:
			on_darkarrow_hit(1)
			body._OnHit(100)
		elif "BlackArrow" in body.name:
			on_darkarrow_hit(1)
			body._OnHit(100)
		elif "NovaStrike" in body.name:
			on_darkarrow_hit(100)
		elif "Shoryuuken" in body.name:
			on_darkarrow_hit(100)
		elif "SpiralMagnum" in body.name:
			on_spiralmagnum_hit(1)
			body._OnHit(100)
		elif "Saber" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(1)
		elif "SaberCharged" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(1)
		elif "Rekkyoudan" in body.name:
			if body.break_guards:
				on_saber_hit(40)
			else:
				on_saber_hit(1)
		elif "Rasetsusen" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(1)
		elif "Youdantotsu" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(1)
		elif "Enkoujin" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(5)
		elif "Raikousen" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(5)
		elif "Hyouryuushou" in body.name:
			if body.upgraded:
				if body.break_guards:
					on_saber_hit(40)
				else:
					on_saber_hit(5)
		elif "Juuhazan" in body.name:
			if "Juuhazan_Charged_C" in body.name:
				on_saber_hit(40)
			elif "Juuhazan_Charged_B" in body.name:
				on_saber_hit(40)
			elif "Juuhazan_Charged" in body.name:
				on_saber_hit(5)
			else:
				if body.upgraded:
					if body.break_guards:
						on_saber_hit(40)
					else:
						on_saber_hit(5)
		elif "SqueezeBombCharged" in body.name:
			if "Charged_B" in body.name:
				on_saber_hit(5)
			else:
				on_darkarrow_hit(3)
		elif "RogueSwordWave" in body.name:
			on_darkarrow_hit(1)
		elif "RogueWave" in body.name:
			on_darkarrow_hit(3)
		elif "SwordWave" in body.name:
			on_darkarrow_hit(1)
		elif "ZBuster" in body.name:
			on_darkarrow_hit(1)
		elif "HangerArrow" in body.name:
			on_darkarrow_hit(1)
		elif "Rekohouha" in body.name:
			on_darkarrow_hit(3)
		elif "Shingetsurin" in body.name:
			on_darkarrow_hit(3)
		elif "Genmuzerowave" in body.name:
			on_darkarrow_hit(3)
		elif "GenmuzeroCharged" in body.name:
			on_saber_hit(40)
		elif "Player_Desperation" in body.name:
			on_darkarrow_hit(3)

func on_saber_hit(amount: int) -> void :
	blink()
	hit.play()
	hit_times += amount
	if hit_times >= 40:
		emit_signal("destroyed")
		active = false

func on_spiralmagnum_hit(amount: int) -> void :
	blink()
	hit.play()
	hit_times += amount
	if hit_times >= 2:
		emit_signal("destroyed")
		active = false

func on_darkarrow_hit(amount: int) -> void :
	blink()
	hit.play()
	hit_times += amount
	if hit_times >= 3:
		emit_signal("destroyed")
		active = false

func deactivate() -> void :
	active = false
