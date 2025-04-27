pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- constants for flags on tiles
FLAG_SOLID = 1
FLAG_LADDER = 2
FLAG_checkpoint = 3
start_x = 40 * 8
start_y = 20 * 8

function _init()
    music(0, 0, 1)
    -- display palette remap
    pal(1, 129, 1)
    pal(2, 130, 1)
    pal(9, 142, 1)
    pal(10, 134, 1)
    pal(11, 131, 1)
    pal(12, 128, 1)
    pal(14, 135, 1)

    -- draw palette untouched for now, unless you need it

    -- make black transparent for sprites
    -- palt(0,false)

    -- carmilla initial state
    carmilla = {
        sp = 1,
        x=40 * 8,
        y=20 * 8,
        w = 8,
        h = 8,
        flipped = false,
        climbing = false,
        gliding = false,
        falling = false,
        landed = false,
        running = false,
        jumping = false,
        dx = 0,
        dy = 0,
        max_dx = 2,
        max_dy = 3,
        acc = .5,
        boost = 3.5,
        anim = 0,
        lives = 3,
        delivered_items = 0,
        gloves = false,
        glide_dir = 1, -- controls ping-pong of gliding
        inventory = {},
        checkpoint = {},
        has_gloves = false,
            --      checkpoint_reached = false

    }

    checkpoint_message_timer = 0
    checkpoint_message_duration = 15
   

   -- carmilla.checkpoint = {x = carmilla.x, y = carmilla.y}

    --map limits
    map_start = 0
    map_end = 1024 -- change this

    gravity = 0.3
end

function apply_difficulty()
    if difficulty == "easy" then
        anim_timer = 0  -- global anim_timer for npc animation
        countdown_timer = 30*60
        carmilla.lives = 15
    elseif difficulty == "hard" then
        anim_timer = 0  -- global anim_timer for npc animation
        countdown_timer = 1*60
        carmilla.lives = 2
    end
end

state = "menu"
states = {}

-- main update function
function _update()
    states[state].update()  -- call the current state's update function
end



-- create list of NPCs
npcs = {
    groundskeeper_npc = {
        x = 58 * 8, y = 17 * 8, w = 8, h = 8,
        spr1 = 37,
        spr2 = 38,
        show_prompt = false,
        talking = false,
        text = "can you get rid\n of the silver\n it hurts",
        alt_text = "thank you for this",
        item_required = {
            name = "silver nugget",
            sprite = 14
        },
        item_recieved = false
    },
    cross_npc = {
        x = 7 * 8, y = 42 * 8, w = 8, h = 8,
        sp1 = 33,
        sp2 = 34,
        show_prompt = false,
        talking = false,
        text = "i think there is\n a cross to the \nright headmistress",
        alt_text = "thank you for this",
        item_required = {
            name = "cross",
            sprite = 28
        },
        item_recieved = false
    },
    silver_nugget_npc = {
        x = 4 * 8, y = 33 * 8, w = 8, h = 8,
        spr1 = 19,
        spr2 = 20,
        show_prompt = false,
        talking = false,
        text = "there's a silver\nnugget somewhere\nto our right.",
        alt_text = "thank you for this",
        item_required = {
            name = "silver nugget",
            sprite = 14
        },
        item_recieved = false
    },
    glide_npc = {
        x = 3 * 8, y = 3 * 8, w = 8, h = 8,
        spr1 = 35,
        spr2 = 36,
        show_prompt = false,
        talking = false,
        text = "headmistress turn into\na bat to get the garlic\nin the sky."
    },
    key_npc = {
        x = 92 * 8, y = 29 * 8, w = 8, h = 8,
        spr1 = 19,
        spr2 = 20,
        show_prompt = false,
        talking = false,
        text = "the key to caverns is\n on the edge of\n grounds to\n the right"
    },
    holy_water_npc = {
        x = 50 * 8, y = 30 * 8, w = 8, h = 8,
        spr1 = 17,
        spr2 = 18,
        show_prompt = false,
        talking = false,
        text = "there is holy\nwater somewhere below.",
        alt_text = "thank you for this",
        item_required = {
            name = "holy water",
            sprite = 12
        },
        item_recieved = false
    },
    intro_npc = {
        x = 45 * 8, y = 23 * 8, w = 8, h = 8,
        spr1 = 17,
        spr2 = 18,
        show_prompt = false,
        talking = false,
        dialogue = {
            "aaaa! please help\nme, miss. we're\nin danger!",
            "my insides are\nburning. carmilla\nit hurts so much!!!",
            "theres garlic and\nsilver everywhere\nget rid of them",
            "before sunrise. van\nhelsing will kill\nus all t t\n        - ...",
            "you need gloves to\nhandle garlic. head\neast. i saw some\non the ground."
        },
        dialogue_index = 1
    }
}


items = {
    {
        x = 42 * 8, y = 5 * 8,
        w = 8, h = 8,
        name = "garlic",
        sprite = 10,
        picked = false
    },
    {
        x=60*8, y=17*8,
        w = 8, h = 8,
        name = "silver nugget",
        sprite = 14,
        picked = false
    },

    {
        x=25*8, y=43*8,
        w = 8, h = 8,
        name = "cross",
        sprite = 28,
        picked = false
    },

    {
        x=26*8, y=37*8,
        w = 8, h = 8,
        name = "silver nugget",
        sprite = 14,
        picked = false
    },

    {
        x=56*8, y=44*8,
        w = 8, h = 8,
        name = "holy water",
        sprite = 12,
        picked = false
    },

    {
        x=89*8, y=28*8,
        w = 8, h = 8,
        name = "gloves",
        sprite = 13,
        picked = false
    },

    {
        x=127*8, y=12*8,
        w = 8, h = 8,
        name = "key",
        sprite = 11,
        picked = false
    },

    {
        x=85*8, y=9*8,
        w = 8, h = 8,
        name = "garlic",
        sprite = 10,
        picked = false
    },

    {
        x=92*8, y=29*8,
        w = 8, h = 8,
        name = "garlic",
        sprite = 10,
        picked = false
    }
}


-- main draw function
function _draw()
   
    cls() 
    -- call the current state's draw function
    states[state].draw()
end


-->8

-- menu state
states.menu = {
    update = function()
        if btnp(❎) then
            difficulty = "easy"
            apply_difficulty()
            state = "game"
        elseif btnp(🅾️) then
            difficulty = "hard"
            apply_difficulty()
            state = "game"
        end
    end,
    
    draw = function()
        camera(0, 0)
        -- sky
   --     draw_sky()
        
        -- drawing clouds that move across screen
        t=time()
        local x=(t*2)%128
        
        -- draw multiple clouds in a row
        for i=0,3 do
            spr(197, (i*31)-x, 0, 8, 4)
            spr(197, (i*32)-x, 20, 6, 4)
        end
         -- change the 3 to the 2 if
         -- you perfer the bush gone
        -- or to 5 if want whole plant
        spr(192, 45, 60, 5, 2)
        
        -- display text
        local e = "press ❎ for easy mode"
        local h = "press 🅾️ for hard mode"
        print(e, 60 - (#e * 2), 80, 7, 0)
        print(h, 60 - (#h * 2), 90, 7, 0)
                       
  -- original house
          spr(205, 40, 96, 4, 4)
       
          -- flipped house (mirrored version)
        spr(205, 64, 96, 4, 4,1)  -- base part of flipped house
       
    
    end
}


-->8

-- game state
states.game = {
    update = function()
        anim_timer += 1
        if countdown_timer > 0 then
            countdown_timer -= 1/30 -- subtract 1 frame
            countdown_timer = max(0, countdown_timer) -- make sure never drops under 0
        end

        if countdown_timer <= 0 and carmilla.lives > 0 then
            carmilla.lives = 0
        end

        --simple cam
        cam_x = carmilla.x-64+(carmilla.w/2)
        if cam_x < map_start then
            cam_x = map_start --makes sure cam never moves farther left than where map starts
        end
        if cam_x > map_end-128 then
            cam_x = map_end-128
        end

        -- player update; add if statement
        update_carmilla()
       -- interactwithnpc()
        

for key, npc in pairs(npcs) do
    local dist = abs(carmilla.x - npc.x) + abs(carmilla.y - npc.y)
    if dist < 12 then
        npc.show_prompt = true

        if btnp(❎) then
            if npc.dialogue then
                -- multi-part dialogue npc
                if npc.talking then
                    npc.dialogue_index += 1
                    if npc.dialogue_index > #npc.dialogue then
                        npc.talking = false
                        npc.dialogue_index = 1
                    end
                else
                    npc.talking = true
                    npc.dialogue_index = npc.dialogue_index or 1
                end
            else
                -- normal text/alt_text npc
                npc.talking = not npc.talking

                if npc.item_required and not npc.item_recieved and npc.talking then
                    for i, item in ipairs(carmilla.inventory) do
                        if item.name == npc.item_required.name then
                            npc.item_recieved = true
                            deli(carmilla.inventory, i)
                            if not npc.alt_text then
                                npc.text = "thank you!"
                            end
                            break
                        end
                    end
                end
            end
        end
    else
        npc.show_prompt = false
        npc.talking = false
        if npc.dialogue then
            npc.dialogue_index = 1
        end
    end
end


       
        cam_y = carmilla.y - 64 + (carmilla.h / 2)
        local max_cam_y = 47*8-128

        if cam_y > max_cam_y then
            cam_y = max_cam_y
        end

        camera(flr(cam_x), flr(cam_y))
      
    end,
    
    
    -- handle drawing
    draw = function()
        cls()
        -- screen is 128x128, each tile is 8 pixels
        map(0,0)   
        
        for item in all(items) do
            if not item.picked then
                spr(item.sprite, item.x, item.y)
            end
                    end
        
        -- draw npcs
        for key, val in pairs(npcs) do
            draw_npc(val)
        end
        
        -- draw carmilla
        draw_carmilla()

        -- draw door
        --draw_door()

        -- reset cam to draw text
        -- display num lives left
        camera()
        print("lives: "..carmilla.lives, 5, 10, 7)

        -- calc mins and secs left
        local mins = flr(countdown_timer / 60)
        local secs = flr(countdown_timer % 60)

        local display_time = mins .. ":" 

        if secs < 10 then
            display_time = display_time .. "0" .. secs
        else
            display_time = display_time .. secs
        end
        if countdown_timer < 30 then

            print(display_time, 5, 18, 8)
        else
            print(display_time, 5, 18, 7)
        end

        if checkpoint_message_timer > 0 then
            checkpoint_message_timer -= 1
            local checkpoint = "checkpoint!"
            local draw_x = carmilla.checkpoint.x - cam_x
            local draw_y = carmilla.checkpoint.y - cam_y - 24
            print(checkpoint, draw_x - (#checkpoint*2), draw_y + 1, 5)
            print(checkpoint, draw_x - (#checkpoint*2), draw_y, 7)
        end

        -- drawing a list of collected and uncollected items
        print("items:", 5, 2, 7)
        local x = 30
        local y = 0
        local draw_index = 0
        for i, item in ipairs(items) do
            if not item.picked then
            spr(item.sprite, x + draw_index*10, y)
            draw_index += 1
            end

        end

    end
}

states.gameover_lost = {
    update = function()
        -- wait for restart input (e.g., button press)
        if btnp(❎) or btnp(🅾️) then
            -- reset the game state
            state = "menu"
            -- reset carmilla's state
            carmilla = {
                sp = 1,
                x=40 * 8,
                y=20 * 8,
                w = 8,
                h = 8,
                flipped = false,
                climbing = false,
                gliding = false,
                falling = false,
                landed = false,
                running = false,
                jumping = false,
                dx = 0,
                dy = 0,
                max_dx = 2,
                max_dy = 3,
                acc = .5,
                boost = 3.5,
                anim = 0,
                lives = 3,
                delivered_items = 0,
                gloves = false,
                glide_dir = 1, -- controls ping-pong of gliding
                inventory = {},
                checkpoint = {},
                has_gloves = false
                            }

            for i, item in ipairs(items) do
                item.picked = false
             end
        end
    end,
    
    draw = function()
        cls(1)  -- clear the screen

        camera(0, 0)


        -- alive van helsing
        spr(46, 72, 90)
        spr(47, 80, 90)
        spr(62, 72, 98)
        spr(63, 80, 98)

        -- dead carmilla
        spr(79, 40, 90) 
        spr(111, 48, 90)
        spr(119, 40, 98)
        spr(95, 48, 98)

        -- crown sprite
        spr(25, 77, 83)


        -- sun sprite
        function draw_sun()
            -- draw a yellow filled circle as the sun
            circfill(64, 64, 12, 14) -- x, y, radius, color

        -- optional: sun rays (spiky look)
            for a=0,1,0.125 do
                local x1 = 64 + cos(a) * 14
                local y1 = 64 + sin(a) * 14
                local x2 = 64 + cos(a) * 18
                local y2 = 64 + sin(a) * 18
                line(x1, y1, x2, y2, 14)
            end
        end

        draw_sun()

        local txt1 = "game over!"
        print(txt1, (128 - #txt1 * 4) / 2, 5, 7)

    -- center and print text
        local txt2a = "van helsing has won!"
        local txt2b = "he has killed all the students!"
        local txt2c = "you have failed!"
        print(txt2a, (128 - #txt2a * 4) / 2, 22, 7)
        print(txt2b, (128 - #txt2b * 4) / 2, 30, 7)
        print(txt2c, (128 - #txt2c *4) / 2, 38, 7)

    -- center "press x to restart" at the bottom
        local txt3 = "press x to try again"
        print(txt3, (128 - #txt3 * 4) / 2, 110, 7)
    end
}

states.gameover_win = {
    update = function()
        -- wait for restart input (e.g., button press)
        if btnp(❎) or btnp(🅾️) then
            -- reset the game state
            state = "menu"
            -- reset carmilla's state
            carmilla = {
                sp = 1,
                x=40 * 8,
                y=20 * 8,
                w = 8,
                h = 8,
                flipped = false,
                climbing = false,
                gliding = false,
                falling = false,
                landed = false,
                running = false,
                jumping = false,
                dx = 0,
                dy = 0,
                max_dx = 2,
                max_dy = 3,
                acc = .5,
                boost = 3.5,
                anim = 0,
                lives = 3,
                delivered_items = 0,
                gloves = false,
                glide_dir = 1, -- controls ping-pong of gliding
                inventory = {},
                checkpoint = {},
                has_gloves = false
                            }
        end
    end,
    
    draw = function()
        cls(1)  -- clear the screen

        camera(0, 0)


        -- dead van helsing
        spr(44, 72, 90)
        spr(45, 80, 90)
        spr(60, 72, 98)
        spr(61, 80, 98)

        -- alive carmilla
        spr(127, 40, 90) 
        spr(15, 48, 90)
        spr(29, 40, 98)
        spr(30, 48, 98)

        -- crown sprite
        spr(25, 45, 83)


        -- sun sprite
        function draw_sun()
            -- draw a yellow filled circle as the sun
            circfill(64, 64, 12, 14) -- x, y, radius, color

        -- optional: sun rays (spiky look)
            for a=0,1,0.125 do
                local x1 = 64 + cos(a) * 14
                local y1 = 64 + sin(a) * 14
                local x2 = 64 + cos(a) * 18
                local y2 = 64 + sin(a) * 18
                line(x1, y1, x2, y2, 14)
            end
        end

        draw_sun()

        local txt1 = "victory!"
        print(txt1, (128 - #txt1 * 4) / 2, 5, 7)

    -- center and print text
        local txt2a = "carmilla has won!"
        local txt2b = "carmilla saved her students!"
        local txt2c = "congratulations!"
        print(txt2a, (128 - #txt2a * 4) / 2, 22, 7)
        print(txt2b, (128 - #txt2b * 4) / 2, 30, 7)
        print(txt2c, (128 - #txt2c *4) / 2, 38, 7)

    -- center "press x to restart" at the bottom
        local txt3 = "press x to play again"
        print(txt3, (128 - #txt3 * 4) / 2, 110, 7)
    end
}

function draw_hb(x, y, w, h, col)
    rect(x, y, x + w - 1, y + h - 1, col or 15)
end

function draw_npc(n)
    local cur_sprite 
    if (anim_timer % 30) < 15 then -- switch betw spr1 and spr2
        cur_sprite = n.spr1
    else
        cur_sprite = n.spr2
    end
    spr(cur_sprite, n.x, n.y)
    
    if n.show_prompt and not n.talking then
        spr(26, n.x + 4, n.y - 8) -- position above npc
    end

    if n.talking then
        -- draw speech bubble
        --rectfill(n.x - 8, n.y - 20, n.x + 40, n.y - 10, 7)  -- background
        --rect(n.x - 8, n.y - 20, n.x + 40, n.y - 10, 0)      -- border
        --print(n.text, n.x - 6, n.y - 18, 0)
                                
                        local text = n.text
                                -- if it's a multi-part dialogue (like intro_npc)
                                if n.dialogue then
                                    text = n.dialogue[n.dialogue_index]
                                elseif n.item_recieved and n.alt_text then
                                    text = n.alt_text
                                end


                                local lines = split(text, "\n")
        --local lines = split(n.text, "\n")
        local padding = 4
        local line_height = 6
        local bubble_width = 80  -- adjust if needed
        
        -- calculate bubble height based on number of lines
        local bubble_height = #lines * line_height + padding
        
        -- top-left and bottom-right coords of bubble
        local bx1 = n.x - 8
        local by1 = n.y - bubble_height - 10
        local bx2 = bx1 + bubble_width
        local by2 = n.y - 10

        -- draw bubble background and border
        rectfill(bx1, by1, bx2, by2, 7)
        rect(bx1, by1, bx2, by2, 0)

        -- draw each line of text
        for i = 1, #lines do
            print(lines[i], bx1 + 2, by1 + 2 + (i - 1) * line_height, 0)
        end
    end
end


function draw_carmilla()
    carmilla_animate()
    spr(carmilla.sp, flr(carmilla.x), flr(carmilla.y), 1, 1, carmilla.flipped)

end


-- check map collision
function collide_map(obj, aim, flag)
    local x = obj.x local y = obj.y
    local w = obj.w local h = obj.h
    
    local x1 = 0    local y1 = 0
    local x2 = 0    local y2 = 0
    
    if aim == "left" then
        x1=x-1  y1=y
        x2=x    y2=y+h-1
    
    elseif aim == "right" then
        x1=x+w-1    y1=y
        x2=x+w  y2=y+h-1
    elseif aim == "up" then
        x1=x+1  y1=y-2
        x2=x+w-2    y2=y
    elseif aim == "down" then
        x1=x+2  y1=y+h
        x2=x+w-3    y2=y+h
    end

    --convert pixels to tiles
    x1/=8   y1/=8
    x2/=8   y2/=8
    
    if fget(mget(x1,y1), flag)
    or fget(mget(x1,y2), flag)
    or fget(mget(x2,y1), flag)
    or fget(mget(x2,y2), flag) then
        return true
    else
        return false
    end
    
end




function update_carmilla()
    local acc = 0.5
    local max_dx = 3
    local friction = 0.7
                
                local tx = flr((carmilla.x + 4) / 8)
                local ty = flr((carmilla.y + 4) / 8)
                if fget(mget(tx, ty), 3) then
                    if not carmilla.checkpoint or carmilla.checkpoint.x ~= carmilla.x or carmilla.checkpoint.y ~= carmilla.y then
                        carmilla.checkpoint.x = carmilla.x
                        carmilla.checkpoint.y = carmilla.y
                        checkpoint_message_timer = checkpoint_message_duration
                        sfx(3)
                    end 
                                                            
                end
                
    -- physics


  if not carmilla.landed and not carmilla.climbing and btn(⬆️) and btn(❎) and carmilla.dy >= 0 then
        carmilla.gliding = true
        carmilla.dy = 0.5
    elseif not carmilla.climbing then
        carmilla.dy += gravity
    elseif carmilla.gliding then
        carmilla.gliding = false
    end

    if carmilla.climbing then
        carmilla.dy *= friction
    end
    -- movement controls
    if btn(⬅️) then 
        --carmilla.dx -= carmilla.acc
        carmilla.dx = max(carmilla.dx - acc, -max_dx)
        carmilla.running = true
        carmilla.flipped=true
    elseif (btn(➡️)) then
        --carmilla.dx += carmilla.acc
        carmilla.dx = min(carmilla.dx + acc, max_dx)
        carmilla.running = true
        carmilla.flipped=false
    elseif btn(⬆️) and carmilla.climbing then
        carmilla.dy = -carmilla.acc
    elseif btn(⬇️) and carmilla.climbing then
        carmilla.dy = carmilla.acc
    else
        carmilla.running = false
        -- friction: slow down when not pressing buttons
        carmilla.dx *= friction

        -- if val of horizontal movement is close to 0, force it to be 0 to prevent sliding
        if abs(carmilla.dx) < 0.05 then 
            carmilla.dx = 0 
        end
    end
    
    for item in all(items) do
    if not item.picked and
       carmilla.x < item.x + item.w and
       carmilla.x + carmilla.w > item.x and
       carmilla.y < item.y + item.h and
       carmilla.y + carmilla.h > item.y then

        item.picked = true
        sfx(0)
        add(carmilla.inventory, {name=item.name, sprite=item.sprite})
        -- optional: play sound, show message, etc.

        if item.name == "gloves" then
            has_gloves = true
        end

        if item.name == "key" then
            spr(110, 52*8, 30*8)
            spr(94, 52*8, 30*8)
        end
    end
    end


    -- jump from pressing z
    if btnp(🅾️) and carmilla.landed then
        sfx(2)
        carmilla.dy-=carmilla.boost
        carmilla.landed=false
        carmilla.jumping = true
        -- check for up collision
    elseif carmilla.jumping then
        carmilla.jumping = false
    end

    -- climbing
    if not carmilla.gliding and collide_map(carmilla, "up", FLAG_LADDER) then
        if btn(⬆️) then
            carmilla.climbing = true
        end
    elseif carmilla.climbing then -- makes sure she isn't climbing forever
        carmilla.climbing = false
    end

    -- check collision up and down
    if carmilla.dy > 0 then
        carmilla.falling = true
        carmilla.landed = false
        -- make sure she's not falling through solid tiles
        if collide_map(carmilla, "down", FLAG_SOLID) then
            carmilla.landed = true
            carmilla.falling = false
            carmilla.gliding = false
            carmilla.dy = 0
            carmilla.y -= ((carmilla.y + carmilla.h + 1) % 8) - 1
        end
    elseif carmilla.dy<0 then
        --carmilla.jumping=true
        if collide_map(carmilla,"up",1) then
            carmilla.dy=0
    
        end
    
    end
  
    -- check collision left and right
    if carmilla.dx < 0 then
        if collide_map(carmilla,"left",FLAG_SOLID) then
            carmilla.dx=0
        end
    elseif carmilla.dx>0 then
        if collide_map(carmilla,"right",FLAG_SOLID) then
            carmilla.dx=0
        end
    end


    carmilla.x += carmilla.dx
    carmilla.y += carmilla.dy -- probably what was causing our issue
    -- vertical movement
    
    local tx = carmilla.x // 8
                local ty = carmilla.y // 8
                
                if fget(mget(tx, ty), 3) then
                    if not carmilla.checkpoint then
                        carmilla.checkpoint = {}
                    end
                    carmilla.checkpoint.x = carmilla.x
                    carmilla.checkpoint.y = carmilla.y
                end


    -- map limit check (y = 368)
 if carmilla.y > 376 then
    carmilla.lives -= 1
    if carmilla.lives > 0 then
         if carmilla.checkpoint then
            carmilla.x = carmilla.checkpoint.x
            carmilla.y = carmilla.checkpoint.y
        else
            -- default spawn position
            carmilla.x = 40 * 8
            carmilla.y = 20 * 8
            carmilla.dx = 0
            carmilla.dy = 0
        end
            
        else
            state = "gameover_lost"
            sfx(1)
        end
    end

    if carmilla.lives == 0 then
        state = "gameover_lost"
        sfx(1)
    end

    if check_all_items_picked() then
        state = "gameover_win"
    end

end

function carmilla_animate()
    -- jumping
    if carmilla.jumping then 
        carmilla.sp = 2

    -- climbing
    elseif carmilla.climbing then
        if btn(⬆️) or btn(⬇️) then
            if time() - carmilla.anim > 0.2 then
                carmilla.anim = time()
                if carmilla.sp ~= 5 and carmilla.sp ~= 6 then
                    carmilla.sp = 5
                elseif carmilla.sp == 5 then
                    carmilla.sp = 6
                else
                    carmilla.sp = 5
                end
            end
        else
            -- not moving on the ladder, hold one frame
            carmilla.sp = 5
        end

    -- gliding
    elseif carmilla.gliding then
        if time() - carmilla.anim > 0.15 then
            carmilla.anim = time()
            if carmilla.sp < 7 or carmilla.sp > 9 then
                carmilla.sp = 7
                carmilla.glide_dir = 1
            else
                carmilla.sp += carmilla.glide_dir
                if carmilla.sp >= 9 then
                    carmilla.glide_dir = -1
                elseif carmilla.sp <= 7 then
                    carmilla.glide_dir = 1
                end
            end
        end

    -- falling
    elseif carmilla.falling then
        carmilla.sp = 1

    -- running
    elseif carmilla.running then
        if time() - carmilla.anim > 0.1 then
            carmilla.anim = time()
            if carmilla.sp < 2 or carmilla.sp >= 4 then
                carmilla.sp = 2
            else
                carmilla.sp += 1
            end
        end

    -- idle
    else
        carmilla.sp = 1
    end
end


function check_all_items_picked()
    for i, item in ipairs(items) do
        if not item.picked then
            return false  -- If any item is not picked, return false
        end
        
        -- Check if the item is picked by the correct NPC
        local npc = npcs[item.required_npc]
        if npc and not npc.item_received then
            return false  -- If the required NPC has not received the item, return false
        end
    end
    return true  -- All items picked and returned to correct NPCs
end




__gfx__
00000000000000000099990000099990000999900099900000099900000000000000000000000000007700000000000000ff990000dd20000055550077700000
00000000009999000998f80000998f8000998f800999990ff0999990500000050000000000000000000770000000000007aa44d00dddd2000566775077777000
000000000998f800099fff000099fff00099fff0f055500ff005550f5500005500000000000000000066760000e000000077dd000dddd2005666677577777700
00000000099fff00099555000095550000955500f55555f00f55555f658008560000000000000000067667600e0eeee007bb11d00dddd2d25666667500040000
00000000099555000058885000588850005888500555550000555550065757605580085505800850676776760e0e0e007bbb111d0dddd2d25666666590040000
000000000058885000588850005888500058885005555500005555500055550006575760055757506767767600e000007bbb111d0ddddd2005666650f0040000
00000000005888500058885000588850005888500555550000555550000000000055550055655655676676760000000007bb11d00dddd2000055550080040000
000000000558885000588850055888505588850000f0f000000f0f0000000000000000000600006006666660000000000777ddd000aa400000000000f0040000
00000000004444000044440000dddd0000dddd000000000000000000000000000000000000000000000000000000000000000000000995555004000000077000
000000000048f8000048f80000d8480000d84800000000000000000000000000000000000000000000077700000000000000000000005888850f000000777700
00000000004fff00004fff000dd444000dd4440000000000000000000000000000000000000000000077777000000000000f40000000588885f0000007777770
00000000044111f0044111000dd676400dd676000000000000000000000000000000000000000000077070770000000000fff400000058888500000007777770
0000000000011100000111000006760000067600000000000000000000000000000000000e0e90900777077700000000000f4000000058888500000000004000
0000000000055500000555000001110000011100000000000000000000000000000000000eef89900770707700000000000f4000000588888850000000004000
00000000000f0f00000f0f0000040400000404000000000000000000000000000000000000ee99000077777000000000000f4000005588888850000000404000
0000000000000000000000000000000000000000000000000000000000000000000000000099440000077700000000000000000000000f00f000000000040000
000000000000000000aaaa0000000000004444000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0000a8f800004444000048f8000f8f804006666040000000000000000000000000000000000000000000000000000000000000005555500000
0000000000a8f80000afff000048f800004fff000ffff0400f8f8040000000000000000000000000000000000000000000000000000000000000005555500000
0000000000afff0000555500004fff000022220001771f400ffff040000000000000000000000000000000000000000000000000000000000000055555550000
00000000003333000035330000dddd0000dddd000111104001771f400000000000000000000000000000000000000000000fff5500ccc50000000cfffffc0000
00000000003333000033330000dddd0000dddd0001111040011110400000000000000000000000000000000000000000f11555556ffff55504c00cf1f1fc0000
000000000011110000111100005555000055550001001555010015550000000000000000000000000000000000000000f11555556ff0f555444c00fffff00000
0000000000f00f0000f00f0000f00f0000f00f000f00f53b0f00f53b0000000000000000000000000000000000000000001555666f0ff55504c0006666600000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001555556ffff55504cf055655550000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f1155f556ff0f5550000f55655550000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f1155f556f0ff55500000f55555f0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5500ccc50000000011111f0000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111f0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001101100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001101100000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0ff00000
33b3333303b0000303000030333333b300330000211a111100a000a000000000000006aa000000000000000006a0000000000002111211111100000000000000
b3333333b33000b333330033b3b33333000300001111111a00a00040009ff000000666aaa00000000000000066aa000000000022211221122110006600000000
bb33b33bbbb333b3b3b30333b333bb3b0003b0001111111104a4a440009ff0000006e6a4aa00000000000006e6aa0000000002c2221111112112055a00000000
1bbbbbbbbbb33bbbbbbb33b3bbbbbbbb000030001211111100400040055666000066e6a44a2aaaaaaaaaaa6ee6a4a0000000224f422111111111105500000000
11abbb111bbbbbb111abbbbb2b3bbbb3000030001a111af10040004a222dddd0066ee6a44aa2cacacacaca6ee6a44a00000c2ff4ff2c1112111111a500000000
11aa111111b111121111b1121111b1120000b3001f111f1100a0004006677700066ee6a444a2aaaaaaaaaaa6e6a44a000022fffffff221111121111500000099
112112a1111111a1121111111a111111000003001111111100a444a0005dd00066eee6a4444a2cacacacaca666a444a002cfff444fff22111111111100009999
111111111a111111111aa11a11111a1100000b001111a111044000a0055ddd00666666aaaaaa2aaaaaaaaaaa66aaaaaa222cc2222cc22221111111110009ffff
21111afa1111fffa01ff111121aafa10111111111111ff110a4444a0565d77d06666665522222acacacacaca26aaaaaa2fff4fffff4fff2fff44fff28f888800
11111ff1aaaa1112011111a2111a111011111111aaa111110a444440565d77d006666aaaaaa22aaaaaaaaaaaa2222222cff4fffffff4ffcff4ff4ff288888800
1a1111111a1af1111111aaaa12111100111111111a1111110a4aa440565d77d006666aaaaaa222222222222262222220cf4fffffffff4fcf4ffff4f28f888800
12111aaa111a111111211ffa1211a11011111111111a111104444c40565d77d006666aabbaa21babbabbabba6aaaaaa0c4fffffffffff4c4ffffff428f888800
1a12aafa111111110111aaaa111af12111111111111111110444c5c0565d77d006a66aabbaa21babbabbabba6aaaaaa0cfffffffffffffcfff112ff28f8888f0
1f1aafaa11211aa1001111a211aaf1111111111111211a11044a4c40565d77d006a6eaaaaaa2aaaaaaaaaaaa6aabbaa02fffffffffffffcff11cf2f255555500
1f1aaf11a111a2a100111aaa1afa1100111111111111111104444440055ddd000666eaabbaa21babbabbabba6aabbaa02fffffffff5fffcf112fff2200055500
1a111a11111afaa11121ff111afa1000111111111111121104a44440005dd0000666eaabbaa21babbabbabba6aaaaaa02aff5fffffffff2f52fffff200000000
11a111ff2111f1101fff11111112211f00111111111111101111ff11055ddd000666eaaaaaa2aaaaaaaaaaaa6aabbaa0caffffffff5fff2f5cffcff200000000
0121faa11a2af100111ff121aaaaaaf1000111111111111111111111005d60000a66eaabbaa21babbabbabba6aabbaa02aaffff4fffaf52f5cfcccf200000000
001aafa11a2aa100111aa1aa11a11110000111111111110011211111005d600006a6eaabbaa21babbabbabba6aaaaaa0caafff444ffafa2f52fcccfc00000000
0112affa1aaaa11001111aaa1f1fff10011111111111110011111111005d60000666eaaaaaa2aaaaaaaaaaaa6aabbaa02aafaf444ffaaa2ff2fffffc00000000
011aaaa21faf110000121aaaaa1aa110111111111111111011111111005d60000666eaabbaa2aaaa1cc1aaaa6aabbaa02affaac44affaa2af2affffc00000000
112ff11a1aafa11000111111af2211000011111111111111a1111111222dddd006666aabbaa2aaa11cc11aaa6aaaaaa02fffaa440afffacffcfffffc00555500
01ff1a2a21aaaa110000111fa22100000011111111111100aa111121055666000a666aaaaaa2aaa1cccc1aaa6aaaaaa02aafaa444affaacff2ffaaf255555500
001ff1aa11aff21000000111111000000001111111111000111111111111111006666aaaaaa2aaa1cccc1aaa6aaaaaa0caaaaa4c4aaaaacff2faaaa28f8888f0
1121a10003b0000000300330000003001111111111111110111111120009fcff000820000000000000000000000000000e000555a05055a000e0000000000777
01111100003330000b3000b0000003000001111111111000111111110009fff000888200000000000000660000000000060050505a05050a0060000000077777
01a1110000030b0000300000000b3b00011111111111111011a111110009fff00888882000007700000666600000000077f5505050aa0505af77000000777777
01a1100000bb000000b33000003330001111111111111110111111110009fcff88888882000777700066666600000000fff555a5a5aa5a555fff000000000000
00aa1200033000000000333b3330b0000011111111111100111111110009ffff5555555a0077777006666666000000000555a1a1a1aa1a1a1555000000000999
0011000000b00000000003030b000000000111111111111011111aa1000099995445115a07777700666666600000000007f5a5a5a5aa5a5a5f60000000009fff
001f000000b3300000000b000b000000000011111111100021111fa10000009954c5bb5a0000000006666600000000000ff5a0a0a0550a050ff0000000009f8f
f111f1000000300000000b0003300000001111111111000011111111000000005445555a0000000000000000000000006665555aaa555aa56660000000099fff
8595a5b5000000000000000000000000000000000000000000454545454545450000454545456400454545454500006400000000000000000000000000000000
00000000000000000000000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8696a6b6000000000000000000000000000000000000000000000000000000000000000000006400000000000000002424000000000000000000000000000000
00000000000000000000000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45454545454500000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000
00000000000000000000000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45454545454500000000242400000000000000000000000000000000000000000000000000003400000000000000000000000000000000000000000000000000
00000000000000000000000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45454545454500000000000000002424000000000000000000000000000000000000000000000000003434000000000000000000000000000000000000000000
00000000000000000000000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45454545454500002400000000000000000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000242404040404040000000000000000000000000000003434000000000000000000000000000000000000
00000000000000003434343434343434000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000074006400000000000000000024240000000000000000000000000000000000000000000000000000000034340000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000075006400006400002424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000870076006400006400000000000000000000000000000000000000000000000000000000000000003434000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000141414142400006400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000040400000000000000000000000000000000000000000000000000000000003434000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002424000000240000000000240000000000000000000000000000000000000034340034340000003400002424000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000011111111111110000000000000000000000000000000000000000000000000000000000000111102
00eeeee0000000000000000000000000000000000060000116661111110010000000000000000000000000000011110000000000000000000000000000111022
00ee00ee044444eeeeeee00e00ee0000000000000076001016111111111010000000000000000000000000001110010000000000000000000000000001110222
00ee0000e4e0e4e0000e00e00e0e0000000000000060001111111111111011111000000000000000000000011000000066600000000000000000000011122211
00ee000ee04e400e000e0e0000e00000000000000000001111111111111101001110140000011111111101111110000666000000000000000000000012222111
00ee000ee0040000e00ee0000e0e0e00000000000001101111111111111000111111000000110000111111111110006600000000000000000000000122221122
00ee00ee004e40000e0e0e000e00e000000000000001111111111111010011111111110000100000111111111110006601110000000000000000001222211222
00eeeee0044444eee00e00e000ee0e00000000000010111111111110110011111111110000100000111111111000006601111000000000000000012222112222
00000000000000000000000e00000000000000000011111111111101100111111111111100100111111111111110006601111100000000000000122211222211
00eeeee00000000000000000e0000000000000000001111111100011111111111111111100101111111116611110006660111100000000000001222112222110
00ee00ee000000000000000000000000000000000001111111000111111111111111111100101111111166611111000660111000000000000002221122221100
00ee0000eeeeeeeeeeeee0ee00eee0ee000000000000100000001111111111111111111111101111111166611111000066600000000000000022211222211105
00ee000eee00e000e00e00e0e0e0e0e0000000000000111100111111111111111111111111011111111166661111000000000000000000000222111222111105
00ee000eeee0eee0e00e00e00ee00e0000000000000000000111111a111111111001111111111111111116661111111100000000000000001221112221111155
00ee00ee0e0000e0e00e00e000e00e000000000000000000011111a1a111100111111111111111111111aa666111111111000000000000012211122221101155
00eeeee00eeeeee0e0eeeee000e00e0000000000000000011111111a1111111100666661111101111111aa666111111111000000000000112111122211155555
00000000000000000000000000000000000000000001111111111111111111110660000111110011111666661111111111000000000000112111222111077777
00000000000000000000000000000000000000000111111111111611111111110661111111110011116666611111111110000000000000116112222110077777
00000033000000000000000000000000000000000111111111116600011111001661111111111011116611111111110000600000000000111122221100577077
00000333300000000000000000000000000000001111111111660010111110001611111111111011111111111111100111111110000000110122211000577007
00003333b30000000000000000000000000000001111066666601110111111111611111111101000111111111111001166611110000000111222110005577007
0003bb33bb3000000000000003300000000000001111660011111000111111111611111a11100100011111111111661000111110000000112222110055577557
0003b3333b3000000003330333333330000000001111100100000011111111110111111111100000001111111116010011111110000000112221000555577777
0003b333333300000333333333333333000000001111100000111111111101111111111111111111111111111106111111111100000000111111000555577777
003bb333333300000303333333333333000000000111100111111111111101111111111100011111111111111106101111111100000000111110055555577777
003bb333333300000303303333333333000000000111110111111111111111111111000011011111111111110001001111111100000000111005555555555555
00333343333300000333333333333333000000000111111111111111100011111000111111110111111100001111001111100070000000110005555555555555
000000440000000033333333e333333300000000011111111111011000000000101110001110111111111011000a000000000660000000110055555555505555
000000440000000033333333333333330000000000111111111111000000011111100110111111111111111000a0000000000000000000110055555555555555
00000444000000003333333333333333000000000011111111111111110011000111110011111111111111100000000000000000000000110055555555555555
00000444000000003333303333333333000000000001110001101111110110000000000001111111111111100000000000000000000000110055555555550055
00000044000000000333333333333330000000000000011110001111110100000000000000111111111111100000000000000000000000110055555555555555
__gff__
0000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000003030303000305080000000000000000030303030303030800000000000000000303030303030308000000000000000003000000030303000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000570000404040004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000670000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4200404000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7546000000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7546420000000000004600000000000000000000000000000000000000000000000000000000000000424242414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6546000000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041414600000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004600000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004600000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004600000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004100460000004342414142424241000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343000043000000000000
0000000041460000000000000000000000004242424242004242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343430000000000000000000054545454
0000000000460000000000000000000000000000000000000000004242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054545454
0000000000460000000000000000000000000000000000000000000000004242424100460000000000000000000000000000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043434300000000000000434300000000000054545454
0000000000460000000000000000000000000000000000000000000000000000000043460000000000000000000000000000000000004300000000570047000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000000000460000000000000000000000000000000000000000000000000000000000460000000000000000000000000000000000004600007800670067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000000000460000000000000000000000000000000000000000000000000000000000460000000000000000000000000000000043004600434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000000000460000000000000000000000000000000000000000000000000000000000460000000000000000000000000000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600430000000000000000000000000000000000000000545454545454547500460000000000000000000000000043430000004600000000000000000000004343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600000000000000000000000000000000000000000000545454545454547500464c4d4e0047000000000000000000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600000000000000000000000000000000000000000000545454545454547500465c5d5e0057000000000043430000000000004600000000000000000000000000000000004343000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600000000000000000000000000000000000000000000545454545454547500466c6d6e0067000000000000000000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600000000000000000000000000000000000000000000000000000000000000434040404040424042424100000000000000004600000000000000000000000000000000000000000000004343000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600000000000000000000000000000000000000000000000000000000000000005454545454545454545400000000000000004600000000000000000000000000000000000000000046000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000054545454
0000004600000000000000000000000000000000000000000054540000000000000000005454545400000000545400000000000000004600000000000000000000000000000000000000000046000000000000000000000000000000000000000000000000000000000000000000000000004600000000000000000000000000
00000046000000000000000000000000000000000000000000545400004600000000000054540000005454000054000000000000000046000000000000000000000000000000000000000000460000000000000048494a4b00000000000000000000000000000000000043434300430000434343430000000000000000000000
40404040000000000000000000000000000000000000000000545454004654000000460054540000005454000054000000000047000046000000000000000000000000000000000000000000460000000000000058595a5b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000545454004654540000460000000000005454000000004600000057560046000000000000000000000000000000000000000000460000000000000068696a6b00000000000000000000000000000000430000000000000000000000000000000000000000000000
0000000000004343000000000000000000000000000000000054545400465454000054545454000054545454540000460000006756004600000000000000000000000000000000000000000046000000000000004343434343434343434300000000004343430000000000000000000000000000000000000000000000000000
48494a4b00000000000000000000000000000000000000000054545454545454000054545454000054545454540000460042424242424242000000000000000000000000000000000000000046000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000011050000000000000000000000000000000140501a0502b05024050210501f05019050150501205000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000002a0502905028050260502405022050200501c050190501605013050110500e0500c0500a05008050060500405002050010500005000000000000000000000000000000000000000000000000000
000200000000000000000001a0501f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e0000005502d5502f5503255034550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
210e00001576015760097400974000000000001576015760097400974000000000001576015760097400974000000000001576015760097400974000000000001576015760097400974015760157600974009740
00100000210001585510d4109c10100000080510d550dc101c90100000000550dd501c901090100000000d501dd050981410900000000dd05158541094109d501dd0509814109210e00000164146400640424046
a90e000024121241202412024120211212112021120211201c1211c1201c1201c12024121241202412024120211212112021120211201c1211c1201c1201c1202412124120241202412021121211201c1211c120
0001000000000000000000000000000000000000000140501a0502b05024050210501f05019050150501205000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000000000000000000140501a0502b05024050210501f05019050150501205000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000000000000000000140501a0502b05024050210501f05019050150501205000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000000000000000000140501a0502b05024050210501f05019050150501205000000000000000000000000000000000000000000000000000000000000000000000000000000000
310e00001c0601c06000000000002106021060000000000000000000002406024060000000000000000000002106021060000000000000000000001c0601c0602606026060000000000028060280600000000000
210e00001376013760077400774000000000001376013760077400774000000000001376013760077400774000000000001376013760077400774000000000001376013760077400774013760137600774007740
a90e0000231212312023120231201f1211f1201f1201f1201c1211c1201c1201c120231212312023120231201f1211f1201f1201f1201c1211c1201c1201c120231212312023120231201f1211f1201c1211c120
310e00001c0601c06000000000001f0601f060000000000000000000002306023060000000000000000000001f0601f060000000000000000000001c0601c0602406024060000000000026060260600000000000
210e00001176011760057400574000000000001176011760057400574000000000001176011760057400574000000000001176011760057400574000000000001176011760057400574011760117600574005740
031213141415000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
041617181811000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052021222223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
062425262627000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
072829303031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a90e0000211212112021120211201d1211d1201d1201d12018121181201812018120211212112021120211201d1211d1201d1201d12018121181201812018120211212112021120211201d1211d1201812118120
310e0000180601806000000000001d0601d060000000000000000000002106021060000000000000000000001d0601d0602106021060230602306024060240602606026060240602406023060230602106021060
210e00000e7600e760027400274000000000000e7600e760027400274000000000000e7600e760027400274000000000000e7600e760027400274000000000000e7600e76002740027400e7600e7600274002740
a90e0000231212312023120231201f1211f1201f1201f1201a1211a1201a1201a120231212312023120231201f1211f1201f1201f1201a1211a1201a1201a120231212312023120231201f1211f1201a1211a120
310e00001a0601a06000000000001f0601f060000000000000000000002306023060000000000000000000001f0601f0600000000000290602906028060280602606026060240602406026060260602806028060
010e00001536015360093400934000000000001536015360093400934000000000001536015360093400934000000000001536015360093400934000000000001536015360093400934015360153600934009340
310e00001c1621c16200000000002116221162211522115200000000002416224162000000000000000000002116221162211522115200000000001c1621c1622616226162000000000024162241620000000000
010e000018073000003e2243c00324665000003e2250000018073000003e2243c00324665000003e2250000018073000003e2243c00324665000003e2250000018073000003e2243c003246653e2153e22500000
010e00001336013360073400734000000000001336013360073400734000000000001336013360073400734000000000001336013360073400734000000000001336013360073400734013360133600734007340
310e00001c1621c16200000000001f1621f1621f1521f15200000000002316223162000000000000000000001f1621f1621f1521f15200000000001c1621c1622416224162000000000026162261622610226102
010e00001136011360053400534000000000001136011360053400534000000000001136011360053400534000000000001136011360053400534000000000001136011360053400534011360113600534005340
310e0000181621816200000000001d1621d1621d1521d15200000000002116221162000000000000000000001d1621d1622116221162231622316224162241622616226162241622416223162231622116221162
010e00000e3600e360023400234000000000000e3600e360023400234000000000000e3600e360023400234000000000000e3600e360023400234000000000000e3600e36002340023400e3600e3600234002340
310e00001a1621a16200000000001f1621f1621f1521f15200000000002316223162000000000000000000001f1621f1620000000000291622916228162281622616226162241622416226162261622816228162
010e000018073000003e2243c00324665000003e2250000018073000003e2243c00324665000003e2250000018073000003e2243c00324665000003e2250000018073000003e22418073246653e2153e22518073
__music__
00 04060b40
00 0c0d0e40
00 0f151640
00 17181940
00 04060b40
00 0c0d0e40
00 0f151640
00 17181940
00 1a061b1c
00 1d0d1e1c
00 1f15201c
00 21182223
00 1a061b1c
00 1d0d1e1c
00 1f15201c
04 21182223

