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
	
	-- Physical Stuff
	self:SetModel(self.model)
	self:PhysicsInitSphere(3,"super_bouncy")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
	self:SetColor( Color(255,127,0,255) )
	

	
	-- Bouncy Fungus bounces around, and takes off on spawn.
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(true)
		local power = Vector(math.Rand(fungus_float_minpower, fungus_float_maxpower), math.Rand(fungus_float_minpower, fungus_float_maxpower), math.Rand(fungus_float_minpower, fungus_float_maxpower))
		phys:ApplyForceCenter(power)
	end
	
	-- Update global population value
	fungus_currentpop = fungus_currentpop + 1
	
	-- Precache fungus noises
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze1.wav")
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze2.wav") 
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav") 

	
end

-- Lifted straight from the bouncy ball entity. urp.

function ENT:PhysicsCollide( data, physobj )
	
	-- Play sound on bounce
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then
		self:EmitSound( "Rubber.BulletImpact" )
	end
	
	-- Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	
	local TargetVelocity = NewVelocity * LastSpeed * 1
	
	physobj:SetVelocity( TargetVelocity )
	
end

function ENT:OnFungusThink()

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
	
	-- Make the traces kinda short for bouncy fungus.
	trace.endpos = Vector((trace_pos.x + math.Rand(-100,100)), (trace_pos.y + math.Rand(-100,100)), (trace_pos.z + math.Rand(-100,100)))
	
	-- Perform the trace
	tr = util.TraceLine(trace)
	
	-- Bouncy Fungus do not like breeding near walls.
	
	-- If we do not hit anything...
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
		ent:Initialize()
		
					
			
		-- Make a noise!
			
		local whichsound = math.random(1,3)
		local sound = tostring(whichsound)
			
		ent:EmitSound("weapons/bugbait/bugbait_squeeze" .. sound .. ".wav",100,100)
			
		-- Bouncy fungus doesn't stay attached to objects.
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(true)
			
		-- Successfully made a baby!
		breed_success = true
			
		-- Bouncy fungus jumps into the air at this point to celebrate!
		phys:ApplyForceCenter( Vector(0,0,100))
		
			
		
	end
	
	-- If we successfully breeded...
	
	if(breed_success == true) then
		
		-- Pick the next spawn time.
		self.next_spawn_time =  (CurTime() + math.Rand(GetConVar("fungus_min_breeding_delay"):GetFloat(), GetConVar("fungus_max_breeding_delay"):GetFloat()))
	
	else

	end
	
	
	
end