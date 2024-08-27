extends Control

func thousands_sep(value: float) -> String:
	var str_value: String = str(value)
	var loop_end: int = 0 if value > -0.001 else 1
	var loop_start: int = 3

	for i in range(str_value.length()-1, -1, -1):
		if str_value[i] == ".":
			loop_start += (str_value.length() - i)
			break;

	for i in range(str_value.length()-loop_start, loop_end, -3):
		str_value = str_value.insert(i, ",")
		
	return str_value

func _ready():
	var b_nodes  := %ShopList.get_children()
	var b_keys   := global.buildings.keys()
	var b_values := global.buildings.values()
	
	for i in len(b_nodes):
		b_values[i]["cost"] = b_values[i]["base_cost"]
		var b_node = "%" + b_keys[i] + "/Button"
		b_nodes[i].name = b_keys[i]
		
		get_node(b_node + "/Title").text = b_keys[i]
		get_node(b_node + "/AmountOwned").text = thousands_sep(global.buildings[b_keys[i]]["amount_owned"])
		get_node(b_node + "/Cost").text = thousands_sep(global.buildings[b_keys[i]]["cost"])
		get_node(b_node).button_down.connect(buy_building.bind(b_keys[i]))
		get_node(b_node).mouse_entered.connect(hover)

func hover():
	$HoverSound.play()

func _process(_delta):
	%cigartess.text = thousands_sep(floor(global.cigartess)) + " Cigartess"
	%cps.text = thousands_sep(global.cps) + " Cigartess per Second"
	
func buy_building(building):
	$BuySound.play()
	
	if !global.buy_building(building):
		return
		
	var b_node: String = "%" + building + "/Button"
	
		
	get_node(b_node + "/AmountOwned").text = thousands_sep(global.buildings[building]["amount_owned"])
	
	if building == "Jesús":
		global.sell_building("Satanus", false)
		global.sell_building("Jesús", false)
		%Satanus/Button/AmountOwned.text = "0"
		%Satanus/Button.disabled = false
		%Jesús.visible = false
	
	elif building == "Satanus":
		get_node(b_node).disabled = true
		%Jesús.visible = true
		return
		
	get_node(b_node + "/Cost").text = thousands_sep(global.buildings[building]["cost"])

func sell_building(building):
	$SellSound.play()
	global.sell_building(building)
