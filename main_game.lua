DEBUG = true

stone_x = 64
stone_y = 100
cam_x = 0
y = 128-32
PODS_ORIG_Y = -200
PODS_Y_RAND = 50
GROUND_Y = 100

IS_IN_CMD_MODE = false
LOCKED_BTN = -1
CMDS = {}
CMDS_MAX = 4

TWR_DANGER_ZONE = 300
TWR_HP = 1000

WAVE_TIME = 360
AP_DMG = 1
AP_SHOOT_SPEED = 5
AP_HP = 10
AP_RANGE=48

PLR_DMG = 2
PLR_SPEED = 1
PLR_SHOOT_SPEED = 10 -- larger = slower

WK_DMG = 2
WK_HP = 10
WK_ATK_SPEED = 5
WK_SPEED = 0.5

PODS = {}
ANTI_P_TURRETS = {}
ENEMIES = {}
BULLETS = {}
GFXS = {}

CMD_TO_POD = {}

ALIEN_JELLY = {}

function sbtn(b)
    if LOCKED_BTN == b then
        -- A locked button is unlocked once unpressed. This is for preventing
        -- a button to be considered pressed after it was used as the last button of a
        -- pod command list.
        if not btn(b) then LOCKED_BTN = -1 end
        return false
    end
    return not IS_IN_CMD_MODE and btn(b)
end

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
        if DEBUG then
            print('mem:'.. stat(0), 0+Camera.x(), 0, 7)
            print('cpu:'.. stat(1), 0+Camera.x(), 8, 7)
            print('cmdmode: ' .. tostr(IS_IN_CMD_MODE), Camera.x(), 16, 7)
        end

        print("cmds: ", Camera.x(), 24, 7)
        for i=1,#CMDS do
            spr(33 + CMDS[i], Camera.x() + 7 * (i + 2), 22)
        end
        print('wave:'.. GameState.wv, 90+Camera.x(), 0, 2)
        print('hp:'.. Tower._hp, 90+Camera.x(), 8, 2)
        print('jelly:'.. GameState.jelly, 90+Camera.x(), 16, 11)
        print('aliens:'.. GameState.enemies, 90+Camera.x(), 24, 3)
        if Tower._hp <= 0 then
            Camera.scr_shk_str=0
            print('game over', 50+Camera.x(), 64, 7)
            return
        end
        if GameState.cur < 100 then
            print(''.. (GameState.cur/10), 64+Camera.x(), 64, 7)
        end
    end,
    x = function()
        return Camera._x + (rnd (Camera.scr_shk_str*2)) - Camera.scr_shk_str
    end,
    y = function()
        return Camera._y + (rnd (Camera.scr_shk_str*2)) - Camera.scr_shk_str
    end
}

GameState = {
    wv = 0,
    wv_time = WAVE_TIME,
    cur = 100,
    jelly = 0,
    enemies=0,
    update = function()
        GameState.cur = GameState.cur - 1
        if GameState.cur <= 0 then
            GameState.cur = GameState.wv_time
            GameState.wv = GameState.wv+1
            GameState.next_wave()
        end
    end,
    next_wave = function()
        local spawn=GameState.wv*2
        GameState.enemies = GameState.enemies+spawn
        for i = 1,spawn do
            local x = 100+(rnd(64))
            EnemyFactory.createWeakling(x, GROUND_Y)
        end
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
    pod.landed_t = time()
    Camera.shake()
    sfx(1)
end

GFXFactory = {
    create = function(x, y, spr_start, spr_end, frame_per_spr)
        gfx = {
            _x = x,
            _y = y,
            spr_start = spr_start,
            spr_end = spr_end,
            frame_per_spr = frame_per_spr,
            frame_ctr = 0,
            spr_ctr = 0
        }
        add(GFXS, gfx)
        return gfx
    end
}

function update_gfx(gfx)
    gfx.frame_ctr += 1
    if gfx.frame_ctr == gfx.frame_per_spr then
        if gfx.spr_ctr == gfx.spr_end - gfx.spr_start then
            del(GFXS, gfx)
        else
            gfx.frame_ctr = 0
            gfx.spr_ctr += 1
        end
    end
end

function draw_gfx(gfx)
    print('gfx: ' .. tostr(gfx.spr_ctr + gfx.spr_start) .. " - " .. tostr(gfx._x) .. " " .. tostr(gfx._y), Camera.x(), 50, 7)
    spr(gfx.spr_start + gfx.spr_ctr, gfx._x, gfx._y)
end

AntiPersonnelTurretFactory = {
    create = function(x, y)
        t = {
            _x = x,
            _y = y,
            dir = 1,
            cdwn = 0,
            speed = AP_SHOOT_SPEED,
            hp = AP_HP,
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
        min = AP_RANGE
        closest = nil
        for e in all(ENEMIES) do
            dx = e._x - t._x
            if abs(dx) < abs(min) and dx > -32 then
                min = dx
                closest = e
            end
        end
        if abs(min) < AP_RANGE then
            if min < 0 then t.dir = -1 else t.dir = 1 end
            BulletFactory.create(x+t.dir*3,y+3,AP_DMG,3*t.dir)
            sfx(2)
            t.shooting = true
            t.cdwn = t.speed
        end
    end
end

damage_anti_personnel_turret = function(t, dmg)
    t.hp = t.hp - dmg
    if t.hp <= 0 then del(ANTI_P_TURRETS, t) end
end

draw_anti_personnel_turret = function(t)
    local flip = t.dir < 0
    if t.shooting then
        spr(18, t._x, t._y, 1, 1, flip)
    else
        spr(17, t._x, t._y, 1, 1, flip)
    end
end

Tower = {
    _x = 0,
    _y = GROUND_Y,
    _h = 6,
    _hp = TWR_HP,
    _blink_t = 30,
    _is_red = false,
    update = function()
        Tower._blink_t -= 1
        if Tower._blink_t <= 0 then
            if not Tower._is_red then
                Tower._is_red = true
                Tower._blink_t = 5
            else
                Tower._is_red = false
                Tower._blink_t = 30
            end
        end
    end,
    damage = function(hp)
        if Tower._hp < TWR_DANGER_ZONE then
            Camera.shake()
        end
        Tower._hp = Tower._hp - hp
    end,
    draw = function()
        spr(32, Tower._x, Tower._y)
        for i=1,Tower._h-2 do
            spr(16, Tower._x, Tower._y - 8 * i)
        end
        if Tower._is_red then pal(12, 1) end
        spr(0, Tower._x, Tower._y - 8 * (Tower._h - 1))
        pal()
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
        for j in all(ALIEN_JELLY) do
        if abs(Player._x - j._x) < 3 then
            GameState.jelly = GameState.jelly + 1
            del(ALIEN_JELLY, j)
            sfx(4)
        end
    end
    end,
    move = function(dx, dy)
        Player._x = Player._x + dx*PLR_SPEED
        if dx > 0 then Player.dir = 1 else Player.dir = -1 end
        Player._y = Player._y + dy*PLR_SPEED
    end,
    shoot = function()
        if Player.cldn <= 0 then
            Player.cldn = PLR_SHOOT_SPEED
            BulletFactory.create(Player._x, Player._y, 5, Player.dir*5)
            sfx(2)
        end
    end,
    draw = function()
        rectfill(Player._x,Player._y,Player._x+Player._w,Player._y+Player._h,5)
    end,
}

JellyFactory = {
    create = function(x,y)
        j = {
            _x=x,
            _y=y,
            _o=0
        }
        add(ALIEN_JELLY, j)
        return j
    end

}

draw_jelly = function(j)
    circfill(j._x, j._y+sin(j._o), 1, 11)
end

update_jelly = function(j)
    j._o = j._o + 0.1
    if j._o > 1 then j._o = 0 end
end

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
    createWeakling = function(x)
        e = {
            _x = x,
            _y = GROUND_Y,
            _hp = WK_HP,
            _cdwn = 0
        }
        add(ENEMIES, e)
        return e
    end
}

function update_enemy(enemy)
    min = Tower._x - enemy._x
    dy = Tower._y - enemy._y

    if enemy._cdwn > 0 then
        enemy._cdwn = enemy._cdwn - 1
        return
    end

    if abs(min) < 3 then
        Tower.damage(WK_DMG)
        enemy._cdwn = WK_ATK_SPEED
        sfx(3)
        return
    end
    closest = nil
    for t in all(ANTI_P_TURRETS) do
        dx = t._x - enemy._x
        if abs(dx) < abs(min) then
            closest = t
            min = dx
        end
    end
    if min > 0 then
        enemy._x = enemy._x+WK_SPEED
    else
        enemy._x = enemy._x-WK_SPEED
    end
    if abs(min) < 3 and closest then
        damage_anti_personnel_turret(closest, WK_DMG)
        enemy._cdwn = WK_ATK_SPEED
        sfx(3)
    end
    -- if dy > 0 then
    --     enemy._y = enemy._y+1
    -- else
    --     enemy._y = enemy._y-1
    -- end

end

function draw_enemy(enemy)
    rectfill(enemy._x, enemy._y, enemy._x+4, enemy._y+4,8)
end

function damage_enemy(enemy, dmg)
    enemy._hp = enemy._hp - dmg
    if enemy._hp <= 0 then
        JellyFactory.create(enemy._x, enemy._y)
        del(ENEMIES, enemy)
        GameState.enemies = GameState.enemies - 1
    end
end

CMD_TO_POD[{0, 1 , 2, 1}] = AntiPersonnelTurretFactory.create

function check_cmds(cmds)
    for candidate, factory in pairs(CMD_TO_POD) do
        local same = true
        assert(#cmds == #candidate)
        assert(#cmds == CMDS_MAX)
        for i=1,#cmds do
            if candidate[i] ~= cmds[i] then
                same = false
                break
            end
        end

        if same then
            PodFactory.create(Player._x, factory)
            GFXFactory.create(Tower._x + 5, Tower._y + 8 * Tower._h, 48, 53, 4)
            return
        end
    end
end

function update_cmds()
    if btnp(4) then
        IS_IN_CMD_MODE = not IS_IN_CMD_MODE
        CMDS = {}
    end

    if IS_IN_CMD_MODE then
        if #CMDS == CMDS_MAX then
            check_cmds(CMDS)
            LOCKED_BTN = CMDS[#CMDS]
            CMDS = {}
            IS_IN_CMD_MODE = false
        else
            for i=0,5 do
                if i != 4 and i != 5 and btnp(i) then add(CMDS, i) end
            end
        end
    end
end

function _update()
    if Tower._hp <= 0 then return end

    update_cmds()

    for gfx in all(GFXS) do
        update_gfx(gfx)
    end
    for p in all(PODS) do
        update_pod(p)
    end
    for t in all(ANTI_P_TURRETS) do
        update_anti_personnel_turret(t)
    end
 if (sbtn(0)) then
    Camera.move(-1, 0)
    Player.move(-1, 0)
 end
 if (sbtn(1)) then
    Camera.move(1, 0)
    Player.move(1, 0)
 end
 --if (sbtn(2)) then Camera.move(0, -1) end
 --if (sbtn(3)) then Camera.move(0, 1) end
 if (sbtn(5)) then Player.shoot() end
 Tower.update()
 Camera.update()
 Player.update()
 GameState.update()
 for e in all (ENEMIES) do
    update_enemy(e)
 end
 for b in all (BULLETS) do
    if update_bullet(b, ENEMIES) then del(BULLETS, b) end
 end
 for j in all (ALIEN_JELLY) do
    update_jelly(j)
 end
end

function _draw()
 cls(1)
 rectfill(-20+Camera.x(),99+Camera.y(),140+Camera.x(),130+Camera.y(),4)
 circfill(stone_x%127,stone_y%127,2,6)
 Player.draw()
 Camera.draw()
 Tower.draw()

 for gfx in all(GFXS) do
    draw_gfx(gfx)
 end
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
 for j in all (ALIEN_JELLY) do
    draw_jelly(j)
 end
end
