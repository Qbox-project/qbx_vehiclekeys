VehicleClasses = {
    COMPACTS = 0,
    SEDANS = 1,
    SUVS = 2,
    COUPES = 3,
    MUSCLE = 4,
    SPORTS_CLASSICS = 5,
    SPORTS = 6,
    SUPER = 7,
    MOTORCYCLES = 8,
    OFF_ROAD = 9,
    INDUSTRIAL = 10,
    UTILITY = 11,
    VANS = 12,
    CYCLES = 13,
    BOATS = 14,
    HELICOPTERS = 15,
    PLANES = 16,
    SERVICE = 17,
    EMERGENCY = 18,
    MILITARY = 19,
    COMMERCIAL = 20,
    TRAINS = 21,
    OPEN_WHEEL = 22,
}

WeaponTypeGroups = {
    MELEE = 2685387236,
    HANDGUN = 416676503,
    SMG = -957766203,
    SHOTGUN = 860033945,
    RIFLE = 970310034,
    LMG = 1159398588,
    SNIPER = 3082541095,
    HEAVY = 2725924767,
    THROWABLE = 1548507267,
    MISC = 4257178988,
}

return {
    -- NPC Vehicle Lock States
    lockNPCDrivingCars = true, -- Lock state for NPC cars being driven by NPCs [true = locked, false = unlocked]
    lockNPCParkedCars = true, -- Lock state for NPC parked cars [true = locked, false = unlocked]

        -- Lockpick Settings
    removeNormalLockpickChance = { -- Chance to remove lockpick on fail by vehicle class
        [VehicleClasses.COMPACTS] = 0.5,
        [VehicleClasses.SEDANS] = 0.5,
        [VehicleClasses.SUVS] = 0.5,
        [VehicleClasses.COUPES] = 0.5,
        [VehicleClasses.MUSCLE] = 0.5,
        [VehicleClasses.SPORTS_CLASSICS] = 0.5,
        [VehicleClasses.SPORTS] = 0.5,
        [VehicleClasses.SUPER] = 0.5,
        [VehicleClasses.MOTORCYCLES] = 0.5,
        [VehicleClasses.OFF_ROAD] = 0.5,
        [VehicleClasses.INDUSTRIAL] = 0.5,
        [VehicleClasses.UTILITY] = 0.5,
        [VehicleClasses.VANS] = 0.5,
        [VehicleClasses.CYCLES] = 0.5,
        [VehicleClasses.BOATS] = 0.5,
        [VehicleClasses.HELICOPTERS] = 0.5,
        [VehicleClasses.PLANES] = 0.5,
        [VehicleClasses.SERVICE] = 0.5,
        [VehicleClasses.EMERGENCY] = 0.5,
        [VehicleClasses.MILITARY] = 0.5,
        [VehicleClasses.COMMERCIAL] = 0.5,
        [VehicleClasses.TRAINS] = 0.5,
        [VehicleClasses.OPEN_WHEEL] = 0.5
    },
    removeAdvancedLockpickChance = { -- Chance to remove advanced lockpick on fail by vehicle class
        [VehicleClasses.COMPACTS] = 0.5,
        [VehicleClasses.SEDANS] = 0.5,
        [VehicleClasses.SUVS] = 0.5,
        [VehicleClasses.COUPES] = 0.5,
        [VehicleClasses.MUSCLE] = 0.5,
        [VehicleClasses.SPORTS_CLASSICS] = 0.5,
        [VehicleClasses.SPORTS] = 0.5,
        [VehicleClasses.SUPER] = 0.5,
        [VehicleClasses.MOTORCYCLES] = 0.5,
        [VehicleClasses.OFF_ROAD] = 0.5,
        [VehicleClasses.INDUSTRIAL] = 0.5,
        [VehicleClasses.UTILITY] = 0.5,
        [VehicleClasses.VANS] = 0.5,
        [VehicleClasses.CYCLES] = 0.5,
        [VehicleClasses.BOATS] = 0.5,
        [VehicleClasses.HELICOPTERS] = 0.5,
        [VehicleClasses.PLANES] = 0.5,
        [VehicleClasses.SERVICE] = 0.5,
        [VehicleClasses.EMERGENCY] = 0.5,
        [VehicleClasses.MILITARY] = 0.5,
        [VehicleClasses.COMMERCIAL] = 0.5,
        [VehicleClasses.TRAINS] = 0.5,
        [VehicleClasses.OPEN_WHEEL] = 0.5
    },
    -- Lockpick Settings
    removeLockpickNormal = 0.5, -- Chance to remove lockpick on fail
    removeLockpickAdvanced = 0.2, -- Chance to remove advanced lockpick on fail

    -- Carjack Settings
    carJackEnable = true, -- True allows for the ability to car jack peds.
    carjackingTime = 7500, -- How long it takes to carjack
    delayBetweenCarjackings = 10000, -- Time before you can carjack again
    carjackChance = { -- Probability of successful carjacking based on weapon used
        [WeaponTypeGroups.MELEE] = 0.0,
        [WeaponTypeGroups.HANDGUN] = 0.5,
        [WeaponTypeGroups.SMG] = 0.75,
        [WeaponTypeGroups.SHOTGUN] = 0.90,
        [WeaponTypeGroups.RIFLE] = 0.90,
        [WeaponTypeGroups.LMG] = 0.99,
        [WeaponTypeGroups.SNIPER] = 0.99,
        [WeaponTypeGroups.HEAVY] = 0.99,
        [WeaponTypeGroups.THROWABLE] = 0.0,
        [WeaponTypeGroups.MISC] = 0.0,
    },

    hotwireChance = { -- Chance for a successful hotwire by vehicle Class
        [VehicleClasses.COMPACTS] = 0.5,
        [VehicleClasses.SEDANS] = 0.5,
        [VehicleClasses.SUVS] = 0.5,
        [VehicleClasses.COUPES] = 0.5,
        [VehicleClasses.MUSCLE] = 0.5,
        [VehicleClasses.SPORTS_CLASSICS] = 0.5,
        [VehicleClasses.SPORTS] = 0.5,
        [VehicleClasses.SUPER] = 0.5,
        [VehicleClasses.MOTORCYCLES] = 0.5,
        [VehicleClasses.OFF_ROAD] = 0.5,
        [VehicleClasses.INDUSTRIAL] = 0.5,
        [VehicleClasses.UTILITY] = 0.5,
        [VehicleClasses.VANS] = 0.5,
        [VehicleClasses.CYCLES] = 0.5,
        [VehicleClasses.BOATS] = 0.5,
        [VehicleClasses.HELICOPTERS] = 0.5,
        [VehicleClasses.PLANES] = 0.5,
        [VehicleClasses.SERVICE] = 0.5,
        [VehicleClasses.EMERGENCY] = 0.5,
        [VehicleClasses.MILITARY] = 0.5,
        [VehicleClasses.COMMERCIAL] = 0.5,
        [VehicleClasses.TRAINS] = 0.5,
        [VehicleClasses.OPEN_WHEEL] = 0.5
    },

    -- Hotwire Settings
    timeBetweenHotwires = 5000, -- Time in ms between hotwire attempts
    minHotwireTime = 20000, -- Minimum hotwire time in ms
    maxHotwireTime = 40000, --  Maximum hotwire time in ms

    -- Police Alert Settings
    alertCooldown = 10000, -- 10 seconds
    policeAlertChance = 0.75, -- Chance of alerting police during the day
    policeNightAlertChance = 0.50, -- Chance of alerting police at night (times:01-06)
    
}