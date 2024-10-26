return {
    ---For a given vehicle, the config used is based on precendence of:
    ---1. model
    ---2. category from qbx_core shared/vehicles.lua
    ---3. class
    ---4. type
    ---5. default
    ---Each field falls back to its parent value if not specified.
    ---Example: model's shared value is nil, so the type's shared value is used.
    vehicles = {
        ---@type VehicleConfig
        default = {
            noLock = false,
            spawnLockedIfParked = 0.75,
            spawnLockedIfDriven = 0.75,
            carjackingImmune = false,
            lockpickImmune = false,
            shared = false,
            removeNormalLockpickChance = 0.4,
            removeAdvancedLockpickChance = 0.2,
            findKeysChance = 0.5,
        },
        ---@type table<VehicleClass, VehicleConfig>
        classes = {
            -- [VehicleClass.EMERGENCY] = {

            -- }
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
}
