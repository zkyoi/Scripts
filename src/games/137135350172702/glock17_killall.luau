-- // Library
local _version: string = "v1.1.1"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()

-- // Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- // Variables
local localPlayer: Player = Players.LocalPlayer
local character: Model? = vortex.GetChar(localPlayer)
if not character then warn("Failed to find character!") return end

local allPlayers = Players:GetPlayers()

local glock17: Tool? = vortex.FindTool(localPlayer, "Glock 17")
if not glock17 then warn("Failed to find Glock 17!") return end

local inflictTarget: RemoteEvent = glock17.GunScript_Server.InflictTarget
if not inflictTarget then warn("Failed to find InflictTarget remote!") return end

local function Kill(character): boolean
    local characterName = character.Name
    local humanoid: Humanoid? = vortex.GetHumanoid(character)
    local root: BasePart? = vortex.GetRoot(character)
    if not humanoid or not root then warn("Failed to find humanoid or root!") return end
    print(string.format("Trying to kill %s...", characterName))

    inflictTarget:FireServer(
        humanoid,
        root,
        9999,
        vortex.GetCFrame(root).Position,
        9999,
        9999,
        true
    )

    task.wait(1)

    if humanoid and humanoid.Health <= 0 then
        print(string.format("Killed %s!", characterName))
    else
        warn(string.format("Failed to kill %s!", characterName))
    end
end

local equip = vortex.EquipTool(glock17)
if not equip then warn("Failed to equip Glock 17!") return end

-- Kill all players (if pvp is on)
if #allPlayers > 1 then
    for _, player in allPlayers do
        if player == localPlayer then continue end
        task.spawn(Kill, vortex.GetChar(player))
        task.wait()
    end
end

-- Kill all zombies
for _, v in Workspace:GetChildren() do
    if v:IsA("Model") and string.find(v.Name:lower(), "zombie") then
        task.spawn(Kill, v)
        task.wait()
    end
end
