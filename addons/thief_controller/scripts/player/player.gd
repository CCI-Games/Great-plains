extends KinematicBody


var collision_shape: CollisionShape

func _ready():
	collision_shape = $CollisionShape

var speed: float = 10.0 # Assign a value to the speed variable
var gravity: float = 9.8
var jump_force: float = 10.0


func _physics_process(delta):
	var motion = Vector3()
	motion.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	motion.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	motion = motion.normalized() * speed

	motion = move_and_slide(motion, Vector3.UP)

	if is_on_floor():
		motion.y = -gravity * delta
	else:
		motion.y -= gravity * delta

	motion = move_and_slide(motion, Vector3.UP)

	if is_on_floor():
		motion.y = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		motion.y = jump_force

	if Input.is_action_just_pressed("crouch"):
		collision_shape.scale.y = 0.5
	elif Input.is_action_just_released("crouch"):
		collision_shape.scale.y = 1.0
