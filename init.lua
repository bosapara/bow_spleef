--Bow Spleef based on "teleport_potion" by TenPlus



-- particle effects
local function tp_effect(pos)
	
	minetest.add_particlespawner({
		amount = 5,
		time = 0.1,
		minpos = vector.subtract(pos, 1),
		maxpos = vector.add(pos, 1),
		minvel = {x = -0.8, y = 0, z = -0.8},
		maxvel = {x = 0.8, y = 0.7,  z = 0.8},
		minacc = {x = 0, y = -10, z = 0},
		maxacc = {x = 0, y = -10, z = 0},
		minexptime = 0.4,
		maxexptime = 1.3,
		minsize = 0.5,
		maxsize = 1,
		texture = "default_obsidian.png",
		collisiondetection = true,
	})	
	
end




-- Throwable potion
local function throw_potion(itemstack, player)

	local playerpos = player:get_pos()

	local obj = minetest.add_entity({
		x = playerpos.x,
		y = playerpos.y + 1.5,
		z = playerpos.z
	}, "bow_spleef:bomb_entity")

	local dir = player:get_look_dir()
	local velocity = 20

	obj:set_velocity({
		x = dir.x * velocity,
		y = dir.y * velocity,
		z = dir.z * velocity
	})

	obj:set_acceleration({
		x = dir.x * -3,
		y = -9.5,
		z = dir.z * -3
	})

	obj:set_yaw(player:get_look_yaw() + math.pi)
	obj:get_luaentity().player = player
end


local bomb_entity = {
	physical = true,
	visual_size = {x = 0.3, y = 0.3},
	visual="cube",
	textures={"default_obsidian.png","default_obsidian.png","default_obsidian.png","default_obsidian.png","default_obsidian.png","default_obsidian.png"},	
	collisionbox = {0,0,0,0,0,0},
	lastpos = {},
	player = "",
}

bomb_entity.on_step = function(self, dtime)

	if not self.player then
		self.object:remove()
		return
	end

	local pos = self.object:get_pos()
	
	if pos.y < 400 or (pos.x > 120 or pos.x < 96) or (pos.z < 118 or pos.z > 142) then
		self.object:remove()
	end

	if self.lastpos.x ~= nil then

		local vel = self.object:get_velocity()

		-- only when potion hits something physical
		if vel.x == 0
		or vel.y == 0
		or vel.z == 0 then

			if self.player ~= "" then

				-- round up coords to fix glitching through doors
				self.lastpos = vector.round(self.lastpos)

				--self.player:set_pos(self.lastpos)
				
				
				
				local p1 = {x = self.lastpos.x, y = self.lastpos.y - 1, z = self.lastpos.z}
				local p2 = {x = self.lastpos.x - 1, y = self.lastpos.y - 1, z = self.lastpos.z}
				local p3 = {x = self.lastpos.x + 1, y = self.lastpos.y - 1, z = self.lastpos.z}
				local p4 = {x = self.lastpos.x, y = self.lastpos.y - 1, z = self.lastpos.z - 1}
				local p5 = {x = self.lastpos.x, y = self.lastpos.y - 1, z = self.lastpos.z + 1}

				local check = self.lastpos


				local v = {
					{p1},
					{p2},
					{p3},
					{p4},
					{p5},
				}
				for _, v in pairs(v) do


					if minetest.get_node(v[1]).name == "default:wood" then
						minetest.set_node(v[1], {name = "air"})
						
						minetest.sound_play("boom", {
							pos = self.lastpos,
							gain = 0.7,
							max_hear_distance = 25
						})

						tp_effect(self.lastpos)						
						
					end
				
				end	
				

			end

			self.object:remove()

			return

		end
	end

	self.lastpos = pos
end

minetest.register_entity("bow_spleef:bomb_entity", bomb_entity)







minetest.register_craftitem("bow_spleef:bomb", {
	description = "Bomb",
	inventory_image = "bomb.png",
	wield_image = "bomb.png",
	--groups = {book = 1, flammable = 3},
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)

		local pos = user:get_pos()
		local name = user:get_player_name()	
	
		if pointed_thing.type == "node" then
		
		elseif ((pos.y < 400 or pos.y > 406) or (pos.x > 120.5 or pos.x < 95.5) or (pos.z < 117.5 or pos.z > 142.5)) then

		minetest.chat_send_player(name, (minetest.colorize("red","<Mr.Bot> "..name..", you can't use bombs here!")))

			--set_teleport_destination(user:get_player_name(), pointed_thing.above)
		else
			throw_potion(itemstack, user)
			
			minetest.sound_play("bomb_throw", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 10
			})
			

				
		end
	end,
})



