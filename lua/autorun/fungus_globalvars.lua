-- Globally-used variables for Blastfungus

CreateConVar("fungus_maxfungi", "500", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum number of active fungi allowed.")
CreateConVar("fungus_min_breeding_delay", "2", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum amount of time (in seconds) between fungi attempting to breed.")
CreateConVar("fungus_max_breeding_delay", "8", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum amount of time (in seconds) between fungi attempting to breed.")
CreateConVar("fungus_min_lifespan", "25", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Minimum amount of time (in seconds) that fungi can live.")
CreateConVar("fungus_max_lifespan", "35", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Maximum amount of time (in seconds) that fungi can live.")
CreateConVar("fungus_think_rate", "0.5", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE, "Time (in seconds) between each fungus performing an action. Increase this to lower the strain on your server - however, it will decrease the survivability of fungi.")

fungus_currentpop = 0

fungus_float_minpower = -100
fungus_float_maxpower = 100

