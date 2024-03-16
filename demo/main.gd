extends Control

var scene_broadcast = preload("res://broadcast/main.tscn")
var scene_dashboard = preload("res://dashboard/main.tscn")

func _on_button_broadcast_pressed():
	get_node("/root/Main").queue_free()
	get_tree().root.add_child(scene_broadcast.instantiate())

func _on_button_dashboard_pressed():
	get_node("/root/Main").queue_free()
	get_tree().root.add_child(scene_dashboard.instantiate())
