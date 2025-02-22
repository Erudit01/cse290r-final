func _on_area_entered(area: Area2D) -> void:
	if area.name == "JabHitBox":
		if area.owner.has_method("take_damage"):
			area.owner.take_damage(area.damage)
