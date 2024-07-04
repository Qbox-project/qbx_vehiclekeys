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

EasyLockpickSkillCheck = { { 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' }, { '1', '2', '3' } }
NormalLockpickSkillCheck = { { 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' }, { '1', '2', '3', '4' } }
HardLockpickSkillCheck = { { 'easy', 'easy', { areaSize = 60, speedMultiplier = 2 }, 'medium' }, { '1', '2', '3', '4' } }

return {
    vehicleMaximumLockingDistance = 5.0, -- Minimum distance for vehicle locking

    -- Lockpick Settings
    isSharedVehicleAutolock = true,

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
    policeAlertNightStartHour = 1,
    policeAlertNightDuration = 5,

    vehicleAlarmDuration = 10000,
    lockpickCooldown = 1000,
    hotwireCooldown = 1000,

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
    },

    skillCheck = {
        lockpick = {
            default = NormalLockpickSkillCheck,
            class = {
                [VehicleClasses.COMPACTS]        = NormalLockpickSkillCheck,
                [VehicleClasses.SEDANS]          = NormalLockpickSkillCheck,
                [VehicleClasses.SUVS]            = NormalLockpickSkillCheck,
                [VehicleClasses.COUPES]          = NormalLockpickSkillCheck,
                [VehicleClasses.COMPACTS]        = NormalLockpickSkillCheck,
                [VehicleClasses.SEDANS]          = NormalLockpickSkillCheck,
                [VehicleClasses.SUVS]            = NormalLockpickSkillCheck,
                [VehicleClasses.COUPES]          = NormalLockpickSkillCheck,
                [VehicleClasses.MUSCLE]          = NormalLockpickSkillCheck,
                [VehicleClasses.SPORTS_CLASSICS] = NormalLockpickSkillCheck,
                [VehicleClasses.SPORTS]          = NormalLockpickSkillCheck,
                [VehicleClasses.SUPER]           = NormalLockpickSkillCheck,
                [VehicleClasses.MOTORCYCLES]     = NormalLockpickSkillCheck,
                [VehicleClasses.OFF_ROAD]        = NormalLockpickSkillCheck,
                [VehicleClasses.INDUSTRIAL]      = NormalLockpickSkillCheck,
                [VehicleClasses.UTILITY]         = NormalLockpickSkillCheck,
                [VehicleClasses.VANS]            = NormalLockpickSkillCheck,
                [VehicleClasses.BOATS]           = NormalLockpickSkillCheck,
                [VehicleClasses.HELICOPTERS]     = {},
                [VehicleClasses.PLANES]          = NormalLockpickSkillCheck,
                [VehicleClasses.SERVICE]         = NormalLockpickSkillCheck,
                [VehicleClasses.EMERGENCY]       = HardLockpickSkillCheck,
                [VehicleClasses.MILITARY]        = {},                          -- The vehicle class can only be opened with an advanced lockpick
                [VehicleClasses.COMMERCIAL]      = NormalLockpickSkillCheck,
                [VehicleClasses.TRAINS]          = {},
                [VehicleClasses.OPEN_WHEEL]      = EasyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = NormalLockpickSkillCheck
            }
        },
        advancedLockpick = {
            default = EasyLockpickSkillCheck,
            class = {
                [VehicleClasses.COMPACTS]        = EasyLockpickSkillCheck,
                [VehicleClasses.SEDANS]          = EasyLockpickSkillCheck,
                [VehicleClasses.SUVS]            = EasyLockpickSkillCheck,
                [VehicleClasses.COUPES]          = EasyLockpickSkillCheck,
                [VehicleClasses.MUSCLE]          = EasyLockpickSkillCheck,
                [VehicleClasses.SPORTS_CLASSICS] = EasyLockpickSkillCheck,
                [VehicleClasses.SPORTS]          = EasyLockpickSkillCheck,
                [VehicleClasses.SUPER]           = EasyLockpickSkillCheck,
                [VehicleClasses.MOTORCYCLES]     = EasyLockpickSkillCheck,
                [VehicleClasses.OFF_ROAD]        = EasyLockpickSkillCheck,
                [VehicleClasses.INDUSTRIAL]      = EasyLockpickSkillCheck,
                [VehicleClasses.UTILITY]         = EasyLockpickSkillCheck,
                [VehicleClasses.VANS]            = EasyLockpickSkillCheck,
                [VehicleClasses.BOATS]           = EasyLockpickSkillCheck,
                [VehicleClasses.HELICOPTERS]     = HardLockpickSkillCheck,
                [VehicleClasses.PLANES]          = HardLockpickSkillCheck,
                [VehicleClasses.SERVICE]         = EasyLockpickSkillCheck,
                [VehicleClasses.EMERGENCY]       = EasyLockpickSkillCheck,
                [VehicleClasses.MILITARY]        = HardLockpickSkillCheck,
                [VehicleClasses.COMMERCIAL]      = EasyLockpickSkillCheck,
                [VehicleClasses.TRAINS]          = {},                         -- The vehicle class can't be opened with an lockpick
                [VehicleClasses.OPEN_WHEEL]      = EasyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = EasyLockpickSkillCheck
            }
        },
        hotwire = {
            default = NormalLockpickSkillCheck,
            class = {
                [VehicleClasses.COMPACTS]        = NormalLockpickSkillCheck,
                [VehicleClasses.SEDANS]          = NormalLockpickSkillCheck,
                [VehicleClasses.SUVS]            = NormalLockpickSkillCheck,
                [VehicleClasses.COUPES]          = NormalLockpickSkillCheck,
                [VehicleClasses.COMPACTS]        = NormalLockpickSkillCheck,
                [VehicleClasses.SEDANS]          = NormalLockpickSkillCheck,
                [VehicleClasses.SUVS]            = NormalLockpickSkillCheck,
                [VehicleClasses.COUPES]          = NormalLockpickSkillCheck,
                [VehicleClasses.MUSCLE]          = NormalLockpickSkillCheck,
                [VehicleClasses.SPORTS_CLASSICS] = NormalLockpickSkillCheck,
                [VehicleClasses.SPORTS]          = NormalLockpickSkillCheck,
                [VehicleClasses.SUPER]           = NormalLockpickSkillCheck,
                [VehicleClasses.MOTORCYCLES]     = NormalLockpickSkillCheck,
                [VehicleClasses.OFF_ROAD]        = NormalLockpickSkillCheck,
                [VehicleClasses.INDUSTRIAL]      = NormalLockpickSkillCheck,
                [VehicleClasses.UTILITY]         = NormalLockpickSkillCheck,
                [VehicleClasses.VANS]            = NormalLockpickSkillCheck,
                [VehicleClasses.BOATS]           = NormalLockpickSkillCheck,
                [VehicleClasses.HELICOPTERS]     = {},
                [VehicleClasses.PLANES]          = NormalLockpickSkillCheck,
                [VehicleClasses.SERVICE]         = NormalLockpickSkillCheck,
                [VehicleClasses.EMERGENCY]       = HardLockpickSkillCheck,
                [VehicleClasses.MILITARY]        = {},
                [VehicleClasses.COMMERCIAL]      = NormalLockpickSkillCheck,
                [VehicleClasses.TRAINS]          = {},
                [VehicleClasses.OPEN_WHEEL]      = EasyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = NormalLockpickSkillCheck
            }
        },
        advancedHotwire = {
            default = EasyLockpickSkillCheck,
            class = {
                [VehicleClasses.COMPACTS]        = EasyLockpickSkillCheck,
                [VehicleClasses.SEDANS]          = EasyLockpickSkillCheck,
                [VehicleClasses.SUVS]            = EasyLockpickSkillCheck,
                [VehicleClasses.COUPES]          = EasyLockpickSkillCheck,
                [VehicleClasses.MUSCLE]          = EasyLockpickSkillCheck,
                [VehicleClasses.SPORTS_CLASSICS] = EasyLockpickSkillCheck,
                [VehicleClasses.SPORTS]          = EasyLockpickSkillCheck,
                [VehicleClasses.SUPER]           = EasyLockpickSkillCheck,
                [VehicleClasses.MOTORCYCLES]     = EasyLockpickSkillCheck,
                [VehicleClasses.OFF_ROAD]        = EasyLockpickSkillCheck,
                [VehicleClasses.INDUSTRIAL]      = EasyLockpickSkillCheck,
                [VehicleClasses.UTILITY]         = EasyLockpickSkillCheck,
                [VehicleClasses.VANS]            = EasyLockpickSkillCheck,
                [VehicleClasses.BOATS]           = EasyLockpickSkillCheck,
                [VehicleClasses.HELICOPTERS]     = HardLockpickSkillCheck,
                [VehicleClasses.PLANES]          = HardLockpickSkillCheck,
                [VehicleClasses.SERVICE]         = EasyLockpickSkillCheck,
                [VehicleClasses.EMERGENCY]       = EasyLockpickSkillCheck,
                [VehicleClasses.MILITARY]        = HardLockpickSkillCheck,
                [VehicleClasses.COMMERCIAL]      = EasyLockpickSkillCheck,
                [VehicleClasses.TRAINS]          = {},                         -- The vehicle class can't be hotwired
                [VehicleClasses.OPEN_WHEEL]      = EasyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = EasyLockpickSkillCheck
            }
        }
    }
}
