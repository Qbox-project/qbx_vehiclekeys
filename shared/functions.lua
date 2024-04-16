local public = {}

--- Gets model hash
--- @param model string | number model name or number.
--- @return number hash of the model.
function public.getHash(model)
    if type(model) == 'string' then return joaat(model) end
    return model
end

--- Checks if the given two coordinates are close to each other based on distance.
--- @param coord1 vector3[] The first set of coordinates.
--- @param coord2 vector3[] The second set of coordinates.
--- @param distance number The maximum allowed distance for them to be considered close.
--- @return boolean true if the distance between two entities is less than the distance parameter.
function public.isCloseToCoords(coord1, coord2, distance)
    return #(coord1 - coord2) < distance
end

return public
