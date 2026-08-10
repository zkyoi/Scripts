-- // Library
local _version: string = "v1.1.1"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()

-- // Services
local Players = game:GetService("Players")

-- // Variables
local localPlayer: Player = Players.LocalPlayer
local allPlayers = Players:GetPlayers()
local swordTool: Tool? = vortex.FindTool(localPlayer, "Sword")

-- // Main
if not firetouchinterest then
    warn("Failed to find firetouchinterest function!")
    return
end

if swordTool then
    local equip = vortex.EquipTool(swordTool)
    if equip then
        local handle: BasePart? = swordTool:FindFirstChild("Handle")
        local handleTouch: TouchTransmitter? = handle:FindFirstChildOfClass("TouchTransmitter")
        if not handle or not handleTouch then warn("Failed to find Handle or TouchInterest!") return end

        if #allPlayers <= 1 then warn("No players in server!") return end

        for _, player in allPlayers do
            if player == localPlayer then continue end
            local playerName: string = player.Name
            local character: Model? = vortex.GetChar(player)
            if not character then warn(string.format("Failed to find %s's character!", playerName)) return end

            local root: BasePart? = vortex.GetRoot(character)
            if not root then warn(string.format("Failed to find %s's root!", playerName)) return end

            local humanoid: Humanoid = vortex.GetHumanoid(player)
            if not humanoid then warn(string.format("Failed to find %'s humanoid!", playerName)) return end
            print(string.format("Trying to kill: %s...", playerName))

            local function Touch(): ()
                firetouchinterest(handle, root, true)
                task.wait()
                firetouchinterest(handle, root, false)
            end

            local isRunning = false
            local thread: thread?  = nil
            local startTime = os.clock()

            local function Cancel(): ()
                isRunning = false
                if thread then
                    task.cancel(thread)
                end
            end

            thread = task.spawn(function()
                isRunning = true
                while isRunning do
                    local elapsedTime = os.clock() - startTime
                    if (humanoid and humanoid.Health <= 0) then
                        print(string.format("Killed %s!", playerName))
                        Cancel()
                    end

                    if elapsedTime > 10 then
                        warn(string.format("Timed out on %s!", playerName))
                        Cancel()
                    end

                    Touch()
                    task.wait(0.1)
                end
            end)
        end
    else
        warn("Couldn't equip Sword tool!")
    end
else
    warn("Failed to find Sword tool!")
end
