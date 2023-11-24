return {
    -- Carjack Settings
    carJackEnable = true, -- True allows for the ability to car jack peds.

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

    -- These vehicles cannot be jacked
    immuneVehicles = {
        'stockade'
    },

    -- These vehicles will never lock
    noLockVehicles = {
        -- 'stockade' -- example
    },

    -- These weapons cannot be used for carjacking
    noCarjackWeapons = {
        "WEAPON_UNARMED",
        "WEAPON_Knife",
        "WEAPON_Nightstick",
        "WEAPON_HAMMER",
        "WEAPON_Bat",
        "WEAPON_Crowbar",
        "WEAPON_Golfclub",
        "WEAPON_Bottle",
        "WEAPON_Dagger",
        "WEAPON_Hatchet",
        "WEAPON_KnuckleDuster",
        "WEAPON_Machete",
        "WEAPON_Flashlight",
        "WEAPON_SwitchBlade",
        "WEAPON_Poolcue",
        "WEAPON_Wrench",
        "WEAPON_Battleaxe",
        "WEAPON_Grenade",
        "WEAPON_StickyBomb",
        "WEAPON_ProximityMine",
        "WEAPON_BZGas",
        "WEAPON_Molotov",
        "WEAPON_FireExtinguisher",
        "WEAPON_PetrolCan",
        "WEAPON_Flare",
        "WEAPON_Ball",
        "WEAPON_Snowball",
        "WEAPON_SmokeGrenade",
    },
}