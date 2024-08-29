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
	for i in buildings:
		buildings[i]["cost"] = ceil(buildings[i]["base_cost"] * 1.15 ** buildings_data[i]["amount_owned"])
	
	cps = buildings_data["Cigartess"]["amount_owned"] * 0.1
	cps += buildings_data["Grandpa"]["amount_owned"]
	cps += buildings_data["Tobacco Factory"]["amount_owned"] * 10
	cps -= cps / 100 * buildings_data["Teenager"]["amount_owned"]

	click_mult *= 1 + (0.97 * 0.97 ** buildings_data["Teenager"]["amount_owned"]) / 20
	click_mult = clampf(click_mult, 1.0 / HUGE, 5)
	
	if buildings_data["Satanus"]["amount_owned"] > 0 and buildings_data["Jesús"]["amount_owned"] == 0:
		cps = 0

func get_total_cost(building, start, end) -> float:
	var total_cost := 0.0
	
	for i in range(start + 1, end + 1):
		var term = (buildings[building]["base_cost"] * 1.15 ** i) / 1.15
		total_cost += term
	
	return total_cost

func get_building_cost(building, amount, buy_max):
	var b_stats = buildings[building]
	var b_data = buildings_data[building]
	var total_cost := 0.0
	
	if buy_max:
		amount = 0
		for i in range(1, 65536):
			
			var amount_to_add = (b_stats["cost"] * 1.15 ** i) / 1.15
			if total_cost + amount_to_add > cigartess:
				if i == 1:
					total_cost = b_data["amount_owned"]
				break

			total_cost += amount_to_add
			amount = i

	else:
		total_cost = get_total_cost(building, b_data["amount_owned"], b_data["amount_owned"] + amount)
	
	if building == "Satanus" or building == "Jesús":
		total_cost = b_stats["cost"]
		
	return {"cost": total_cost, "amount": amount}

func buy_building(building, amount, buy_max) -> bool:
	var total_cost = get_building_cost(building, amount, buy_max)
	if total_cost["amount"] == 0 or cigartess < total_cost["cost"]:
			return false
	
	cigartess -= total_cost["cost"]
	buildings_data[building]["amount_owned"] += total_cost["amount"]
	
	update_data()
	return true

func sell_building(building, amount, sell_max, return_cigartess = true) -> bool:
	var amount_owned = buildings_data[building]["amount_owned"]

	if !sell_max && amount_owned - amount < 0:
		return false
	if sell_max:
		amount = amount_owned
	
	if return_cigartess:
		cigartess += get_total_cost(building, amount_owned - amount, amount_owned) / 2
	
	buildings_data[building]["amount_owned"] -= amount
	update_data()
	return true
	
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
		buildings_data[i] = {"amount_owned": 0}
		
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
