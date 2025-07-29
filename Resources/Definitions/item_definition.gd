class_name ItemDefinition
extends Resource

## The unique ID from the server for this item type. This is the link.
@export var item_type_id: String

## The base scene to use (e.g., all cauldrons use Cauldron.tscn).
@export var scene: PackedScene

## The specific sprite for this variation.
@export var display_sprite: Texture2D

## A flexible dictionary for any other custom properties (e.g., animation names, sound effects, stat modifiers).
@export var custom_properties: Dictionary
