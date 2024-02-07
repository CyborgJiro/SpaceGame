extends Sprite2D

var boost_speed := 1500.0
var normal_speed := 600.0

var max_speed := normal_speed
var velocity := Vector2(0, 0)
var steering_factor := 10.0

func _process(delta):
	#A variable that says which direction the ship should be moving in.
	var direction := Vector2(0, 0)
	#Getting directional input.
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	#This makes sure when going diagonal, the movement speed doesnt increase from the vector being higher than 1.0.

	if direction.length() > 1.0:
		direction = direction.normalized()

	if Input.is_action_just_pressed("boost"):
		max_speed = boost_speed
		get_node("Timer").start()
	
	var desired_velocity := max_speed * direction
	var steering := desired_velocity - velocity
	#Sets the speed of the ship.
	velocity += steering * steering_factor * delta
	#Sets the actual movement and times it by delta so its independant from framerate.
	position += velocity * delta
	#If statement to make sure it doesnt rerotate/snap back to only looking in the -> direction when stopped. 
	if direction.length() > 0.0:
		#Rotates the ship sprite to the direction the ship is moving. 
		rotation = velocity.angle()
	#Just here so I remember what pass does. "pass" is used when you have a function with nothing inside the function. 
	pass


func _on_timer_timeout():
	max_speed = normal_speed
