extends Node

const HUGE: int = 9223372036854775807
var time: int
var click_mult := 1.0
var cigartess := 0.0
var cps := 0.0
var buildings := {
	"Cigartess": {"base_cost": 20.0, "cost": 0.0, "amount_owned": 0.0},
	"Teenager": {"base_cost": 120.0, "cost": 0.0, "amount_owned": 0.0},
	"Grandpa": {"base_cost": 250.0, "cost": 0.0, "amount_owned": 0.0},
	"Tobacco Plant": {"base_cost": 1500.0, "cost": 0.0, "amount_owned": 0.0},
	"Satanus": {"base_cost": 666666666.0, "cost": 0.0, "amount_owned": 0.0},
	"Jesús": {"base_cost": 777777777.0, "cost": 0.0, "amount_owned": 0.0},
}

func add_cookies(amount: float):
	if cigartess + amount < 0:
		cigartess = 0
	cigartess += amount
	await get_tree().create_timer(1).timeout

func update_cps():
	cps = buildings["Cigartess"]["amount_owned"] / 10
	cps += buildings["Grandpa"]["amount_owned"]
	cps += buildings["Tobacco Plant"]["amount_owned"] * 10
	cps -= cps / 100 * buildings["Teenager"]["amount_owned"]

	click_mult *= 1 + (0.97 * 0.97 ** buildings["Teenager"]["amount_owned"]) / 20
	click_mult = clampf(click_mult, 1.0 / HUGE, 5)

func buy_building(building) -> bool:
	var b_stats = buildings[building]
	if cigartess < b_stats["cost"]:
		return false
	
	cigartess -= b_stats["cost"]
	b_stats["amount_owned"] += 1
	b_stats["cost"] = ceil(b_stats["base_cost"] * 1.15 ** b_stats["amount_owned"])
	update_cps()
	
	if buildings["Satanus"]["amount_owned"] == 1 and buildings["Jesús"]["amount_owned"] == 0:
		cps = 0
	
	return true

func sell_building(building, return_cigartess = true) -> bool:
	var b_stats = buildings[building]
	if b_stats["amount_owned"] - 1 < 0:
		return false
	
	b_stats["amount_owned"] -= 1
	b_stats["cost"] = ceil(b_stats["base_cost"] * 1.15 ** b_stats["amount_owned"])
	update_cps()
	
	if return_cigartess:
		cigartess += b_stats["cost"]
	
	return true
	
func _ready():
	time = Time.get_ticks_msec()
	
func _process(delta):
	add_cookies(cps * delta)
