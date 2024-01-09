class_name CardsOverlay
extends CanvasLayer

static var __instance

static func is_available():
	if __instance:
		return __instance.visible
	return false

static func toggle(visible: bool):
	if __instance:
		__instance.visible = visible

func setup_player_data(data: PlayerData):
	$CardsOverview.player_data = data
	$CardsOverview.refresh()


func _ready():
	$CardsOverview.visible = false
	__instance = self


func _on_toggle_cards_overview_pressed():
	$CardsOverview.visible = not $CardsOverview.visible
	$ToggleCardsOverview.text = "hide\ndeck" if $CardsOverview.visible else "show\ndeck"
	if $CardsOverview.visible:
		$CardsOverview.refresh()
