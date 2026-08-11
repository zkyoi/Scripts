local prisonlife = {}

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

function prisonlife.init(vortexLibrary): { SpawnCar: () -> () }
    if not vortexLibrary then return end
    local vortex = vortexLibrary

    local lib = {}

    -- // Helper Functions
    local function GetSpawner(): BasePart?
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

    local function CheckSeat(car, spawnerPosition): VehicleSeat?
        if not car then return nil end

        local body: Model? = car:FindFirstChild("Body")
        local seat: VehicleSeat? = (body and body:FindFirstChild("VehicleSeat"))

        if seat and seat:IsA("VehicleSeat") and seat:FindFirstChild("ReadyToSpawn") then
            local distance = (seat.Position - spawnerPosition).Magnitude
            if distance <= MAX_SPAWN_DISTANCE then
                return seat :: VehicleSeat
            end
        end
    end

    -- // Core Functions
    function lib.SpawnVehicle(): ()
        local character: Model? = vortex.GetChar(localPlayer)
        if not character then warn("Failed to find character!") return end
        local root: BasePart? = vortex.GetRoot(character)
        if not root then warn("Failed to find HumanoidRootPart!") return end
        local humanoid: Humanoid? = vortex.GetHumanoid(character)
        if not humanoid then warn("Failed to find Humanoid!") return end

        local spawner: BasePart? = GetSpawner()
        if not spawner then warn("Failed to find Spawner!") return end

        local spawnerCFrame = vortex.GetCFrame(spawner)
        if not spawnerCFrame then warn("Failed to get Spawner CFrame!") return end

        vortex.TeleportTo(spawnerCFrame * CFrame.new(0, 3, 0))
        task.wait(0.25)

        local targetSeat: VehicleSeat?
        local connection: RBXScriptConnection?
        connection = carContainer.ChildAdded:Connect(function(car)
            task.wait(0.1)

            local seat: VehicleSeat? = CheckSeat(car, spawnerCFrame.Position)
            if seat then
                targetSeat = seat
            end
        end)

        task.spawn(function()
            remotes["InteractWithItem"]:InvokeServer(spawner)
        end)

        local getTimer = vortex.CreateTimer(3)
        while true do
            local data = getTimer()
            for _, car: Model? in carContainer:GetChildren() do
                local seat: VehicleSeat? = CheckSeat(car, spawnerCFrame.Position)
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
            task.wait(0.05)
        end

        vortex.Disconnect(connection)

        if targetSeat then
            vortex.TeleportTo(targetSeat.CFrame * CFrame.new(0, 2, 0))
            if firetouchinterest then
                firetouchinterest(root, spawner, true)
                task.wait()
                firetouchinterest(root, spawner, false)
            end
            targetSeat:Sit(humanoid)
        else
            warn("Failed!")
        end
    end

    return lib
end

return prisonlife
