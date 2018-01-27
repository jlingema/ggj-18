stone_x = 64
stone_y = 100
cam_x = 0
y = 128-32

-- GameData = require('data')
Camera = require('camera')
Player = require('player')

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
 rectfill(0,0,127,127,1) --the sky
 rectfill(0,99,127,127,2) --the floor
 circfill(stone_x%127,stone_y%127,2,4) --a stone
 Player.draw()
end
