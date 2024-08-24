return {
    ---For a given vehicle, the config used is based on precendence of:
    ---1. model
    ---2. type
    ---3. default
    ---Each field inherits from its parent if not specified.
    ---@type VehiclesConfig
    vehicles = {
        default = {
            spawnLocked = 1.0,
        },
        types = {

        },
        models = {
            -- Example:
            -- [`stockade`] = {
            --     spawnLocked = 0.5
            -- }
        }
    },
    sharedVehicles = {
        -- `stockade` -- example
    },

    sharedVehicleTypes = {
        'bike'
    },

    -- Vehicles that will never lock
     ---@type VehicleSelection
    noLockVehicles = {
        models = {
            -- `stockade` -- example
        },

        types = {

        }
    },

    -- Vehicles that cannot be jacked
    carjackingImmuneVehicles = {
        `stockade`
    },

    lockpickImmuneVehicles = {
        -- `stockade` -- example
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
