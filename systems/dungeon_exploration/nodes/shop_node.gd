extends EventNode

func _trigger_event():
	var shop = event.instantiate() as ShopKeeper
	shop.seed = seed
	get_tree().root.add_child(shop)
	shop.setup(player.data)
	await shop.close_shop
