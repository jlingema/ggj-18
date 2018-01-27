local Camera = {
    _x=0,
    _y=0,
    scr_shk_str = 0,
    update = function(dx,dy)
        Camera._x = Camera._x + dx
        Camera._y = Camera._y + dy
        if(Camera.scr_shk_str > 0.1) then Camera.scr_shk_str=Camera.scr_shk_str*0.6
        else Camera.scr_shk_str=0 end
    end,
    shake = function()
        Camera.scr_shk_str = 4
    end,
    x = function()
        return Camera._x + (rnd (Camera.scr_shk_str*2)) - Camera.scr_shk_str
    end,
    y = function()
        return Camera._y + (rnd (Camera.scr_shk_str*2)) - Camera.scr_shk_str
    end,
    transform = function(x,y)
        return {x=x-Camera.x(), y=y-Camera.y()}
    end
}

return Camera