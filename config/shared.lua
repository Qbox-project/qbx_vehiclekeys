return {
    ---For a given vehicle, the config used is based on precendence of:
    ---1. model
    ---2. category from qbx_core shared/vehicles.lua
    ---3. type
    ---4. default
    ---Each field falls back to its parent value if not specified.
    ---Example: model's shared value is nil, so the type's shared value is used.
    vehicles = {
        ---@type VehicleConfig
        default = {
            noLock = false,
            spawnLockedIfParked = .75,
            spawnLockedIfDriven = .75,
            carjackingImmune = false,
            lockpickImmune = false,
            shared = false,
            removeNormalLockpickChance = 1.0,
            removeAdvancedLockpickChance = 1.0,
            findKeysChance = 0.5,
        },
        ---@type table<string, VehicleConfig>
        categories = { -- known categories: super, service, utility, helicopters, motorcycles, suvs, planes, sports, emergency, military, sportsclassics, compacts, sedans
            -- super = {
            --     noLock = false,
            --     spawnLockedIfParked = 1.0,
            --     carjackingImmune = false,
            --     lockpickImmune = false,
            --     shared = false,
            --     removeNormalLockpickChance = 1.0,
            --     removeAdvancedLockpickChance = 1.0,
            --     findKeysChance = 0.5,
            -- }
        },
        ---@type table<VehicleType, VehicleConfig>
        types = { -- known types: automobile, bike, boat, heli, plane, submarine, trailer, train
            bike = {
                noLock = true
            },
            -- automobile = {
            --     noLock = false,
            --     spawnLockedIfParked = 1.0,
            --     carjackingImmune = false,
            --     lockpickImmune = false,
            --     shared = false,
            --     removeNormalLockpickChance = 1.0,
            --     removeAdvancedLockpickChance = 1.0,
            --     findKeysChance = 0.5,
            -- }
        },
        ---@type table<Hash, VehicleConfig>
        models = {
            -- [`stockade`] = {
            --     spawnLockedIfParked = 0.5
            -- }
        }
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
