-- Globally-used variables for Blastfungus

CreateConVar("fungus_maxfungi", "500", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum number of active fungi allowed.")
CreateConVar("fungus_min_breeding_delay", "2", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum amount of time (in seconds) between fungi attempting to breed.")
CreateConVar("fungus_max_breeding_delay", "8", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum amount of time (in seconds) between fungi attempting to breed.")
CreateConVar("fungus_min_lifespan", "25", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum amount of time (in seconds) that fungi can live.")
CreateConVar("fungus_max_lifespan", "35", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum amount of time (in seconds) that fungi can live.")
CreateConVar("fungus_think_rate", "0.15", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Time (in seconds) between each fungus performing an action. Increase this to lower the strain on your server - however, it will decrease the survivability of fungi.")
CreateConVar("fungus_min_distance", "50", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum distance in game units for fungi to breed to. Recommended that you don't change this.")
CreateConVar("fungus_max_distance", "400", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum distance in game units for fungi to breed to. Recommended that you don't change this.")
CreateConVar("fungus_balloon_min_size_increase", "5.0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum scale increase that balloon fungus can undergo.")
CreateConVar("fungus_balloon_max_size_increase", "10.0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum scale increase that balloon fungus can undergo.")
CreateConVar("fungus_min_lightning_zap_delay", "0.05", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum time (in seconds) between lightning fungus zaps.")
CreateConVar("fungus_max_lightning_zap_delay", "0.15", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum time (in seconds) between lightning fungus zaps.")

fungus_currentpop = 0

fungus_float_minpower = -100
fungus_float_maxpower = 100
fungus_evolve_mutation_rate = 0.10
fungus_evolve_mutation_chance = 25.0

fungus_think_next = CurTime()
fungus_list = {}

if(SERVER) then
	local function OnFungusThink()
		if(CurTime() >= fungus_think_next) then
			-- When do we think next?
			fungus_think_next = CurTime() + GetConVar("fungus_think_rate"):GetFloat()
			
			
			-- Clean out any nil values and re-create master table
			clean_list = {}
			for k, v in pairs(fungus_list) do
				if(v != nil && IsValid(v)) then
					table.insert(clean_list, v)
				end
			end
			fungus_list = clean_list
			
			-- Do think for all fungi!
			for k, v in pairs(fungus_list) do
				if(IsValid(v)) then 
					v:OnFungusThink()
				end
			end					
		end
		

	end

	hook.Add("Think", "OnFungusThink", OnFungusThink)
end