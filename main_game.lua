plr_x = 64
plr_y = 100
cam_x = 0
y = 128-32

Camera = require('camera')
PodFactory = require('pod')

somepod = PodFactory.create(64, 64)

function _update()
 dx=0
 dy=0
 if (btn(0)) then Camera.move(-1, 0) end
 if (btn(1)) then Camera.move(1, 0) end
 --if (btn(2)) then Camera.move(0, -1) end
 --if (btn(3)) then Camera.move(0, 1) end
 if (btn(4)) then Cmaera.shake() end
 Camera.update()
end

function _draw()
 rectfill(0,0,127,127,1)
 rectfill(0,99,127,127,2)
 circfill(plr_x%127,plr_y%127,2,4)
 somepod.draw()

 print('mem:'.. stat(0), 0, 0, 7)
 print('cpu:'.. stat(1), 0, 8, 7)
end
