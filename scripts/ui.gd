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
	
	
	var building_nodes  := %ShopList.get_children()
	var index = 0
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

func _process(_delta):
	%cigartess.text = thousands_sep(floor(global.cigartess)) + " Cigartess"
	%cps.text = thousands_sep("%.2f" % global.cps) + " Cigartess per Second"

func hover_sound(): $HoverSound.play()
func click_sound(): $ClickSound.play()

func handle_building(building):
	if sell_mode:
		sell_building(building)
	else:
		buy_building(building)

func buy_building(building):
	if !global.buy_building(building, buy_mult, buy_max):
		return
	
	$BuySound.play()
	var b_node: String = "%" + building + "/Button"
	get_node(b_node + "/AmountOwned").text = thousands_sep(global.buildings_data[building]["amount_owned"])
	
	if building == "Jesús":
		global.sell_building("Satanus", 0, true, false)
		global.sell_building("Jesús", 0, true, false)
		%Satanus/Button/AmountOwned.text = "0"
		%Satanus/Button.disabled = false
		%Jesús.visible = false
	
	elif building == "Satanus":
		get_node(b_node).disabled = true
		%Jesús.visible = true
		return
		
	get_node(b_node + "/Cost").text = thousands_sep(global.buildings[building]["cost"])

func sell_building(building):
	if !global.sell_building(building, buy_mult, buy_max):
		return
		
	$SellSound.play()
	var b_node: String = "%" + building + "/Button"
	get_node(b_node + "/AmountOwned").text = thousands_sep(global.buildings_data[building]["amount_owned"])
	get_node(b_node + "/Cost").text = thousands_sep(global.buildings[building]["cost"])

func set_sell_mode(option: bool):
	sell_mode = option

func set_buy_mult(value: int):
	if value == 0:
		buy_max = true
	else:
		buy_mult = value
		buy_max = false
