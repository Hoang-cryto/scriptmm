getgenv().Config = {
    ["Harvest"] = {
        ["Enable"] = true,
        ["Rarity"] = "All",--All or Common, Uncommon, Rare, Epic, Legendary, Mythic, Super, Secret
        ["Filter"] = {"All"},--All or Carrot, Strawberry, Blueberry, Tulip, Tomato, Apple, Bamboo, Corn, Cactus, Pineapple, Mushroom, Green Bean, Banana, Grape, Coconut, Mango, Dragon Fruit, Acorn,Cherry, Sunflower, Venus Fly Trap, Pomegranate, Poison Apple, Moon Bloom, Dragon's Breath, Ghost Pepper, Poison Ivy, Baby Cactus, Glow Mushroom, Romanesco, Horned Melon    
        ["Ignore Mutations"] = {},
        ["Pause"] = false,
        ["Pause Events"] = {},
    },
    ["Sell"] = {
        ["Enable"] = true,
        ["When Full"] = true,
    },
    ["Seed"] = {
        ["Auto Collect"] = true,
    },
    ["Seed Pack"] = {
        ["Auto Pick"] = true,
    },
    ["Steal"] = {
        ["Enable"] = false,
        ["Blacklist"] = {},--Carrot, Strawberry, Blueberry, Tulip, Tomato, Apple, Bamboo, Corn, Cactus, Pineapple, Mushroom, Green Bean, Banana, Grape, Coconut, Mango, Dragon Fruit, Acorn,Cherry, Sunflower, Venus Fly Trap, Pomegranate, Poison Apple, Moon Bloom, Dragon's Breath, Ghost Pepper, Poison Ivy, Baby Cactus, Glow Mushroom, Romanesco, Horned Melon    
    },
    ["Anti Steal"] = {
        ["Enable"] = false,
    },
    ["Plant"] = {
        ["Enable"] = true,
        ["Mode"] = "Random In Plot",--Random In Plot, Under Player, Row
        ["Seed Mode"] = "All Seed",--All Seed, Equipped Only
    },
    ["Buy"] = {
    ["Seed"] = {
        ["Enable"] = true,
        ["List"] = {
            ["Carrot"] = true,
            ["Strawberry"] = true,
            ["Blueberry"] = true,
            ["Tulip"] = true,
            ["Tomato"] = true,
            ["Apple"] = true,
            ["Bamboo"] = true,
            ["Corn"] = true,
            ["Cactus"] = true,
            ["Pineapple"] = true,
            ["Mushroom"] = true,
            ["Green Bean"] = true,
            ["Banana"] = true,
            ["Grape"] = true,
            ["Coconut"] = true,
            ["Mango"] = true,
            ["Dragon Fruit"] = true,
            ["Acorn"] = true,
            ["Cherry"] = true,
            ["Sunflower"] = true,
            ["Venus Fly Trap"] = true,
            ["Pomegranate"] = true,
            ["Poison Apple"] = true,
            ["Moon Bloom"] = true,
            ["Dragon's Breath"] = true,
            ["Ghost Pepper"] = true,
            ["Poison Ivy"] = true,
            ["Baby Cactus"] = true,
            ["Glow Mushroom"] = true,
            ["Romanesco"] = true,
            ["Horned Melon"] = true,
        },
    },
        ["Pet"] = {
            ["Enable"] = false,
            ["List"] = {"IceSerpent","Raccoon","Unicorn","GoldenDragonfly","BlackDragon","Monkey","Bee","Robin"},
        },
        ["Gear"] = {
            ["Enable"] = false,
            ["List"] = {"Common Watering Can","Common Sprinkler","Uncommon Sprinkler","Rare Sprinkler","Legendary Sprinkler","Super Watering Can","Super Sprinkler"},
        },
    },
    ["Shovel"] = {
        ["Enable"] = false,
        ["Rarity"] = "All",
    },
    ["Stand Center"] = {
        ["Enable"] = true,
        ["Height"] = 3,
        ["Interval"] = 2,
    },
    ["Max Plant Fruit"] = 200,
    ["Buy Expand Plot"] = false,
    ["Buy Slot Pet"] = false,
    ["Movement"] = {
        ["Tween Speed"] = 300,
        ["Move Mode"] = "Tween",
    },
    ["Settings"] = {
        ["Anti AFK"] = true,
        ["Plant Delay"] = 0.3,
        ["Harvest Delay"] = 0.1,
        ["Sell Delay"] = 0.2,
        ["Shovel Delay"] = 0.1,
    },
    ["Webhook"] = {
        ["Enable"] = false,
        ["URL"] = "",
        ["Username"] = "Gravity Hub",
    },
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-GravityHub/GrowAGarden2/refs/heads/main/Kaitun.lua"))()