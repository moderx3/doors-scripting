local Library = {}
Library.__index = Library

-- хранение
local UIS = game:GetService("UserInputService")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomLibMenu"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(28,28,32)
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 28)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40,40,45)
    TitleBar.Text = title or "Menu"
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextSize = 18
    TitleBar.TextColor3 = Color3.fromRGB(255,255,255)
    TitleBar.Parent = Main

    -- Unload button
    local UnloadBtn = Instance.new("TextButton")
    UnloadBtn.Size = UDim2.new(0,80,0,22)
    UnloadBtn.Position = UDim2.new(1,-90,0,3)
    UnloadBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    UnloadBtn.Font = Enum.Font.SourceSansBold
    UnloadBtn.TextSize = 15
    UnloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
    UnloadBtn.Text = "Unload"
    UnloadBtn.Parent = Main

    UnloadBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- скрытие/показ по Insert
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            Main.Visible = not Main.Visible
        end
    end)

    local win = setmetatable({Main = Main, Tabs = {}}, Library)
    return win
end

function Library:AddTab(name)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,0,1,-28)
    TabFrame.Position = UDim2.new(0,0,0,28)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = self.Main

    local Tab = setmetatable({Frame = TabFrame}, Library)
    table.insert(self.Tabs, Tab)
    return Tab
end

function Library:AddLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,22)
    lbl.Position = UDim2.new(0,10,0,10 + #self.Frame:GetChildren()*26)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = self.Frame
    return lbl
end

function Library:AddToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,24)
    btn.Position = UDim2.new(0,10,0,10 + #self.Frame:GetChildren()*28)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = self.Frame
    local state = default or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        if callback then callback(state) end
    end)
    return btn
end

function Library:AddSwitch(text, default, callback)
    return self:AddToggle(text, default, callback)
end

function Library:AddSlider(text, min, default, max, callback)
    local val = default or min
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,22)
    lbl.Position = UDim2.new(0,10,0,10 + #self.Frame:GetChildren()*28)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text .. ": " .. val
    lbl.Parent = self.Frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1,-20,0,20)
    slider.Position = UDim2.new(0,10,0,10 + #self.Frame:GetChildren()*28)
    slider.BackgroundColor3 = Color3.fromRGB(70,70,75)
    slider.Text = ""
    slider.Parent = self.Frame

    local dragging = false
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mouse = UIS:GetMouseLocation().X
            local pos = math.clamp((mouse - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max-min)*pos)
            lbl.Text = text .. ": " .. val
            if callback then callback(val) end
        end
    end)
end

function Library:AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,24)
    btn.Position = UDim2.new(0,10,0,10 + #self.Frame:GetChildren()*28)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.Parent = self.Frame
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

return Library
