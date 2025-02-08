extends Node2D

# What state the spider is in
enum Spider_State {
	Attack,
	Death,
	Hurt,
	Walk
	}

#Movement Speed
const SPEED = 80.0

@onready 
var animations: AnimatedSprite2D = $animations
