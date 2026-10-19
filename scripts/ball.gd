extends Window

#@onready var ballWindow: Window = $
@onready var ball_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ball_area: Area2D = $Area2D

var ball_drag_offset = Vector2()

enum BallStates { DRAG, IDLE }
var ball_state = BallStates.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.activateBall.connect(_activate_ball)
	Global.removeBall.connect(_remove_ball)
	#ball_area.input_event.connect(_on_ball_input)
	

	

func _remove_ball() -> void:
	hide()
	always_on_top = false

func _activate_ball() -> void:
	show()
	always_on_top = true
	transparent = true

	position = Vector2i(DisplayServer.mouse_get_position().x - 300, DisplayServer.mouse_get_position().y - 500)
	ball_state = BallStates.IDLE

#func _on_ball_input(_viewport, event, _shape_idx):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#ball_state = BallStates.DRAG
			#var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			#var win_pos = Vector2(DisplayServer.window_get_position())
			##var win_pos = ballWindow.position
			#print(win_pos)
			#ball_drag_offset = mouse_pos - win_pos
			#print("Drag")
		#else:
			#ball_state = BallStates.IDLE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Global.ballActive:
		if event.pressed:
			ball_state = BallStates.DRAG
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			#var win_pos = Vector2(DisplayServer.window_get_position())
			var win_pos = Vector2(position)
			#print(win_pos)
			ball_drag_offset = mouse_pos - win_pos
			#print("Drag")
		else:
			ball_state = BallStates.IDLE



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Global.ballActive:
		match ball_state:
				BallStates.IDLE:
					ball_sprite.play("idle")
					
				BallStates.DRAG:
					#print("drag")
					ball_sprite.play("drag")
					
					var mouse_pos = Vector2(DisplayServer.mouse_get_position())
					var new_win_pos = mouse_pos - ball_drag_offset
					position = Vector2i(new_win_pos)
					#DisplayServer.window_set_position(Vector2i(new_win_pos))

#
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if area.is_in_group("kitty"):
		#print("kitty has caught the ball")
