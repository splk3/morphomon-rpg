class_name ElementType
extends Resource
## Defines one of the game's elemental affinities.
##
## There are 8 true elements (fire, water, electric, earth, plant, light, dark,
## astro) plus the element-less "normal" type. Each town/school specializes in
## one element; the player's hometown school specializes in "normal".

@export var id: StringName = &"normal"
@export var display_name: String = "Normal"
## Primary theme color used for UI accents, town palettes and creature tinting.
@export var color: Color = Color.WHITE
## Short flavor description shown in the Morphopedia.
@export var description: String = ""
