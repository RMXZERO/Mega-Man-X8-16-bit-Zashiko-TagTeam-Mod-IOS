extends Node

const subtle_motion: Array = [Vector2(1, 1), Vector2( - 1, - 1), Vector2(1, - 1), Vector2( - 1, 1), Vector2(0, 0)]

export  var active: bool = false
export  var frequency: float = 0.03
export  var duration: float = 0.5
export  var extra_y_position: float = 0
export  var extra_scale: float = 1
export  var extra_z_index: float = 1
export  var ignored_colors: Array = [
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0)
]

export var initial_color := Color(1,1,1,0)
export var final_color := Color(1,1,1,0)

export  var motion_amount: float = 0.0
export var zero_material_aura: bool = false
export var omega_aura: bool = false
export var custom_omega_aura: bool = false
export  var axl: bool = false
onready var character = get_parent().get_parent()
onready var original: AnimatedSprite = character.get_node("animatedSprite")

var upgraded: bool = false
var current_motion: = 0
var _rotator_script: Script = preload("res://System/misc/rotatordelete.gd")
var can_emit: bool = false

func _ready() -> void :
	call_deferred("set_shader_colors")
	if active:
		afterimage_emit()

func set_shader_colors():
	var material = original.get_material()
	if material is ShaderMaterial:
		if zero_material_aura:
			if axl:
				initial_color = material.get_shader_param("R_AxlAfterimagesColor1")
				final_color = Color("#00000000")
			else:
				initial_color = material.get_shader_param("R_AfterimagesColor")
				final_color = Color("#00000000")
		if omega_aura:
			frequency = 0.01
			duration = 0.01
			extra_y_position = -4
			extra_scale = 1.5
			extra_z_index = 0
			if not custom_omega_aura:
				initial_color = Color("#FFFFFFFF")
				final_color = Color("#FFFFFFFF")
			else:
				if axl:
					initial_color = material.get_shader_param("R_AxlYellowColor1")
					final_color = material.get_shader_param("R_AxlYellowColor1")

func _process(_delta):
	if active:
		if not can_emit:
			can_emit = true
			afterimage_emit()

func activate():
	if active:
		afterimage_emit()

func deactivate():
	can_emit = false
	active = false

func set_afterimage_shader(_afterimage) -> void :
	var material = ShaderMaterial.new()
	material.shader = load("res://Zero_mod/Player/DashShader.shader")
	material.set_shader_param("display_color", initial_color)
	material.set_shader_param("ignored_color_1", ignored_colors[0])
	material.set_shader_param("ignored_color_2", ignored_colors[1])
	material.set_shader_param("ignored_color_3", ignored_colors[2])
	material.set_shader_param("ignored_color_4", ignored_colors[3])
	material.set_shader_param("ignored_color_5", ignored_colors[4])
	material.set_shader_param("ignored_color_6", ignored_colors[5])
	material.set_shader_param("ignored_color_7", ignored_colors[6])
	material.set_shader_param("ignored_color_8", ignored_colors[7])
	_afterimage.material = material

func afterimage_emit() -> void :
	if active:
		var afterimage: = AnimatedSprite.new()
		add_child(afterimage)
		equate_settings(afterimage)
		set_afterimage_shader(afterimage)
		fade_and_delete(afterimage)
		var rotator = Node.new()
		rotator.set_name("rotator")
		rotator.set_script(_rotator_script)
		afterimage.add_child(rotator)
		Tools.timer(frequency, "afterimage_emit", self)
			

func fade_and_delete(afterimage: AnimatedSprite) -> void :
	afterimage.modulate = initial_color
	var tween: = afterimage.create_tween().set_parallel(true)
	tween.tween_property(afterimage, "modulate", final_color, duration)
	tween.tween_property(afterimage, "position", afterimage.position + get_motion(), duration)
	tween.set_parallel(false)
	#Tools.timer(duration, "queue_free", afterimage)
	tween.tween_callback(afterimage, "queue_free")

func equate_settings(afterimage: AnimatedSprite) -> void :
	afterimage.scale = original.scale * rand_range( 1, extra_scale)
	afterimage.frames = original.frames
	afterimage.animation = original.animation
	afterimage.frame = original.frame
	afterimage.playing = false
	afterimage.centered = original.centered
	afterimage.offset = original.offset
	afterimage.flip_h = original.flip_h
	afterimage.flip_v = original.flip_v
	afterimage.z_index = 1
	afterimage.global_position = original.global_position + Vector2(0, extra_y_position)
	afterimage.rotation_degrees = original.rotation_degrees
	afterimage.z_index = original.z_index - extra_z_index
	afterimage.visible = original.visible

func get_motion() -> Vector2:
	current_motion += 1
	if current_motion > subtle_motion.size() - 1:
		current_motion = 0
	return subtle_motion[current_motion] * motion_amount
