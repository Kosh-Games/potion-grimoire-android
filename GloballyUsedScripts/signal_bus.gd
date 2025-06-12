class_name SignalBusTemplate
extends Node

# -- System Signals --
signal login_successful(user_id)
signal login_failed

# -- Gameplay Signals --
# Emitted when the server confirms a brew has started.
# Passes the item_id so the correct object can react.
signal brew_started(item_id, server_response)

# Emitted when a brew request fails at the server.
signal brew_failed(item_id, server_response)

# Emitted when the server confirms an item has been collected.
signal item_collected(item_id, server_response)

# Emitted when a collect request fails.
signal item_collect_failed(item_id, server_response)

# -- Data Loading Signals --
# Emitted after the NetworkManager gets a list of all static item types
signal item_types_received(item_data)

# Emitted when user owned ingredients recieved
signal ingredients_received(ingredient_data)
	
signal 
	
