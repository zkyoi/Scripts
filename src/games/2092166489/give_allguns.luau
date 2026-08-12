if not firetouchinterest then warn("Not supported!") return end

-- // Library
local _version: string = "v1.2.0"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()

-- // Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- // Variables
local localPlayer: Player = Players.LocalPlayer
local character: Model? = vortex.GetChar(localPlayer)
if not character then warn("Failed to find character!") return end
local root: BasePart? = vortex.GetRoot(character)
if not root then warn("Failed to find root!") return end
local weaponsFolder: Instance? = Workspace:FindFirstChild("Weapons")
if not weaponsFolder then warn("Failed to find Weapons folder!") return end

for _, weapon: Model? in weaponsFolder:GetChildren() do
    local hitbox: BasePart? = weapon:FindFirstChild("Hitbox")
    if not hitbox and not hitbox:IsA("BasePart") then continue end
    firetouchinterest(root, hitbox, true)
    task.wait()
    firetouchinterest(root, hitbox, false)
    task.wait(0.1)
end
