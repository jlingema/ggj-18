plr_x = 64
plr_y = 100
cam_x = 0
y = 128-32

 GameData = require('data')
 Camera = require('camera')
 Pod = require('pod')

function _update()
 dx=0
 dy=0
 if (btn(0)) then dx=-1 end
 if (btn(1)) then dx=1 end
 --if (btn(2)) then dy=-1 end
 --if (btn(3)) then dy=1 end
 if (btn(4)) then Cmaera.shake() end
 Camera.update(dx, dy)
end

function _draw()
 rectfill(0,0,127,127,1)
 rectfill(0,99,127,127,2)
 pos = Camera.transform(plr_x, plr_y)
 circfill((pos.x)%127,(pos.y)%127,2,4)
end
