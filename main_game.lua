x = 64  y = 64
scr_shk_str = 0
function _update()
 if (btn(0)) then x=x-1 end
 if (btn(1)) then x=x+1 end
 if (btn(2)) then y=y-1 end
 if (btn(3)) then y=y+1 end
 if (btn(4)) then scr_shk_str=scr_shk_str+4 end
 if(scr_shk_str > 0.1) then  scr_shk_str=scr_shk_str*0.6
 else scr_shk_str=0 end
end

function _draw()
 x_random = (rnd (scr_shk_str*2)) - scr_shk_str
 y_random = (rnd (scr_shk_str*2)) - scr_shk_str
 rectfill(0,0,127,127,1)
 circfill((x+x_random)%127,(y+y_random)%127,2,4)
end
