class_name Keyword
extends Resource

@export var title := "Keyword"
@export_multiline var description := "Gives your card an ability and stuff"
@export var icon : Texture
@export var highlight_duration := 1.0
var id : int

func init(id = 0):
	self.id = id

