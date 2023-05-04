--[[

The MIT License (MIT)
Copyright (C) 2023 Acronymmk

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

]]

local cooldown_time = 60 -- Cooldown
cooldown_data = {}
local duration = 60 -- Fire duration

if minetest.global_exists("cooldown_data") == false then
  minetest.register_globalstep(function(dtime)
      minetest.set_global_exists("cooldown_data", {})
  end)
end

minetest.register_tool("firemaster:tool", {
  description = minetest.colorize("orange", "Fire Master") ..
    minetest.get_background_escape_sequence("#000000"),
  inventory_image = "firemaster_tool.png",
  on_use = function(itemstack, user, pointed_thing)
      local player_name = user:get_player_name()
      local pos = user:getpos()
      local dir = user:get_look_dir()

      local playername = user:get_player_name()
      if cooldown_data[playername] == nil then
          cooldown_data[playername] = 0
      end

      local curr_time = minetest.get_gametime()
      if curr_time - cooldown_data[playername] >= cooldown_time then
        cooldown_data[playername] = curr_time
        if pointed_thing.type == "node" then
          local pointed_pos = pointed_thing.under
          for i=1, 50 do
            local pos_to_check1 = {x = pointed_pos.x + math.sin(i/50*2*math.pi)*6, y = pointed_pos.y + 1, z = pointed_pos.z + math.cos(i/50*2*math.pi)*6}
            local pos_to_check2 = {x = pointed_pos.x + math.sin(i/50*2*math.pi)*3, y = pointed_pos.y + 1, z = pointed_pos.z + math.cos(i/50*2*math.pi)*3}
            local node1 = minetest.get_node(pos_to_check1)
            local node2 = minetest.get_node(pos_to_check2)
            if node1.name == "air" and pos_to_check1.y == pointed_pos.y + 1 then
              minetest.after(0.010 * i, function()
                minetest.set_node(pos_to_check1, {name = "fire:permanent_flame"})
                minetest.after(duration, function()
                  minetest.remove_node(pos_to_check1)
                end)
                itemstack:add_wear(1000)
              end)
            end
            if node2.name == "air" and pos_to_check2.y == pointed_pos.y + 1 then
              minetest.after(0.010 * i, function()
                minetest.set_node(pos_to_check2, {name = "fire:permanent_flame"})
                minetest.after(duration, function()
                  minetest.remove_node(pos_to_check2)
                end)
                itemstack:add_wear(1000)
              end)
            end
          end
        else
          for i=1, 50 do
            local pos_to_check = {x = pos.x + (dir.x * i), y = pos.y + (dir.y * i) + (2), z = pos.z + (dir.z * i)}
            local node = minetest.get_node(pos_to_check)
            if node.name == "air" then
              minetest.after(0.1 * i, function()
                minetest.set_node(pos_to_check, {name = "fire:permanent_flame"})
                minetest.after(duration, function()
                  minetest.remove_node(pos_to_check)
                end)
                itemstack:add_wear(1000)
              end)
            end
          end
        end
      else
        local remaining_cooldown = math.ceil(cooldown_time - (curr_time - cooldown_data[playername]))
        minetest.chat_send_player(playername, minetest.colorize("#FF0000", "You have to wait "..remaining_cooldown.." seconds before using this tool again."))
      end
  end
})

minetest.register_craft({
	output = "firemaster:tool",
	recipe = {
		{"", "fire:permanent_flame", "fire:permanent_flame"},
		{"", "default:lava_source", "fire:permanent_flame"},
		{"default:stick", "", ""},
	}
})