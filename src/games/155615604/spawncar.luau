-- // Vortex Library
local _version = "v1.2.0"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()

-- // Prison Life Library
local prisonLife = loadstring(game:HttpGet("https://raw.githubusercontent.com/zkyoi/Scripts/refs/heads/main/src/games/155615604/library.luau"))().init(vortex)

prisonLife.SpawnCar()
