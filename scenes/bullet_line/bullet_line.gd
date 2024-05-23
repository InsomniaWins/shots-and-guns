extends Line2D

func _process(delta):
	
	points[0] = points[0].lerp(points[1], delta * 8)
	
	modulate.a = max(0.0, modulate.a - delta * 7)
	
	if modulate.a <= 0.0:
		queue_free()
	
	

