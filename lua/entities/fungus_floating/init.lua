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
	self.move_time = self.next_spawn_time
	
	-- Physical Stuff
	self.Entity:SetModel(self.model)
	self.Entity:PhysicsInitSphere(3)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
	self.Entity:SetColor( Color(0,127,0,255) )
	
	-- Floating fungus flies around.
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(false)
	end
	
	-- Update global population value
	fungus_currentpop = fungus_currentpop + 1
	
	-- Precache fungus noises
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze1.wav")
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze2.wav") 
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav") 
	
end

function ENT:Think()

	-- When do we think next?
	self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
	
	-- Floating Fungus moves and changes direction in the air.
	if (CurTime() >= self.move_time) then
		self.move_time = (CurTime() + math.random(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
		local power = Vector(math.random(fungus_float_minpower, fungus_float_maxpower), math.random(fungus_float_minpower, fungus_float_maxpower), math.random(fungus_float_minpower, fungus_float_maxpower))
		local phys = self.Entity:GetPhysicsObject()
		phys:ApplyForceCenter(power)
	end
			
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
	
	-- Make the traces super short for floaty fungus.
	trace.endpos = Vector((trace_pos.x + math.random(-10,10)), (trace_pos.y + math.random(-10,10)), (trace_pos.z + math.random(-10,10)))
	
	-- Perform the trace
	tr = util.TraceLine(trace)
	
	-- Floating fungus do not like breeding near things.
	
	-- If we hit something, and it isn't the sky...
	if (!tr.Hit) and (!tr.HitSky) then

		-- Make a baby!
			
		local spawn_pos = tr.HitPos + tr.HitNormal * 2
		local spawn_angle = tr.HitNormal:Angle()
		local ent = ents.Create(self.Entity.BreedName)
			
		-- Create the entity
			
		ent:SetPos(spawn_pos)
		ent:SetAngles(spawn_angle)
		ent:Spawn()
		ent:Activate()
		ent.Entity:SetColor( Color(0,127,0,255) )
		
					
			
		-- Make a noise!
			
		local whichsound = math.random(1,3)
		local sound = tostring(whichsound)
			
		ent:EmitSound("weapons/bugbait/bugbait_squeeze" .. sound .. ".wav",100,100)
			
		-- Floating fungus doesn't stay attached to objects.
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
			
		-- Successfully made a baby!
		breed_success = true
			
		
		
			
		
	end
	
	-- If we successfully breeded...
	
	if(breed_success == true) then
		
		-- Pick the next spawn time.
		self.next_spawn_time =  (CurTime() + math.random(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
	
	else
	
		-- Try again!
		self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
	end
	
	
	
end