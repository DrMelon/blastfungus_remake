AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')




function ENT:Touch(activator)

	-- What's touching me?
	toucher = activator:GetClass()
	
	if(string.find(toucher,"fungus_") == nil) then
		-- If it wasn't a fungus that bumped us...
		self.Entity:FungusAction(activator)
		-- ... perform this fungus' action!	
	end
	
end


function ENT:FungusAction(trigger)
	-- Infectious Fungus does not explode - rather, it plants spores inside the object which caused it harm.
	
	-- NOTE: Disabling this fungus for now. Ideally, we'd want to make an invisible entity which tracks the thing that touched it.
	
	if(self.has_exploded == false) then
		self.has_exploded = true
		-- Where are we?
		pos = self.Entity:GetPos()
		-- What touched us? This only works on players and npcs
		if(trigger:IsValid()) then
			-- Play a sound and start the doom timer (30 seconds)
			self.Entity:EmitSound("weapons/bugbait/bugbait_squeeze1.wav",100,100)
			timer.Simple(30,function()
			
				-- Play a sound and kill the target, spreading fungi all over the place!
				-- Also move here.
				self.Entity:SetPos(trigger:GetPos())
				
				trigger:SetHealth(0)
				trigger:EmitSound("weapons/bugbait/bugbait_squeeze1.wav",100,100)
				trigger:Kill()
				for i = 1, 15 do
					self.Entity:FungusBreed()
				end
				
				-- Remove self
				self.Entity:Remove()	

				end
			
			)
		else
			self.Entity:Remove()
		end
		
		
	end
end
	
function ENT:Think()
	-- Infection Fungi do not Die or Breed naturally.
	self.Entity:NextThink(CurTime() + GetConVar("fungus_think_rate"):GetFloat())
	
	return true
	
end		
	
	
	
	