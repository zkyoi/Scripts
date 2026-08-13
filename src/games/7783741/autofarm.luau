-- I don't know why this code works, sorry future me 🤲

if not firetouchinterest then warn("Not supported!") return end

-- // Library
local _version: string = "v1.2.0"
local vortex = loadstring(game:HttpGet("https://github.com/zkyoi/Vortex/releases/download/" .. _version .. "/main.luau"))()
if not vortex then warn("Failed to load Vortex!") return end

-- // Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- // Variables
local localPlayer: Player = Players.LocalPlayer
local character: Model? = vortex.GetChar(localPlayer)
if not character then warn("Failed to find character!") return end
local root: BasePart? = vortex.GetRoot(character)
if not root then warn("Failed to find root!") return end

local isAutoFarming: boolean = false
local isFinished: boolean = false

-- // Helper Functions
local function FindKiller(): Model?
    for _, v: Model? in Workspace:GetChildren() do
        if v:IsA("Model") and (v:FindFirstChild("TimerTimer") or v:FindFirstChild("Map") or v:FindFirstChild("MapParts") or v:FindFirstChild("EARNINGS") or v:FindFirstChild("KILLER")) then
            return v :: Model
        end
    end

    return nil
end

-- // Game Variables
local lastKiller: Model?
local currentKiller: Model? = FindKiller()

isAutoFarming = true

while isAutoFarming do
    -- Checks
    if not character then
        warn("Failed to find character, retrying..!")
        character = vortex.GetChar(localPlayer)
    end

    if not root then
        warn("Failed to find root, retrying..!")
        root = vortex.GetRoot(character)
    end

    if not root or not character then
        warn("Failed to find root or character!")
        task.wait(1)
        return
    end

    -- Actual autofarming stuff
    if currentKiller ~= nil then
        if not isFinished then
            print("Found Killer Model!")
        end

        task.wait(0.5)
        lastKiller = currentKiller

        local map: Model? = currentKiller:FindFirstChild("Map")
        local earnings: Model? = currentKiller:FindFirstChild("EARNINGS")
        local allEarnings = earnings and earnings:GetChildren()

        -- Check earnings and collect badges, coins, etc.
        if earnings and #allEarnings > 1 then
            if isFinished then
                print("Attempting to collect earnings again..")
            end

            for _, coin in earnings:GetChildren() do
                local name: string = coin.Name
                if coin:IsA("BasePart") and string.match(name, "Coin") then
                    -- For some reason this broke it, so ig I'll leave it lol
                    if coin ~= nil then -- and root:IsDescendantOf(Workspace) and coin:IsDescendantOf(Workspace)
                        print(string.format("Collecting %s..", name))
                        local success, err = pcall(function()
                            firetouchinterest(root, coin, true)
                            task.wait(0.05)
                            firetouchinterest(root, coin, false)
                        end)

                        if not success then
                            warn("Something went wrong: " .. tostring(err))
                        end

                        task.wait(0.1)
                    else
                        warn(string.format("Failed to collect %s!", name))
                    end
                elseif name == "BADGE" and coin:IsA("Model") or coin:IsA("BasePart") then
                    local basePart: BasePart? = coin:FindFirstChild("Parts") and coin:FindFirstChild("Parts"):FindFirstChild("Base")
                    if basePart ~= nil then -- and root:IsDescendantOf(Workspace) and basePart:IsDescendantOf(Workspace)
                        print("Collecting Badge..")
                        local success, err = pcall(function()
                            firetouchinterest(root, basePart, true)
                            task.wait(0.05)
                            firetouchinterest(root, basePart, false)
                        end)

                        if not success then
                            warn("Something went wrong: " .. tostring(err))
                        end
                    else
                        warn("Failed to collect Badge!")
                    end
                end
            end
        else
            if not earnings and not isFinished then
                warn("Failed to find EARNINGS folder!") -- waba laba doo
            end
        end

        -- Collect stuff in the Model
        for _, v in currentKiller:GetChildren() do
            if not (v ~= nil and root:IsDescendantOf(Workspace) and v:IsDescendantOf(Workspace)) then continue end
            if v.Name == "RedKeyGiver" and v:FindFirstChild("Head") then
                local head: BasePart = v:FindFirstChild("Head")
                print("Collecting Red Key..")
                local success, err = pcall(function()
                    firetouchinterest(root, head, true)
                    task.wait(0.05)
                    firetouchinterest(root, head, false)
                end)

                if not success then
                    warn("Something went wrong: " .. tostring(err))
                end
            end
        end

        -- Finished
        if not isFinished then
            isFinished = true
            print("Finished! Waiting for next round..")
        end
    end

    currentKiller = FindKiller()
    if currentKiller ~= nil and currentKiller ~= lastKiller then
        isFinished = false
    end

    task.wait(1)
end
