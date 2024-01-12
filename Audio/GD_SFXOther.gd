extends Node

const SFX_VFXKarmaBlipLo = preload("res://Audio/Karma/VFXKarmaBlipLo.ogg")
const SFX_VFXKarmaBlipMid = preload("res://Audio/Karma/VFXKarmaBlipMid.ogg")
const SFX_VFXKarmaBlipHi = preload("res://Audio/Karma/VFXKarmaBlipHi.ogg")

var dropletScaler = 0.0

func _SFX_Draw():
	$Draw.play()

func _SFX_HandOpen():
	$HandOpen.play()
	
func _SFX_HandClose():
	$HandClose.play()

func _SFX_HandCardHover():
	$HandCardHover.play()
	
func _SFX_Damage():
	$Damage.play()


func _SFX_PlacableHover():
	$PlacableHover.play();
	$PlacableHoverLoop.play();
	$PlacableHoverLoop/AnimationPlayer.play("Fade", 1, 10, false)
	
func _SFX_PlacableHoverStop():
	#$UIHoverLoop.stop();
	$PlacableHoverLoop/AnimationPlayer.play("Fade", 1, -4, true)

func _SFX_Blip(karmaValue):
	#var blipScale = clamp(remap(karmaValue, -4.0, 4.0, 0.8, 1.5), 0.8, 1.5)
	
	#$KarmaPlayerBlip.play()
	#$KarmaPlayerBlip.set_pitch_scale(blipScale)
	if karmaValue <0:
		$KarmaPlayerBlip.get_stream().set_stream(0, SFX_VFXKarmaBlipLo)
	elif karmaValue >0:
		$KarmaPlayerBlip.get_stream().set_stream(0, SFX_VFXKarmaBlipHi)
	else:
		$KarmaPlayerBlip.get_stream().set_stream(0, SFX_VFXKarmaBlipMid)
	$KarmaPlayerBlip.play()
	
	
	$KarmaPlayerDroplet.play()
	$KarmaPlayerDroplet.set_pitch_scale(0.5*sqrt(dropletScaler)+1)
	dropletScaler += 1
	

func _SFX_UIButtonHover():
	$UiButtonHover.play()


func _SFX_UIButtonPress():
	$UiButtonPress.play()
