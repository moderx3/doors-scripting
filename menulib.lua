-- Library: Universal GUI + lightweight ESP & FullBright manager
-- Usage:
-- local Library = loadstring(game:HttpGet("URL"))()
-- local win = Library:CreateWindow("Xayware", ICON_APP)
-- local tab = win:AddTab("ESP", ICON_EYE)
-- tab:AddToggle("Player ESP", false, function(v) Library.Features.PlayerESP = v end)
-- (see example at bottom)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

-- ICON placeholders (use emoji or replace by ImageId strings)
local ICON_APP    = "ICON_APP"
local ICON_EYE    = "ICON_EYE"
local ICON_DOOR   = "ICON_DOOR"
local ICON_KEY    = "ICON_KEY"
local ICON_MON    = "ICON_MON"
local ICON_USER   = "ICON_USER"
local ICON_SETTINGS= "ICON_SETTINGS"

-- UI defaults
local UI = {
    WindowWidth = 520,
    WindowHeight = 420,
    LeftPanelWidth = 96,
    Background = Color3.fromRGB(20,20,22),
    Accent = Color3.fromRGB(55,55,60),
    Contrast = Color3.fromRGB(28,28,30),
    Text = Color3.fromRGB(230,230,230)
}

-- helpers
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

local function setParent(obj, parent)
    obj.Parent = parent
    return obj
end

local function clamp(n, a, b) if n < a then return a elseif n > b then return b else return n end end

-- root ScreenGui
local rootGui = Instance.new("ScreenGui")
rootGui.ResetOnSpawn = false
rootGui.Name = "XayLibGui"
rootGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Core UI creation (not exposed)
local function createWindowFrame(title, icon)
    local main = new("Frame", {
        Size = UDim2.new(0, UI.WindowWidth, 0, UI.WindowHeight),
        Position = UDim2.new(0.5, -UI.WindowWidth/2, 0.5, -UI.WindowHeight/2),
        BackgroundColor3 = UI.Background,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
    })
    local uic = new("UICorner", {CornerRadius = UDim.new(0,10)})
    uic.Parent = main

    -- left icons column
    local left = new("Frame", {
        Size = UDim2.new(0, UI.LeftPanelWidth, 1, 0),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Parent = main
    })
    -- content panel
    local content = new("Frame", {
        Size = UDim2.new(1, -UI.LeftPanelWidth - 16, 1, -56),
        Position = UDim2.new(0, UI.LeftPanelWidth + 8, 0, 48),
        BackgroundTransparency = 1,
    })
    content.Parent = main

    local titleBar = new("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundTransparency = 1,
        Parent = main
    })
    local tlabel = new("TextLabel", {
        Parent = titleBar,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,12,0,0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = title or "Window",
        TextSize = 20,
        TextColor3 = UI.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local iconLabel = new("TextLabel", {
        Parent = titleBar,
        Size = UDim2.new(0,36,0,36),
        Position = UDim2.new(1, -48, 0.5, -18),
        BackgroundColor3 = UI.Contrast,
        BorderSizePixel = 0,
        Text = icon or "",
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        TextColor3 = UI.Text,
        TextScaled = false
    })
    new("UICorner", {Parent = iconLabel, CornerRadius = UDim.new(0,8)})

    -- left layout
    local leftList = new("UIListLayout", {Parent = left})
    leftList.Padding = UDim.new(0,8)
    leftList.SortOrder = Enum.SortOrder.LayoutOrder
    local leftPadding = new("UIPadding", {Parent = left})
    leftPadding.PaddingTop = UDim.new(0,8)
    leftPadding.PaddingLeft = UDim.new(0,8)

    -- content scrolling container
    local container = new("ScrollingFrame", {
        Parent = content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0,6,0,6),
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    local layout = new("UIListLayout", {Parent = container})
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = new("UIPadding", {Parent = container})
    pad.PaddingLeft = UDim.new(0,8)
    pad.PaddingTop = UDim.new(0,8)

    return {
        Main = main,
        Left = left,
        Container = container,
        TitleBar = titleBar,
        Title = tlabel,
        Icon = iconLabel
    }
end

-- library constructor
function Library:CreateWindow(title, icon)
    local winObj = {}
    local ui = createWindowFrame(title, icon)
    ui.Main.Parent = rootGui

    winObj.UI = ui
    winObj.Tabs = {}
    winObj.CurrentTab = nil

    function winObj:AddTab(name, iconText)
        local tabBtn = new("TextButton", {
            Parent = ui.Left,
            Size = UDim2.new(1, -8, 0, 72),
            BackgroundColor3 = UI.Contrast,
            BorderSizePixel = 0,
            Text = iconText or name,
            Font = Enum.Font.SourceSansBold,
            TextSize = 24,
            TextColor3 = UI.Text,
            AutoButtonColor = true
        })
        new("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0,10)})

        local container = new("ScrollingFrame", {
            Parent = ui.Container.Parent, -- children of same parent so we can hide/show easily
            Size = ui.Container.Size,
            Position = ui.Container.Position,
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
            Visible = false,
            CanvasSize = UDim2.new(0,0,0,0)
        })
        local layout = new("UIListLayout", {Parent = container})
        layout.Padding = UDim.new(0,8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        new("UIPadding", {Parent = container, PaddingLeft = UDim.new(0,8), PaddingTop = UDim.new(0,8)})

        local tab = {Name = name, Button = tabBtn, Container = container}

        function tab:AddLabel(text)
            local f = new("Frame", {Parent = container, Size = UDim2.new(1, -12, 0, 36), BackgroundColor3 = UI.Contrast})
            new("UICorner", {Parent = f, CornerRadius = UDim.new(0,8)})
            local lbl = new("TextLabel", {
                Parent = f,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text = text,
                Font = Enum.Font.SourceSansSemibold,
                TextSize = 16,
                TextColor3 = UI.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return lbl
        end

        function tab:AddToggle(text, default, callback)
            local f = new("Frame", {Parent = container, Size = UDim2.new(1,-12,0,36), BackgroundColor3 = UI.Contrast})
            new("UICorner", {Parent = f, CornerRadius = UDim.new(0,8)})
            local label = new("TextLabel", {
                Parent = f,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,-60,1,0),
                Position = UDim2.new(0,8,0,0),
                Text = text,
                Font = Enum.Font.SourceSansSemibold,
                TextSize = 16,
                TextColor3 = UI.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local btn = new("TextButton", {
                Parent = f,
                Size = UDim2.new(0,44,0,24),
                Position = UDim2.new(1,-52,0.5,-12),
                BackgroundColor3 = Color3.fromRGB(40,40,44),
                BorderSizePixel = 0,
                Text = ""
            })
            new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
            local mark = new("TextLabel", {
                Parent = btn,
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSansBold,
                Text = "✔",
                TextSize = 18,
                TextColor3 = Color3.fromRGB(0,200,120),
                Visible = default
            })
            local state = default
            btn.MouseButton1Click:Connect(function()
                state = not state
                mark.Visible = state
                if callback then
                    pcall(callback, state)
                end
            end)
            return {Frame = f, Label = label, Button = btn, Get = function() return state end}
        end

        function tab:AddButton(text, callback)
            local btn = new("TextButton", {
                Parent = container,
                Size = UDim2.new(1,-12,0,36),
                BackgroundColor3 = UI.Contrast,
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSans,
                TextSize = 16,
                Text = text,
                TextColor3 = UI.Text
            })
            new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
            if callback then
                btn.MouseButton1Click:Connect(function() pcall(callback) end)
            end
            return btn
        end

        function tab:AddSlider(text, min, max, default, callback)
            local f = new("Frame", {Parent = container, Size = UDim2.new(1,-12,0,44), BackgroundColor3 = UI.Contrast})
            new("UICorner", {Parent = f, CornerRadius = UDim.new(0,8)})
            local label = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Size = UDim2.new(1,-12,0,20), Position = UDim2.new(0,8,0,2), Text = text, Font = Enum.Font.SourceSansSemibold, TextSize = 14, TextColor3 = UI.Text, TextXAlignment = Enum.TextXAlignment.Left})
            local valueLabel = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Size = UDim2.new(0,60,0,20), Position = UDim2.new(1,-68,0,2), Text = tostring(default), Font = Enum.Font.SourceSans, TextSize = 14, TextColor3 = UI.Text})
            local barBg = new("Frame", {Parent = f, Size = UDim2.new(1,-24,0,12), Position = UDim2.new(0,12,0,24), BackgroundColor3 = Color3.fromRGB(36,36,38)})
            new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,6)})
            local fill = new("Frame", {Parent = barBg, Size = UDim2.new( (default-min)/(max-min), 0, 1, 0), BackgroundColor3 = UI.Accent})
            new("UICorner", {Parent = fill, CornerRadius = UDim.new(0,6)})
            local dragging = false
            barBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            barBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    local pos = mouse.X - barBg.AbsolutePosition.X
                    local frac = clamp(pos / barBg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(frac, 0, 1, 0)
                    local val = math.floor(min + frac*(max-min))
                    valueLabel.Text = tostring(val)
                    if callback then pcall(callback, val) end
                end
            end)
            return {Frame = f, Label = label, ValueLabel = valueLabel}
        end

        -- click behavior to switch
        tabBtn.MouseButton1Click:Connect(function()
            for _,t in pairs(winObj.Tabs) do
                t.Container.Visible = false
                t.Button.BackgroundColor3 = UI.Contrast
            end
            container.Visible = true
            tabBtn.BackgroundColor3 = UI.Accent
            winObj.CurrentTab = tab
        end)

        table.insert(winObj.Tabs, tab)
        if #winObj.Tabs == 1 then
            -- activate first tab by default
            tabBtn.BackgroundColor3 = UI.Accent
            container.Visible = true
            winObj.CurrentTab = tab
        end

        return tab
    end

    function winObj:Show() ui.Main.Visible = true end
    function winObj:Hide() ui.Main.Visible = false end

    setmetatable(winObj, {__index = Library})
    return winObj
end

-- ============================
-- ESP & FullBright Managers
-- ============================
local ESPManager = {}
ESPManager.tracked = {
    players = {},
    monsters = {},
    doors = {},
    keys = {}
}
ESPManager.maxDistance = 900
ESPManager.updateInterval = 0.9
ESPManager._lastSweep = 0

local function safeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function makeBillboard(part, text, color)
    if not part or not part:IsA("BasePart") then return nil end
    local bb = Instance.new("BillboardGui")
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,140,0,28)
    bb.StudsOffset = Vector3.new(0,1.6,0)
    bb.Parent = part
    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextColor3 = color or Color3.new(1,1,1)
    label.Text = text or ""
    return bb, label
end

local function makeHighlight(part, color)
    if not part then return nil end
    local h = Instance.new("Highlight")
    h.Adornee = part
    h.FillColor = color
    h.FillTransparency = 0.55
    h.OutlineTransparency = 0.2
    h.Parent = part
    return h
end

function ESPManager:add(model, kind, displayName, color)
    if not model or not model.Parent then return end
    if self.tracked[kind][model] then return end
    local primary
    if model:IsA("BasePart") then primary = model else primary = model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart end
    if not primary then
        for _,p in pairs(model:GetDescendants()) do if p:IsA("BasePart") then primary = p break end end
    end
    if not primary then return end
    local dist = (primary.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())):Magnitude()
    if dist > ESPManager.maxDistance then return end
    local bb, lbl = makeBillboard(primary, displayName, color)
    local h = makeHighlight(primary, color)
    self.tracked[kind][model] = {model = model, part = primary, bb = bb, label = lbl, h = h, t = tick()}
    -- cleanup when removed
    local conn1 = model.AncestryChanged:Connect(function(_, parent)
        if not parent then self:remove(kind, model) end
    end)
    local conn2 = primary:GetPropertyChangedSignal("Parent"):Connect(function()
        if not primary.Parent then self:remove(kind, model) end
    end)
    self.tracked[kind][model].conn1 = conn1
    self.tracked[kind][model].conn2 = conn2
end

function ESPManager:remove(kind, model)
    if not self.tracked[kind] or not self.tracked[kind][model] then return end
    local obj = self.tracked[kind][model]
    if obj.conn1 then pcall(function() obj.conn1:Disconnect() end) end
    if obj.conn2 then pcall(function() obj.conn2:Disconnect() end) end
    safeDestroy(obj.bb)
    safeDestroy(obj.h)
    self.tracked[kind][model] = nil
end

function ESPManager:clearKind(kind)
    if not self.tracked[kind] then return end
    for m,_ in pairs(self.tracked[kind]) do self:remove(kind, m) end
end

function ESPManager:sweep()
    for kind,tbl in pairs(self.tracked) do
        for model,data in pairs(tbl) do
            if not data.model or not data.model.Parent or not data.part or not data.part.Parent then
                self:remove(kind, model)
            else
                local pos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and LocalPlayer.Character.HumanoidRootPart.Position or nil
                if pos and (data.part.Position - pos).Magnitude > self.maxDistance then
                    self:remove(kind, model)
                else
                    -- refresh appearance for doors with lock (optional)
                    if kind == "doors" and data.model then
                        local locked = false
                        if data.model:FindFirstChild("Locked") and data.model.Locked.Value == true then locked = true end
                        if data.h then data.h.FillColor = (locked and Color3.fromRGB(255,80,80) or Color3.fromRGB(0,255,0)) end
                        if data.label then data.label.TextColor3 = (locked and Color3.fromRGB(255,80,80) or Color3.fromRGB(0,255,0)) end
                    end
                end
            end
        end
    end
end

-- quick helper to detect numbered doors
local function hasNumberIndicator(root)
    if not root then return false end
    for _,n in pairs({"Number","DoorNumber","DoorId","ID"}) do
        local v = root:FindFirstChild(n)
        if v and (v:IsA("IntValue") or v:IsA("StringValue")) and tostring(v.Value):match("%d") then
            return true
        end
    end
    for _,guiObj in pairs(root:GetDescendants()) do
        if guiObj:IsA("TextLabel") or guiObj:IsA("TextBox") or guiObj:IsA("TextButton") then
            if tostring(guiObj.Text):match("%d") then return true end
        end
        if guiObj:IsA("Decal") or guiObj:IsA("Texture") then
            if tostring(guiObj.Name):match("%d") or (guiObj.Texture and tostring(guiObj.Texture):match("%d")) then return true end
        end
    end
    return false
end

-- scanning and auto-add functions
local function scanWorkspaceForESP(settings)
    for _,inst in pairs(Workspace:GetDescendants()) do
        if inst:IsA("Model") then
            local name = inst.Name:lower()
            if settings.PlayerESP then
                -- players handled separately
            end
            if settings.MonsterESP then
                local monNames = {"figurerig","seekrig","rush","ambush","screech","eyes","monster","glitch"}
                for _,m in ipairs(monNames) do
                    if name:find(m) then
                        ESPManager:add(inst, "monsters", inst.Name, Color3.fromRGB(255,80,80))
                        break
                    end
                end
            end
            if settings.KeyESP then
                if name:find("key") or name:find("keyobtain") then
                    ESPManager:add(inst, "keys", "Key", Color3.fromRGB(255,255,0))
                end
            end
            if settings.DoorESP then
                if name:find("door") then
                    -- filter small beams etc by size
                    local prim = inst:FindFirstChildWhichIsA("BasePart") or inst.PrimaryPart
                    if prim then
                        local sy = prim.Size.Y
                        if sy and sy >= 1.2 and sy <= 12 then
                            local display = hasNumberIndicator(inst) and ("Numbered "..tostring(inst.Name)) or "Door"
                            ESPManager:add(inst, "doors", display, (hasNumberIndicator(inst) and Color3.fromRGB(0,150,255) or Color3.fromRGB(0,255,0)))
                        end
                    end
                end
            end
        end
    end
end

-- respond to workspace changes
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        local name = obj.Name:lower()
        if Library.Features.MonsterESP then
            local monNames = {"figurerig","seekrig","rush","ambush","screech","eyes","monster","glitch"}
            for _,m in ipairs(monNames) do if name:find(m) then ESPManager:add(obj,"monsters",obj.Name,Color3.fromRGB(255,80,80)); break end end
        end
        if Library.Features.KeyESP and (name:find("key") or name:find("keyobtain")) then ESPManager:add(obj,"keys","Key",Color3.fromRGB(255,255,0)) end
        if Library.Features.DoorESP and name:find("door") then
            local prim = obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
            if prim then
                local sy = prim.Size.Y
                if sy and sy >= 1.2 and sy <= 12 then
                    ESPManager:add(obj,"doors", (hasNumberIndicator(obj) and ("Numbered "..obj.Name) or "Door"), (hasNumberIndicator(obj) and Color3.fromRGB(0,150,255) or Color3.fromRGB(0,255,0)))
                end
            end
        end
    end
end)

-- players ESP
local playerConnections = {}
local function trackPlayer(player)
    if player == LocalPlayer then return end
    local function addIf()
        if not player.Character then return end
        ESPManager:add(player.Character, "players", player.Name, Color3.fromRGB(0,255,180))
    end
    player.CharacterAdded:Connect(addIf)
    if player.Character then addIf() end
end
Players.PlayerAdded:Connect(trackPlayer)
for _,p in pairs(Players:GetPlayers()) do trackPlayer(p) end

-- FullBright manager
Library.FullBright = {enabled = false, orig = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows
}}
function Library:SetFullBright(v)
    Library.FullBright.enabled = v
    if v then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Library.FullBright.orig.Ambient
        Lighting.OutdoorAmbient = Library.FullBright.orig.OutdoorAmbient
        Lighting.Brightness = Library.FullBright.orig.Brightness
        Lighting.GlobalShadows = Library.FullBright.orig.GlobalShadows
    end
end

-- library runtime features state
Library.Features = {
    PlayerESP = false,
    MonsterESP = false,
    DoorESP = false,
    KeyESP = false,
    FullBright = false,
    Tracers = false,
    SpeedHack = false
}

-- expose ctrl for external use
Library.ESPManager = ESPManager

-- main loop: sweep and update
RunService.Heartbeat:Connect(function(dt)
    -- sweep occasionally (throttle)
    if tick() - ESPManager._lastSweep >= ESPManager.updateInterval then
        ESPManager._lastSweep = tick()
        ESPManager:sweep()
    end

    -- fullbright enforcement (keeps values while enabled)
    if Library.Features.FullBright then
        if Lighting.Ambient ~= Color3.fromRGB(255,255,255) then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        end
    end
end)

-- speedhack (basic safe implementation)
local normalSpeed = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed) or 16
local speedCycle = {18,20,22}
local speedIndex = 1
spawn(function()
    while true do
        wait(0.6)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Library.Features.SpeedHack and hum then
            if hum.Sit or hum:GetState() == Enum.HumanoidStateType.Seated or hum:GetState() == Enum.HumanoidStateType.PlatformStanding then
                hum.WalkSpeed = 25
            else
                speedIndex = (speedIndex % #speedCycle) + 1
                hum.WalkSpeed = speedCycle[speedIndex]
            end
        elseif hum then
            hum.WalkSpeed = normalSpeed
        end
    end
end)

-- API usage example (auto-setup window with toggles)
local window = Library:CreateWindow("Xayware", ICON_APP)
local tabESP = window:AddTab("ESP", ICON_EYE)
local t1 = tabESP:AddToggle("Player ESP", false, function(v)
    Library.Features.PlayerESP = v
    if not v then ESPManager:clearKind("players") else scanWorkspaceForESP(Library.Features) end
end)
local t2 = tabESP:AddToggle("Monster ESP", false, function(v)
    Library.Features.MonsterESP = v
    if not v then ESPManager:clearKind("monsters") else scanWorkspaceForESP(Library.Features) end
end)
local t3 = tabESP:AddToggle("Doors ESP", false, function(v)
    Library.Features.DoorESP = v
    if not v then ESPManager:clearKind("doors") else scanWorkspaceForESP(Library.Features) end
end)
local t4 = tabESP:AddToggle("Key ESP", false, function(v)
    Library.Features.KeyESP = v
    if not v then ESPManager:clearKind("keys") else scanWorkspaceForESP(Library.Features) end
end)

local tabMisc = window:AddTab("Misc", ICON_SETTINGS)
local tbFB = tabMisc:AddToggle("FullBright", false, function(v)
    Library.Features.FullBright = v
    Library:SetFullBright(v)
end)
local tbSpeed = tabMisc:AddToggle("SpeedHack", false, function(v) Library.Features.SpeedHack = v end)

-- initial scan (only when toggles enabled)
scanWorkspaceForESP(Library.Features)

return Library
