extends BossAI

var next_attack_time = 0.01

func set_game_mode():
	if CharacterManager.game_mode == -1:
		desperation_multi = 0
	elif CharacterManager.game_mode >= 0:
		desperation_multi = 5
	next_attack_time = 0

func decide_time_for_next_attack():
	set_game_mode()
	timer_for_next_attack = next_attack_time
