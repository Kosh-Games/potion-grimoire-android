extends Node

var user_id: String:
	set(new_id):
		if user_id != new_id:
			user_id = new_id
			# Emit a signal so other parts of the game can react to the login.
			SignalBus.emit_signal("login_successful", user_id)


# You can easily add more player-specific data here later.
var player_name: String
var gold: int = 0
