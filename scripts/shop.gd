extends Node

func get_total_cost(building, start, end) -> float:
	var total_cost := 0.0
	
	for i in range(start + 1, end + 1):
		var term = (global.buildings[building]["base_cost"] * 1.15 ** i) / 1.15
		total_cost += term
	
	return total_cost

func get_building_cost(building, amount, buy_max):
	var b_stats = global.buildings[building]
	var b_data = global.buildings_data[building]
	var total_cost := 0.0
	
	if buy_max:
		amount = 0
		for i in range(1, 65536):
			
			var amount_to_add = (b_stats["cost"] * 1.15 ** i) / 1.15
			if total_cost + amount_to_add > global.cigartess:
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
	if total_cost["amount"] == 0 or global.cigartess < total_cost["cost"]:
			return false
	
	global.cigartess -= total_cost["cost"]
	global.buildings_data[building]["amount_owned"] += total_cost["amount"]
	
	global.update_data()
	return true

func sell_building(building, amount, sell_max, return_cigartess = true) -> bool:
	var amount_owned = global.buildings_data[building]["amount_owned"]

	if !sell_max && amount_owned - amount < 0:
		return false
	if sell_max:
		amount = amount_owned
	
	if return_cigartess:
		global.cigartess += get_total_cost(building, amount_owned - amount, amount_owned) / 2
	
	global.buildings_data[building]["amount_owned"] -= amount
	global.update_data()
	return true
