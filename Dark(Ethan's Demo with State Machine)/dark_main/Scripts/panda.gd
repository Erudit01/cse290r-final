extends Node2D

# What state the Player is in
enum Player_State {
	Attack,
	Death,
	Fall,
	Idle,
	Jab,
	Jab_Repeat,
	Jump,
	Jump_W_Spin,
	Roll,
	Run,
	Slam,
	Spin_Jump
}

#Movement Speed
const SPEED = 120.0
const JUMP_VELOCITY = -250.0

#reference what we need
@onready 
var body: CharacterBody2D = $"."
@onready 
var animations: AnimatedSprite2D = $animations

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Set the default state
var current_state: Player_State = Player_State.Idle
var new_state = current_state
var attacking = false
var death = false
var jump = false
var double_jump = false
var movable = true
var roll = false

# Handles everything related to changing states
func change_state(new_state: Player_State) -> void:
	current_state = new_state
	match current_state:
		Player_State.Attack:
			animations.play('Attack')
			movable = false
			attacking = true
			
		Player_State.Death:
			animations.play('Death')
			death = true
			movable = false
		
		Player_State.Fall:
			animations.play('Fall')
			movable = true
		
		Player_State.Idle:
			animations.play('Idle')
			movable = true
		
		Player_State.Jab:
			animations.play('Jab')
			movable = false
		
		Player_State.Jab_Repeat:
			animations.play('Jab_Repeat')
			movable = false
		
		Player_State.Jump:
			animations.play('Jump')
			movable = true
		
		Player_State.Jump_W_Spin:
			animations.play('Jump_W_Spin')
			body.velocity.y = JUMP_VELOCITY
			movable = true
			double_jump = false
		
		Player_State.Run:
			animations.play('Run')
			movable = true
		
		Player_State.Roll:
			animations.play('Roll')
			movable = true
			roll = true
		
		Player_State.Slam:
			animations.play('Slam')
			movable = false
		
		Player_State.Spin_Jump:
			animations.play('Spin_Jump')
			movable = true

#Handles Movement
func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	else:
		jump = false
		double_jump = false

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY
		jump = true
	
	if Input.is_action_just_pressed("Jump") and jump == true and not body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY
		double_jump = true
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("Left", "Right")

	# Flip the Sprite
	if direction > 0 and movable == true:
		animations.flip_h = false
	elif direction < 0 and movable == true:
		animations.flip_h = true
	
		#Apply movement
	if direction and movable == true:
		body.velocity.x = direction * SPEED
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, SPEED)	
	
	
	#CHANGE THE STATES BELOW HERE
	
	#Change state based on movement
	if direction == 0:
		if attacking == false and death == false and jump == false and roll == false:
			new_state = Player_State.Idle
	else:
		if attacking == false and death == false and jump == false and roll == false:
			new_state = Player_State.Run
		
	#Attack and Death and Jump
	if Input.is_action_just_pressed("Attack"):
		new_state = Player_State.Attack
	if Input.is_action_just_pressed("Roll"):
		new_state = Player_State.Roll
	if jump == true:
		new_state = Player_State.Jump
	if double_jump == true:
		new_state = Player_State.Jump_W_Spin
	
	body.move_and_slide()
	change_state(new_state)


func _on_animations_animation_finished() -> void:
	if animations.animation == "Attack":
		attacking = false
	if animations.animation == "Death":
		death = false
	if animations.animation == "Roll":
		roll = false
