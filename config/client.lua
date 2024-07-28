--- placeholder. Not yet implemented

---@enum VehicleClass
local VehicleClass = {
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

---@enum WeaponTypeGroup
local WeaponTypeGroup = {
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

---@alias Difficulty 'easy' | 'medium' | 'hard' | {areaSize: number, speedMultiplier: number}

---Arguments of https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
---@class SkillCheckConfig
---@field difficulty Difficulty[]
---@field inputs? string[]

---@type SkillCheckConfig
local easyLockpickSkillCheck = {
    difficulty = { 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' },
    inputs = { '1', '2', '3' }
}

---@type SkillCheckConfig
local normalLockpickSkillCheck = {
    difficulty = { 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' },
    inputs = { '1', '2', '3', '4' }
}

---@type SkillCheckConfig
local hardLockpickSkillCheck = {
    difficulty = { 'easy', 'easy', { areaSize = 60, speedMultiplier = 2 }, 'medium' },
    inputs = { '1', '2', '3', '4' }
}

---@alias Anim {dict: string, clip: string}

---@type Anim
local defaultHotwireAnim = { dict = 'anim@veh@plane@howard@front@ds@base', clip = 'hotwire' }

---@type Anim
local defaultSearchKeysAnim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' }

---@type Anim
local defaultLockpickAnim = { dict = 'anim@mp_player_intmenu@key_fob@', clip = 'fob_click' }

---@type Anim
local defaultHoldupAnim = { dict = 'mp_am_hold_up', clip = 'holdup_victim_20s' }

return {
    vehicleMaximumLockingDistance = 5.0, -- Minimum distance for vehicle locking

    -- Lockpick Settings
    keepVehicleRunning = true,

    ---@type table<VehicleClass, number>
    removeNormalLockpickChance = { -- Chance to remove lockpick on fail by vehicle class
        [VehicleClass.COMPACTS] = 0.5,
        [VehicleClass.SEDANS] = 0.5,
        [VehicleClass.SUVS] = 0.5,
        [VehicleClass.COUPES] = 0.5,
        [VehicleClass.MUSCLE] = 0.5,
        [VehicleClass.SPORTS_CLASSICS] = 0.5,
        [VehicleClass.SPORTS] = 0.5,
        [VehicleClass.SUPER] = 0.5,
        [VehicleClass.MOTORCYCLES] = 0.5,
        [VehicleClass.OFF_ROAD] = 0.5,
        [VehicleClass.INDUSTRIAL] = 0.5,
        [VehicleClass.UTILITY] = 0.5,
        [VehicleClass.VANS] = 0.5,
        [VehicleClass.CYCLES] = 0.5,
        [VehicleClass.BOATS] = 0.5,
        [VehicleClass.HELICOPTERS] = 0.5,
        [VehicleClass.PLANES] = 0.5,
        [VehicleClass.SERVICE] = 0.5,
        [VehicleClass.EMERGENCY] = 0.5,
        [VehicleClass.MILITARY] = 0.5,
        [VehicleClass.COMMERCIAL] = 0.5,
        [VehicleClass.TRAINS] = 0.5,
        [VehicleClass.OPEN_WHEEL] = 0.5
    },

    ---@type table<VehicleClass, number>
    removeAdvancedLockpickChance = { -- Chance to remove advanced lockpick on fail by vehicle class
        [VehicleClass.COMPACTS] = 0.5,
        [VehicleClass.SEDANS] = 0.5,
        [VehicleClass.SUVS] = 0.5,
        [VehicleClass.COUPES] = 0.5,
        [VehicleClass.MUSCLE] = 0.5,
        [VehicleClass.SPORTS_CLASSICS] = 0.5,
        [VehicleClass.SPORTS] = 0.5,
        [VehicleClass.SUPER] = 0.5,
        [VehicleClass.MOTORCYCLES] = 0.5,
        [VehicleClass.OFF_ROAD] = 0.5,
        [VehicleClass.INDUSTRIAL] = 0.5,
        [VehicleClass.UTILITY] = 0.5,
        [VehicleClass.VANS] = 0.5,
        [VehicleClass.CYCLES] = 0.5,
        [VehicleClass.BOATS] = 0.5,
        [VehicleClass.HELICOPTERS] = 0.5,
        [VehicleClass.PLANES] = 0.5,
        [VehicleClass.SERVICE] = 0.5,
        [VehicleClass.EMERGENCY] = 0.5,
        [VehicleClass.MILITARY] = 0.5,
        [VehicleClass.COMMERCIAL] = 0.5,
        [VehicleClass.TRAINS] = 0.5,
        [VehicleClass.OPEN_WHEEL] = 0.5
    },

    -- Carjack Settings
    carjackEnable = true,                -- Enables the ability to carjack pedestrian vehicles, stealing them by pointing a weapon at them
    carjackingTimeInMs = 7500,           -- Time it takes to successfully carjack in miliseconds
    delayBetweenCarjackingsInMs = 10000, -- Time before you can attempt another carjack in miliseconds
    ---@type table<VehicleClass, number>
    carjackChance = {                    -- Probability of successful carjacking based on weapon used
        [WeaponTypeGroup.MELEE] = 0.0,
        [WeaponTypeGroup.HANDGUN] = 0.5,
        [WeaponTypeGroup.SMG] = 0.75,
        [WeaponTypeGroup.SHOTGUN] = 0.90,
        [WeaponTypeGroup.RIFLE] = 0.90,
        [WeaponTypeGroup.LMG] = 0.99,
        [WeaponTypeGroup.SNIPER] = 0.99,
        [WeaponTypeGroup.HEAVY] = 0.99,
        [WeaponTypeGroup.THROWABLE] = 0.0,
        [WeaponTypeGroup.MISC] = 0.0,
    },

    -- Hotwire Settings
    ---@type table<VehicleClass, number>
    findKeysChance = { -- Chance for a successful hotwire by vehicle Class
        [VehicleClass.COMPACTS] = 0.5,
        [VehicleClass.SEDANS] = 0.5,
        [VehicleClass.SUVS] = 0.5,
        [VehicleClass.COUPES] = 0.5,
        [VehicleClass.MUSCLE] = 0.5,
        [VehicleClass.SPORTS_CLASSICS] = 0.5,
        [VehicleClass.SPORTS] = 0.5,
        [VehicleClass.SUPER] = 0.5,
        [VehicleClass.MOTORCYCLES] = 0.5,
        [VehicleClass.OFF_ROAD] = 0.5,
        [VehicleClass.INDUSTRIAL] = 0.5,
        [VehicleClass.UTILITY] = 0.5,
        [VehicleClass.VANS] = 0.5,
        [VehicleClass.CYCLES] = 0.5,
        [VehicleClass.BOATS] = 0.5,
        [VehicleClass.HELICOPTERS] = 0.5,
        [VehicleClass.PLANES] = 0.5,
        [VehicleClass.SERVICE] = 0.5,
        [VehicleClass.EMERGENCY] = 0.5,
        [VehicleClass.MILITARY] = 0.5,
        [VehicleClass.COMMERCIAL] = 0.5,
        [VehicleClass.TRAINS] = 0.5,
        [VehicleClass.OPEN_WHEEL] = 0.5
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
            enableAutolock = true,
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

    ---@type table<VehicleClass, boolean>
    sharedVehicleClasses = {
        [VehicleClass.CYCLES] = true
    },

    ---@class SkillCheckConfigEntry
    ---@field default SkillCheckConfig
    ---@field class table<VehicleClass, SkillCheckConfig | {}>
    ---@field model table<number, SkillCheckConfig>

    ---@class AnimConfigEntry
    ---@field default Anim
    ---@field class table<VehicleClass, Anim | {}>
    ---@field model table<number, Anim>

    skillCheck = {
        ---@type SkillCheckConfigEntry
        lockpick = {
            default = normalLockpickSkillCheck,
            class = {
                [VehicleClass.COMPACTS]        = normalLockpickSkillCheck,
                [VehicleClass.SEDANS]          = normalLockpickSkillCheck,
                [VehicleClass.SUVS]            = normalLockpickSkillCheck,
                [VehicleClass.COUPES]          = normalLockpickSkillCheck,
                [VehicleClass.COMPACTS]        = normalLockpickSkillCheck,
                [VehicleClass.SEDANS]          = normalLockpickSkillCheck,
                [VehicleClass.SUVS]            = normalLockpickSkillCheck,
                [VehicleClass.COUPES]          = normalLockpickSkillCheck,
                [VehicleClass.MUSCLE]          = normalLockpickSkillCheck,
                [VehicleClass.SPORTS_CLASSICS] = normalLockpickSkillCheck,
                [VehicleClass.SPORTS]          = normalLockpickSkillCheck,
                [VehicleClass.SUPER]           = normalLockpickSkillCheck,
                [VehicleClass.MOTORCYCLES]     = normalLockpickSkillCheck,
                [VehicleClass.OFF_ROAD]        = normalLockpickSkillCheck,
                [VehicleClass.INDUSTRIAL]      = normalLockpickSkillCheck,
                [VehicleClass.UTILITY]         = normalLockpickSkillCheck,
                [VehicleClass.VANS]            = normalLockpickSkillCheck,
                [VehicleClass.BOATS]           = normalLockpickSkillCheck,
                [VehicleClass.HELICOPTERS]     = {},
                [VehicleClass.PLANES]          = normalLockpickSkillCheck,
                [VehicleClass.SERVICE]         = normalLockpickSkillCheck,
                [VehicleClass.EMERGENCY]       = hardLockpickSkillCheck,
                [VehicleClass.MILITARY]        = {},                          -- The vehicle class can only be opened with an advanced lockpick
                [VehicleClass.COMMERCIAL]      = normalLockpickSkillCheck,
                [VehicleClass.TRAINS]          = {},
                [VehicleClass.OPEN_WHEEL]      = easyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = normalLockpickSkillCheck
            }
        },
        ---@type SkillCheckConfigEntry
        advancedLockpick = {
            default = easyLockpickSkillCheck,
            class = {
                [VehicleClass.COMPACTS]        = easyLockpickSkillCheck,
                [VehicleClass.SEDANS]          = easyLockpickSkillCheck,
                [VehicleClass.SUVS]            = easyLockpickSkillCheck,
                [VehicleClass.COUPES]          = easyLockpickSkillCheck,
                [VehicleClass.MUSCLE]          = easyLockpickSkillCheck,
                [VehicleClass.SPORTS_CLASSICS] = easyLockpickSkillCheck,
                [VehicleClass.SPORTS]          = easyLockpickSkillCheck,
                [VehicleClass.SUPER]           = easyLockpickSkillCheck,
                [VehicleClass.MOTORCYCLES]     = easyLockpickSkillCheck,
                [VehicleClass.OFF_ROAD]        = easyLockpickSkillCheck,
                [VehicleClass.INDUSTRIAL]      = easyLockpickSkillCheck,
                [VehicleClass.UTILITY]         = easyLockpickSkillCheck,
                [VehicleClass.VANS]            = easyLockpickSkillCheck,
                [VehicleClass.BOATS]           = easyLockpickSkillCheck,
                [VehicleClass.HELICOPTERS]     = hardLockpickSkillCheck,
                [VehicleClass.PLANES]          = hardLockpickSkillCheck,
                [VehicleClass.SERVICE]         = easyLockpickSkillCheck,
                [VehicleClass.EMERGENCY]       = easyLockpickSkillCheck,
                [VehicleClass.MILITARY]        = hardLockpickSkillCheck,
                [VehicleClass.COMMERCIAL]      = easyLockpickSkillCheck,
                [VehicleClass.TRAINS]          = {},                         -- The vehicle class can't be opened with an lockpick
                [VehicleClass.OPEN_WHEEL]      = easyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = easyLockpickSkillCheck
            }
        },
        ---@type SkillCheckConfigEntry
        hotwire = {
            default = normalLockpickSkillCheck,
            class = {
                [VehicleClass.COMPACTS]        = normalLockpickSkillCheck,
                [VehicleClass.SEDANS]          = normalLockpickSkillCheck,
                [VehicleClass.SUVS]            = normalLockpickSkillCheck,
                [VehicleClass.COUPES]          = normalLockpickSkillCheck,
                [VehicleClass.COMPACTS]        = normalLockpickSkillCheck,
                [VehicleClass.SEDANS]          = normalLockpickSkillCheck,
                [VehicleClass.SUVS]            = normalLockpickSkillCheck,
                [VehicleClass.COUPES]          = normalLockpickSkillCheck,
                [VehicleClass.MUSCLE]          = normalLockpickSkillCheck,
                [VehicleClass.SPORTS_CLASSICS] = normalLockpickSkillCheck,
                [VehicleClass.SPORTS]          = normalLockpickSkillCheck,
                [VehicleClass.SUPER]           = normalLockpickSkillCheck,
                [VehicleClass.MOTORCYCLES]     = normalLockpickSkillCheck,
                [VehicleClass.OFF_ROAD]        = normalLockpickSkillCheck,
                [VehicleClass.INDUSTRIAL]      = normalLockpickSkillCheck,
                [VehicleClass.UTILITY]         = normalLockpickSkillCheck,
                [VehicleClass.VANS]            = normalLockpickSkillCheck,
                [VehicleClass.BOATS]           = normalLockpickSkillCheck,
                [VehicleClass.HELICOPTERS]     = {},
                [VehicleClass.PLANES]          = normalLockpickSkillCheck,
                [VehicleClass.SERVICE]         = normalLockpickSkillCheck,
                [VehicleClass.EMERGENCY]       = hardLockpickSkillCheck,
                [VehicleClass.MILITARY]        = {},
                [VehicleClass.COMMERCIAL]      = normalLockpickSkillCheck,
                [VehicleClass.TRAINS]          = {},
                [VehicleClass.OPEN_WHEEL]      = easyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = normalLockpickSkillCheck
            }
        },
        ---@type SkillCheckConfigEntry
        advancedHotwire = {
            default = easyLockpickSkillCheck,
            class = {
                [VehicleClass.COMPACTS]        = easyLockpickSkillCheck,
                [VehicleClass.SEDANS]          = easyLockpickSkillCheck,
                [VehicleClass.SUVS]            = easyLockpickSkillCheck,
                [VehicleClass.COUPES]          = easyLockpickSkillCheck,
                [VehicleClass.MUSCLE]          = easyLockpickSkillCheck,
                [VehicleClass.SPORTS_CLASSICS] = easyLockpickSkillCheck,
                [VehicleClass.SPORTS]          = easyLockpickSkillCheck,
                [VehicleClass.SUPER]           = easyLockpickSkillCheck,
                [VehicleClass.MOTORCYCLES]     = easyLockpickSkillCheck,
                [VehicleClass.OFF_ROAD]        = easyLockpickSkillCheck,
                [VehicleClass.INDUSTRIAL]      = easyLockpickSkillCheck,
                [VehicleClass.UTILITY]         = easyLockpickSkillCheck,
                [VehicleClass.VANS]            = easyLockpickSkillCheck,
                [VehicleClass.BOATS]           = easyLockpickSkillCheck,
                [VehicleClass.HELICOPTERS]     = hardLockpickSkillCheck,
                [VehicleClass.PLANES]          = hardLockpickSkillCheck,
                [VehicleClass.SERVICE]         = easyLockpickSkillCheck,
                [VehicleClass.EMERGENCY]       = easyLockpickSkillCheck,
                [VehicleClass.MILITARY]        = hardLockpickSkillCheck,
                [VehicleClass.COMMERCIAL]      = easyLockpickSkillCheck,
                [VehicleClass.TRAINS]          = {},                         -- The vehicle class can't be hotwired
                [VehicleClass.OPEN_WHEEL]      = easyLockpickSkillCheck,
            },
            model = {
                [`zombiea`] = easyLockpickSkillCheck
            }
        }
    },

    anims = {
        ---@type AnimConfigEntry
        hotwire = {
            default = defaultHotwireAnim,
            class = {
                [VehicleClass.COMPACTS]        = defaultHotwireAnim,
                [VehicleClass.SEDANS]          = defaultHotwireAnim,
                [VehicleClass.SUVS]            = defaultHotwireAnim,
                [VehicleClass.COUPES]          = defaultHotwireAnim,
                [VehicleClass.MUSCLE]          = defaultHotwireAnim,
                [VehicleClass.SPORTS_CLASSICS] = defaultHotwireAnim,
                [VehicleClass.SPORTS]          = defaultHotwireAnim,
                [VehicleClass.SUPER]           = defaultHotwireAnim,
                [VehicleClass.MOTORCYCLES]     = defaultHotwireAnim,
                [VehicleClass.OFF_ROAD]        = defaultHotwireAnim,
                [VehicleClass.INDUSTRIAL]      = defaultHotwireAnim,
                [VehicleClass.UTILITY]         = defaultHotwireAnim,
                [VehicleClass.VANS]            = defaultHotwireAnim,
                [VehicleClass.BOATS]           = defaultHotwireAnim,
                [VehicleClass.HELICOPTERS]     = defaultHotwireAnim,
                [VehicleClass.PLANES]          = defaultHotwireAnim,
                [VehicleClass.SERVICE]         = defaultHotwireAnim,
                [VehicleClass.EMERGENCY]       = defaultHotwireAnim,
                [VehicleClass.MILITARY]        = defaultHotwireAnim,
                [VehicleClass.COMMERCIAL]      = defaultHotwireAnim,
                [VehicleClass.TRAINS]          = defaultHotwireAnim,
                [VehicleClass.OPEN_WHEEL]      = defaultHotwireAnim,
            },
            model = {
                [`zombiea`] = defaultHotwireAnim
            }
        },
        ---@type AnimConfigEntry
        searchKeys = {
            default = defaultSearchKeysAnim,
            class = {
                [VehicleClass.COMPACTS]        = defaultSearchKeysAnim,
                [VehicleClass.SEDANS]          = defaultSearchKeysAnim,
                [VehicleClass.SUVS]            = defaultSearchKeysAnim,
                [VehicleClass.COUPES]          = defaultSearchKeysAnim,
                [VehicleClass.MUSCLE]          = defaultSearchKeysAnim,
                [VehicleClass.SPORTS_CLASSICS] = defaultSearchKeysAnim,
                [VehicleClass.SPORTS]          = defaultSearchKeysAnim,
                [VehicleClass.SUPER]           = defaultSearchKeysAnim,
                [VehicleClass.MOTORCYCLES]     = defaultSearchKeysAnim,
                [VehicleClass.OFF_ROAD]        = defaultSearchKeysAnim,
                [VehicleClass.INDUSTRIAL]      = defaultSearchKeysAnim,
                [VehicleClass.UTILITY]         = defaultSearchKeysAnim,
                [VehicleClass.VANS]            = defaultSearchKeysAnim,
                [VehicleClass.BOATS]           = defaultSearchKeysAnim,
                [VehicleClass.HELICOPTERS]     = defaultSearchKeysAnim,
                [VehicleClass.PLANES]          = defaultSearchKeysAnim,
                [VehicleClass.SERVICE]         = defaultSearchKeysAnim,
                [VehicleClass.EMERGENCY]       = defaultSearchKeysAnim,
                [VehicleClass.MILITARY]        = defaultSearchKeysAnim,
                [VehicleClass.COMMERCIAL]      = defaultSearchKeysAnim,
                [VehicleClass.TRAINS]          = defaultSearchKeysAnim,
                [VehicleClass.OPEN_WHEEL]      = defaultSearchKeysAnim,
            },
            model = {
                [`zombiea`] = defaultSearchKeysAnim
            }
        },
        ---@type AnimConfigEntry
        lockpick = {
            default = defaultLockpickAnim,
            class = {
                [VehicleClass.COMPACTS]        = defaultLockpickAnim,
                [VehicleClass.SEDANS]          = defaultLockpickAnim,
                [VehicleClass.SUVS]            = defaultLockpickAnim,
                [VehicleClass.COUPES]          = defaultLockpickAnim,
                [VehicleClass.MUSCLE]          = defaultLockpickAnim,
                [VehicleClass.SPORTS_CLASSICS] = defaultLockpickAnim,
                [VehicleClass.SPORTS]          = defaultLockpickAnim,
                [VehicleClass.SUPER]           = defaultLockpickAnim,
                [VehicleClass.MOTORCYCLES]     = defaultLockpickAnim,
                [VehicleClass.OFF_ROAD]        = defaultLockpickAnim,
                [VehicleClass.INDUSTRIAL]      = defaultLockpickAnim,
                [VehicleClass.UTILITY]         = defaultLockpickAnim,
                [VehicleClass.VANS]            = defaultLockpickAnim,
                [VehicleClass.BOATS]           = defaultLockpickAnim,
                [VehicleClass.HELICOPTERS]     = defaultLockpickAnim,
                [VehicleClass.PLANES]          = defaultLockpickAnim,
                [VehicleClass.SERVICE]         = defaultLockpickAnim,
                [VehicleClass.EMERGENCY]       = defaultLockpickAnim,
                [VehicleClass.MILITARY]        = defaultLockpickAnim,
                [VehicleClass.COMMERCIAL]      = defaultLockpickAnim,
                [VehicleClass.TRAINS]          = defaultLockpickAnim,
                [VehicleClass.OPEN_WHEEL]      = defaultLockpickAnim,
            },
            model = {
                [`zombiea`] = defaultLockpickAnim
            }
        },
        ---@type AnimConfigEntry
        holdup = {
            default = defaultHoldupAnim,
            class = {
                [VehicleClass.COMPACTS]        = defaultHoldupAnim,
                [VehicleClass.SEDANS]          = defaultHoldupAnim,
                [VehicleClass.SUVS]            = defaultHoldupAnim,
                [VehicleClass.COUPES]          = defaultHoldupAnim,
                [VehicleClass.MUSCLE]          = defaultHoldupAnim,
                [VehicleClass.SPORTS_CLASSICS] = defaultHoldupAnim,
                [VehicleClass.SPORTS]          = defaultHoldupAnim,
                [VehicleClass.SUPER]           = defaultHoldupAnim,
                [VehicleClass.MOTORCYCLES]     = defaultHoldupAnim,
                [VehicleClass.OFF_ROAD]        = defaultHoldupAnim,
                [VehicleClass.INDUSTRIAL]      = defaultHoldupAnim,
                [VehicleClass.UTILITY]         = defaultHoldupAnim,
                [VehicleClass.VANS]            = defaultHoldupAnim,
                [VehicleClass.BOATS]           = defaultHoldupAnim,
                [VehicleClass.HELICOPTERS]     = defaultHoldupAnim,
                [VehicleClass.PLANES]          = defaultHoldupAnim,
                [VehicleClass.SERVICE]         = defaultHoldupAnim,
                [VehicleClass.EMERGENCY]       = defaultHoldupAnim,
                [VehicleClass.MILITARY]        = defaultHoldupAnim,
                [VehicleClass.COMMERCIAL]      = defaultHoldupAnim,
                [VehicleClass.TRAINS]          = defaultHoldupAnim,
                [VehicleClass.OPEN_WHEEL]      = defaultHoldupAnim,
            },
            model = {
                [`zombiea`] = defaultHoldupAnim
            }
        }
    }
}
