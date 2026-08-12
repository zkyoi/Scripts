-- // Vortex Library
local _version = "v1.2.0"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()
if not vortex then warn("Failed to load Vortex!") return nil end

-- // Prison Life Library
local prisonlife = loadstring(game:HttpGet("https://raw.githubusercontent.com/zkyoi/Scripts/refs/heads/main/src/games/155615604/library.luau"))()

prisonlife.SpawnVehicle()
