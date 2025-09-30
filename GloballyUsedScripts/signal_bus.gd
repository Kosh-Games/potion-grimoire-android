extends Node

# -- System Signals --
signal login_successful(new_user_id)
signal login_failed

### -- Gameplay Signals --

## Emitted when a brew request fails at the server.
signal brew_failed(item_id, server_response)

## Emitted when the server confirms an item has been collected.
signal potion_collected(item_id, server_response)

## Emitted when a collect request fails.
signal potion_collect_failed(item_id, server_response)

## Emitted when timer item changes state.
signal item_state_updated(item_data)

## Emitted when a potion/ingredient is claimed
signal item_collected(item_data)

## Emitted when item state info is requested
signal request_single_item_update(item_id)

### Gameplay Error Signals

## Emitted when there's an issue with the 
signal request_failed(response_code, body, metadata)

### -- Data Loading Signals --
## Emitted after the NetworkManager gets a list of all static item types
signal item_types_received(item_data)

## Emiited when user owned items are recieved
signal user_items_received(user_item_list)

## Emitted when the list on ingredients is received
signal ingredients_received(ingredients_list)

## Emitted when user owned ingredients recieved
signal user_ingredients_received(user_ingredient_data)

## Emitted when the list of the potions is received
signal potions_received(potions_list)

## Emiited when user owned potions recieved
signal user_potions_received(user_potions_data)

## Emitted when the list of the recipes is received
signal recipes_received(recipes_data)
	
## Emitted after checking if there's a need to update static data
## @experimental currently not in use, needs development or rethinking of the idea
signal server_data_version_changed(version_data)

## Signal to be emitted when an empty pot is tapped, ready for planting.
signal pot_selected_for_planting(pot_instance)	
