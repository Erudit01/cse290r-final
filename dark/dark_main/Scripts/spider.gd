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
var damage = 0

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
			
func take_damage(dmg: int):
	health -= dmg
	print(health)

func _on_spider_hurt_box_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print(5)
	if area.name == "JabHitBox":
		damage = 30
	elif area.name == "AttackHitBox":
		damage = 40
	elif area.name == "SlamHitBox":
		damage = 25
	else:
		return
	
	take_damage(damage)
