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
	trace.endpos = Vector((trace_pos.x + math.random(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.y + math.random(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.z + math.random(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())))
	
	
	

	
	
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
		if(self.Entity:GetPos():Distance(tr.HitPos) > GetConVar("fungus_min_distance"):GetFloat() / 10) and (self.Entity:GetPos():Distance(tr.HitPos) < GetConVar("fungus_max_distance"):GetFloat() / 2) then
			
			-- Make a baby!
			
			local spawn_pos = tr.HitPos + tr.HitNormal * 2
			local spawn_angle = tr.HitNormal:Angle()
			ent = ents.Create(self.Entity.BreedName)
			
			-- Create the entity
			
			ent:SetPos(spawn_pos)
			ent:SetAngles(spawn_angle)
			ent:Spawn()
			ent:Activate()
			ent:SetColor(Color(0,0,0,55))
			ent:SetOwner(tr.Entity)
			
			-- Make a noise!
			
			local whichsound = math.random(1,3)
			local sound = tostring(whichsound)
			
			ent:EmitSound("weapons/bugbait/bugbait_squeeze" .. sound .. ".wav",100,100)
			
			-- Weld to the thing we hit.
			
			local weld = constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone, 0)
			
			-- If we hit a place on the map...
			if(tr.Entity:IsWorld()) then
				ent:GetPhysicsObject():EnableMotion(false)
			end
			
			-- Successfully made a baby!
			breed_success = true
			
		
		end
			
		
	end
	
	-- If we successfully breeded...
	
	if(breed_success == true) then
		-- Vent Fungus is incredibly proliferent within tight spaces. Otherwise, it grows slower than usual.
		
		if(self.Entity:GetPos():Distance(tr.HitPos) <= GetConVar("fungus_min_distance"):GetFloat()) then
			self.next_spawn_time = (CurTime() + GetConVar("fungus_min_breeding_delay"):GetFloat() / 4)
			self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
			
		else
			self.next_spawn_time = (CurTime() + GetConVar("fungus_max_breeding_delay"):GetFloat()*2)
		end
	
	else
	
		-- Try again!
		self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
	end
	
	
	
end

