--- placeholder. Not yet implemented

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
    vehicleMaximumLockingDistance = 5.0, -- Minimum distance for vehicle locking

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

    advancedLockpickVehicleClasses = { -- The vehicle classes can only be opened with an advanced lockpick
        [VehicleClasses.HELICOPTERS] = true,
        [VehicleClasses.MILITARY] = true
    },

    -- Carjack Settings
    carjackEnable = true,                -- Enables the ability to carjack pedestrian vehicles, stealing them by pointing a weapon at them
    carjackingTimeInMs = 7500,           -- Time it takes to successfully carjack in miliseconds
    delayBetweenCarjackingsInMs = 10000, -- Time before you can attempt another carjack in miliseconds
    carjackChance = {                    -- Probability of successful carjacking based on weapon used
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

    -- Hotwire Settings
    findKeysChance = { -- Chance for a successful hotwire by vehicle Class
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
    timeBetweenHotwires = 5000, -- Time in milliseconds between hotwire attempts
    minKeysSearchTime = 20000,  -- Minimum hotwire time in milliseconds
    maxKeysSearchTime = 40000,  -- Maximum hotwire time in milliseconds

    -- Police Alert Settings
    alertCooldown = 10000,         -- Cooldown period in milliseconds (10 seconds)
    policeAlertChance = 0.75,      -- Chance of alerting the police during the day
    policeNightAlertChance = 0.50, -- Chance of alerting the police at night (times: 01-06)

    vehicleAlarmDuration = 10000,
    lockpickCooldown = 1000,
    searchKeysCooldown = 1000,

    -- Job Settings
    sharedKeys = { -- Share keys amongst employees. Employees can lock/unlock any job-listed vehicle
        police = { -- Job name
            requireOnduty = false,
            vehicles = {
                [`police`] = true,  -- Vehicle model
                [`police2`] = true, -- Vehicle model
            }
        },
        mechanic = {
            requireOnduty = false,
            vehicles = {
                [`towtruck`] = true,
            }
        }
    },

    sharedVehicleClasses = {
        [VehicleClasses.CYCLES] = true
    }
}
