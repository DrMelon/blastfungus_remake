AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')



function ENT:Initialize()
	-- Random Seed
	table.insert(fungus_list, self)
	math.randomseed(CurTime())
	
	-- Variables
	self.model = "models/weapons/w_bugbait.mdl"
	self.radius = 100
	self.damage = 30
	self.has_exploded = false
	self.death_time = (CurTime() + math.Rand(GetConVar("fungus_min_lifespan"):GetFloat(), GetConVar("fungus_max_lifespan"):GetFloat()))
	self.next_spawn_time =  (CurTime() + math.Rand(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
	self.move_time = self.next_spawn_time
	self.final_size_increase = math.Rand(GetConVar("fungus_balloon_min_size_increase"):GetFloat(), GetConVar("fungus_balloon_max_size_increase"):GetFloat())
	self.buoyancy = 0
	self.spawn_time = CurTime()
	self.has_latched = false
	
	-- Physical Stuff
	self.Entity:SetModel(self.model)
	self.Entity:PhysicsInitSphere(3)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
	self.Entity:SetColor( Color(255,40,40,255) )
	
	-- Balloon fungus flies around.
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(true)
		phys:Wake()
	end
	
	-- Update global population value
	fungus_currentpop = fungus_currentpop + 1
	
	-- Precache fungus noises
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze1.wav")
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze2.wav") 
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav") 
	
end

function ENT:FungusBreed()

	-- Let's breed!
	local breed_success = false

	if (!self.has_latched) then
		-- Balloon fungus doesn't breed if it hasn't latched yet.
		return
	end

	-- Make a noise!
	local numbertospawn = math.random(3,5)

	-- Spawn a number of fungi
	for idx = 0, numbertospawn do
		-- But only if the population isn't huge.
		if(fungus_currentpop >= GetConVar("fungus_maxfungi"):GetInt()) then
			return
		end
		
		-- Spawn in a radius around the current fungus.
		local spawn_center = self.Entity:GetPos() + (self.Entity:GetForward() * 16)
		local spawn_pos = Vector((spawn_center.x + math.Rand(-self.final_size_increase,self.final_size_increase)), (spawn_center.y + math.Rand(-self.final_size_increase,self.final_size_increase)), (spawn_center.z + math.Rand(-self.final_size_increase,self.final_size_increase)))

		-- Create the entity
		local ent = ents.Create(self.Entity.BreedName)
		ent:SetPos(spawn_pos)
		ent:Spawn()
		ent:Activate()
		ent:Initialize()
		local ent_phys = ent:GetPhysicsObject()
		local phys = self.Entity:GetPhysicsObject()
		if (ent_phys:IsValid()) then
			ent_phys:EnableGravity(true)
			ent_phys:Wake()
			ent_phys:SetVelocity(phys:GetVelocity())
		end
	
		-- Successfully made a baby!
		breed_success = true
	end
end

function ENT:PhysicsUpdate(phys)
	if(self.has_latched) then
		
		phys:ApplyForceCenter( Vector( 0, 0, phys:GetMass() * self.buoyancy ) )
	end
end

function ENT:FungusFindAndLatchTarget()
	-- Begin tracing a few feet away from the current fungus.
	trace_pos = self.Entity:GetPos() + (self.Entity:GetForward() * 16)
	
	trace = {}
	trace.start = trace_pos
	-- Make the traces short
	trace.endpos = Vector((trace_pos.x + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.y + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.z + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())))
	trace.filter = self.Entity

	-- Perform the trace
	tr = util.TraceLine(trace)
	
	-- If we hit something, and it isn't the sky...
	if ((tr.Hit) and (!tr.HitSky) and IsValid(tr.Entity)) then
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
			-- Balloon Fungus ties itself to things.
			local phys = self.Entity:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:EnableGravity(false)
				phys:Wake()
				phys:SetVelocity(Vector(0,0,-0.5))
			end
			
			local rope_vector = Vector(0,0,1)
			self.has_latched = true
			local target_phys = tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone)
			if(IsValid(target_phys)) then
				local rope_constraint, rope = constraint.Rope(self.Entity, tr.Entity, 0, tr.PhysicsBone, rope_vector, target_phys:WorldToLocal(tr.HitPos), GetConVar("fungus_max_distance"):GetFloat(), 5, 0, 2, "cable/cable", false)
			else
				local rope_constraint, rope = constraint.Rope(self.Entity, tr.Entity, 0, tr.PhysicsBone, rope_vector, tr.Entity:WorldToLocal(tr.HitPos), GetConVar("fungus_max_distance"):GetFloat(), 5, 0, 2, "cable/cable", false)
			end
			
			
			
		end
	end
end

function ENT:OnFungusThink()

	-- Is this past the current death time?
	if (CurTime() >= self.death_time) then
		-- Balloon fungi breed upon death.
		self.Entity:FungusBreed()
		self.Entity:FungusDeath()
	end

	-- This fungus searches for things to latch onto
	if (self.has_latched == false) then
		self.Entity:FungusFindAndLatchTarget()
	else
	
		-- Once latched, this fungus also slowly increases in size, up to a maximum size. 
		local current_scale_increase = self.final_size_increase * ((CurTime() - self.spawn_time) / (self.death_time - self.spawn_time))
		self.Entity:SetModelScale(1.0 + current_scale_increase, 0.5)

		-- And it buoys upwards.
		self.buoyancy = 1.0 + (current_scale_increase*10.0)

	

	end
	
	return true
	
end		