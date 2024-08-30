extends Node

const upgrades_cost := {
	"Nag Remover": 1000, # Boosts grenpa by 2x
	"Meth": 1500, # Boosts cigartess clicks by 2x
}
var upgrades_bought = {}

func buy_upgrade(upgrade) -> bool:
	if upgrades_bought[upgrade] or upgrades_cost[upgrade] > global.cigartess:
		return false
		
	upgrades_bought[upgrade] = true
	if upgrade == "Nag Remover":
		global.buildings_data["Grandpa"]["multiplier"] *= 2
	if upgrade == "Meth":
		global.click_mult *= 2
	
	return true
