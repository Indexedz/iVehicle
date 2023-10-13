local matrix = import 'matrix';
local module = {}

function module.new(locations)
  local self = {}
  self.locations = array.new(locations)

  function self.first(size)
    return self.locations:find(function(vec)
      return matrix.hasEntityInArea(vec, size)
    end)
  end

  function self.get()
    return self.locations:filter(function(vec)
      return matrix.hasEntityInArea(vec, size)
    end)
  end
end

return {}
