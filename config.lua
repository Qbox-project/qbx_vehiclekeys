VehicleClasses = {
    Compacts = 0,
    Sedans = 1,
    SUVs = 2,
    Coupes = 3,
    Muscle = 4,
    Sports_Classics = 5,
    Sports = 6,
    Super = 7,
    Motorcycles = 8,
    Off_road = 9,
    Industrial = 10,
    Utility = 11,
    Vans = 12,
    Cycles = 13,
    Boats = 14,
    Helicopters = 15,
    Planes = 16,
    Service = 17,
    Emergency = 18,
    Military = 19,
    Commercial = 20,
    Trains = 21,
    Open_Wheel = 22,
}

WeaponTypeGroups = {
    Melee = 2685387236,
    Handgun = 416676503,
    SMG = -957766203,
    Shotgun = 860033945,
    Rifle = 970310034,
    LMG = 1159398588,
    Sniper = 3082541095,
    Heavy = 2725924767,
    Throwable = 1548507267,
    Misc = 4257178988,
}

Config = {
    debug = true, -- Set to true for development purposes only. Used for zones, and essential prints. Will be removed upon release

    vehicleMaximumLockingDistance = 5.0, -- Minimum distance for vehicle locking

    -- NPC Vehicle Lock States
    lockNPCDrivenCars = true, -- Lock state for NPC cars being driven by NPCs [true = locked, false = unlocked]
    lockNPCParkedCars = true, -- Lock state for NPC parked cars [true = locked, false = unlocked]

    -- Lockpick Settings
    removeNormalLockpickChance = { -- Chance to remove lockpick on fail by vehicle class
        [VehicleClasses.Compacts] = 0.5,
        [VehicleClasses.Sedans] = 0.5,
        [VehicleClasses.SUVs] = 0.5,
        [VehicleClasses.Coupes] = 0.5,
        [VehicleClasses.Muscle] = 0.5,
        [VehicleClasses.Sports_Classics] = 0.5,
        [VehicleClasses.Sports] = 0.5,
        [VehicleClasses.Super] = 0.5,
        [VehicleClasses.Motorcycles] = 0.5,
        [VehicleClasses.Off_road] = 0.5,
        [VehicleClasses.Industrial] = 0.5,
        [VehicleClasses.Utility] = 0.5,
        [VehicleClasses.Vans] = 0.5,
        [VehicleClasses.Cycles] = 0.5,
        [VehicleClasses.Boats] = 0.5,
        [VehicleClasses.Helicopters] = 0.5,
        [VehicleClasses.Planes] = 0.5,
        [VehicleClasses.Service] = 0.5,
        [VehicleClasses.Emergency] = 0.5,
        [VehicleClasses.Military] = 0.5,
        [VehicleClasses.Commercial] = 0.5,
        [VehicleClasses.Trains] = 0.5,
        [VehicleClasses.Open_Wheel] = 0.5
    },
    removeAdvancedLockpickChance = { -- Chance to remove advanced lockpick on fail by vehicle class
        [VehicleClasses.Compacts] = 0.5,
        [VehicleClasses.Sedans] = 0.5,
        [VehicleClasses.SUVs] = 0.5,
        [VehicleClasses.Coupes] = 0.5,
        [VehicleClasses.Muscle] = 0.5,
        [VehicleClasses.Sports_Classics] = 0.5,
        [VehicleClasses.Sports] = 0.5,
        [VehicleClasses.Super] = 0.5,
        [VehicleClasses.Motorcycles] = 0.5,
        [VehicleClasses.Off_road] = 0.5,
        [VehicleClasses.Industrial] = 0.5,
        [VehicleClasses.Utility] = 0.5,
        [VehicleClasses.Vans] = 0.5,
        [VehicleClasses.Cycles] = 0.5,
        [VehicleClasses.Boats] = 0.5,
        [VehicleClasses.Helicopters] = 0.5,
        [VehicleClasses.Planes] = 0.5,
        [VehicleClasses.Service] = 0.5,
        [VehicleClasses.Emergency] = 0.5,
        [VehicleClasses.Military] = 0.5,
        [VehicleClasses.Commercial] = 0.5,
        [VehicleClasses.Trains] = 0.5,
        [VehicleClasses.Open_Wheel] = 0.5
    },

    -- Carjack Settings
    carjackEnable = true, -- Enables the ability to carjack pedestrian vehicles, stealing them by pointing a weapon at them
    carjackingTimeInMs = 7500, -- Time it takes to successfully carjack in miliseconds
    delayBetweenCarjackingsInMs = 10000, -- Time before you can attempt another carjack in miliseconds
    carjackChance = { -- Probability of successful carjacking based on weapon used
        [WeaponTypeGroups.Melee] = 0.0, -- melee
        [WeaponTypeGroups.Handgun] = 0.5, -- handguns
        [WeaponTypeGroups.SMG] = 0.75, -- SMG
        [WeaponTypeGroups.Shotgun] = 0.90, -- shotgun
        [WeaponTypeGroups.Rifle] = 0.90, -- assault
        [WeaponTypeGroups.LMG] = 0.99, -- LMG
        [WeaponTypeGroups.Sniper] = 0.99, -- sniper
        [WeaponTypeGroups.Heavy] = 0.99, -- heavy
        [WeaponTypeGroups.Throwable] = 0.0, -- throwable
        [WeaponTypeGroups.Misc] = 0.0, -- misc
    },

    -- Hotwire Settings
    hotwireChance = { -- Chance for a successful hotwire by vehicle Class
        [VehicleClasses.Compacts] = 0.5,
        [VehicleClasses.Sedans] = 0.5,
        [VehicleClasses.SUVs] = 0.5,
        [VehicleClasses.Coupes] = 0.5,
        [VehicleClasses.Muscle] = 0.5,
        [VehicleClasses.Sports_Classics] = 0.5,
        [VehicleClasses.Sports] = 0.5,
        [VehicleClasses.Super] = 0.5,
        [VehicleClasses.Motorcycles] = 0.5,
        [VehicleClasses.Off_road] = 0.5,
        [VehicleClasses.Industrial] = 0.5,
        [VehicleClasses.Utility] = 0.5,
        [VehicleClasses.Vans] = 0.5,
        [VehicleClasses.Cycles] = 0.5,
        [VehicleClasses.Boats] = 0.5,
        [VehicleClasses.Helicopters] = 0.5,
        [VehicleClasses.Planes] = 0.5,
        [VehicleClasses.Service] = 0.5,
        [VehicleClasses.Emergency] = 0.5,
        [VehicleClasses.Military] = 0.5,
        [VehicleClasses.Commercial] = 0.5,
        [VehicleClasses.Trains] = 0.5,
        [VehicleClasses.Open_Wheel] = 0.5
    },
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
