local module = {}

function module.getModelSize(model)
  local min, max = GetModelDimensions(model)

  local back     = vector3((max.x - min.x), min.y, min.z)
  local forward  = vector3((max.x - min.x), max.y, min.z)

  local pad      = 0.001
  local zOffset  = 2

  local width    = max.x - min.x + pad
  local height   = max.z - min.z + pad + zOffset
  local length   = #(back - forward) + pad

  return vec(width, length, height)
end

function module.hasEntityInArea(vec, size)
  local flags   = 2 + 4 + 16 + 256
  local raycast = StartShapeTestBox(vec.x, vec.y, vec.z, size.x, size.y, size.z, 0.0, 0.0, vec.w, 2, flags, 0, 4)
  local retval, hit, endCoords, surfaceNormal, entity  = GetShapeTestResult(raycast) 

  return hit, entity
end

return module