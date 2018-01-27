stone_x = 64
stone_y = 100
cam_x = 0
y = 128-32

Camera = {
    _x=0,
    _y=0,
    scr_shk_str = 0,
    update = function()
        if(Camera.scr_shk_str > 0.1) then Camera.scr_shk_str=Camera.scr_shk_str*0.6
        else Camera.scr_shk_str=0 end
        camera(Camera.x(), Camera.y())
    end,
    move = function(dx,dy)
        Camera._x = Camera._x + dx
        Camera._y = Camera._y + dy
    end,
    shake = function()
        Camera.scr_shk_str = 4
    end,
    x = function()
        return Camera._x + (rnd (Camera.scr_shk_str*2)) - Camera.scr_shk_str
    end,
    y = function()
        return Camera._y + (rnd (Camera.scr_shk_str*2)) - Camera.scr_shk_str
    end
}

PodFactory = {
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

 Player = {
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


somepod = PodFactory.create(64, 64)

function _update()
 if (btn(0)) then
    Camera.move(-1, 0)
    Player.move(-1, 0)
 end
 if (btn(1)) then
    Camera.move(1, 0)
    Player.move(1, 0)
 end
 --if (btn(2)) then Camera.move(0, -1) end
 --if (btn(3)) then Camera.move(0, 1) end
 if (btn(4)) then Camera.shake() end
 Camera.update()
end

function _draw()
 rectfill(0+Camera.x(),0+Camera.x(),127+Camera.y(),127+Camera.y(),1)
 rectfill(0,99,127,127,2)
 circfill(stone_x%127,stone_y%127,2,4)
 Player.draw()
 somepod.draw()

 print('mem:'.. stat(0), 0, 0, 7)
 print('cpu:'.. stat(1), 0, 8, 7)
end
