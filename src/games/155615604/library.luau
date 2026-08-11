local PrisonLife = {}

-- // Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Variables
local localPlayer: Player? = Players.LocalPlayer
local carContainer = Workspace:FindFirstChild("CarContainer")
local prisonItems = Workspace:FindFirstChild("Prison_ITEMS")
local buttonsFolder = prisonItems:FindFirstChild("buttons")
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

local remotes = {
    ["InteractWithItem"] = remotesFolder:FindFirstChild("InteractWithItem")
}

-- // Constants
local MAX_SPAWN_DISTANCE: number = 35
local TARGET_CAR_NAME: string = "Sedan"

-- // Helper Functions
local function GetSpawnerPart(): ()
    for _, child in buttonsFolder:GetChildren() do
        local targetPart: BasePart? = nil

        if child:IsA("Model") then
            targetPart = child:FindFirstChild("Car Spawner")
        elseif child:IsA("BasePart") and child.Name == "Car Spawner" then
            targetPart = child
        end

        if targetPart and targetPart:IsA("BasePart") then
            return targetPart
        end
    end

    return nil
end

local function CheckCarSeat(carModel, spawnerPos): VehicleSeat?
    if not carModel then return nil end

    local body: Model? = carModel:FindFirstChild("Body")
    local seat: VehicleSeat? = (body and body:FindFirstChild("VehicleSeat")) or carModel:FindFirstChild("VehicleSeat")

    if seat and seat:IsA("BasePart") and seat:FindFirstChild("ReadyToSpawn") then
        local distance = (seat.Position - spawnerPos).Magnitude
        if distance <= MAX_SPAWN_DISTANCE then
            return seat
        end
    end

    return nil
end

-- // Core Functions
function PrisonLife.init(vortexLibrary): { SpawnCar: () -> () }?
    local vortex = vortexLibrary
    if not vortex then return nil end

    local lib = {}

    function lib.SpawnCar(): ()
        -- Setup
        local character: Model? = vortex.GetChar(localPlayer)
        local root: BasePart? = vortex.GetRoot(character)
        local humanoid: Humanoid? = character and vortex.GetHumanoid(character)
        if not character or not root or not humanoid then warn("Missing variables!") return end

        local spawnerPart: BasePart? = GetSpawnerPart()
        if not spawnerPart then warn("Failed to find Spawner Part!") return end

        local spawnerCFrame: CFrame? = vortex.GetCFrame(spawnerPart)
        if not spawnerCFrame then warn("Failed to get CFrame!") return end

        -- Teleport character to spawner
        root.CFrame = spawnerCFrame * CFrame.new(0, 3, 0)
        task.wait(0.25)

        local targetSeat: VehicleSeat? = nil

        local connection: RBXScriptConnection?
        connection = carContainer.ChildAdded:Connect(function(car)
            task.wait(0.1)

            local seat: VehicleSeat? = CheckCarSeat(car, spawnerCFrame.Position)
            if seat then
                targetSeat = seat
            end
        end)

        -- Spawn car using remote
        task.spawn(function()
            remotes["InteractWithItem"]:InvokeServer(spawnerPart)
        end)

        -- Timer
        local getTimer = vortex.CreateTimer(5)
        while true do
            local data = getTimer()
            for _, car in carContainer:GetChildren() do
                local seat: VehicleSeat? = CheckCarSeat(car, spawnerCFrame.Position)
                if seat then
                    targetSeat = seat
                    break
                end
            end

            if data.isFinished then
                warn("Timed out.")
                break
            end

            if targetSeat then break end
            task.wait(0.1)
        end

        vortex.Disconnect(connection)

        -- Get into car
        if targetSeat then
            vortex.TeleportTo(targetSeat.CFrame * CFrame.new(0, 2, 0))
            if firetouchinterest then
                firetouchinterest(root, targetSeat, true)
            end
            task.wait()
            if firetouchinterest then
                firetouchinterest(root, targetSeat, false)
            end
            targetSeat:Sit(humanoid)
            print("Spawned car!")
        else
            warn("Failed to spawn car!")
        end
    end

    return lib
end

return PrisonLife
