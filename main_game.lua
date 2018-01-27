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
    draw = function()
        print('mem:'.. stat(0), 0+Camera.x(), 0, 7)
        print('cpu:'.. stat(1), 0+Camera.x(), 8, 7)
        print('hp:'.. Tower._hp, 100+Camera.x(), 8, 2)
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
    if pod.y >= 100 and not pod.landed then land_pod(pod) end

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


Tower = {
    _x = 0,
    _y = 100,
    _h = 6,
    _hp = 1000,
    update = function()
    end,
    damage = function(hp)
        Tower._hp = Tower._hp - hp
    end,
    draw = function()
        spr(32, Tower._x, Tower._y)
        for i=1,Tower._h-2 do
            spr(16, Tower._x, Tower._y - 8 * i)
        end
        spr(0, Tower._x, Tower._y - 8 * (Tower._h - 1))
    end
}

Player = {
    _x = 64,
    _y = 99,
    _w = 2,
    _h = 5,
    dir=1,
    update = function()
    end,
    move = function(dx, dy)
        Player._x = Player._x + dx
        if dx > 0 then dir = 1 else dir = -1 end
        Player._y = Player._y + dy
    end,
    draw = function()
        rectfill(Player._x,Player._y,Player._x+Player._w,Player._y+Player._h,5)
    end
}

BulletFactory = {
    create = function(x,y,dmg,speed)
        return {
            speed=speed,
            x=x,
            y=y,
            dmg=dmg
        }
    end
}

function update_bullet(bullet, enemies)
    pre_x = bullet.x
    bullet.x = bullet.x+bullet.speed
    for e in all (enemies) do
        if e._x > pre_x and e._x < bullet.x then
            damage_enemy(e, bullet.dmg)
            return true
        end
    end
    return false
end

function draw_bullet(bullet)
    rectfill(bullet.x, bullet.y, bullet.x+1, bullet.y+1,5)
end

EnemyFactory = {
    createWeakling = function(x,y)
        return {
            _x = x,
            _y = y,
            _hp = 10
        }
    end
}

function update_enemy(enemy)
    dx = Tower._x - enemy._x
    dy = Tower._y - enemy._y
    if dx > 0 then
        enemy._x = enemy._x+1
    else
        enemy._x = enemy._x-1
    end
    if dy > 0 then
        enemy._y = enemy._y+1
    else
        enemy._y = enemy._y-1
    end
    if abs(dx) < 3 and abs(dy) < 3 then Tower.damage(1) end
end

function draw_enemy(enemy)
    rectfill(enemy._x, enemy._y, enemy._x+4, enemy._y+4,8)
end

function damage_enemy(enemy, dmg)
    enemy._hp = enemy._hp - dmg
    if enemy._hp <= 0 then del(enemies, enemy) end
end

somepod = PodFactory.create(64, -100)
enemies = {EnemyFactory.createWeakling(99, 99)}
bullets = {}

function _update()
    update_pod(somepod)
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
 if (btn(5)) then add(bullets, BulletFactory.create(Player._x, Player._y, 5, Player.dir*5)) end
 Camera.update()
 for e in all (enemies) do
    update_enemy(e)
 end
end

function _draw()
 rectfill(0+Camera.x(),0+Camera.y(),127+Camera.x(),127+Camera.y(),1)
 rectfill(0+Camera.x(),99+Camera.y(),127+Camera.x(),127+Camera.y(),2)
 circfill(stone_x%127,stone_y%127,2,4)
 Player.draw()
 Camera.draw()
 Tower.draw()
 for e in all (enemies) do
    draw_enemy(e)
 end
 draw_pod(somepod)
 for b in all (bullets) do
    draw_bullet(b)
    if update_bullet(b, enemies) then del(bullets, b) end
 end
end
