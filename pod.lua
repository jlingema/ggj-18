local PodFactory = {
    create = function(x, y)
        return {
            x = x,
            y = y,

            draw = function()
                spr(1, x, y)
            end
        }
    end
}

return PodFactory