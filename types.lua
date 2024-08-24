---@meta

---@alias VehicleType 'automobile' | 'bike' | 'boat' | 'heli' | 'plane' | 'submarine' | 'trailer' | 'train'

---@class VehicleSelection
---@field types VehicleType[]
---@field models number[]

---@class VehiclesConfig
---@field default VehicleConfig
---@field types table<VehicleType, VehicleConfig>
---@field models table<number, VehicleConfig>

---@class VehicleConfig
---@field spawnLocked? boolean | number ratio 0.0 - 1.0