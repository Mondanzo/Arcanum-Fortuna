class_name TooltipBasic extends TooltipBase

func setup(title: String, texture: Texture2D, text: String):
	if texture == null:
		%"TooltipIcon".visible = false
	else:
		%"TooltipIcon".texture = texture
	%"TooltipTitle".text = title
	%"TooltipText".text = text
