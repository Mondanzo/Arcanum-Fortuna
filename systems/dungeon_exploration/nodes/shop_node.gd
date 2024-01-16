extends EventNode

func _trigger_event():
	var shop = event.instantiate() as ShopKeeper
	shop.seed = seed
	SceneHandler.add_shelf_element(shop)
	shop.setup(player.data)
	await shop.close_shop
