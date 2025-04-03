extends Node2D

# What state the Player is in
enum Player_State {
	Attack,         #DONE
	Death,          #DONE
	Fall,           #DONE
	Idle,           #DONE
	Jab,            #DONE
	Jump,           #DONE
	Jump_W_Spin,    #CUT THE ANIMATION WE NEED PARTICLE EFFECTS INSTEAD ON DOUBLE JUMP
	Roll,           #ONLY WORKS GOING TO THE RIGHT
	Run,            #DONE
	Slam,           #DONE
	Spin_Jump,      #NEEDS REPOSITIONING AND MOVING OF COLLIDER
	Wall_Slide      #NEEDS EVERYTHING NOTHING HAS BEEN DONE YET
}

#Movement Speed
const SPEED = 120.0
const JUMP_VELOCITY = -200.0
const ROLL_VELOCITY = 400
const FULL_HEALTH = 100

#reference what we need
@onready 
var body: CharacterBody2D = $"."
@onready 
var animate: AnimationPlayer = $Animations/AnimationPlayer
@onready var enemy_collision: Area2D = $EnemyOverlap

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
var double_jump_ready = true
var falling = false
var slam_ready = false
var seen = false
var health = FULL_HEALTH

# Handles everything related to changing states
func change_state(new_state: Player_State) -> void:
	current_state = new_state
	match current_state:
		Player_State.Attack:
			animate.play('Attack')
			movable = false
			attacking = true
			
		Player_State.Death:
			animate.play('Death')
			death = true
			movable = false
		
		Player_State.Fall:
			animate.play('Fall')
			movable = true
		
		Player_State.Idle:
			animate.play('Idle')
			movable = true
		
		Player_State.Jab:
			animate.play('Jab')
			movable = false
			attacking = true
		
		Player_State.Jump:
			animate.play('Jump')
			movable = true
		
		Player_State.Jump_W_Spin:
			animate.play('Jump')
			body.velocity.y = JUMP_VELOCITY
			movable = true
			double_jump = false
			double_jump_ready = false
		
		Player_State.Run:
			animate.play('Run')
			movable = true
		
		Player_State.Roll:
			if $Animations.flip_h == false:
				body.velocity.x = ROLL_VELOCITY
			elif $Animations.flip_h == true:
				body.velocity.x = ROLL_VELOCITY * -1
			animate.play('Roll')
			movable = true
			roll = true
		
		Player_State.Slam:
			animate.play('Slam')
			movable = false
		
		Player_State.Spin_Jump:
			animate.play('Spin_Jump')
			movable = false
			attacking = true

#Handles Movement
func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not body.is_on_floor():
		body.velocity.y += gravity * delta/2
		if Input.is_action_just_pressed("Special_Attack"):
			slam_ready = true
	else:
		jump = false
		double_jump = false
		double_jump_ready = true
		falling = false

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY
		jump = true
	
	if Input.is_action_just_pressed("Jump") and jump == true and not body.is_on_floor() and double_jump_ready == true:
		body.velocity.y = JUMP_VELOCITY
		double_jump = true
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("Left", "Right")

	# Flip the Sprite/Hitboxes
	if direction > 0 and movable == true:
		if $Animations.flip_h == true:
			$JabHitBox/JabCollision1.position *= Vector2(-1,1)
			$JabHitBox/JabCollision1.rotation *= -1
			$JabHitBox/JabCollision2.position *= Vector2(-1,1)
			$JabHitBox/JabCollision2.rotation *= -1
			$AttackHitBox/AttackCollision1.position *= Vector2(-1,1)
			$AttackHitBox/AttackCollision2.position *= Vector2(-1,1)
			$PlayerHitBox.position *= Vector2(-1,1)
			$EnemyOverlap/EnemyInArea.position *= Vector2(-1,1)
		$Animations.flip_h = false
	elif direction < 0 and movable == true:
		if $Animations.flip_h == false:
			$JabHitBox/JabCollision1.position *= Vector2(-1,1)
			$JabHitBox/JabCollision1.rotation *= -1
			$JabHitBox/JabCollision2.position *= Vector2(-1,1)
			$JabHitBox/JabCollision2.rotation *= -1
			$AttackHitBox/AttackCollision1.position *= Vector2(-1,1)
			$AttackHitBox/AttackCollision2.position *= Vector2(-1,1)
			$PlayerHitBox.position *= Vector2(-1,1)
			$EnemyOverlap/EnemyInArea.position *= Vector2(-1,1)
		$Animations.flip_h = true
	
		#Apply movement
	if direction and movable == true:
		body.velocity.x = direction * SPEED
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, SPEED)	
	
	
	#CHANGE THE STATES BELOW HERE
	
	if not body.is_on_floor() and body.velocity.y > 0:
		falling = true
	
	#Change state based on movement
	if direction == 0:
		if attacking == false and death == false and jump == false and roll == false:
			new_state = Player_State.Idle
	else:
		if attacking == false and death == false and jump == false and roll == false:
			new_state = Player_State.Run
		
	#Attack and Death and Jump
	if Input.is_action_just_pressed("DEV-TOOL-DIE"):
		new_state = Player_State.Death
	if Input.is_action_just_pressed("Attack"):
		new_state = Player_State.Attack
	if Input.is_action_just_pressed("Jab"):
		new_state = Player_State.Jab
	if Input.is_action_just_pressed("Special_Attack"):
		new_state = Player_State.Spin_Jump
	if Input.is_action_just_pressed("Roll"):
		new_state = Player_State.Roll
	if falling == true:
		new_state = Player_State.Fall
	if jump == true and falling == false:
		new_state = Player_State.Jump
	if double_jump == true:
		new_state = Player_State.Jump_W_Spin
	if slam_ready == true and body.is_on_floor():
		attacking = true
		slam_ready = false
		new_state = Player_State.Slam
		
	if health <= 0:
		death = true
		new_state = Player_State.Death
		movable = false
		queue_free()
	
	body.move_and_slide()
	check_enemy_hit_player()
	change_state(new_state)
	
	

func take_damage(damage: int):
	health -= damage
	print(health)

func check_enemy_hit_player():
	for body in enemy_collision.get_overlapping_bodies():
		if body.name in ["spider","spider2","spider3","spider4","spider5","spider6","spider7","spider8","spider9"]:
			take_damage(5)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack" or anim_name == "Jab" or anim_name == "Spin_Jump" or anim_name == "Slam":
		attacking = false
	if anim_name == "Roll":
		roll = false
		
