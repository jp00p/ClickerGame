extends Node2D

var things = 0
var click_power = 1
var total_things = 0
var total_captured = 0

var autoclick_price = 10
var autoclick_power_price = 100
var clickpower_price = 50
var summon_price = 15
var summon_power_price = 250
var reveal_price = 10
var capture_price = 10

var autoclick_price_factor = 1.1
var autoclick_power_price_factor = 1.3
var clickpower_price_factor = 1.4
var summon_price_factor = 1.2
var summon_power_price_factor = 1.25
var reveal_price_factor = 1.15
var capture_price_factor = 1.15

var autoclick_amt = 0
var autoclick_visible = false

var autoclick_power = 1
var autoclick_power_visible = false

var clickpower_visible = false

var location_progress = 0
var location_total = 10
var location_visible = false

var summon_progress = 0
var summon_total = 10
var summon_visible = false
var summon_power = 1
var summon_power_visible = false
var summon_power_level = 0
var summon_power_level_max = 3

var reveal_progress = 0
var reveal_total = 10
var reveal_visible = false

var capture_progress = 0
var capture_total = 15
var capture_visible = false

var bgs = []
var girls = []

var autoclick_trigger = 10
var clickpower_trigger = 50
var bgcolor_trigger = 100
var summon_trigger = 500
var summon_power_trigger = 3 # summon progress, not energy
var autoclick_power_trigger = 1000

func _ready():
	randomize()
	
	$Girl/Sprite.set_visible(false)
	$Portal.set_visible(false)
	$Girl/Name.set_visible(false)
	$Container/LocationProgress.set_visible(true)
	$Container/PerSec.set_visible(false)
	$Container/SummonProg.set_visible(false)
	$Container/AutoClick.set_visible(false)
	$Container/ClickPower.set_visible(false)
	$Container/Summon.set_visible(false)
	$Container/SummonPower.set_visible(false)
	$Container/AutoClickPower.set_visible(false)
	$Container/Reveal.set_visible(false)
	$Container/RevealProg.set_visible(false)
	$Container/Capture.set_visible(false)
	$Container/CaptureProg.set_visible(false)
	$Container/Clicker.text = "Gain "+str(click_power)+" Energy"
	$Container/Summon/SummonPrice.text = str(summon_price)
	$Container/AutoClick/AutoClickPrice.text = str(autoclick_price)
	$Container/ClickPower/ClickPowerPrice.text = str(clickpower_price)
	$Container/SummonPower/SummonPowerPrice.text = str(summon_power_price)
	$Container/AutoClickPower/AutoClickPowerPrice.text = str(autoclick_power_price)
	$Container/Reveal/RevealPrice.text = str(reveal_price)
	$Container/Capture/CapturePrice.text = str(capture_price)
	$Container/SummonProg/SummonProgAmtContainer/SummonProgAmt.text = "0/"+str(summon_total)
	$Container/RevealProg/RevealProgAmt.text = "0/"+str(reveal_total)
	$Container/CaptureProg/CaptureProgAmt.text = "0/"+str(capture_total)
	$Container/LocationProgress/LocationProgAmt.text = "0/"+str(location_total)

	#load bgs
	var bg_path = "res://BG/"
	var dir = Directory.new()
	dir.open(bg_path)
	dir.list_dir_begin(true, true)
	var bg_file_name = dir.get_next()
	while bg_file_name != '':
		if bg_file_name.ends_with(".png.import"):
			bgs.append({'file':ResourceLoader.load(bg_path+bg_file_name.get_basename()), 'name': bg_file_name.get_basename().replace(".png", "")})
		bg_file_name = dir.get_next()
	dir.list_dir_end()
	
	#load girls
	var g_path = "res://Girls/"
	dir = Directory.new()
	dir.open(g_path)
	dir.list_dir_begin(true, true)
	var g_file_name = dir.get_next()
	while g_file_name != '':
		if g_file_name.ends_with(".png.import"):
			girls.append({'file':ResourceLoader.load(g_path+g_file_name.get_basename()), 'name':g_file_name.get_basename().replace(".png", "")})
		g_file_name = dir.get_next()
	dir.list_dir_end()

	bgs.shuffle()
	girls.shuffle()
	
	print(girls.size())
	$Background.texture = bgs[0]['file']
	$Girl/Sprite.texture = girls[0]['file']
	$Girl/Name.text = girls[0]['name']
	


func new_girl():
	girls.remove(0)
	girls.shuffle()
	$Girl/Sprite.texture = girls[0]['file']
	$Girl/Name.text = girls[0]['name']
	$Girl/Sprite.set_visible(false)
	$Girl/Sprite.set_modulate(Color(0,0,0,1))
	var mat = $Girl/Sprite.get_material()
	mat.set_shader_param("blur_scale", Vector2(1,1))
	
func new_bg():
	bgs.remove(0)
	bgs.shuffle()
	location_progress = 0
	location_total = ceil(location_total*1.1)
	$Background.texture = bgs[0]['file']
	$LocationMask.set_visible(true)
	$Container/LocationProgress/LocationProgAmt.text = str(location_progress) + "/" + str(location_total)
	var mat = $LocationMask.get_material()
	mat.set_shader_param("dissolve_amount", 0)
	location_visible = false
	location_progress = 0
	
	
	
func reset_summoning():
	summon_progress = 0
	reveal_progress = 0
	capture_progress = 0
	summon_total = ceil(summon_total*1.5)
	capture_total = ceil(capture_total*1.25)
	summon_power = 1
	summon_power_level = 0
	$Girl/Name.set_visible(false)
	$Girl/Name.text = "?????"
	$Container/LocationProgress.set_visible(true)
	$Container/Summon/SummonButton.set_disabled(true)
	$Container/Reveal/RevealButton.set_disabled(true)
	$Container/Capture/CaptureButton.set_disabled(true)
	$Container/SummonProg/SummonProgAmtContainer/SummonProgAmt.text = "0/"+str(summon_total)
	$Container/SummonPower/SummonPowerButton.set_disabled(true)
	$Container/RevealProg/RevealProgAmt.text = "0/"+str(reveal_total)
	$Container/CaptureProg/CaptureProgAmt.text = "0/"+str(capture_total)
	$Container/CaptureProg.set_visible(false)
	$Container/SummonProg.set_visible(false)
	for c in $Container/SummonProg/SummonProgAmtContainer.get_children():
		print(c.get_name())
		if "SummonIndicator" in c.get_name():
			c.queue_free()
			
func _process(delta):
	$Container/Things/ThingAmt.text = str(ceil(things))
	$Container/PerSec/CPSAmt.text = str(ceil(autoclick_amt*autoclick_power))
				
	if things >= autoclick_power_trigger and !autoclick_power_visible and autoclick_visible:
		$Container/AutoClickPower.set_visible(true)
		autoclick_visible = true
		
	if summon_power_level >= summon_power_level_max:
		$Container/SummonPower/SummonPowerButton.set_disabled(true)


func _on_Clicker_pressed():
	things += abs(click_power)
	total_things += abs(click_power)
	
	if !location_visible:
		if location_progress < location_total:
			location_progress += 1
			var mat = $LocationMask.get_material()
			var per = float(location_progress)/float(location_total)
			mat.set_shader_param("dissolve_amount", per)
			$Container/LocationProgress/LocationProgAmt.text = str(location_progress) + "/" + str(location_total)
		else:
			location_visible = true
			$LocationMask.set_visible(false)
			$Container/LocationProgress.set_visible(false)
			$Container/SummonProg.set_visible(true)
			$Container/Summon.set_visible(true)
			$Portal.set_visible(true)
			$Container/SummonPower/SummonPowerButton.set_disabled(false)
			$Container/Summon/SummonButton.set_disabled(false)
			summon_visible = true
			$Girl/Name.text = "?????"
			$Girl/Name.set_visible(true)
	
	if things >= autoclick_trigger and autoclick_visible == false:
		autoclick_visible = true
		$Container/AutoClick.set_visible(true)
		$Container/PerSec.set_visible(true)
		
	if things >= clickpower_trigger and clickpower_visible == false:
		clickpower_visible = true
		$Container/ClickPower.set_visible(true)
		
	

func _on_AutoClickButton_pressed():
	if things >= autoclick_price:
		things -= autoclick_price
		autoclick_amt += 1
		autoclick_price = floor(autoclick_price * autoclick_price_factor)
		$Container/AutoClick/AutoClickPrice.text = str(autoclick_price)

func _on_ClickPowerButton_pressed():
	if things >= clickpower_price:
		things -= clickpower_price
		click_power = ceil(click_power * 1.33)
		$Container/Clicker.text = "Gain " + str(click_power) + " energy"
		clickpower_price = floor(clickpower_price * clickpower_price_factor)
		$Container/ClickPower/ClickPowerPrice.text = str(clickpower_price)

func _on_AutoClickTimer_timeout():
	things += autoclick_amt * autoclick_power
	total_things += autoclick_amt * autoclick_power

func _on_SummonButton_pressed():
	if things >= summon_price:
		things -= summon_price
		if !$Summoning.is_emitting():
			$Summoning.restart()
			$Summoning.set_emitting(true)
		summon_progress = min(summon_progress+summon_power, summon_total)
		summon_price = floor(summon_price * summon_price_factor)
		$Container/SummonProg/SummonProgAmtContainer/SummonProgAmt.text = str(summon_progress) + "/" + str(summon_total)
		$Container/Summon/SummonPrice.text = str(summon_price)
		if summon_progress >= summon_power_trigger and !summon_power_visible:
			$Container/SummonPower.set_visible(true)
		if summon_progress >= summon_total:
			$Girl/AnimationPlayer.play("appear")
			$Container/SummonProg.set_visible(false)
			$Container/Summon/SummonButton.set_disabled(true)
			$Girl/Sprite.set_visible(true)
			$Girl/Name.set_visible(true)
			$Container/Reveal.set_visible(true)
			$Container/Reveal/RevealButton.set_disabled(false)
			$Container/RevealProg.set_visible(true)
			$Portal.set_visible(false)
			$Container/SummonPower/SummonPowerButton.set_disabled(true)
			reveal_visible = true


func _on_SummonPowerButton_pressed():
	if things >= summon_power_price:
		things -= summon_power_price
		summon_power += 1
		summon_power_price = floor(summon_power_price * summon_power_price_factor)
		$Container/SummonPower/SummonPowerPrice.text = str(summon_power_price)
		if summon_power_level < summon_power_level_max:
			var dot = load("res://Scenes/SummonIndicator.tscn").instance()
			$Container/SummonProg/SummonProgAmtContainer.add_child(dot)
			summon_power_level += 1

		


func _on_AutoClickPowerButton_pressed():
	if things >= autoclick_power_price:
		things -= autoclick_power_price
		autoclick_power_price = floor(autoclick_power_price * autoclick_power_price_factor)
		autoclick_power += 1
		$Container/AutoClickPower/AutoClickPowerPrice.text = str(autoclick_power_price)


func _on_RevealButton_pressed():
	if things >= reveal_price:
		things -= reveal_price
		reveal_progress = min(reveal_progress+1, reveal_total)
		reveal_price = floor(reveal_price*reveal_price_factor)
		
		var rc = (float(reveal_progress)/float(reveal_total))
		var bp = 1-rc
		print(rc)
		
		$Girl/Sprite.set_modulate(Color(rc,rc,rc,1))
		var mat = $Girl/Sprite.get_material()
		mat.set_shader_param("blur_scale", Vector2(bp,bp))
		$Container/Reveal/RevealPrice.text = str(reveal_price)
		$Container/RevealProg/RevealProgAmt.text = str(reveal_progress) + "/" + str(reveal_total)
		if reveal_progress >= reveal_total:
			mat.set_shader_param("blur_scale", Vector2(0,0))
			$Girl/Name.set_text(girls[0]['name'])
			$Container/Reveal/RevealButton.set_disabled(true)
			$Container/Capture.set_visible(true)
			$Container/RevealProg.set_visible(false)
			$Container/CaptureProg.set_visible(true)
			$Container/Capture/CaptureButton.set_disabled(false)
			capture_visible = true
			reveal_total = ceil(reveal_total * 1.1)


func _on_CaptureButton_pressed():
	if things >= capture_price:
		things -= capture_price
		capture_progress = min(capture_progress+1, capture_total)
		capture_price = floor(capture_price * capture_price_factor)
		$Container/CaptureProg/CaptureProgAmt.text = str(capture_progress) + "/" + str(capture_total)
		$Container/Capture/CapturePrice.text = str(capture_price)
		$Girl/AnimationPlayer.play("shake")
		if capture_progress >= capture_total:
			$Container/Capture/CaptureButton.set_disabled(true)
			total_captured += 1
			#reset cycle
			$Girl/AnimationPlayer.play("capture")
			yield($Girl/AnimationPlayer, "animation_finished")
			new_bg()
			new_girl()
			reset_summoning()
