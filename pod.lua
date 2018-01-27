Camera = require('Camera')

local PodFactory = {
    create = function(x, y, type) {
        return {
            x = x,
            y = y,
            type = type,

            draw = function() {
                spr(1, x, y)
            }
        }
    }
}

return Pod