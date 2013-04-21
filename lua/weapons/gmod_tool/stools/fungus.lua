TOOL.Category		= "Biological"
TOOL.Name			= "#Fungus"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if ( CLIENT ) then
    TOOL.ClientConVar[ "type" ] = "0"
	TOOL.ClientConVar[ "r" ] = "0"
	TOOL.ClientConVar[ "g" ] = "0"
	TOOL.ClientConVar[ "b" ] = "0"
	TOOL.ClientConVar[ "a" ] = "55"
	TOOL.ClientConVar[ "thisbreed" ] = "0"
	language.Add( "Fungus", "Blastfungus" )
	
	language.Add( "fungus_normal", "Normal Fungus")
	language.Add( "fungus_color", "Colour Fungus")
	language.Add( "fungus_rope", "Rope Fungus")
	language.Add( "fungus_float", "Floating Fungus")
	language.Add( "fungus_bouncy", "Bouncy Fungus")
	language.Add( "fungus_vent", "Vent Fungus")
	language.Add( "fungus_infect", "Infectious Fungus")
	
	language.Add( "Fungus_type", "Fungus Type")
	
	language.Add( "Tool_fungus_name", "Blastfungus Tool" )
	language.Add( "Tool_fungus_desc", "Start a Blastfungus colony." )
	language.Add( "Tool_fungus_0", "Left click to start a colony." )
	
	language.Add( "Undone_fungus", "Undone Blastfungus" )
end

function TOOL:Reload()

	--Reloading the tool removes all the fungus.
	local removetype = "fungus_*"
	if (self:GetOwner():IsAdmin()) then
		-- Only remove this breed.
		if(self:GetClientInfo("thisbreed") == "1") then
			local fungtype = self:GetClientInfo("type")
			if(fungtype == "0") then
				removetype = "fungus_base"
			elseif(fungtype == "1") then
				removetype = "fungus_color"
			elseif(fungtype == "2") then
				removetype = "fungus_rope"
			elseif(fungtype == "3") then
				removetype = "fungus_floating"
			elseif(fungtype == "4") then
				removetype = "fungus_bouncy"
			elseif(fungtype == "5") then
				removetype = "fungus_vent"
			elseif(fungtype == "6") then
				removetype = "fungus_infect"
			else
				removetype = "fungus_base"
			end
		end
		local t = ents.FindByClass( removetype )
		for k,v in ipairs(t) do
			v:Remove()
		end
		self:GetOwner():EmitSound("ui/buttonclickrelease.wav", 500, 100 )
		return false
	else
		return true 
	end
end



function TOOL:LeftClick( trace )

	-- Do not do it if it ain't serverside!
	if (CLIENT) then return true end
	
	-- If we hit an entity...
    if (trace.HitNonWorld) then
		
		local hitent = trace.Entity:GetClass()
		
		-- Make sure it isn't a player, npc, or another fungus.
		
		if ("player" == hitent) or (string.find(hitent,"npc")) or (string.find(hitent,"fungus_")) then
			return
		end
	end
	
	-- Set up spawn position
	
	local pos = trace.HitPos
	local ang = trace.HitNormal:Angle()
	
	pos = pos + (trace.HitNormal * 2)
	
	ang.pitch = ang.pitch + 90
	
	local fungtype = self:GetClientInfo("type")
	
	-- Do it!
	
	-- Make a fungus!
	if(fungtype == "0") then
		fungus = ents.Create("fungus_base")
	elseif(fungtype == "1") then
		fungus = ents.Create("fungus_color")
	elseif(fungtype == "2") then
		fungus = ents.Create("fungus_rope")
	elseif(fungtype == "3") then
		fungus = ents.Create("fungus_floating")
	elseif(fungtype == "4") then
		fungus = ents.Create("fungus_bouncy")
	elseif(fungtype == "5") then
		fungus = ents.Create("fungus_vent")
	elseif(fungtype == "6") then
		fungus = ents.Create("fungus_infect")
	else
		fungus = ents.Create("fungus_base")
	end
	
	-- Check validity!
	if(!fungus:IsValid()) then return end
	
	
	fungus:SetPos(pos)
	fungus:SetAngles(ang)
	--weld it to a prop if we hit one
	if(trace.HitNonWorld) then
		fungus:SetOwner(trace.Entity)
	end
	fungus:Spawn()
	
	-- Make a noise!
	local soundrandom = math.random(1,3)
	local sound = tostring(soundrandom)
	fungus:EmitSound("weapons/bugbait/bugbait_squeeze" .. sound .. ".wav",500,100)

	-- Provided this is not a floating fungus, weld it.
	if(fungtype != "3") then
		local weld = constraint.Weld(fungus,trace.Entity, 0, trace.PhysicsBone, 0)
	end

	-- Add undo entries
	undo.Create("Blastfungus")
	undo.AddEntity(fungus)
	undo.SetPlayer(self:GetOwner())
	undo.Finish()
	self:GetOwner():AddCleanup("Blastfungus",fungus)
	
	-- If this is a colour fungus, apply the colour from the colour panel.
	
	if(fungtype == "1") then
		
		local r = self:GetClientInfo("r")
		local g = self:GetClientInfo("g")
		local b = self:GetClientInfo("b")
		local a = self:GetClientInfo("a")
		
		
		fungus:SetColor( Color(r, g, b, a))
		
	end
	
	

	
	return true
end



function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "ComboBox", { 
						Label = "#Fungus_type",
						MenuButton = "0",
						Options = {
							["#fungus_normal"]	= { fungus_type = "0" },
							["#fungus_color"]	= { fungus_type = "1" },
							["#fungus_rope"]	= { fungus_type = "2" },
							["#fungus_float"]	= { fungus_type = "3" },
							["#fungus_bouncy"]	= { fungus_type = "4" },
							["#fungus_vent"]	= { fungus_type = "5" },
							["#fungus_infect"]  = { fungus_type = "6" }
						},
						CVars = { "fungus_type" },
	})	
					
	CPanel:AddControl("Color", {
						Label = "Colour",
						Red   = "fungus_r",
						Green = "fungus_g",
						Blue  = "fungus_b",
						Alpha = "fungus_a",
	})
	
	
	CPanel:AddControl("Checkbox", {
						Label = "Remove this breed only?",
						Command = "fungus_thisbreed"
	
						
	})
end
