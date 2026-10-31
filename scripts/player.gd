extends CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sound = $audio/jump_sound
@onready var dash_sound = $audio/dash_sound

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DOUBLE_JUMP_VELOCITY = JUMP_VELOCITY * 0.7
const DASH = SPEED * 1.3
var dash_speed := 0.0

var tween: Tween


#jump count
var jump_count = 0
const MAX_JUMPS = 2

#dash 
var can_dash = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	
	# Apply gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
		
	# Handle jump and doublejump.
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		jump_count += 1
		if !is_on_floor() and jump_count < 2:
			velocity.y = DOUBLE_JUMP_VELOCITY
			jump_sound.play()
		if jump_count < MAX_JUMPS and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			
	if Input.is_action_just_pressed("dash") and can_dash and not is_on_floor():
		dash_speed = DASH
		if tween:
			tween.stop()
		tween = get_tree().create_tween()
		tween.tween_property(self, "dash_speed", 0, 1).set_ease(Tween.EASE_OUT)
		can_dash = false
		dash_sound.play()
		
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Play animations
	if is_on_floor():
		can_dash = true
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
		jump_count = 0
	else:
		if can_dash:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("dash")
		
	#Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	
	# Apply movement
	if direction:
		velocity.x = direction * (SPEED + dash_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
func getJumps():
	return jump_count
