stone_x = 64
stone_y = 100
cam_x = 0
y = 128-32
PODS_ORIG_Y = -200
PODS_Y_RAND = 50
GROUND_Y = 100

PODS = {}
ANTI_P_TURRETS = {}
ENEMIES = {}
BULLETS = {}

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
    create = function(x, spawn_func)
        p = {
            x = x,
            y = PODS_ORIG_Y + rnd(PODS_Y_RAND * 2) - PODS_Y_RAND,
            speed = 6,
            spark_idx = -1,
            landed = false,
            landed_t,
            spawn_func = spawn_func
        }
        add(PODS, p)
        sfx(0)
        return p
    end
}

update_pod = function(pod)
    pod.y = pod.y + pod.speed
    if pod.y >= GROUND_Y and not pod.landed then land_pod(pod) end

    if pod.spark_idx >= 0 then pod.spark_idx += 1 end
    if pod.spark_idx == 15 then pod.spark_idx = -1 end

    if pod.landed and (time() - pod.landed_t > 1) then
        pod.spawn_func(pod.x, pod.y)
        del(PODS, pod)
    end
end
draw_pod = function(pod)
    spr(1, pod.x, pod.y)
    if pod.spark_idx > -1 then
        spr(2 + flr(pod.spark_idx / 5), pod.x + 7, pod.y)
        spr(2 + flr(pod.spark_idx / 5), pod.x - 7, pod.y, 1, 1, true)
    end
end
land_pod = function(pod)
    pod.speed = 0
    pod.spark_idx = 0
    pod.landed = true
    pod.landed_t = t()
    Camera.shake()
    sfx(1)
end

AntiPersonnelTurretFactory = {
    create = function(x, y)
        t = {
            _x = x,
            _y = y,
            dir = 1,
            cdwn = 0,
            speed = 3,
            shooting = false,
        }
        add(ANTI_P_TURRETS, t)
        return t
    end
}

update_anti_personnel_turret = function(t)
    t.cdwn = t.cdwn - 1
    t.shooting=false
    if t.cdwn <= 0 then
        x = t._x
        y = t._y
        min = 32
        closest = nil
        for e in all(ENEMIES) do
            dx = e._x - t._x
            if abs(dx) < abs(min) and dx > -32 then
                min = dx
                closest = e
            end
        end
        if min < 32 and min > -32 then
            if min < 0 then t.dir = -1 else t.dir = 1 end
            BulletFactory.create(x,y,5,3*t.dir)
            t.shooting = true
            t.cdwn = t.speed
        end
    end
end

draw_anti_personnel_turret = function(t)
    local flip = t.dir < 0
    if t.shooting then
        spr(18, t._x, t._y, 1, 1, flip)
    else
        spr(17, t._x, t._y, 1, 1, flip)
    end
end

-- todo replace by a player action that creates PODS
PodFactory.create(30, AntiPersonnelTurretFactory.create)

Tower = {
    _x = 0,
    _y = GROUND_Y,
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
    cldn=0,
    update = function()
        Player.cldn = Player.cldn - 1
        if Player.cldn < 0 then Player.cldn = 0 end
    end,
    move = function(dx, dy)
        Player._x = Player._x + dx
        if dx > 0 then Player.dir = 1 else Player.dir = -1 end
        Player._y = Player._y + dy
    end,
    shoot = function()
        if Player.cldn <= 0 then
            Player.cldn = 10
            BulletFactory.create(Player._x, Player._y, 5, Player.dir*5)
        end
    end,
    draw = function()
        rectfill(Player._x,Player._y,Player._x+Player._w,Player._y+Player._h,5)
    end
}

BulletFactory = {
    create = function(x,y,dmg,speed)
        b = {
            speed=speed,
            x=x,
            y=y,
            dmg=dmg
        }
        add(BULLETS, b)
        return b
    end
}

function update_bullet(bullet, enemies)
    pre_x = bullet.x
    bullet.x = bullet.x+bullet.speed
    for e in all (enemies) do
        if (e._x > pre_x and e._x < bullet.x) or (e._x < pre_x and e._x > bullet.x) then
            damage_enemy(e, bullet.dmg)
            return true
        end
    end
    return false
end

function draw_bullet(bullet)
    rectfill(bullet.x, bullet.y, bullet.x+1, bullet.y+1,9)
end

EnemyFactory = {
    createWeakling = function(x,y)
        e = {
            _x = x,
            _y = y,
            _hp = 10
        }
        add(ENEMIES, e)
        return e
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
    if enemy._hp <= 0 then del(ENEMIES, enemy) end
end

-- todo remove this and have an enemy spawner logic thingy
EnemyFactory.createWeakling(30, GROUND_Y)

function _update()
    for p in all(PODS) do
        update_pod(p)
    end
    for t in all(ANTI_P_TURRETS) do
        update_anti_personnel_turret(t)
    end
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
 if (btn(5)) then Player.shoot() end
 Camera.update()
 Player.update()
 for e in all (ENEMIES) do
    update_enemy(e)
 end
 for b in all (BULLETS) do
    if update_bullet(b, ENEMIES) then del(BULLETS, b) end
 end
end

function _draw()
 cls(1)
 rectfill(-20+Camera.x(),99+Camera.y(),140+Camera.x(),130+Camera.y(),2)
 circfill(stone_x%127,stone_y%127,2,4)
 Player.draw()
 Camera.draw()
 Tower.draw()
 for p in all(PODS) do
    draw_pod(p)
 end
 for t in all(ANTI_P_TURRETS) do
    draw_anti_personnel_turret(t)
 end
 for e in all (ENEMIES) do
    draw_enemy(e)
 end
 for b in all (BULLETS) do
    draw_bullet(b)
 end
end
