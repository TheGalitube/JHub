-- Grundlegendes UI für JJsploit
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AutoBubbleButton = Instance.new("TextButton")
local AutoSellButton = Instance.new("TextButton")
local IntervalLabel = Instance.new("TextLabel")
local IntervalInput = Instance.new("TextBox")

-- UI-Setup
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Bubble Simulator Tester"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18.0

AutoBubbleButton.Name = "AutoBubbleButton"
AutoBubbleButton.Parent = MainFrame
AutoBubbleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoBubbleButton.BorderSizePixel = 0
AutoBubbleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
AutoBubbleButton.Size = UDim2.new(0.8, 0, 0, 30)
AutoBubbleButton.Font = Enum.Font.SourceSans
AutoBubbleButton.Text = "Auto Bubble: AUS"
AutoBubbleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBubbleButton.TextSize = 16.0

AutoSellButton.Name = "AutoSellButton"
AutoSellButton.Parent = MainFrame
AutoSellButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoSellButton.BorderSizePixel = 0
AutoSellButton.Position = UDim2.new(0.1, 0, 0.45, 0)
AutoSellButton.Size = UDim2.new(0.8, 0, 0, 30)
AutoSellButton.Font = Enum.Font.SourceSans
AutoSellButton.Text = "Auto Sell: AUS"
AutoSellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoSellButton.TextSize = 16.0

IntervalLabel.Name = "IntervalLabel"
IntervalLabel.Parent = MainFrame
IntervalLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
IntervalLabel.BorderSizePixel = 0
IntervalLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
IntervalLabel.Size = UDim2.new(0.8, 0, 0, 20)
IntervalLabel.Font = Enum.Font.SourceSans
IntervalLabel.Text = "Verkaufsintervall (Sekunden):"
IntervalLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntervalLabel.TextSize = 14.0

IntervalInput.Name = "IntervalInput"
IntervalInput.Parent = MainFrame
IntervalInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
IntervalInput.BorderSizePixel = 0
IntervalInput.Position = UDim2.new(0.35, 0, 0.75, 0)
IntervalInput.Size = UDim2.new(0.3, 0, 0, 25)
IntervalInput.Font = Enum.Font.SourceSans
IntervalInput.Text = "10"
IntervalInput.TextColor3 = Color3.fromRGB(255, 255, 255)
IntervalInput.TextSize = 14.0

-- Variablen für die Funktionssteuerung
local autoBubbleEnabled = false
local autoSellEnabled = false
local sellInterval = 10
local bubbleConnection = nil
local sellConnection = nil

-- Funktion: Auto Blasen
local function toggleAutoBubble()
    autoBubbleEnabled = not autoBubbleEnabled
    AutoBubbleButton.Text = "Auto Bubble: " .. (autoBubbleEnabled and "AN" or "AUS")
    
    if autoBubbleEnabled then
        bubbleConnection = game:GetService("RunService").Heartbeat:Connect(function()
            -- Remote-Event finden und auslösen (typischer Weg)
            local blowBubbleRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BlowBubble")
            if blowBubbleRemote then
                blowBubbleRemote:FireServer()
            end
        end)
    else
        if bubbleConnection then
            bubbleConnection:Disconnect()
            bubbleConnection = nil
        end
    end
end

-- Funktion: Auto Verkaufen
local function toggleAutoSell()
    autoSellEnabled = not autoSellEnabled
    AutoSellButton.Text = "Auto Sell: " .. (autoSellEnabled and "AN" or "AUS")
    
    if autoSellEnabled then
        -- Verkaufsintervall aus Textfeld übernehmen
        local inputText = IntervalInput.Text
        local interval = tonumber(inputText)
        if interval and interval >= 1 and interval <= 60 then
            sellInterval = interval
        else
            IntervalInput.Text = tostring(sellInterval)
        end
        
        -- Verkaufslogik
        sellConnection = coroutine.wrap(function()
            while autoSellEnabled do
                -- Remote-Hook für Verkauf finden und auslösen
                local sellRemote = game:GetService("ReplicatedStorage"):FindFirstChild("SellBubbles")
                if sellRemote then
                    sellRemote:FireServer()
                end
                wait(sellInterval)
            end
        end)()
    else
        autoSellEnabled = false
    end
end

-- Event-Handler für das Verkaufsintervall
IntervalInput.FocusLost:Connect(function(enterPressed)
    local inputText = IntervalInput.Text
    local interval = tonumber(inputText)
    if interval and interval >= 1 and interval <= 60 then
        sellInterval = interval
    else
        IntervalInput.Text = tostring(sellInterval)
    end
end)

-- Event-Handler für Buttons
AutoBubbleButton.MouseButton1Click:Connect(toggleAutoBubble)
AutoSellButton.MouseButton1Click:Connect(toggleAutoSell)

-- Aufräumen bei Script-Beendigung
local function cleanup()
    if bubbleConnection then
        bubbleConnection:Disconnect()
    end
    autoSellEnabled = false
    ScreenGui:Destroy()
end

-- Ermöglicht Deaktivierung des Scripts
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        cleanup()
    end
end)
