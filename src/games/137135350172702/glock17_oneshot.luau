if not hookmetamethod or not checkcaller then warn("Not supported!") return end

-- // Library
local _version: string = "v1.2.0"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()
if not vortex then warn("Failed to load Vortex!") return end

-- // Services
local Players = game:GetService("Players")

-- // Variables
local localPlayer: Player = Players.LocalPlayer
local character: Model? = vortex.GetChar(localPlayer)
if not character then warn("Failed to find character!") return end

-- // Game Variables
local glock17: Tool? = vortex.FindTool(localPlayer, "Glock 17")
if not glock17 then warn("Failed to find Glock 17!") return end

local inflictTarget: RemoteEvent = glock17.GunScript_Server.InflictTarget
if not inflictTarget then warn("Failed to find InflictTarget remote!") return end

local hook = nil
hook = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod():lower()
	if not checkcaller() and self == inflictTarget and method == "fireserver" then
		local args = {...}
        args[3] = 9999
        args[5] = 9999
        args[6] = 9999
        args[7] = true
		return hook(self, unpack(args))
	end
	return hook(self, ...)
end)

local equip = vortex.EquipTool(glock17)
if not equip then warn("Failed to equip Glock 17!") return end
