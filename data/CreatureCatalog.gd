class_name CreatureCatalog
extends RefCounted
## Static catalog of all creature species. Each element has 5 themed species.

const ENTRIES: Array = [
# --- NORMAL ---
{"id": "normal_pup", "name": "Puffpup", "element": "normal", "description": "A bouncy puppy that chases its own tail like it owes rent.", "hp": 24, "attack": 11, "defense": 10, "speed": 15, "scan_resistance": 0.34, "tint": "c9b89a"},
{"id": "normal_raccoon", "name": "Snackoon", "element": "normal", "description": "It raids picnic baskets and politely leaves napkins behind.", "hp": 22, "attack": 13, "defense": 9, "speed": 16, "scan_resistance": 0.38, "tint": "8f8a82"},
{"id": "normal_bot", "name": "Bumblebot", "element": "normal", "description": "A wind-up helper robot that beeps whenever it feels important.", "hp": 28, "attack": 10, "defense": 16, "speed": 7, "scan_resistance": 0.52, "tint": "b7bcc2"},
{"id": "normal_goat", "name": "Nibbilly", "element": "normal", "description": "This tiny goat can chew through homework with heroic focus.", "hp": 26, "attack": 14, "defense": 12, "speed": 10, "scan_resistance": 0.42, "tint": "d2c6ad"},
{"id": "normal_ferret", "name": "Zipslink", "element": "normal", "description": "A noodle-shaped ferret that turns every hallway into a racetrack.", "hp": 20, "attack": 12, "defense": 8, "speed": 18, "scan_resistance": 0.36, "tint": "a99372"},

# --- FIRE ---
{"id": "fire_mole", "name": "Moltenose", "element": "fire", "description": "A flaming mole that tunnels by sneezing sparks into the dirt.", "hp": 25, "attack": 15, "defense": 12, "speed": 9, "scan_resistance": 0.46, "tint": "e85a24"},
{"id": "fire_lizard", "name": "Sizzlizard", "element": "fire", "description": "It sunbathes on hot stones until its tail becomes a torch.", "hp": 22, "attack": 14, "defense": 9, "speed": 16, "scan_resistance": 0.40, "tint": "f47a1f"},
{"id": "fire_boar", "name": "Emberboar", "element": "fire", "description": "This chunky boar snorts charcoal puffs when it gets excited.", "hp": 30, "attack": 16, "defense": 14, "speed": 6, "scan_resistance": 0.58, "tint": "c83a1d"},
{"id": "fire_moth", "name": "Flareflutter", "element": "fire", "description": "A glowing moth that draws tiny campfires in the night sky.", "hp": 19, "attack": 12, "defense": 8, "speed": 17, "scan_resistance": 0.35, "tint": "ff9b2f"},
{"id": "fire_turtle", "name": "Lavaback", "element": "fire", "description": "A sleepy turtle with a bubbling shell of friendly lava.", "hp": 32, "attack": 13, "defense": 18, "speed": 6, "scan_resistance": 0.66, "tint": "b82418"},

# --- WATER ---
{"id": "water_crane", "name": "Flowcrane", "element": "water", "description": "A graceful crane made of water that reshapes itself mid-dance.", "hp": 23, "attack": 12, "defense": 11, "speed": 17, "scan_resistance": 0.44, "tint": "3aa7e8"},
{"id": "water_otter", "name": "Bubblewhisk", "element": "water", "description": "It juggles bubbles on its nose and giggles when they pop.", "hp": 24, "attack": 11, "defense": 10, "speed": 16, "scan_resistance": 0.37, "tint": "42c6d9"},
{"id": "water_penguin", "name": "Frostwaddle", "element": "water", "description": "A chilly penguin that slides into battle on a self-made ice rink.", "hp": 27, "attack": 10, "defense": 15, "speed": 11, "scan_resistance": 0.50, "tint": "7ed6f7"},
{"id": "water_octopus", "name": "Inkuddle", "element": "water", "description": "This squishy octopus paints silly faces with magical sea ink.", "hp": 21, "attack": 13, "defense": 9, "speed": 14, "scan_resistance": 0.41, "tint": "256fc2"},
{"id": "water_whale", "name": "Spraybelly", "element": "water", "description": "A tiny whale that launches fountain blasts bigger than itself.", "hp": 32, "attack": 14, "defense": 16, "speed": 7, "scan_resistance": 0.64, "tint": "1f8ccf"},

# --- ELECTRIC ---
{"id": "electric_mouse", "name": "Joltcheeks", "element": "electric", "description": "A sparky mouse that powers toy trains by doing happy hops.", "hp": 20, "attack": 12, "defense": 8, "speed": 18, "scan_resistance": 0.36, "tint": "ffd83d"},
{"id": "electric_eel", "name": "Zapoodle", "element": "electric", "description": "This noodle eel ties itself into knots to charge lightning loops.", "hp": 23, "attack": 15, "defense": 9, "speed": 15, "scan_resistance": 0.43, "tint": "f6c700"},
{"id": "electric_ram", "name": "Voltram", "element": "electric", "description": "Its wool crackles like a storm cloud wearing a sweater.", "hp": 28, "attack": 14, "defense": 13, "speed": 10, "scan_resistance": 0.55, "tint": "ffe96a"},
{"id": "electric_drone", "name": "Buzzbyte", "element": "electric", "description": "A tiny drone that sends cheerful lightning emojis through the air.", "hp": 18, "attack": 13, "defense": 8, "speed": 18, "scan_resistance": 0.39, "tint": "d6ff3f"},
{"id": "electric_beetle", "name": "Thunderclick", "element": "electric", "description": "It snaps its pincers to make thunderclaps that sound like applause.", "hp": 26, "attack": 16, "defense": 14, "speed": 9, "scan_resistance": 0.60, "tint": "f2b705"},

# --- EARTH ---
{"id": "earth_armadillo", "name": "Pebblillo", "element": "earth", "description": "A round armadillo that rolls downhill collecting souvenir rocks.", "hp": 29, "attack": 12, "defense": 17, "speed": 8, "scan_resistance": 0.57, "tint": "9b6b3d"},
{"id": "earth_scarab", "name": "Dunebug", "element": "earth", "description": "It rolls sand balls so perfectly that other bugs ask for lessons.", "hp": 22, "attack": 13, "defense": 12, "speed": 13, "scan_resistance": 0.42, "tint": "c28a45"},
{"id": "earth_golem", "name": "Chunklump", "element": "earth", "description": "A stubby golem that waves with both hands and causes small quakes.", "hp": 32, "attack": 15, "defense": 18, "speed": 6, "scan_resistance": 0.69, "tint": "7a5a3a"},
{"id": "earth_coyote", "name": "Dustyip", "element": "earth", "description": "This sandy coyote howls little dust devils into playful spirals.", "hp": 23, "attack": 14, "defense": 9, "speed": 16, "scan_resistance": 0.39, "tint": "b99062"},
{"id": "earth_tortoise", "name": "Bouldoze", "element": "earth", "description": "A patient tortoise that naps so hard moss grows on its shell.", "hp": 31, "attack": 10, "defense": 18, "speed": 6, "scan_resistance": 0.63, "tint": "8b734f"},

# --- PLANT ---
{"id": "plant_cactus", "name": "Cactooth", "element": "plant", "description": "A cactus creature with a prickly grin and a secret sweet tooth.", "hp": 24, "attack": 12, "defense": 15, "speed": 8, "scan_resistance": 0.45, "tint": "4fb24f"},
{"id": "plant_fox", "name": "Leaflick", "element": "plant", "description": "A leafy fox that camouflages by pretending to be a fancy shrub.", "hp": 21, "attack": 13, "defense": 9, "speed": 17, "scan_resistance": 0.38, "tint": "66c84f"},
{"id": "plant_frog", "name": "Budribbit", "element": "plant", "description": "It croaks tiny blossoms into bloom whenever it hiccups.", "hp": 25, "attack": 10, "defense": 12, "speed": 14, "scan_resistance": 0.40, "tint": "7bd957"},
{"id": "plant_deer", "name": "Petalprance", "element": "plant", "description": "A flowery deer that leaves confetti petals in every hoofprint.", "hp": 26, "attack": 11, "defense": 11, "speed": 16, "scan_resistance": 0.47, "tint": "8fd35a"},
{"id": "plant_snail", "name": "Mossnail", "element": "plant", "description": "This slow snail carries a miniature garden and several bug tenants.", "hp": 30, "attack": 9, "defense": 18, "speed": 6, "scan_resistance": 0.62, "tint": "3f8f3d"},

# --- LIGHT ---
{"id": "light_lamb", "name": "Glimmerwool", "element": "light", "description": "A radiant lamb whose fluffy fleece glows like bedtime moonlight.", "hp": 25, "attack": 10, "defense": 13, "speed": 12, "scan_resistance": 0.43, "tint": "fff4a8"},
{"id": "light_dove", "name": "Halohoo", "element": "light", "description": "It flutters down sunbeams and coos encouraging theme music.", "hp": 20, "attack": 11, "defense": 8, "speed": 18, "scan_resistance": 0.35, "tint": "fffbd1"},
{"id": "light_lion", "name": "Solmane", "element": "light", "description": "A brave lion cub with a mane bright enough to toast marshmallows.", "hp": 28, "attack": 16, "defense": 12, "speed": 11, "scan_resistance": 0.56, "tint": "ffd86f"},
{"id": "light_beetle", "name": "Lumenbug", "element": "light", "description": "This shiny beetle blinks secret patterns to lost travelers.", "hp": 22, "attack": 9, "defense": 15, "speed": 13, "scan_resistance": 0.48, "tint": "f5f0b8"},
{"id": "light_unicorn", "name": "Prismane", "element": "light", "description": "A tiny unicorn that sneezes rainbow sparkles when praised.", "hp": 24, "attack": 14, "defense": 10, "speed": 17, "scan_resistance": 0.51, "tint": "ffe6f5"},

# --- DARK ---
{"id": "dark_bat", "name": "Gloomflap", "element": "dark", "description": "A shy bat that hides in its own dramatic cape of shadows.", "hp": 21, "attack": 13, "defense": 8, "speed": 17, "scan_resistance": 0.40, "tint": "4b3a66"},
{"id": "dark_cat", "name": "Mischiefur", "element": "dark", "description": "This spooky cat steals socks and returns them as mysterious prophecies.", "hp": 23, "attack": 14, "defense": 9, "speed": 16, "scan_resistance": 0.44, "tint": "2f2f3a"},
{"id": "dark_mushroom", "name": "Shroomurk", "element": "dark", "description": "A giggling mushroom that pops from shadows to shout boo politely.", "hp": 27, "attack": 10, "defense": 16, "speed": 7, "scan_resistance": 0.59, "tint": "5c466f"},
{"id": "dark_wolf", "name": "Nightyip", "element": "dark", "description": "A moonlit wolf pup that trips over its own shadow paws.", "hp": 26, "attack": 16, "defense": 11, "speed": 14, "scan_resistance": 0.53, "tint": "3b2a4f"},
{"id": "dark_ghost", "name": "Boojumble", "element": "dark", "description": "This wobbly ghost tries to haunt people but mostly tells jokes.", "hp": 19, "attack": 12, "defense": 10, "speed": 18, "scan_resistance": 0.49, "tint": "6d5b7d"},

# --- ASTRO ---
{"id": "astro_bunny", "name": "Moonbun", "element": "astro", "description": "A cosmic bunny that hops between craters with stardust whiskers.", "hp": 22, "attack": 11, "defense": 9, "speed": 18, "scan_resistance": 0.42, "tint": "8b6cff"},
{"id": "astro_squid", "name": "Nebulurk", "element": "astro", "description": "This space squid stirs nebula soup with its twinkly tentacles.", "hp": 25, "attack": 14, "defense": 11, "speed": 13, "scan_resistance": 0.50, "tint": "6f4ed9"},
{"id": "astro_owl", "name": "Stargoggle", "element": "astro", "description": "A wide-eyed owl that reads constellations like bedtime comics.", "hp": 24, "attack": 12, "defense": 12, "speed": 15, "scan_resistance": 0.47, "tint": "4f5bd5"},
{"id": "astro_crab", "name": "Orbitclaw", "element": "astro", "description": "Its little moons orbit its shell and bonk foes on command.", "hp": 29, "attack": 15, "defense": 17, "speed": 8, "scan_resistance": 0.61, "tint": "5a3d9e"},
{"id": "astro_dragon", "name": "Cometmunch", "element": "astro", "description": "A baby dragon that snacks on comet crumbs and burps glitter trails.", "hp": 31, "attack": 18, "defense": 13, "speed": 10, "scan_resistance": 0.68, "tint": "9d4edd"}
]
