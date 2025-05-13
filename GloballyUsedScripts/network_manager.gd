class_name NetworkManager
extends Node

var _queued_potions: Array[Dictionary]

func add_potion_to_queue(potion_data: Dictionary):
	_queued_potions.append(potion_data)