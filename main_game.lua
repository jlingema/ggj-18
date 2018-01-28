DEBUG = true
DEBUG_JELLY = 20

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

WALL_HP = 250

BTW_WAVE_TIME = 10 * 30 -- 10 sec at 30 fps
AP_DMG = 1
AP_SHOOT_SPEED = 5
AP_HP = 10
AP_RANGE=48

PLR_HP = 30
PLR_HEAL = 5 / 30 -- health back per sec
PLR_SAFE_TIME_BEFORE_HEAL = 3
PLR_DMG = 2
PLR_SPEED = 1
PLR_SHOOT_SPEED = 10 -- larger = slower
PLAYER_LOCKED = true
PLAYER_POD = nil
PLAYER_BASE_Y = 99

WK_DMG = 2
WK_HP = 10
WK_ATK_SPEED = 5
WK_SPEED = 0.5
WK_SPRITE_START=9

TNK_DMG = 10
TNK_HP = 20
TNK_ATK_SPEED = 10
TNK_SPEED = 0.25
TNK_SPRITE_START=41


PODS = {}
POD_SPOT = {}
WALLS = {}
ANTI_P_TURRETS = {}
WEAKLINGS = {}
TANKS = {}
BULLETS = {}
GFXS = {}

CMD_TO_POD = {}
SMOKE = {}

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
        if PLAYER_LOCKED then
            Camera._x = PLAYER_POD.x-64
            Camera._y = PLAYER_POD.y - PLAYER_BASE_Y
            Camera.scr_shk_str = 2
        else
            Camera._x = PLAYER._x-64
            Camera._y = PLAYER._y - PLAYER_BASE_Y
        end
        if(Camera.scr_shk_str > 0.1) then Camera.scr_shk_str=Camera.scr_shk_str*0.6
        else Camera.scr_shk_str=0 end
        camera(Camera.x(), Camera.y())
    end,
    -- move = function(dx,dy)
    --     Camera._x = Camera._x + dx
    --     Camera._y = Camera._y + dy
    -- end,
    shake = function()
        Camera.scr_shk_str = 4
    end,
    draw = function()
        if DEBUG then
            print('mem:'.. stat(0), 0+Camera.x(), 0, 7)
            print('cpu:'.. stat(1), 0+Camera.x(), 8, 7)
            print('cmdmode: ' .. tostr(IS_IN_CMD_MODE), Camera.x(), 16, 7)
            -- print('spots: ', Camera.x(), 32, 7)
            -- local i = 1
            -- for k, v in pairs(POD_SPOT) do
            --     print(tostr(k), Camera.x() + 8 * (i + 1) + 15, 35, 7)
            --     i += 1
            -- end
        end

        print("cmds: ", Camera.x(), 24, 7)
        for i=1,#CMDS do
            spr(33 + CMDS[i], Camera.x() + 7 * (i + 2), 22)
        end
        local right_offset = 90+Camera.x()
        print('wave:'.. GameState.wv, right_offset, 0, 2)
        if (GameState.cur < BTW_WAVE_TIME) then
            print('next:'.. ceil(GameState.cur / 30), right_offset, 8, 7)
        end
        print('hp:'.. Tower._hp, right_offset, 16, 2)
        print('jelly:'.. GameState.jelly, right_offset, 24, 11)
        print('aliens:'.. GameState.enemies, right_offset, 32, 3)
        if Tower._hp <= 0 then
            Camera.scr_shk_str=0
            print('game over', 50+Camera.x(), 64, 7)
            return
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
    wv_time = BTW_WAVE_TIME,
    cur = 100,
    jelly = 0,
    enemies=0,
    update = function()
        if #WEAKLINGS + #TANKS == 0 then
            GameState.cur -= 1
            if GameState.cur <= 0 then
                GameState.cur = GameState.wv_time
                GameState.wv = GameState.wv+1
                GameState.next_wave()
            end
        end
    end,
    next_wave = function()
        local spawn=GameState.wv*2
        GameState.enemies = GameState.enemies+spawn
        for i = 1,spawn do
            local x = 0
            if i%2 == 0 then
                x = -128-(rnd(32))
            else
                x = 128+(rnd(32))
            end
            EnemyFactory.create_weakling(x)
        end
    end
}

if DEBUG then
    GameState.jelly = DEBUG_JELLY
end

PodFactory = {
    create = function(x, size, spawn_func, force_y)
        p = {
            x = x,
            y = PODS_ORIG_Y + rnd(PODS_Y_RAND * 2) - PODS_Y_RAND,
            obj_size = size,
            speed = 6,
            spark_idx = -1,
            landed = false,
            landed_t,
            spawn_func = spawn_func
        }
        if force_y != nil then p.y = force_y end
        add(PODS, p)
        set_pod_spot_occupied(x, size)
        sfx(0)
        return p
    end
}

update_pod = function(pod)
    pod.y = pod.y + pod.speed
    if pod.y >= GROUND_Y and not pod.landed then land_pod(pod) end

    if pod.spark_idx >= 0 then pod.spark_idx += 1 end
    if pod.spark_idx == 15 then pod.spark_idx = -1 end
    if not pod.landed then
        r = rnd(5)
        if r <= 2 then
            SmokeFactory.create(pod.x, pod.y, 6)
        end
    end
    if pod.landed and (time() - pod.landed_t > 1) then
        pod.spawn_func(pod.x, pod.y, pod.obj_size)
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
    spr(gfx.spr_start + gfx.spr_ctr, gfx._x, gfx._y)
end

WallFactory = {
    create = function(x, y, size)
        w = {
            _x = x,
            _y = y,
            size = size,
            dir = 1,
            hp = WALL_HP,
            _table = WALLS
        }
        if Tower._x > x then w.dir = -1 end
        add(WALLS, w)
        return w
    end
}

function update_wall(w)
end

function draw_wall(w)
    -- todo draw HP using the health bar function
    spr(19, w._x, w._y, 1, 1, w.dir < 0)
    if w.hp < WALL_HP then draw_healthbar(w._x, w._y, w.hp / WALL_HP) end
end

AntiPersonnelTurretFactory = {
    create = function(x, y, size)
        t = {
            _x = x,
            _y = y,
            size = size,
            dir = 1,
            cdwn = 0,
            speed = AP_SHOOT_SPEED,
            hp = AP_HP,
            shooting = false,
            _table = ANTI_P_TURRETS
        }
        add(ANTI_P_TURRETS, t)
        return t
    end
}

update_anti_personnel_turret = function(t)
    t.cdwn = t.cdwn - 1
    t.shooting=false
    if t.cdwn <= 0 then
        result = _find_closest(TANKS, t._x, nil)
        result = _find_closest(WEAKLINGS, t._x, result.entity)
        if abs(result.dist) < AP_RANGE then
            if result.dist < 0 then t.dir = -1 else t.dir = 1 end
            BulletFactory.create(t._x+t.dir*3, t._y+3, AP_DMG, 3*t.dir)
            sfx(2)
            t.shooting=true
            t.cdwn=t.speed
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

    if t.hp < AP_HP then draw_healthbar(t._x, t._y, t.hp / AP_HP) end
end

-- Damage for different entities that have similarely built tables (_x, _y, _table, ...)

damage = function(e, dmg)
    e.hp = e.hp - dmg
    SmokeFactory.create(e._x, e._y, 9)
    if e.hp <= 0 then
        del(e._table, e)
        set_pod_spot_free(e._x, e.size)
        Camera.shake()
    end
end

Tower = {
    _x = 0,
    _y = GROUND_Y,
    _h = 8,
    _hp = TWR_HP,
    _blink_t = 30,
    _is_red = false,
    update = function()
        set_pod_spot_occupied(Tower._x, 10)
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
        SmokeFactory.create(Tower._x, Tower._y, 9)
    end,
    draw = function()
        spr(55, Tower._x, Tower._y)
        spr(56, Tower._x+8, Tower._y)
        spr(39, Tower._x, Tower._y-8)
        for i = 2,Tower._h-2 do
            spr(23, Tower._x, Tower._y-8*i)
        end
        if Tower._is_red then pal(12, 6) end
        spr(7, Tower._x, Tower._y-56)
        pal()
    end
}

SmokeFactory = {
    create = function(x,y,c)
        s = {
            _x=x,
            _y=y,
            _c=0,
            _clr=c
        }
        add(SMOKE, s)
        return s
    end
}

update_smoke = function(s)
    s._y = s._y - rnd(2)
    s._x = s._x - 2*rnd(2) + 2
    r = 15+rnd(60)
    s._c = s._c + 1
    if r < s._c then
        del(SMOKE, s)
    end
end

draw_smoke = function(s)
    rectfill(s._x, s._y, s._x+1, s._y+1,s._clr)
end

PlayerFactory = {
    create = function(x, y, size)
        pl = {
            _x = x,
            _y = y,
            _w = 2,
            _h = 5,
            _spr_idx=0,
            _frames_per_spr=5,
            _frame_ctr=0,
            dir=1,
            cldn=0,
            moving=false,
            _hp=PLR_HP,
            _last_dmg_t = -PLR_SAFE_TIME_BEFORE_HEAL
        }
        PLAYER = pl
        PLAYER_LOCKED = false
        PLAYER_POD = nil
        return pl
    end
}

player_update = function()
    if PLAYER.moving then
        PLAYER._frame_ctr += 1
    end

    if time() - PLAYER._last_dmg_t >= PLR_SAFE_TIME_BEFORE_HEAL then
        PLAYER._hp += PLR_HEAL
        if PLAYER._hp > PLR_HP then
            PLAYER._hp = PLR_HP
        end
    end

    PLAYER.cldn = PLAYER.cldn - 1
    if PLAYER.cldn < 0 then PLAYER.cldn = 0 end
    for j in all(ALIEN_JELLY) do
        if abs(PLAYER._x - j._x) < 3 then
            GameState.jelly = GameState.jelly + 1
            del(ALIEN_JELLY, j)
            sfx(4)
        end
    end
    PLAYER.moving=false
end

player_move = function(dx, dy)
    if PLAYER.cldn > 0 then
        return
    end
    PLAYER._x = PLAYER._x + dx*PLR_SPEED* max(PLAYER._hp / PLR_HP, 0.6)
    if dx > 0 then PLAYER.dir = 1 else PLAYER.dir = -1 end
    PLAYER._y = PLAYER._y + dy*PLR_SPEED
    PLAYER.moving=true
end

player_shoot = function()
    if PLAYER.cldn <= 0 then
        PLAYER.cldn = PLR_SHOOT_SPEED
        BulletFactory.create(PLAYER._x, PLAYER._y, 5, PLAYER.dir*5)
        sfx(2)
    end
end

player_draw = function()
    local flip = PLAYER.dir < 0
    if PLAYER._frame_ctr > PLAYER._frames_per_spr then
        PLAYER._frame_ctr = 0
        PLAYER._spr_idx = (PLAYER._spr_idx+1)%2
    end
    if PLAYER._hp < PLR_HP then
        perc = PLAYER._hp / PLR_HP
        draw_healthbar(PLAYER._x, PLAYER._y, perc)
    end
    if PLAYER.cldn > 0 then
        spr(27, PLAYER._x, PLAYER._y, 1, 1, flip)
        return
    end
    spr(25+PLAYER._spr_idx, PLAYER._x, PLAYER._y, 1, 1, flip)
    -- rectfill(PLAYER._x,Player._y,Player._x+Player._w,Player._y+Player._h,5)
end

player_damage = function(dmg)
    PLAYER._hp = PLAYER._hp - dmg
    PLAYER._last_dmg_t = time()

    -- could add a timer and have a death animation / effect instead of suddenly popping a pod
    if PLAYER._hp <= 0 then
        PLAYER_POD = PodFactory.create(10, 0, PlayerFactory.create, -200)
        PLAYER_LOCKED = true
        PLAYER = nil
    end
end

draw_healthbar = function(x,y,percent)
    xmin = x
    xmax = x + 8
    rectfill(xmin, y, xmax, y-1, 0)
    xmax = xmin + percent * 8
    rectfill(xmin, y, xmax, y-1, 8)
end

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
    local dir = 1
    if pre_x > bullet.x then dir = -1 end
    bullet.y = bullet.y-1
    if bullet.y < GROUND_Y+4 then bullet.y = GROUND_Y+4 end
    for e in all (enemies) do
        if dir > 0 then
            if pre_x < e._x and e._x <= bullet.x then
                damage_enemy(e, bullet.dmg)
                return true
            end
        else
            if pre_x > e._x and e._x >= bullet.x then
                damage_enemy(e, bullet.dmg)
                return true
            end
        end
        -- if (e._x > pre_x and e._x < bullet.x) or (e._x < pre_x and e._x > bullet.x) then
        --     damage_enemy(e, bullet.dmg)
        --     return true
        -- end
    end
    return false
end

function draw_bullet(bullet)
    rectfill(bullet.x, bullet.y, bullet.x, bullet.y,9)
end

EnemyFactory = {
    create_weakling = function(x)
        e = {
            _x = x,
            _y = GROUND_Y,
            hp = WK_HP,
            max_hp=WK_HP,
            speed=WK_SPEED,
            atk_speed=WK_ATK_SPEED,
            dmg=WK_DMG,
            _table=WEAKLINGS,
            _cdwn = 0,
            _sprite_idx=0,
            _frame_per_sprite=10,
            _frame_ctr=0,
            _sprite_strt=WK_SPRITE_START,
            _dir=1
        }
        add(WEAKLINGS, e)
        return e
    end,
    create_tank = function(x)
        e = {
            _x = x,
            _y = GROUND_Y,
            hp = TNK_HP,
            max_hp=TNK_HP,
            speed=TNK_SPEED,
            atk_speed=TNK_ATK_SPEED,
            dmg=TNK_DMG,
            _table=TANKS,
            _cdwn = 0,
            _sprite_idx=0,
            _frame_per_sprite=15,
            _frame_ctr=0,
            _sprite_strt=TNK_SPRITE_START,
            _dir=1
        }
        add(TANKS, e)
        return e
    end
}

if DEBUG then
    EnemyFactory.create_tank(5)
end

function _find_closest(t, from_x, current_closest)
    min_dist = 9999 -- outch
    if current_closest != nil then min_dist = current_closest._x - from_x end
    for e in all(t) do
        dx = e._x - from_x
        if abs(dx) < abs(min_dist) then
            min_dist = dx
            current_closest = e
        end
    end
    return {dist=min_dist, entity=current_closest}
end

function update_enemy(enemy)
    enemy._frame_ctr += 1
    if enemy._cdwn > 0 then
        enemy._cdwn = enemy._cdwn - 1
        return
    end

    result = _find_closest(ANTI_P_TURRETS, enemy._x, nil)
    result = _find_closest(WALLS, enemy._x, result.entity)

    tower_dist = Tower._x - enemy._x
    if abs(tower_dist) <= abs(result.dist) then
        result.entity = nil
    end

    if not PLAYER_LOCKED then
        abs_player_dist = abs(PLAYER._x - enemy._x)
        if abs_player_dist < abs(tower_dist) and abs(tower_dist) > 8 then
            if (PLAYER._x < enemy._x and enemy._x < Tower._x) or (Tower._x < enemy._x and enemy._x < PLAYER._x) then
                if PLAYER._x < enemy._x then
                    enemy._x = enemy._x-enemy.speed
                else
                    enemy._x = enemy._x+enemy.speed
                end
                return
            end
            if abs_player_dist < abs(result.dist) and abs_player_dist < 3 then
                enemy._cdwn = enemy.atk_speed
                player_damage(enemy.dmg)
                sfx(3)
                return
            end
        end
    end

    if result.entity != nil then
        -- Entity closer than tower or player
        if result.dist > 0 then
            enemy._x = enemy._x+enemy.speed
        else
            enemy._x = enemy._x-enemy.speed
        end
        if abs(result.dist) < 3 then
            damage(result.entity, enemy.dmg)
            enemy._cdwn = enemy.atk_speed
            sfx(3)
        end
    else
        -- walk torwards tower
        if tower_dist > 0 then
            enemy._x = enemy._x+enemy.speed
        else
            enemy._x = enemy._x-enemy.speed
        end

        if abs(tower_dist) < 3 then
            Tower.damage(enemy.dmg)
            enemy._cdwn = enemy.atk_speed
            sfx(3)
            return
        end
    end
end

function draw_enemy(enemy)
    if enemy._frame_ctr > enemy._frame_per_sprite then
        enemy._sprite_idx = (1+enemy._sprite_idx)%2
        enemy._frame_ctr=0
    end
    local flip = enemy._dir > 0
    if enemy._cdwn > 0 then
        spr(enemy._sprite_strt+2, enemy._x, enemy._y, 1, 1, flip)
        return
    end
    if enemy.hp < enemy.max_hp then
        perc = enemy.hp / enemy.max_hp
        draw_healthbar(enemy._x, enemy._y, perc)
    end
    spr(enemy._sprite_strt + enemy._sprite_idx, enemy._x, enemy._y, 1, 1, flip)
    -- rectfill(enemy._x, enemy._y, enemy._x+4, enemy._y+4,8)
end


function damage_enemy(enemy, dmg)
    enemy.hp = enemy.hp - dmg
    if enemy.hp <= 0 then
        JellyFactory.create(enemy._x, enemy._y)
        del(enemy._table, enemy)
        GameState.enemies = GameState.enemies - 1
    end
end

-- Where pods come to existence!

function set_pod_spot_free(x, size)
    local s2 = ceil(size / 2)
    for i=-s2,s2 do
        POD_SPOT[x+i] = nil
    end
end

function set_pod_spot_occupied(x, size)
    local s2 = ceil(size / 2)
    for i=-s2,s2 do
        POD_SPOT[x+i] = true
    end
end

function is_pod_spot_free(x, size)
    if size == 0 then return true end

    local s2 = ceil(size / 2)
    for i=-s2,s2 do
        if POD_SPOT[x+i] then return false end
    end

    return true
end

CMD_TO_POD[{0, 1 , 2, 1}] = {size=4, price=2, factory=AntiPersonnelTurretFactory.create}
CMD_TO_POD[{0, 3, 2, 3}] = {size=4, price=6, factory=WallFactory.create}

function check_cmds(cmds)
    for candidate, cfg in pairs(CMD_TO_POD) do
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
            -- Check if the spot is free
            if GameState.jelly < cfg.price then
                -- error GFX
                -- error SFX
                return
            end

            if not is_pod_spot_free(PLAYER._x, cfg.size) then
                -- error GFX?
                -- error SFX
                return
            end

            PodFactory.create(PLAYER._x, cfg.size, cfg.factory)
            GameState.jelly -= cfg.price
            GFXFactory.create(Tower._x + 5, Tower._y - 8 * Tower._h + 3, 48, 53, 4)
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

    if not PLAYER_LOCKED then
        if (sbtn(0)) then
            player_move(-1, 0)
         end
         if (sbtn(1)) then
            player_move(1, 0)
         end

        player_update()
    end

    for gfx in all(GFXS) do
        update_gfx(gfx)
    end
    for p in all(PODS) do
        update_pod(p)
    end
    for w in all(WALLS) do
        update_wall(wall)
    end
    for t in all(ANTI_P_TURRETS) do
        update_anti_personnel_turret(t)
    end
 --if (sbtn(2)) then Camera.move(0, -1) end
 --if (sbtn(3)) then Camera.move(0, 1) end
 if (sbtn(5)) then player_shoot() end
 Tower.update()
 Camera.update()
 GameState.update()
 for e in all (WEAKLINGS) do
    update_enemy(e)
 end
 for e in all (TANKS) do
    update_enemy(e)
 end
 for b in all (BULLETS) do
    if update_bullet(b, WEAKLINGS) then del(BULLETS, b) end
    if update_bullet(b, TANKS) then del(BULLETS, b) end
 end
 for j in all (ALIEN_JELLY) do
    update_jelly(j)
 end
 for s in all (SMOKE) do
    update_smoke(s)
 end
end

function _draw()
 cls(1)
 rectfill(-20+Camera.x(),99+Camera.y(),140+Camera.x(),130+Camera.y(),4)
 circfill(stone_x%127,stone_y%127,2,6)

 if not PLAYER_LOCKED then player_draw() end

 Camera.draw()
 Tower.draw()

 for gfx in all(GFXS) do
    draw_gfx(gfx)
 end
 for p in all(PODS) do
    draw_pod(p)
 end
 for w in all(WALLS) do
    draw_wall(w)
 end
 for t in all(ANTI_P_TURRETS) do
    draw_anti_personnel_turret(t)
 end
 for e in all (WEAKLINGS) do
    draw_enemy(e)
 end
 for e in all (TANKS) do
    draw_enemy(e)
 end
 for b in all (BULLETS) do
    draw_bullet(b)
 end
 for j in all (ALIEN_JELLY) do
    draw_jelly(j)
 end
 for s in all (SMOKE) do
    draw_smoke(s)
 end
end

-- GGJ 2018 logo by Dylan Bennett https://gist.github.com/MBoffin/0ad8ffc850fb797fe2d90fcc98d81492

function _init()
    if not DEBUG then
        show_ggj_logo(34,2.5,10)
    end

    PLAYER_POD = PodFactory.create(10, 0, PlayerFactory.create, -200)
    PLAYER_LOCKED = true
end

function show_ggj_logo(ggjy,ggjw,ggjs)
    ggjw=90+ggjw*30*ggjs
    for i=20-ggjw,110,ggjs do cls(1) clip(i,ggjy,ggjw,62) draw_ggj_logo(ggjy) flip() end
    cls()
end

function draw_ggj_logo(ggjy)
    logo="00000000000000777770000000000000000aaaaa000cc77c7ccccc000000000000aaaaaaaa777cccccccccc0000000000aaa000aaaa77777cccccccc00000000aaa000007aaa7777ccccccccc0000000aa00000777aaa777cccccccc77000000aa000007777aaa7ccccccccc77000000aa0000c77777aaacccccc777ccc00000aaa000c777777aaacccc77777c7000000aaa00cc7777ccaaaccc77777770000000aaaacc777ccccaaacc7777777aaa00000aaacc77ccccccaaacc777777aaaa0000000cc77cccccccaaacc7777700aaa000000cc77ccccccccaaac77777000aa0000000c77cccccccccaaa77770000aa0000000c77ccccccccccaaa777000aaa00000000cc7ccccccccc7aaaa000aaa0000000000cccccccccc777aaaaaaaa000000000000cccccccccc7770aaaaa00000000000000ccccccccccc000000000000000000000000ccccc"
    for i=1,#logo do if (sub(logo,i,i)!="0") pset(48+((i-1)%32),ggjy+16+flr((i-1)/32),tonum("0x"..sub(logo,i,i))) end
    for i=-1,1 do for j=-1,1 do print("game born at",40+i,ggjy+1+j,0) print("global game jam",34+i,ggjy+47+j,0) end end
    print("game born at",40,ggjy+1,13) print("global game jam",34,ggjy+47,7) print("www.globalgamejam.org",22,ggjy+57,13)
end
