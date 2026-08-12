-- // Variables
local localPlayer: Player = game:GetService("Players").LocalPlayer
local speedAttribute = localPlayer:GetAttribute("SpeedBoosted")

if speedAttribute ~= true then
    localPlayer:SetAttribute("SpeedBoosted", true)
end
