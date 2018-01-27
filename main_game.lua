plr_x = 64
plr_y = 100
cam_x = 0
y = 128-32

-- GameData = require('data')
Camera = require('camera')
Camera = require('player')

function _update()
 if (btn(0)) then Camera.move(-1, 0) end
 if (btn(1)) then Camera.move(1, 0) end
 --if (btn(2)) then Camera.move(0, -1) end
 --if (btn(3)) then Camera.move(0, 1) end
 if (btn(4)) then Camera.shake() end
 Camera.update()
end

function _draw()
 rectfill(0,0,127,127,1)
 rectfill(0,99,127,127,2)
 circfill(plr_x%127,plr_y%127,2,4)
end
