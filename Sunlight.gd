tool
extends DirectionalLight

export (int) var day_cycle = 60 setget _set_day_cycle
func _set_day_cycle(val):
	day_cycle = val
	_ready()

export (Color) var dawn = Color(0.8,0.6,0.2) setget _set_dawn
func _set_dawn(val):
	dawn = val

export (Color) var midday = Color(0.8,0.8,0.6) setget _set_midday
func _set_midday(val):
	midday = val

export (Color) var evening = Color(0.8,0.4,0.3) setget _set_evening
func _set_evening(val):
	evening = val

export (Color) var night = Color(0.4,0.2,0.8) setget _set_night
func _set_night(val):
	night = val

export (Color) var sky_color = Color(0.0,0.3,1.0) setget _set_sky_color
func _set_sky_color(val):
	sky_color = val

var day_quadrant = 0;
var curr_tick = 0;
var rot_speed = 0;

var curr_color;
onready var sky : WorldEnvironment;
	
	
func _rotate_light(delta):
	rotate_x(-rot_speed*delta)

func _set_light_color():
	var mix = abs(sin(rotation.x))
	match day_quadrant:
		0:
			curr_color = lerp(dawn, midday, mix)
#			print ("Dawn ", mix)
		1:
			curr_color = lerp(evening, midday, mix)
#			print ("Midday ", mix)
		2:
			curr_color = lerp(evening, night, mix)
#			print ("Evening ", mix)
		3:
			curr_color = lerp(dawn, night, mix)
#			print ("Night ", mix)
			
	light_color = curr_color

func _set_sky_adjustments():
	if sky == null:
		return;
		
	if sky.environment.background_mode == Environment.BG_COLOR:
		sky.environment.background_color = lerp(sky_color, curr_color, 0.45)
		sky.environment.ambient_light_color = sky.environment.background_color

	if sky.environment.fog_enabled == true:
		sky.environment.fog_color = sky.environment.background_color

func _ready():
	rot_speed = (2.0 * PI) / day_cycle;
	rotation.x = 0.0
	rotation.y = 0.0
	rotation.z = 0.0
	curr_color = dawn
	light_color = curr_color
	day_quadrant = 0
	curr_tick = 0
	sky = $Sky;
	if sky.environment.background_mode == Environment.BG_COLOR:
		sky.environment.background_color = sky_color;
	
	
func _process(delta):
	_rotate_light(delta)
	_set_light_color()
	_set_sky_adjustments()
	curr_tick += delta;
	
	if rotation.x < 0 and rotation.x > -PI/2.0:
		day_quadrant = 0
	elif rotation.x < -PI/2.0 and rotation.x > -PI:
		day_quadrant = 1
	elif rotation.x < PI and rotation.x > PI/2.0:
		day_quadrant = 2
	else:
		day_quadrant = 3
	
	if curr_tick > day_cycle:
		curr_tick = 0


