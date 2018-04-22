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
	self.rcol = math.Rand(0.0, 255.0)
	self.gcol = math.Rand(0.0, 255.0)
	self.bcol = math.Rand(0.0, 255.0)
	self.acol = 255.0
	self.dna_string = self:CreateDNAString()
	self.species_marker = GetConVar("fungus_species_marker"):GetString()
	self.root_species = GetConVar("fungus_species_marker"):GetString()
	self.childnum = 0
	self.parent_pos = self:GetPos()
	
	-- Physical Stuff
	self:SetModel(self.model)
	self:PhysicsInitSphere(3)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
	self:SetColor( Color(self.rcol,self.gcol,self.bcol,self.acol) )
	self:SetMaterial("models/debug/debugwhite", true)
	
	-- Update global population value
	fungus_currentpop = fungus_currentpop + 1
	
	-- Precache fungus noises
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze1.wav")
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze2.wav") 
	util.PrecacheSound("weapons/bugbait/bugbait_squeeze3.wav") 
	util.PrecacheSound("vo/k_lab/kl_ahhhh.wav") 
	
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
	
	if(string.find(toucher,"fungus_") == nil and IsValid(activator)) then
		-- If it wasn't a fungus that bumped us...
		self.Entity:FungusAction()
		-- ... perform this fungus' action!	
	end
	
end

function ENT:OnFungusThink()
	self:SetNWString("m", self.species_marker)
	self:SetNWFloat("r", self.rcol)
	self:SetNWFloat("g", self.gcol)
	self:SetNWFloat("b", self.bcol)
	self:SetNWVector("parentpos", self.parent_pos)
	self:SetNWString("dna", self.root_species .. " -- " .. self:PrettyPrintDNAString(self.dna_string))
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
	--puff = ents.Create("env_smoketrail")
	--puff:SetKeyValue("startsize","10")
	--puff:SetKeyValue("endsize","20")
	--puff:SetKeyValue("minspeed","1")
	--puff:SetKeyValue("maxspeed","2")
	--puff:SetKeyValue("startcolor","40 40 40")
	--puff:SetKeyValue("endcolor","0 40 0")
	--puff:SetKeyValue("opacity",".8")
	--puff:SetKeyValue("spawnrate","5")
	--puff:SetKeyValue("lifetime","1")
	--puff:SetPos(self.Entity:GetPos())
	--puff:Spawn()
	--puff:Fire("kill","",0.7)
	
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
			ent:SetOwner(tr.Entity)
			
			ent.root_species = self.root_species
			ent:CreateFromDNAString(self:MutateDNAString(self.dna_string))
			ent.species_marker = self.species_marker .. tostring(self.childnum)
			
			local bredWithOther = false
			local other_dna = {}
			local other_marker = ""
			
			local otherFung = FindNearestEntity("fungus_evolving", self:GetPos(), GetConVar("fungus_max_distance"):GetFloat(), self)
			
			if(otherFung != nil and math.Rand(0, 100) < fungus_evolve_mutation_chance) then
				
				bredWithOther = otherFung:IsValid()
				
				if(bredWithOther == true) then
					if(otherFung.root_species == self.root_species) then
						bredWithOther = false
						print("SAME SPECIES")
					end
				end
				
			end
		
			if(bredWithOther == true) then
				other_dna = otherFung.dna_string
				other_marker = otherFung.species_marker
				ent:CreateFromDNAString(self:MutateDNAString(self:BreedDNAString(other_dna)))
				ent.species_marker = self.species_marker .. tostring(self.childnum) .. "(" .. string.sub(self.root_species, 1) .. "x" .. string.sub(otherFung.root_species, 1) .. ")"
				print("BRED: " .. otherFung.root_species .. " x s." .. self.root_species)
				ent:EmitSound("vo/k_lab/kl_ahhhh.wav", 100, 100)
			end
			
			ent:SetColor(Color(ent.rcol,ent.gcol,ent.bcol,ent.acol))
			ent.parent_pos = self:GetPos()
			
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
			self.childnum = self.childnum + 1
			
		
		end
			
		
	end
	
	-- If we successfully bred...
	
	if(breed_success == true) then
		
		-- Pick the next spawn time.
		self.next_spawn_time = (CurTime() + math.Rand(self.dna_string[3], self.dna_string[4]))
	
	else

	end
	
	
	
end

function FindNearestEntity( className, pos, range, notme )
	local nearestEnt;
	
	for i, entity in ipairs( ents.FindByClass( className ) ) do 
		local distance = pos:Distance( entity:GetPos() )
			if( distance <= range and entity != notme) then
			
				nearestEnt = entity;
				range = distance;
			
		end
	end
	
	return nearestEnt;
    
end

function ENT:CreateDNAString()
	-- Fungus Genome:
	--
	-- 000 000 000    0.0      0.0
	-- 255 255 255 
	--  r  g  b     breedmin breedmax
	
	local dna_string = {}
	dna_string[0] = 0.0
	dna_string[1] = 0.0
	dna_string[2] = 0.0
	dna_string[3] = 0.0
	dna_string[4] = 0.0
	
	
	dna_string[0] = self.rcol
	dna_string[1] = self.gcol
	dna_string[2] = self.bcol
		
	-- minmax breed
	dna_string[3] = GetConVar("fungus_min_breeding_delay"):GetFloat()
	dna_string[4] = GetConVar("fungus_max_breeding_delay"):GetFloat()
	
	return dna_string
end

function ENT:MutateDNAString(dna_string)
	local new_dna = {}
	local sequence_string = self:PrettyPrintDNAString(dna_string)
	local genes_mutated = 0
	sequence_string = sequence_string .. " -> "
	for i=0, #dna_string do
		new_dna[i] = dna_string[i]
		if((math.Rand(0, 100)) < fungus_evolve_mutation_chance) then
			new_dna[i] = math.Rand(dna_string[i] - fungus_evolve_mutation_rate, dna_string[i] + fungus_evolve_mutation_rate)
			genes_mutated = genes_mutated + 1
			print("Mutating gene: " .. tostring(dna_string[i]) .. "->" .. tostring(new_dna[i]))
			if(new_dna[i] < 0) then
				new_dna[i] = 0
			end
		end
	end
	sequence_string = sequence_string .. self:PrettyPrintDNAString(new_dna)
	print("Species Mutate: " .. self.species_marker .. ": " ..  sequence_string .. " -- Genes Affected: " .. tostring(genes_mutated))
	return new_dna
end

function ENT:BreedDNAString(dna_string)
	local new_dna = {}
	for i=0, #dna_string do
		if(math.Rand(0, 100) < 50) then
			new_dna[i] = dna_string[i]
		else
			new_dna[i] = self.dna_string[i]
		end
	end
	
	return new_dna
end

function ENT:CreateFromDNAString(dna_string)

	self.dna_string = dna_string
	self.rcol = (dna_string[0])
	self.gcol = (dna_string[1])
	self.bcol = (dna_string[2])

end

function ENT:PrettyPrintDNAString(dna_string)
	local sequence_string = ""
	for i=0, #dna_string do
		sequence_string = sequence_string .. string.format("%.1f", dna_string[i]) .. ":"
	end
	
	return sequence_string
end
