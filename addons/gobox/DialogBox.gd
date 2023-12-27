@tool
extends CenterContainer
class_name DialogBox

@export var _dialog_tween_duration := 1.0
@export var _fast_foward_velocity := 100 #characters per second
@export var _velocity := 15 #characters per second
@export var _current_name = "ActorName"

var input_disabled: bool = false
var history : String = ""

signal dialog_complete

var _ActorName
var _DialogRigScene : PackedScene = preload("res://addons/GoBox/scenes/DialogRig.tscn")
var _added_rig = false
var _DialogText
var _PointerAnimation
var _Pointer
var _DialogRig
var _TextSoundPlayer
var _DialogConfig
var _length_limit_px = 0
var _characters_visible := 0.0
var _line_queue = []
var _last_char_count = 0
var _tween

func _enter_tree():
	if find_child("DialogRig"):
		_added_rig = true
	
	if Engine.is_editor_hint() && !_added_rig:
		var temp = _DialogRigScene.instantiate()
		add_child(temp)
		temp.owner = get_tree().edited_scene_root
		_added_rig = true
	
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	anchors_preset = Control.PRESET_CENTER_BOTTOM

func _ready():
	if Engine.is_editor_hint():
		return
		
	_ActorName = $DialogRig/ActorName
	set_actor_name(_current_name)
	_DialogText = $DialogRig/MarginContainer/DialogMargin/DialogText
	_PointerAnimation = $DialogRig/MarginContainer/DialogMargin/Pointer/PointerAnimation
	_Pointer = $DialogRig/MarginContainer/DialogMargin/Pointer
	_DialogRig = $DialogRig
	_TextSoundPlayer = $DialogRig/TextSoundPlayer
	_length_limit_px = ($DialogRig/MarginContainer.size.x - 
	$DialogRig/MarginContainer/DialogMargin.size.x - _DialogText.size.x)
	
	_tween = get_tree().create_tween()
	_tween.tween_property(_DialogRig, "position:y", get_viewport_rect().size.y + 100, 
		0).set_trans(Tween.TRANS_LINEAR)

func _process(_delta):
	if Engine.is_editor_hint():
		return
	if _tween.is_running() or input_disabled:
		return
	
	var delta_visible = (_fast_foward_velocity * _delta if
		Input.is_action_pressed("ui_accept") else _velocity * _delta)
		
	_characters_visible += delta_visible
	_characters_visible = clampf(_characters_visible, 0.0, _DialogText.get_total_character_count())
	_DialogText.set("visible_characters", _characters_visible)
	
	if(int(_characters_visible) > _last_char_count and len(_DialogText.text) > 0):
		_TextSoundPlayer.play()
	
	if (_characters_visible >= _DialogText.get_total_character_count() and _DialogText.get_total_character_count() > 0):
		_PointerAnimation.play("PointerAnimation")
		_Pointer.visible = true
		if (Input.is_action_just_pressed("ui_accept")):
			_next_in_queue()
	else:
		_PointerAnimation.stop()
		_Pointer.visible = false
	
	_last_char_count = int(_characters_visible)


#Returns current history as a string
func get_history() -> String:
	return history


#Clears current history
func clear_history():
	history = ""


#Set the name of the current actor
func set_actor_name(name: String):
	_current_name = name
	_ActorName.text = _current_name


#Box will accept input based on whether it is true or false
func set_input_disabled(disabled: bool):
	input_disabled = disabled


#Queues any number of lines to go into an animation cycle of the box. 
#If the text does not fit, it will automatically be broken up for the current cycle.
func queue_lines(text):
	if _ActorName.text != "":
		history += _ActorName.text + ": "
	history += text + "\n"
	
	_DialogRig.position.y = get_viewport_rect().size.y
	await _box_up()
	_line_queue.clear()
	_line_queue = _break_into_lines(text) 
	_next_in_queue()


func _box_down():
	_DialogText.text = ""
	_tween = get_tree().create_tween()
	_tween.tween_property(_DialogRig, "position:y", get_viewport_rect().size.y + 300, 
		_dialog_tween_duration).set_trans(Tween.TRANS_LINEAR)
	await _tween.finished
	emit_signal("dialog_complete")


func _box_up():
	_tween = get_tree().create_tween()
	_tween.tween_property(_DialogRig, "position:y", 0, 
		_dialog_tween_duration/2).set_trans(Tween.TRANS_LINEAR)
	await _tween.finished


func _next_in_queue():
	_characters_visible = 0
	_DialogText.set("visible_characters", _characters_visible)
	
	if len(_line_queue) <= 0:
		_box_down()
		return
		
	_DialogText.text = ""
	
	var content_height = _DialogText.get_theme_font("normal_font").get_string_size(_line_queue[0], 
		HORIZONTAL_ALIGNMENT_LEFT, -1, _DialogText.get_theme_font_size("normal_font_size")).y
		
	var box_height = ($DialogRig/MarginContainer.size.y - 
	$DialogRig/MarginContainer/DialogMargin.size.y - _DialogText.size.y)
	
	var line_count = int(box_height/content_height)
	line_count = abs(line_count)
	
	if (len(_line_queue) < line_count):
		while (len(_line_queue) > 0):
			_DialogText.text += _line_queue.pop_front()
			_DialogText.text += "\n"
	
	for _i in range(line_count):
		if len(_line_queue) <= 0:
			break
		_DialogText.text += _line_queue.pop_front()
		_DialogText.text += "\n"
	pass


func _break_into_lines(text):
	var lines = []
	
	var current_line := ""
	var index := 0
	
	while len(text) > 0:
		current_line = text.left(index)
		
		var current_length_px = _DialogText.get_theme_font("normal_font").get_string_size(current_line, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, _DialogText.get_theme_font_size("normal_font_size")).x
		
		if current_length_px > _length_limit_px:
			var _to_strip 
			
			while (text[index - 1] != ' '):
				index -= 1
				
			current_line = text.left(index)
			
			_to_strip = -(len(current_line) - 1)
			text = text.right(_to_strip)
			lines.append(current_line.left(-1))
			index = 0
			current_line = ""
		elif index == len(text):
			lines.append(current_line)
			text = ""
		
		index += 1
	return lines
