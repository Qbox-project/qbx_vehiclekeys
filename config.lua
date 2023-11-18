Config = {
    debug = true, -- Set to true for development purposes only. Used for zones, and essential prints. Will be removed upon release

    vehicleMaximumLockingDistance = 5.0, -- Minimum distance for vehicle locking

    -- NPC Vehicle Lock States
    lockNPCDrivenCars = true, -- Lock state for NPC cars being driven by NPCs [true = locked, false = unlocked]
    lockNPCParkedCars = true, -- Lock state for NPC parked cars [true = locked, false = unlocked]

    -- Lockpick Settings
    removeNormalLockpickChance = { -- Chance to remove lockpick on fail by vehicle class
        [0] = 0.5, -- Compacts
        [1] = 0.5, -- Sedans
        [2] = 0.5, -- SUVs
        [3] = 0.5, -- Coupes
        [4] = 0.5, -- Muscle
        [5] = 0.5, -- Sports Classics
        [6] = 0.5, -- Sports
        [7] = 0.5, -- Super
        [8] = 0.5, -- Motorcycles
        [9] = 0.5, -- Off-road
        [10] = 0.5, -- Industrial
        [11] = 0.5, -- Utility
        [12] = 0.5, -- Vans
        [13] = 0.5, -- Cycles
        [14] = 0.5, -- Boats
        [15] = 0.5, -- Helicopters
        [16] = 0.5, -- Planes
        [17] = 0.5, -- Service
        [18] = 0.5, -- Emergency
        [19] = 0.5, -- Military
        [20] = 0.5, -- Commercial
        [21] = 0.5, -- Trains
        [22] = 0.5, -- Open Wheel
    },
    removeAdvancedLockpickChance = { -- Chance to remove advanced lockpick on fail by vehicle class
        [0] = 0.5, -- Compacts
        [1] = 0.5, -- Sedans
        [2] = 0.5, -- SUVs
        [3] = 0.5, -- Coupes
        [4] = 0.5, -- Muscle
        [5] = 0.5, -- Sports Classics
        [6] = 0.5, -- Sports
        [7] = 0.5, -- Super
        [8] = 0.5, -- Motorcycles
        [9] = 0.5, -- Off-road
        [10] = 0.5, -- Industrial
        [11] = 0.5, -- Utility
        [12] = 0.5, -- Vans
        [13] = 0.5, -- Cycles
        [14] = 0.5, -- Boats
        [15] = 0.5, -- Helicopters
        [16] = 0.5, -- Planes
        [17] = 0.5, -- Service
        [18] = 0.5, -- Emergency
        [19] = 0.5, -- Military
        [20] = 0.5, -- Commercial
        [21] = 0.5, -- Trains
        [22] = 0.5, -- Open Wheel
    },

    -- Carjack Settings
    carjackEnable = true, -- Enables the ability to carjack pedestrian vehicles, stealing them by pointing a weapon at them
    carjackingTimeInMs = 7500, -- Time it takes to successfully carjack in miliseconds
    delayBetweenCarjackingsInMs = 10000, -- Time before you can attempt another carjack in miliseconds
    carjackChance = { -- Probability of successful carjacking based on weapon used
        [2685387236] = 0.0, -- melee
        [416676503] = 0.5, -- handguns
        [-957766203] = 0.75, -- SMG
        [860033945] = 0.90, -- shotgun
        [970310034] = 0.90, -- assault
        [1159398588] = 0.99, -- LMG
        [3082541095] = 0.99, -- sniper
        [2725924767] = 0.99, -- heavy
        [1548507267] = 0.0, -- throwable
        [4257178988] = 0.0, -- misc
        -- Add more weapon IDs and probabilities as needed
    },

    -- Hotwire Settings
    hotwireChance = {
        [0] = 0.5, -- Compacts
        [1] = 0.5, -- Sedans
        [2] = 0.5, -- SUVs
        [3] = 0.5, -- Coupes
        [4] = 0.5, -- Muscle
        [5] = 0.5, -- Sports Classics
        [6] = 0.5, -- Sports
        [7] = 0.5, -- Super
        [8] = 0.5, -- Motorcycles
        [9] = 0.5, -- Off-road
        [10] = 0.5, -- Industrial
        [11] = 0.5, -- Utility
        [12] = 0.5, -- Vans
        [13] = 0.5, -- Cycles
        [14] = 0.5, -- Boats
        [15] = 0.5, -- Helicopters
        [16] = 0.5, -- Planes
        [17] = 0.5, -- Service
        [18] = 0.5, -- Emergency
        [19] = 0.5, -- Military
        [20] = 0.5, -- Commercial
        [21] = 0.5, -- Trains
        [22] = 0.5, -- Open Wheel
    }, -- Chance for a successful hotwire by vehicle Class
    timeBetweenHotwires = 5000, -- Time in milliseconds between hotwire attempts
    minHotwireTime = 20000, -- Minimum hotwire time in milliseconds
    maxHotwireTime = 40000, -- Maximum hotwire time in milliseconds

    -- Police Alert Settings
    alertCooldown = 10000, -- Cooldown period in milliseconds (10 seconds)
    policeAlertChance = 0.75, -- Chance of alerting the police during the day
    policeNightAlertChance = 0.50, -- Chance of alerting the police at night (times: 01-06)

    -- Job Settings
    sharedKeys = { -- Share keys amongst employees. Employees can lock/unlock any job-listed vehicle
        ['police'] = { -- Job name
            requireOnduty = false,
            vehicles = {
                'police', -- Vehicle model
                'police2', -- Vehicle model
            }
        },
        ['mechanic'] = {
            requireOnduty = false,
            vehicles = {
                'towtruck',
            }
        }
    },

    -- Vehicles that cannot be jacked
    immuneVehicles = {
        'stockade'
    },

    -- Vehicles that will never lock
    noLockVehicles = {

    },

    -- Weapons that cannot be used for carjacking
    noCarjackWeapons = {
        "WEAPON_UNARMED",
        "WEAPON_KNIFE",
        "WEAPON_NIGHTSTICK",
        "WEAPON_HAMMER",
        "WEAPON_BAT",
        "WEAPON_CROWBAR",
        "WEAPON_GOLFCLUB",
        "WEAPON_BOTTLE",
        "WEAPON_DAGGER",
        "WEAPON_HATCHET",
        "WEAPON_KNUCKLE",
        "WEAPON_MACHETE",
        "WEAPON_FLASHLIGHT",
        "WEAPON_SWITCHBLADE",
        "WEAPON_POOLCUE",
        "WEAPON_WRENCH",
        "WEAPON_BATTLEAXE",
        "WEAPON_GRENADE",
        "WEAPON_STOCKYBOMB",
        "WEAPON_PROXIMITYMINE",
        "WEAPON_BZGAS",
        "WEAPON_MOLOTOV",
        "WEAPON_FIREEXTINGUISHER",
        "WEAPON_PETROLCAN",
        "WEAPON_FLARE",
        "WEAPON_BALL",
        "WEAPON_SNOWBALL",
        "WEAPON_SMOKEGRENADE",
        -- Add more weapon names as needed
    }
}
