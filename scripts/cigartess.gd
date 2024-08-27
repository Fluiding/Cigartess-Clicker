extends Area2D
	
func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		global.add_cookies(global.click_mult)
		$ClickSound.play()
