-- menulib.lua
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Создать окно
function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UniversalLibUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 360)
    Main.Position = UDim2.new(0.5, -260, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 36)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Universal Menu"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(240,240,240)
    Title.Parent = Main

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(0, 140, 1, -40)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundTransparency = 1

    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)

    local ContentHolder = Instance.new("Frame", Main)
    ContentHolder.Size = UDim2.new(1, -150, 1, -40)
    ContentHolder.Position = UDim2.new(0, 150, 0, 40)
    ContentHolder.BackgroundTransparency = 1

    local Tabs = {}

    function Tabs:AddTab(tabName)
        local Button = Instance.new("TextButton", TabHolder)
        Button.Size = UDim2.new(1, -10, 0, 32)
        Button.Text = tabName
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 14
        Button.TextColor3 = Color3.fromRGB(220,220,220)
        Button.BackgroundColor3 = Color3.fromRGB(35,35,40)
        Button.BorderSizePixel = 0
        local bcorner = Instance.new("UICorner", Button)
        bcorner.CornerRadius = UDim.new(0,8)

        local Page = Instance.new("ScrollingFrame", ContentHolder)
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 4
        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0,8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        Button.MouseButton1Click:Connect(function()
            for _,child in pairs(ContentHolder:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            Page.Visible = true
        end)

        if #ContentHolder:GetChildren() == 1 then
            Page.Visible = true
        end

        local Elements = {}

        function Elements:AddLabel(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1,-10,0,24)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = text
            return lbl
        end

        function Elements:AddButton(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1,-10,0,32)
            btn.Text = text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
            btn.BorderSizePixel = 0
            local bc = Instance.new("UICorner", btn)
            bc.CornerRadius = UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        function Elements:AddToggle(text, state, callback)
            local frame = Instance.new("Frame", Page)
            frame.Size = UDim2.new(1,-10,0,32)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1,-50,1,0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = Color3.fromRGB(230,230,230)
            label.Text = text

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(0,40,0,22)
            btn.Position = UDim2.new(1,-44,0.5,-11)
            btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
            btn.BorderSizePixel = 0
            btn.Text = ""
            local bc = Instance.new("UICorner", btn)
            bc.CornerRadius = UDim.new(0,6)

            local mark = Instance.new("TextLabel", btn)
            mark.Size = UDim2.new(1,0,1,0)
            mark.BackgroundTransparency = 1
            mark.Text = "✔"
            mark.Font = Enum.Font.GothamBold
            mark.TextSize = 18
            mark.TextColor3 = Color3.fromRGB(0,200,120)
            mark.Visible = state

            btn.MouseButton1Click:Connect(function()
                state = not state
                mark.Visible = state
                if callback then callback(state) end
            end)

            return btn
        end

        function Elements:AddSwitch(text, state, callback)
            local frame = Instance.new("Frame", Page)
            frame.Size = UDim2.new(1,-10,0,32)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1,-60,1,0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = Color3.fromRGB(230,230,230)
            label.Text = text

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(0,40,0,20)
            btn.Position = UDim2.new(1,-50,0.5,-10)
            btn.BackgroundColor3 = state and Color3.fromRGB(0,200,120) or Color3.fromRGB(80,80,85)
            btn.Text = ""
            btn.BorderSizePixel = 0
            local bc = Instance.new("UICorner", btn)
            bc.CornerRadius = UDim.new(1,0)

            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.BackgroundColor3 = state and Color3.fromRGB(0,200,120) or Color3.fromRGB(80,80,85)
                if callback then callback(state) end
            end)
            return btn
        end

        function Elements:AddSlider(text, min, default, max, callback)
            local frame = Instance.new("Frame", Page)
            frame.Size = UDim2.new(1,-10,0,40)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1,0,0,20)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(230,230,230)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = text.." : "..default

            local sliderFrame = Instance.new("Frame", frame)
            sliderFrame.Size = UDim2.new(1,-10,0,8)
            sliderFrame.Position = UDim2.new(0,0,0,28)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,65)
            sliderFrame.BorderSizePixel = 0
            local sc = Instance.new("UICorner", sliderFrame)
            sc.CornerRadius = UDim.new(0,4)

            local fill = Instance.new("Frame", sliderFrame)
            fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
            fill.BackgroundColor3 = Color3.fromRGB(0,200,120)
            fill.BorderSizePixel = 0
            local fc = Instance.new("UICorner", fill)
            fc.CornerRadius = UDim.new(0,4)

            local dragging = false
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            sliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X)/sliderFrame.AbsoluteSize.X,0,1)
                    local value = math.floor(min + (max-min)*pos)
                    fill.Size = UDim2.new(pos,0,1,0)
                    label.Text = text.." : "..value
                    if callback then callback(value) end
                end
            end)

            return sliderFrame
        end

        return Elements
    end

    return Tabs
end

return Library
