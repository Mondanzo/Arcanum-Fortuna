extends EventNode

func _trigger_event():
	var shop = event.instantiate() as ShopKeeper
	add_child(shop)
	shop.setup(player.data)
	await shop.close_shop
