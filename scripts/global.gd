extends Node

const HUGE: int = 9223372036854775807
var time: int
var click_mult := 1.0
var cigartess := 1111111110.0
var cps := 0.0

var buildings := {
	"Cigartess": {"base_cost": 20.0, "cost": 20.0},
	"Grandpa": {"base_cost": 120.0, "cost": 120.0},
	"Teenager": {"base_cost": 170.0, "cost": 170.0},
	"Tobacco Factory": {"base_cost": 1500.0, "cost": 1500.0},
	"Satanus": {"base_cost": 666666666.0, "cost": 666666666.0},
	"Jesús": {"base_cost": 777777777.0, "cost": 777777777.0},
}
var buildings_data = {}

func add_cookies(amount: float):
	if cigartess + amount < 0:
		cigartess = 0
	cigartess += amount

func update_data():
	var d = buildings_data
	for i in buildings:
		buildings[i]["cost"] = ceil(buildings[i]["base_cost"] * 1.15 ** d[i]["amount_owned"])
	
	cps = d["Cigartess"]["amount_owned"] * 0.1 * d["Cigartess"]["multiplier"]
	cps += d["Grandpa"]["amount_owned"] * 1 * d["Cigartess"]["multiplier"]
	cps += d["Tobacco Factory"]["amount_owned"] * 10 * d["Cigartess"]["multiplier"]
	cps -= cps / 100 * d["Teenager"]["amount_owned"] * 1 * d["Cigartess"]["multiplier"]

	click_mult *= 1 + (0.97 * 0.97 ** d["Teenager"]["amount_owned"]) / 20
	click_mult = clampf(click_mult, 1.0 / HUGE, 5)
	
	if d["Satanus"]["amount_owned"] > 0 and d["Jesús"]["amount_owned"] == 0:
		cps = 0

func save_game():
	var save_data = {
		"buildings_data": buildings_data,
		"cigartess": cigartess,
	}
	save_data = JSON.stringify(save_data)
	
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_line(save_data)
	
func load_game():
	if not FileAccess.file_exists("user://save.data"):
		return
		
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	var save_data = JSON.parse_string(save_file.get_line())

	buildings_data = save_data["buildings_data"]
	cigartess = save_data["cigartess"]
	update_data()
	
func _init():
	for i in buildings:
		buildings_data[i] = {"amount_owned": 0,  "multiplier": 1}
		
	load_game()
	time = Time.get_ticks_msec()
	
func _process(delta):
	add_cookies(cps * delta)
	
	if Input.is_action_just_pressed("fullscreen_toggle"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
