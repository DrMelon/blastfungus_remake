AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')







function ENT:FungusBreed()

	-- Let's breed!
	local breed_success = false
	
	-- But only if the population isn't huge.
	if(fungus_currentpop >= GetConVar("fungus_maxfungi"):GetInt()) then
		return
	end
	
	-- Begin tracing a few feet away from the current fungus.
	trace_pos = self.Entity:GetPos() + (self.Entity:GetForward() * 16)
	
	trace = {}
	trace.start = trace_pos
	-- Make the traces short
	trace.endpos = Vector((trace_pos.x + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.y + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.z + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())))
	
	-- Perform the trace
	tr = util.TraceLine(trace)
	
	-- If we hit something, and it isn't the sky...
	if (tr.Hit) and (!tr.HitSky) then
		-- If we hit something that is not solid ground...
		if(tr.HitNonWorld) then
			-- ... better make sure it isn't the player, a fungus, or an NPC.
			local hitentity = tr.Entity:GetClass()
			
			if("player" == hitentity) or (string.find(hitentity,"fungus_")) or (string.find(hitentity,"npc")) then
				return
			end
		end
		
		-- If the trace hit close by...
		if(self.Entity:GetPos():Distance(tr.HitPos) > GetConVar("fungus_min_distance"):GetFloat()) and (self.Entity:GetPos():Distance(tr.HitPos) < GetConVar("fungus_max_distance"):GetFloat()) then
			
			-- Make a baby!
			
			local spawn_pos = tr.HitPos + tr.HitNormal * 2
			local spawn_angle = tr.HitNormal:Angle()
			local ent = ents.Create(self.Entity.BreedName)
			
			-- Create the entity
			
			ent:SetPos(spawn_pos)
			ent:SetAngles(spawn_angle)
			ent:Spawn()
			ent:Activate()
			ent:Initialize()
			
			-- Colour Fungus: This type of fungus likes to change colour.
			
			local random_r = math.Rand(-45,45)
			local random_g = math.Rand(-45,45)
			local random_b = math.Rand(-45,45)
			local random_a = math.Rand(-45,45)
			
			local curcolor = self.Entity:GetColor()
			
			local new_r = curcolor.r + random_r
			local new_g = curcolor.g + random_g
			local new_b = curcolor.b + random_b
			local new_a = curcolor.a + random_a
			
			if new_r < 0 then
				new_r = 0
			end
			if new_r > 255 then
				new_r = 255
			end
			if new_g < 0 then
				new_g = 0
			end
			if new_g > 255 then
				new_g = 255
			end
			if new_b < 0 then
				new_b = 0
			end
			if new_b > 255 then
				new_b = 255
			end
			if new_a < 0 then
				new_a = 0
			end
			if new_a > 255 then
				new_a = 255
			end
			
			ent:SetColor(Color(new_r,new_g,new_b,new_a))
			ent:SetOwner(tr.Entity)
			
			-- Make a noise!
			
			local whichsound = math.random(1,3)
			local sound = tostring(whichsound)
			
			ent:EmitSound("weapons/bugbait/bugbait_squeeze" .. sound .. ".wav",100,100)
			
			-- If we hit a place on the map...
			if(tr.Entity:IsWorld()) then
				ent:GetPhysicsObject():EnableMotion(false)
			else
				local weld = constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone, 0)
			end
			
			-- Successfully made a baby!
			breed_success = true
			
		
		end
			
		
	end
	
	-- If we successfully breeded...
	
	if(breed_success == true) then
		
		-- Pick the next spawn time.
		self.next_spawn_time = (CurTime() + math.Rand(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
	
	else

	end
	
	
	
end