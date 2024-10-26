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

return {
    vehicleMaximumLockingDistance = 5.0, -- Minimum distance for vehicle locking
    getKeysWhenEngineIsRunning = true, -- when enabled, gives keys to a player who doesn't have them if they enter the driver seat when the engine is running
    keepEngineOnWhenAbandoned = true, -- when enabled, keeps a vehicle's engine running after exiting

    -- Carjack Settings
    carjackEnable = true,                -- Enables the ability to carjack pedestrian vehicles, stealing them by pointing a weapon at them
    carjackingTimeInMs = 7500,           -- Time it takes to successfully carjack in miliseconds
    delayBetweenCarjackingsInMs = 10000, -- Time before you can attempt another carjack in miliseconds

    -- Hotwire Settings
    timeBetweenHotwires = 5000, -- Time in milliseconds between hotwire attempts
    minKeysSearchTime = 20000,  -- Minimum hotwire time in milliseconds
    maxKeysSearchTime = 40000,  -- Maximum hotwire time in milliseconds

    -- Police Alert Settings
    alertCooldown = 10000,         -- Cooldown period in milliseconds (10 seconds)
    policeAlertChance = 0.75,      -- Chance of alerting the police during the day
    policeNightAlertChance = 0.50, -- Chance of alerting the police at night (times: 01-06)
    policeAlertNightStartHour = 1,
    policeAlertNightDuration = 5,

    ---Sends an alert to police
    ---@param crime string
    ---@param vehicle number entity
    alertPolice = function(crime, vehicle)
        TriggerServerEvent('police:server:policeAlert', locale("info.vehicle_theft") .. crime)
    end,

    vehicleAlarmDuration = 10000,
    lockpickCooldown = 1000,
    hotwireCooldown = 1000,

    -- Job Settings
    ---@class SharedKeysConfig
    ---@field enableAutolock? boolean auto-lock door on driver exit
    ---@field requireOnDuty? boolean requires player to be on duty to access the vehicle
    ---@field classes? table<VehicleClass, boolean> vehicle classes to enable shared keys on
    ---@field vehicles? table<number, boolean> vehicle hashes to enable shared keys on

    ---@alias JobName string
    ---@type table<JobName, SharedKeysConfig>
    sharedKeys = { -- Share keys amongst employees. Employees can lock/unlock any job-listed vehicle
        police = { -- Job name
            enableAutolock = true,
            requireOnduty = true,
            classes = {},
            vehicles = {
                [`police`] = true,  -- Vehicle model
                [`police2`] = true, -- Vehicle model
            }
        },
        ambulance = {
            enableAutolock = true,
            requireOnduty = true,
            classes = {},
            vehicles = {
                [`ambulance`] = true,
            },
        },
        mechanic = {
            requireOnduty = false,
            vehicles = {
                [`towtruck`] = true,
            }
        }
    },

    ---@class SkillCheckConfigEntry
    ---@field default SkillCheckConfig
    ---@field class table<VehicleClass, SkillCheckConfig | {}>
    ---@field model table<number, SkillCheckConfig>

    ---@class SkillCheckEntities
    ---@field lockpick SkillCheckConfigEntry
    ---@field advancedLockpick SkillCheckConfigEntry
    ---@field hotwire SkillCheckConfigEntry
    ---@field advancedHotwire SkillCheckConfigEntry

    ---@type SkillCheckEntities
    skillCheck = {
        lockpick = {
            default = normalLockpickSkillCheck,
            class = {
                [VehicleClass.PLANES] = hardLockpickSkillCheck,
                [VehicleClass.HELICOPTERS] = hardLockpickSkillCheck,
                [VehicleClass.EMERGENCY] = hardLockpickSkillCheck,
                [VehicleClass.MILITARY] = {}, -- cannot be lockpicked
                [VehicleClass.TRAINS] = {}, -- cannot be lockpicked
                [VehicleClass.OPEN_WHEEL] = easyLockpickSkillCheck,
            },
            model = {}
        },
        advancedLockpick = {
            default = easyLockpickSkillCheck,
            class = {
                [VehicleClass.PLANES] = hardLockpickSkillCheck,
                [VehicleClass.HELICOPTERS] = hardLockpickSkillCheck,
                [VehicleClass.EMERGENCY] = hardLockpickSkillCheck,
                [VehicleClass.MILITARY] = {}, -- cannot be lockpicked
                [VehicleClass.TRAINS] = {}, -- cannot be lockpicked
            },
            model = {}
        },
        hotwire = {
            default = normalLockpickSkillCheck,
            class = {
                [VehicleClass.PLANES] = hardLockpickSkillCheck,
                [VehicleClass.HELICOPTERS] = hardLockpickSkillCheck,
                [VehicleClass.EMERGENCY] = hardLockpickSkillCheck,
                [VehicleClass.MILITARY] = {}, -- cannot be hotwired
                [VehicleClass.TRAINS] = {}, -- cannot be hotwired
                [VehicleClass.OPEN_WHEEL] = easyLockpickSkillCheck,
            },
            model = {}
        },
        advancedHotwire = {
            default = easyLockpickSkillCheck,
            class = {
                [VehicleClass.PLANES] = hardLockpickSkillCheck,
                [VehicleClass.HELICOPTERS] = hardLockpickSkillCheck,
                [VehicleClass.EMERGENCY] = hardLockpickSkillCheck,
                [VehicleClass.MILITARY] = {}, -- cannot be hotwired
                [VehicleClass.TRAINS] = {}, -- cannot be hotwired
            },
            model = {}
        }
    },

    ---@class AnimConfigEntry
    ---@field default Anim
    ---@field class table<VehicleClass, Anim | {}>
    ---@field model table<number, Anim>

    ---@class AnimConfigEntities
    ---@field hotwire AnimConfigEntry
    ---@field searchKeys AnimConfigEntry
    ---@field lockpick AnimConfigEntry
    ---@field holdup AnimConfigEntry
    ---@field toggleEngine AnimConfigEntry

    ---@type AnimConfigEntities
    anims = {
        hotwire = {
            default = {
                dict = 'anim@veh@plane@howard@front@ds@base',
                clip = 'hotwire'
            },
            class = {},
            model = {}
        },
        searchKeys = {
            default = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
            },
            class = {},
            model = {}
        },
        lockpick = {
            default = {
                dict = 'veh@break_in@0h@p_m_one@',
                clip = 'low_force_entry_ds'
            },
            class = {},
            model = {}
        },
        holdup = {
            default = {
                dict = 'mp_am_hold_up',
                clip = 'holdup_victim_20s'
            },
            class = {},
            model = {}
        },
        toggleEngine = {
            default = {
                dict = 'oddjobs@towing',
                clip = 'start_engine',
                delay = 400, -- how long it takes to start the engine
            },
            class = {
                [VehicleClass.MOTORCYCLES] = {
                    dict = 'veh@bike@quad@front@base',
                    clip = 'start_engine',
                    delay = 1000,
                },
                [VehicleClass.CYCLES] = {}, -- does not have an engine
            },
            model = {},
        },
    },
    -- Weapons that cannot be used for carjacking
    noCarjackWeapons = {
        `WEAPON_UNARMED`,
        `WEAPON_KNIFE`,
        `WEAPON_NIGHTSTICK`,
        `WEAPON_HAMMER`,
        `WEAPON_BAT`,
        `WEAPON_CROWBAR`,
        `WEAPON_GOLFCLUB`,
        `WEAPON_BOTTLE`,
        `WEAPON_DAGGER`,
        `WEAPON_HATCHET`,
        `WEAPON_KNUCKLE`,
        `WEAPON_MACHETE`,
        `WEAPON_FLASHLIGHT`,
        `WEAPON_SWITCHBLADE`,
        `WEAPON_POOLCUE`,
        `WEAPON_WRENCH`,
        `WEAPON_BATTLEAXE`,
        `WEAPON_GRENADE`,
        `WEAPON_STOCKYBOMB`,
        `WEAPON_PROXIMITYMINE`,
        `WEAPON_BZGAS`,
        `WEAPON_MOLOTOV`,
        `WEAPON_FIREEXTINGUISHER`,
        `WEAPON_PETROLCAN`,
        `WEAPON_FLARE`,
        `WEAPON_BALL`,
        `WEAPON_SNOWBALL`,
        `WEAPON_SMOKEGRENADE`,
        -- Add more weapon names as needed
    },
}
