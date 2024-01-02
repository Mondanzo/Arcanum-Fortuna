class_name Flip
extends ActivatedKeyword

func init(id = 2):
	super.init(id)


func trigger(source, target, params={}):
	if not target.has_method("flip"):
		push_error("Keyword Flip was triggered from ", source, \
		", but target '", target, "' has no flip method!")
		return
	target.flip()
