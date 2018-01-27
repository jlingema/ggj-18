plr_x = 64
plr_y = 100
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
            speed = 8,
            spark_idx = -1,
            landed = false
        }
    end
}

update_pod = function(pod)
    pod.y = pod.y + pod.speed
    if pod.y == 100 and not pod.landed then land_pod(pod) end

    if pod.spark_idx >= 0 then pod.spark_idx += 1 end
    if pod.spark_idx == 15 then pod.spark_idx = -1 end
end
draw_pod = function(pod)
    spr(1, pod.x, pod.y)
    if pod.spark_idx > -1 then
        spr(2 + flr(pod.spark_idx / 5), pod.x + 7, pod.y)
        spr(2 + flr(pod.spark_idx / 5), pod.x - 7, pod.y, 1, 1, true, false)
    end
end
land_pod = function(pod)
    pod.speed = 0
    pod.spark_idx = 0
    pod.landed = true
end

somepod = PodFactory.create(64, -100)

function _update()
    update_pod(somepod)

 dx=0
 dy=0
 if (btn(0)) then Camera.move(-1, 0) end
 if (btn(1)) then Camera.move(1, 0) end
 --if (btn(2)) then Camera.move(0, -1) end
 --if (btn(3)) then Camera.move(0, 1) end
 if (btn(4)) then Camera.shake() end
 Camera.update()
end

function _draw()
 rectfill(0+Camera.x(),0+Camera.x(),127+Camera.y(),127+Camera.y(),1)
 rectfill(0,99,127,127,2)
 circfill(plr_x%127,plr_y%127,2,4)
 draw_pod(somepod)

 print('mem:'.. stat(0), 0, 0, 7)
 print('cpu:'.. stat(1), 0, 8, 7)
end
