extends Control

var sell_mode := false
var buy_mult := 1
var buy_max := false

func thousands_sep(value) -> String:
	var str_value: String = str(value)
	var loop_start: int = 3

	for i in range(str_value.length()-1, -1, -1):
		if str_value[i] == ".":
			loop_start += (str_value.length() - i)
			break;

	for i in range(str_value.length()-loop_start, 0, -3):
		str_value = str_value.insert(i, ",")
		
	return str_value

func _ready():
	var building_nodes := %ShopList.get_children()
	var upgrades_nodes := %UpgradesList.get_children()
	var index: int
	
	index = 0
	for i in global.buildings:
		var b_node = "%" + i + "/Button"
		building_nodes[index].name = i
		index += 1
		
		get_node(b_node + "/Title").text = i
		get_node(b_node + "/AmountOwned").text = thousands_sep(global.buildings_data[i]["amount_owned"])
		get_node(b_node + "/Cost").text = thousands_sep(global.buildings[i]["cost"])
		get_node(b_node).button_down.connect(handle_building.bind(i))
		get_node(b_node).mouse_entered.connect(hover_sound)
		
	if global.buildings_data["Satanus"]["amount_owned"] > 0:
		%Satanus/Button.disabled = true
		%Jesús.visible = true
		
	index = 0
	for i in upgrades.upgrades_cost:
		var b_node = "%" + i + "/Button"
		upgrades_nodes[index].name = i
		index += 1
		
		get_node(b_node + "/Bought").visible = upgrades.upgrades_bought[i]
		get_node(b_node + "/Title").text = i
		get_node(b_node + "/Cost").text = thousands_sep(upgrades.upgrades_cost[i])
		get_node(b_node).button_down.connect(buy_upgrade.bind(i))
		get_node(b_node).button_down.connect(click_sound)
		get_node(b_node).mouse_entered.connect(hover_sound)

func _process(_delta):
	%cigartess.text = thousands_sep(floor(global.cigartess)) + " Cigartess"
	%cps.text = thousands_sep("%.2f" % global.cps).replace(".00", "") + " Cigartess per Second"

func hover_sound(): $HoverSound.play()
func click_sound(): $ClickSound.play()

func buy_upgrade(building):
	upgrades.buy_upgrade(building)

func handle_building(building):
	if sell_mode:
		sell_building(building)
	else:
		buy_building(building)

func buy_building(building):
	if !shop.buy_building(building, buy_mult, buy_max):
		return
	
	$BuySound.play()
	var b_node: String = "%" + building + "/Button"
	get_node(b_node + "/AmountOwned").text = thousands_sep(global.buildings_data[building]["amount_owned"])
	
	if building == "Jesús":
		shop.sell_building("Satanus", 0, true, false)
		shop.sell_building("Jesús", 0, true, false)
		%Satanus/Button/AmountOwned.text = "0"
		%Satanus/Button.disabled = false
		%Jesús.visible = false
	
	elif building == "Satanus":
		get_node(b_node).disabled = true
		%Jesús.visible = true
		return
		
	get_node(b_node + "/Cost").text = thousands_sep(global.buildings[building]["cost"])

func sell_building(building):
	if !shop.sell_building(building, buy_mult, buy_max):
		return
	$SellSound.play()
	
	var b_node: String = "%" + building + "/Button"
	var cost = global.buildings[building]["cost"]
	var amount_owned = global.buildings_data[building]["amount_owned"]
	
	get_node(b_node + "/AmountOwned").text = thousands_sep(amount_owned)
	get_node(b_node + "/Cost").text = thousands_sep(("%.2f" % cost).replace(".00", ""))

func set_sell_mode(option: bool):
	sell_mode = option

func set_buy_mult(amount: int):
	if amount == 0:
		buy_max = true
	else:
		buy_mult = amount
		buy_max = false

	for i in %ShopList.get_children():
		var cost_label = get_node("%" + i.name + "/Button/Cost")
		var cost = shop.get_building_cost(i.name, buy_mult, buy_max)["cost"]
		cost_label.text = thousands_sep(("%.2f" % cost).replace(".00", ""))
