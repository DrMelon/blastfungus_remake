AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

function ENT:Initialize()
	-- Random Seed
	math.randomseed(CurTime())
	
	-- Variables
	self.model = "models/weapons/w_bugbait.mdl"
	self.radius = 100
	self.damage = 30
	self.has_exploded = false
	self.death_time = (CurTime() + math.random(GetConVar("fungus_min_lifespan"):GetFloat(), GetConVar("fungus_max_lifespan"):GetFloat()))
	self.next_spawn_time =  (CurTime() + math.random(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
	
	-- Physical Stuff
	self.Entity:SetModel(self.model)
	self.Entity:PhysicsInitSphere(3)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetColor( Color(0,0,0,55) )
	
	-- Update global population value
	fungus_currentpop = fungus_currentpop + 1
	
	-- Precache fungus noises
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze1.wav")
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze2.wav") 
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav") 
	
end

function ENT:OnTakeDamage(dmg)
	
	-- What hit us?
	attacker = dmg:GetAttacker():GetClass()
	
	if(string.find(attacker,"fungus_") == nil) then
		-- If it wasn't a fungus that bumped us...
		self.Entity:FungusAction()
		-- ... perform this fungus' action!
	end
	
end

function ENT:Touch(activator)

	-- What's touching me?
	toucher = activator:GetClass()
	
	if(string.find(toucher,"fungus_") == nil) then
		-- If it wasn't a fungus that bumped us...
		self.Entity:FungusAction()
		-- ... perform this fungus' action!	
	end
	
end

function ENT:Think()

	-- When do we think next?
	self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
	
	-- Is this past the current death time?
	if (CurTime() >= self.death_time) then
		-- Perform this breed's death function
		self.Entity:FungusDeath()
	-- Otherwise, if this is the time for breeding, we should breed.
	elseif (CurTime() >= self.next_spawn_time) then
		-- Breeding Function!
		self.Entity:FungusBreed()
	end
	
	return true
	
end		

function ENT:OnRemove()

	-- Reduce the population.
	fungus_currentpop = fungus_currentpop - 1

end



-- Fungus Functions
---- FungusAction: This dictates what happens when this breed of fungus is touched or attacked.
---- FungusDeath: This dictates what happens when a fungus runs out of lifetime.
---- FungusBreed: This dictates what happens when this fungus breed breeds.



function ENT:FungusAction()
	-- If we haven't exploded yet...
	if(self.has_exploded == false) then
		-- Where are we?
		pos = self.Entity:GetPos()
		-- EXPLODE!
		local explosion = EffectData()
		explosion:SetOrigin(pos)
		explosion:SetStart(pos)
		explosion:SetMagnitude(80)
		explosion:SetScale(10)
		explosion:SetRadius(30)
		
		util.Effect("Explosion",explosion)
		util.BlastDamage(self.Entity, self.Entity, pos, self.radius, self.damage)
		
		
		
	end
	
	self.has_exploded = true
	self.Entity:Remove()
	
end

function ENT:FungusDeath()
	-- Create a puff of smoke
	puff = ents.Create("env_smoketrail")
	puff:SetKeyValue("startsize","10")
	puff:SetKeyValue("endsize","20")
	puff:SetKeyValue("minspeed","1")
	puff:SetKeyValue("maxspeed","2")
	puff:SetKeyValue("startcolor","40 40 40")
	puff:SetKeyValue("endcolor","0 40 0")
	puff:SetKeyValue("opacity",".8")
	puff:SetKeyValue("spawnrate","5")
	puff:SetKeyValue("lifetime","1")
	puff:SetPos(self.Entity:GetPos())
	puff:Spawn()
	puff:Fire("kill","",0.7)
	
	self.Entity:Remove()
	
end
	
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
		
		-- Pick the next spawn time.
		self.next_spawn_time = (CurTime() + math.random(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
	
	else
	
		-- Try again!
		self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
	end
	
	
	
end

