extends Node2D

var speed = 300
var fall_speed = 500
var direction = Vector2(1, 0)
var screen_size = Vector2()
var window_size = Vector2(200, 200)

var idle_timer = 0.0
#var is_idling = false
#var is_walking = false
#var is_falling = true
#
#var is_dragging = false
var drag_offset = Vector2()

var usable 
var taskbar_y

var last_mouse = Vector2()
#var velocity = Vector2()
var velocity = Vector2()

enum KittyStates { IDLE, WALK, FALL, DRAG }
var current_state = KittyStates.FALL

@onready var kitty_sprite: AnimatedSprite2D = $kittyNode/AnimatedSprite2D
@onready var area: Area2D = $kittyNode/Area2D

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#is_dragging = true
			current_state = KittyStates.DRAG
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		#elif !event.pressed:
		else:
			if current_state == KittyStates.DRAG:
				trigger_fall()
				#trigger_fall()
			#is_dragging = false
			#is_falling = true
			#is_walking = false
		#else:
			#is_dragging = false

func maybe_idle():
	if randf() < 0.3:
		#is_idling = true
		current_state = KittyStates.IDLE
		idle_timer = randf_range(1.0, 3.0)
		#var r = randi() % 3
		#if r == 0:
			#kitty_sprite.play("Idle")
			#speed = 0
		kitty_sprite.play("Idle")
		speed = 0

func _ready() -> void:
	screen_size = Vector2(DisplayServer.screen_get_size())
	usable = DisplayServer.screen_get_usable_rect()
	taskbar_y = usable.end.y
	kitty_sprite.play("Walk")
	kitty_sprite.flip_h = !kitty_sprite.flip_h
	area.input_event.connect(_on_area_input)

	
	

func trigger_fall() -> void:
	current_state = KittyStates.FALL

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func simulate_key(keycode: Key):
	var press_event = InputEventKey.new()
	press_event.keycode = keycode
	press_event.pressed = true
	Input.parse_input_event(press_event)
	print("press event")
	
	#wait(0.25)
	
	var release_event = InputEventKey.new()
	release_event.keycode = keycode
	press_event.pressed = false
	Input.parse_input_event(release_event)
	print("release event")

#func nextTrack() -> void:
	#var os_name = OS.get_name()
	#
	#match os_name:
		#"Windows":
			#nextTrackWindows()
		#"macOS":
			#nextTrackMacOS()
		#"Linux":
			#nextTrackLinux()
		#_:
			#print("Unsupported OS for media controls: ", os_name)
	#simulate_key(KEY_MEDIANEXT)
	#print("pressed")

#func nextTrackWindows() -> void:
	#var script = "$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys([char]176)"
	#OS.execute("powershell", ["-NoProfile", "-WindowStyle", "Hidden", "-Command", script], [], false)
#
#func nextTrackMacOS() -> void:
	#var script = "import ApplicationServices; " + \
		#"let src = CGEventSource(stateID: .hidSystemState); " + \
		#"let down = CGEvent(keyboardEventSource: src, virtualKey: 0x34, keyDown: true); " + \
		#"let up = CGEvent(keyboardEventSource: src, virtualKey: 0x34, keyDown: false); " + \
		#"down?.post(tap: .cghidEventTap); up?.post(tap: .cghidEventTap);"
	#OS.execute("swift", ["-e", script], [], false)
#
#func nextTrackLinux() -> void:
	#OS.execute("playerctl", ["next"], [], false)

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#print("Physical Keycode: ", event.physical_keycode)
		#print("Keycode: ", event.keycode)
		#print("Key String: ", OS.get_keycode_string(event.keycode))

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	
	match current_state:
		KittyStates.DRAG:
			print("State: Drag")
			kitty_sprite.play("Idle")
			
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			
			#var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			#var win_pos = Vector2(DisplayServer.window_get_position())
			#drag_offset = mouse_pos - win_pos
			
			var new_win_pos = mouse_pos - drag_offset
			print("mouse pos: ", mouse_pos)
			print("drag offset: ", drag_offset)
			print("new win pos: ", new_win_pos)
		
			#var mouse = Vector2(DisplayServer.mouse_get_position())
			#velocity = (mouse - last_mouse) / delta
			#last_mouse = mouse
			
			#print(mouse_pos)
			#print(drag_offset)
			#print(new_win_pos)
			DisplayServer.window_set_position(Vector2i(new_win_pos))
		
		KittyStates.IDLE:
			print("State: Idle")
			idle_timer -= delta
			if idle_timer <= 0:
				#is_idling = false
				current_state = KittyStates.WALK
				speed = 300
				#kitty_sprite.play("Walk")
			return
		
		KittyStates.WALK:
			print("State: Walk")
			kitty_sprite.play("Walk")
			
			window_position += direction * speed * delta
			
			if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
				direction.x *= -1
				kitty_sprite.flip_h = !kitty_sprite.flip_h
				maybe_idle()
				
			#if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
				#direction.y *= 1
				#maybe_idle()
				
			window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
			window_position.y = clamp(window_position.y, 0, taskbar_y - window_size.y)
			DisplayServer.window_set_position((Vector2i(window_position)))
		KittyStates.FALL:
			print("State: Fall")
			kitty_sprite.play("Idle")
			if window_position.y >= taskbar_y - window_size.y:
				#is_falling = false
				#is_walking = true
				current_state = KittyStates.WALK
				print("not falling")
			#window_position.y = taskbar_y - window_size.y
			

			
			#window_position += velocity * delta
			#velocity = velocity.lerp(Vector2.ZERO, 2 * delta)
			#if velocity == Vector2.ZERO:
				#window_position.y += fall_speed * delta
				
			window_position.y += fall_speed * delta
			
			window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
			window_position.y = clamp(window_position.y, 0, taskbar_y - window_size.y)
			DisplayServer.window_set_position((Vector2i(window_position)))
	
	#window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	#window_position.y = clamp(window_position.y, 0, taskbar_y - window_size.y)
	#DisplayServer.window_set_position((Vector2i(window_position)))
	
	#if is_dragging:
		#kitty_sprite.play("Idle")
		#var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		#var new_win_pos = mouse_pos - drag_offset
		#var mouse = Vector2(DisplayServer.mouse_get_position())
		#velocity = (mouse - last_mouse) / delta
		#last_mouse = mouse
		#DisplayServer.window_set_position(Vector2i(new_win_pos))
		##if Input.is_action_just_pressed("right"):
			##nextTrack()
			##print("right")
	#else:
		#kitty_sprite.play("Walk")
		##is_falling = true
		##is_walking = false
	
	#if is_idling:
		#idle_timer -= delta
		#if idle_timer <= 0:
			#is_idling = false
			#speed = 300
			#kitty_sprite.play("Walk")
		#return
		
	#var window_position = Vector2(DisplayServer.window_get_position())
	
	#if is_walking:
		#kitty_sprite.play("Walk")
		#
		#window_position += direction * speed * delta
#
		##DisplayServer.window_set_position((Vector2i(window_position)))
		#
		#if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
			#direction.x *= -1
			#kitty_sprite.flip_h = !kitty_sprite.flip_h
			#maybe_idle()
		##if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
			##direction.y *= 1
			##maybe_idle()
			
	#if is_falling:
		#kitty_sprite.play("Idle")
		#if window_position.y >= taskbar_y - window_size.y:
			#is_falling = false
			#is_walking = true
			#print("not falling")
		##window_position.y = taskbar_y - window_size.y
		#
#
		#
		#window_position += velocity * delta
		#velocity = velocity.lerp(Vector2.ZERO, 2 * delta)
		#if velocity == Vector2.ZERO:
			#window_position.y += fall_speed * delta
		##DisplayServer.window_set_position((Vector2i(window_position)))
	
	#window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	#window_position.y = clamp(window_position.y, 0, taskbar_y - window_size.y)
	#DisplayServer.window_set_position((Vector2i(window_position)))
