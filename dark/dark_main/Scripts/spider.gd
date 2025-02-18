extends Node2D

# What state the spider is in
enum Spider_State {
	Attack,
	Death,
	Hurt,
	Walk, 
	Idle
	}

#Movement Speed
const SPEED = 80.0
const FULL_HEALTH = 50

@onready 
var animations: AnimatedSprite2D = $animations
var current_state: Spider_State = Spider_State.Idle
var movable = true
var attacking = false
var death = false
var health = FULL_HEALTH

func change_state(new_state: Spider_State) -> void:
	current_state = new_state
	match current_state:
		Spider_State.Attack:
			animations.play('attack')
			movable = false
			attacking = true

		Spider_State.Idle:
			animations.play('Idle')
			movable = true
			
		Spider_State.Walk:
			animations.play('walk')
			movable = true
			
		Spider_State.Hurt:
			animations.play('hurt')
			
		Spider_State.Death:
			animations.play('death')
			death = true
			movable = false
			
func take_damage(damage: int):
	health -= damage
