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
	self.spawn_time = CurTime()
	self.next_zap_time = (CurTime() + math.Rand(GetConVar("fungus_min_lightning_zap_delay"):GetFloat(), GetConVar("fungus_max_lightning_zap_delay"):GetFloat()))

	-- Physical Stuff
	self.Entity:SetModel(self.model)
	self.Entity:SetMaterial("models/debug/debugwhite")
	self.Entity:PhysicsInitSphere(3)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
	self.Entity:SetColor( Color(159,61,240,245) )
		
	-- Update global population value
	fungus_currentpop = fungus_currentpop + 1
	
	-- Precache fungus noises
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze1.wav")
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze2.wav") 
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav") 

	-- Precache zaps
	util.PrecacheSound("ambient/energy/zap1.wav")
	util.PrecacheSound("ambient/energy/zap2.wav")
	util.PrecacheSound("ambient/energy/zap3.wav")
	util.PrecacheSound("ambient/energy/zap5.wav")
	util.PrecacheSound("ambient/energy/zap6.wav")
	util.PrecacheSound("ambient/energy/zap7.wav")
	util.PrecacheSound("ambient/energy/zap8.wav")
	util.PrecacheSound("ambient/energy/zap9.wav")
	
end


function ENT:FungusFindAndZapTarget()
	-- Begin tracing a few feet away from the current fungus.
	trace_pos = self.Entity:GetPos() + (self.Entity:GetForward() * 16)
	
	trace = {}
	trace.start = trace_pos
	-- Make the traces short
	trace.endpos = Vector((trace_pos.x + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.y + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())), (trace_pos.z + math.Rand(-GetConVar("fungus_max_distance"):GetFloat(),GetConVar("fungus_max_distance"):GetFloat())))
	trace.filter = self.Entity

	-- Perform the trace
	tr = util.TraceLine(trace)

	local zapdamage = math.random(2,8)
	
	-- If we hit something, and it isn't the sky...
	if ((tr.Hit) and (!tr.HitSky) and IsValid(tr.Entity)) then
		-- ... if it's a fungus, we don't want to apply any damage.
		local hitentity = tr.Entity:GetClass()
		
		if (string.find(hitentity,"fungus_")) then
			zapdamage = 0
		end
		

		-- If the trace hit close by...
		if(self.Entity:GetPos():Distance(tr.HitPos) > GetConVar("fungus_min_distance"):GetFloat()) and (self.Entity:GetPos():Distance(tr.HitPos) < GetConVar("fungus_max_distance"):GetFloat()) then
			-- Do a zap. Let's do this with a CEffect
			local effect_data = EffectData()
			effect_data:SetStart(self.Entity:GetPos())
			effect_data:SetEntity(self.Entity)
			effect_data:SetOrigin(tr.HitPos)
			tr.Entity:TakeDamage(zapdamage, self.Entity, self.Entity)
			util.Effect("ToolTracer", effect_data)

			-- play zap sound
			local whichsound = math.random(1,9)
			local sound = tostring(whichsound)
			self.Entity:EmitSound("ambient/energy/zap" .. sound .. ".wav",100,100)			
			

			-- Set a time out
			self.next_zap_time = (CurTime() + math.Rand(GetConVar("fungus_min_lightning_zap_delay"):GetFloat(), GetConVar("fungus_max_lightning_zap_delay"):GetFloat()))
		end
	end
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

	if(CurTime() >= self.next_zap_time) then
		-- Lightning fungus loves to zap.
		self.Entity:FungusFindAndZapTarget()
	end
	
	return true
	
end	