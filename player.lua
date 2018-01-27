local Player = {
    _x = 0,
    _y =99,
    _w = 2,
    _h = 5,
    _o = 64,
    update = function()
    end,
    move = function(dx, dy)
        Player._x = Player._x + dx
        Player._y = Player._y + dy
    end,
    draw = function()
        rectfill(Player._x+Player._o,Player._y,Player._x+Player._w+Player._o,Player._y+Player._h,5)
    end
}

return Player
