extends EventBase


func complete():
	queue_free()
	finished.emit()
