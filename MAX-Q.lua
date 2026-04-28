local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local function getUIContainer()
    local success, result = pcall(function()
        if gethui then return gethui() end
        return game:GetService("CoreGui")
    end)
    if success and result then return result end
    return player:WaitForChild("PlayerGui")
end

local guiParent = getUIContainer()

if guiParent:FindFirstChild("Max-Q") then
    guiParent["Max-Q"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Max-Q"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

local isMobile = UserInputService.TouchEnabled
local autoSpeed = 100 -- signals per second
local autoScroll = true

-- Cobalt-style Theme Palette
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Secondary = Color3.fromRGB(10, 10, 10),
    Tertiary = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(220, 220, 220),
    AccentHover = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(170, 170, 170),
    Success = Color3.fromRGB(100, 255, 150),
    Danger = Color3.fromRGB(255, 100, 100),
    Border = Color3.fromRGB(25, 25, 25)
}

-- Helpers
local function create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    return inst
end

local function addCorner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function addStroke(parent, color, thickness)
    return create("UIStroke", {Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent})
end

local function tween(obj, props, time)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Exponential), props)
    tw:Play()
    return tw
end

-- Main Panel Construction
local panelWidth = isMobile and 0 or 640
local panelHeight = isMobile and 0 or 420
local panelScaleW = isMobile and 0.9 or 0
local panelScaleH = isMobile and 0.7 or 0

local panelSize = UDim2.new(panelScaleW, panelWidth, panelScaleH, panelHeight)
local panelPos = UDim2.new(0.5, 0, 0.5, 0)

local panel = create("Frame", {
    Name = "MainPanel",
    Size = panelSize,
    Position = panelPos,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    Parent = screenGui
})

local panelScale = create("UIScale", {
    Scale = 1,
    Parent = panel
})
addCorner(panel, 6)
addStroke(panel, Theme.Border, 1)

-- Top Bar & Dragging
local titleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = Theme.Secondary,
    BorderSizePixel = 0,
    Parent = panel
})
addCorner(titleBar, 6)




local dragStart, startPos, dragging
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Title Elements
local titleText = create("TextLabel", {
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "MAX-Q",
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = titleBar
})

local liveDot = create("Frame", {
    Size = UDim2.new(0, 6, 0, 6),
    Position = UDim2.new(0, 85, 0.5, -3),
    BackgroundColor3 = Theme.Success,
    BorderSizePixel = 0,
    Parent = titleBar
})
addCorner(liveDot, 6)

task.spawn(function()
    while panel.Parent do
        tween(liveDot, {BackgroundTransparency = 0.6}, 0.8)
        task.wait(0.8)
        tween(liveDot, {BackgroundTransparency = 0}, 0.8)
        task.wait(0.8)
    end
end)

-- Window Controls
local controlsLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
    Parent = titleBar
})
create("UIPadding", { PaddingRight = UDim.new(0, 6), Parent = titleBar })

local function makeControlBtn(text, color, hoverColor)
    local btn = create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.Tertiary,
        Text = text,
        TextColor3 = color,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    addCorner(btn, 4)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 1}) end)
    return btn
end

local minBtn = makeControlBtn("-", Theme.Text, Theme.Tertiary)
minBtn.Parent = titleBar
local closeBtn = makeControlBtn("X", Theme.Text, Theme.Danger)
closeBtn.Parent = titleBar

-- Filters & Actions Bar
local filterBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 37),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = panel
})

local searchBox = create("TextBox", {
    Size = UDim2.new(1, -190, 0, 26),
    Position = UDim2.new(0, 12, 0.5, -13),
    BackgroundColor3 = Theme.Secondary,
    PlaceholderText = "Search...",
    Text = "",
    TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.TextDark,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    Parent = filterBar
})
addCorner(searchBox, 4)
addStroke(searchBox, Theme.Border, 1)
create("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = searchBox})

local function makeStandardBtn(text, color, w, xOffset, parent)
    local btn = create("TextButton", {
        Size = UDim2.new(0, w, 0, 26),
        Position = UDim2.new(1, xOffset, 0.5, -13),
        BackgroundColor3 = Theme.Secondary,
        Text = text,
        TextColor3 = color,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent
    })
    addCorner(btn, 4)
    addStroke(btn, Theme.Border, 1)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.Tertiary}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Secondary}) end)
    return btn
end

local clearLogsBtn = makeStandardBtn("Clear", Theme.Text, 70, -82, filterBar)
local setBtn = makeStandardBtn("Settings", Theme.Text, 70, -160, filterBar)

-- Log Area
local logArea = create("ScrollingFrame", {
    Size = UDim2.new(1, -24, 1, -90),
    Position = UDim2.new(0, 12, 0, 80),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.TextDark,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = panel
})
create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    Parent = logArea
})
create("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingBottom = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 6),
    Parent = logArea
})

local emptyState = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 200),
    BackgroundTransparency = 1,
    Text = "No events detected yet.",
    TextColor3 = Theme.TextDark,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    LayoutOrder = 99999,
    Parent = logArea
})

-- Modal Background
local modalBackground = create("TextButton", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    Visible = false,
    ZIndex = 40,
    Parent = panel
})
addCorner(modalBackground, 6)
modalBackground.MouseButton1Click:Connect(function()
    tween(modalBackground, {BackgroundTransparency = 1}, 0.2)
    task.wait(0.2)
    modalBackground.Visible = false
end)

-- Settings Modal
local settingsWindow = create("TextButton", {
    Size = UDim2.new(0.65, 0, 0, 285),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Theme.Secondary,
    Text = "",
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 50,
    Parent = modalBackground
})
addCorner(settingsWindow, 8)
addStroke(settingsWindow, Theme.Border, 1)

local setTop = create("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
    Parent = settingsWindow
})
create("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = setTop})
create("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, Text = "Settings", TextColor3 = Theme.Text, TextSize = 15, Font = Enum.Font.GothamMedium,
    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 51, Parent = setTop
})

local setCloseBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, Text = "x", TextColor3 = Theme.TextDark, TextSize = 16, Font = Enum.Font.Gotham,
    ZIndex = 51, Parent = setTop
})
setCloseBtn.MouseEnter:Connect(function() tween(setCloseBtn, {TextColor3 = Theme.Text}) end)
setCloseBtn.MouseLeave:Connect(function() tween(setCloseBtn, {TextColor3 = Theme.TextDark}) end)
setCloseBtn.MouseButton1Click:Connect(function()
    tween(modalBackground, {BackgroundTransparency = 1}, 0.2)
    task.wait(0.2)
    modalBackground.Visible = false
end)

create("Frame", {
    Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 36), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, ZIndex = 51, Parent = settingsWindow
})

local setBody = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -37), Position = UDim2.new(0, 0, 0, 37), BackgroundTransparency = 1,
    ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 51, Parent = settingsWindow
})
create("UIListLayout", {Padding = UDim.new(0, 15), Parent = setBody})
create("UIPadding", {PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), Parent = setBody})

local function addSettingLabel(text)
    local lbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDark,
        TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 51, Parent = setBody
    })
    return lbl
end

addSettingLabel("Auto Speed (events/sec):")
local speedBox = create("TextBox", {
    Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Background, Text = tostring(autoSpeed),
    TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.Gotham, BorderSizePixel = 0, ZIndex = 51, Parent = setBody
})
addCorner(speedBox, 4)
addStroke(speedBox, Theme.Border, 1)

addSettingLabel("Auto Scroll to New Events:")
local autoScrollBtn = create("TextButton", {
    Size = UDim2.new(0, 60, 0, 28), BackgroundColor3 = Theme.Tertiary, Text = "Enabled",
    TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, BorderSizePixel = 0, ZIndex = 51, Parent = setBody
})
addCorner(autoScrollBtn, 4)
addStroke(autoScrollBtn, Theme.Border, 1)

autoScrollBtn.MouseButton1Click:Connect(function()
    autoScroll = not autoScroll
    autoScrollBtn.Text = autoScroll and "Enabled" or "Disabled"
    tween(autoScrollBtn, {TextColor3 = autoScroll and Theme.Text or Theme.TextDark})
end)

local setApplyBtn = create("TextButton", {
    Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Tertiary, Text = "Apply",
    TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.GothamMedium, BorderSizePixel = 0, ZIndex = 51, Parent = setBody
})
addCorner(setApplyBtn, 4)
addStroke(setApplyBtn, Theme.Border, 1)

setApplyBtn.MouseButton1Click:Connect(function()
    local spd = tonumber(speedBox.Text)
    if spd and spd > 0 then
        autoSpeed = spd
        setApplyBtn.Text = "Saved!"
        task.wait(1)
        setApplyBtn.Text = "Apply"
    else
        speedBox.Text = tostring(autoSpeed)
    end
end)

setBtn.MouseButton1Click:Connect(function()
    modalBackground.Visible = true
    tween(modalBackground, {BackgroundTransparency = 0.5}, 0.2)
end)

-- Main Logic
local entries = {}
local activeAutoLoops = {}
local suppressCounter = 0
local eventCount = 0

local function fireFakeSignal(signalType, id)
    suppressCounter = suppressCounter + 1
    pcall(function()
        if signalType == "Product" then
            MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, id, true)
        elseif signalType == "Gamepass" then
            MarketplaceService:SignalPromptGamePassPurchaseFinished(player, id, true)
        elseif signalType == "Bulk" then
            MarketplaceService:SignalPromptBulkPurchaseFinished(player.UserId, id, true)
        elseif signalType == "Purchase" then
            MarketplaceService:SignalPromptPurchaseFinished(player.UserId, id, true)
        end
    end)
    suppressCounter = suppressCounter - 1
end

local function addLog(label, id, signalType)
    if suppressCounter > 0 then return end
    
    local lastData = entries[#entries]
    if lastData and lastData.id == tostring(id) and lastData.type == label:lower() then
        lastData.spamCount = (lastData.spamCount or 1) + 1
        lastData.countLbl.Text = "x" .. lastData.spamCount
        lastData.countLbl.Visible = true
        
        -- Animation on counter update
        local tw = TweenService:Create(lastData.countLbl, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextSize = 16})
        tw:Play()
        tw.Completed:Connect(function()
            tween(lastData.countLbl, {TextSize = 12}, 0.2)
        end)
        return
    end

    emptyState.Visible = false
    eventCount = eventCount + 1

    local entry = create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = -eventCount,
        BackgroundTransparency = 1,
        Parent = logArea
    })
    addCorner(entry, 4)
    local entryStroke = addStroke(entry, Theme.Border, 1)
    entryStroke.Transparency = 1

    -- Pop-in animation
    local entryScale = create("UIScale", {Scale = 0.9, Parent = entry})
    tween(entryScale, {Scale = 1}, 0.25)
    tween(entry, {BackgroundTransparency = 0}, 0.2)
    tween(entryStroke, {Transparency = 0}, 0.2)

    create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextDark,
        TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = entry
    })

    create("TextLabel", {
        Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, 100, 0, 0),
        BackgroundTransparency = 1, Text = tostring(id), TextColor3 = Theme.Text,
        TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = entry
    })

    local countLbl = create("TextLabel", {
        Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(0, 260, 0, 0),
        BackgroundTransparency = 1, Text = "x1", TextColor3 = Theme.Success,
        TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false, Parent = entry
    })

    local buttonsFrame = create("Frame", {
        Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(1, -172, 0, 0),
        BackgroundTransparency = 1, Parent = entry
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6), Parent = buttonsFrame
    })

    local function makeLogBtn(text, color)
        local btn = create("TextButton", {
            Size = UDim2.new(0, 48, 0, 24), BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1, Text = text, TextColor3 = color, TextSize = 11, Font = Enum.Font.GothamMedium,
            BorderSizePixel = 0, AutoButtonColor = false
        })
        addCorner(btn, 4)
        local str = addStroke(btn, Theme.Border, 1)
        str.Transparency = 1
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0}) tween(str, {Transparency = 0}) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 1}) tween(str, {Transparency = 1}) end)
        return btn
    end

    local copyBtn = makeLogBtn("Copy", Theme.TextDark)
    copyBtn.Parent = buttonsFrame
    copyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, tostring(id))
        copyBtn.Text = "Copied"
        tween(copyBtn, {TextColor3 = Theme.Text})
        task.wait(1)
        copyBtn.Text = "Copy"
        tween(copyBtn, {TextColor3 = Theme.TextDark})
    end)

    local runBtn = makeLogBtn("Run", Theme.Text)
    runBtn.Parent = buttonsFrame
    runBtn.MouseButton1Click:Connect(function()
        fireFakeSignal(signalType, id)
        runBtn.Text = "Sent"
        tween(runBtn, {TextColor3 = Theme.Success})
        task.wait(0.5)
        runBtn.Text = "Run"
        tween(runBtn, {TextColor3 = Theme.Text})
    end)

    local autoBtn = makeLogBtn("Auto", Theme.Text)
    autoBtn.Parent = buttonsFrame

    local autoActive = false
    local autoLoop
    autoBtn.MouseButton1Click:Connect(function()
        autoActive = not autoActive
        if autoActive then
            autoBtn.Text = "Stop"
            tween(autoBtn, {TextColor3 = Theme.Danger})
            autoLoop = task.spawn(function()
                while autoActive and entry.Parent do
                    fireFakeSignal(signalType, id)
                    task.wait(1 / autoSpeed)
                end
            end)
            activeAutoLoops[autoLoop] = true
        else
            autoBtn.Text = "Auto"
            tween(autoBtn, {TextColor3 = Theme.Text})
            if autoLoop then
                task.cancel(autoLoop)
                activeAutoLoops[autoLoop] = nil
                autoLoop = nil
            end
        end
    end)

    table.insert(entries, {entry = entry, id = tostring(id), type = label:lower(), countLbl = countLbl, spamCount = 1})

    if autoScroll then
        task.delay(0.05, function()
            logArea.CanvasPosition = Vector2.new(0, 0)
        end)
    end
end

-- Search Logic
searchBox.Changed:Connect(function(prop)
    if prop == "Text" then
        local query = searchBox.Text:lower()
        for _, data in ipairs(entries) do
            if query == "" or string.find(data.id, query) or string.find(data.type, query) then
                data.entry.Visible = true
            else
                data.entry.Visible = false
            end
        end
    end
end)

-- Clear Logic
clearLogsBtn.MouseButton1Click:Connect(function()
    for loop in pairs(activeAutoLoops) do
        task.cancel(loop)
    end
    table.clear(activeAutoLoops)

    for _, data in ipairs(entries) do
        data.entry:Destroy()
    end
    table.clear(entries)
    eventCount = 0
    emptyState.Visible = true
end)

-- Window Minimizing
local isMinimized = false
local floatBtn

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        tween(panelScale, {Scale = 0}, 0.2)
        task.wait(0.2)
        panel.Visible = false
        
        if not floatBtn then
            floatBtn = create("TextButton", {
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(1, -60, 0.5, -20),
                BackgroundColor3 = Theme.Background,
                Text = "S",
                TextColor3 = Theme.Text,
                TextSize = 16,
                Font = Enum.Font.GothamMedium,
                BorderSizePixel = 0,
                Parent = screenGui
            })
            addCorner(floatBtn, 6)
            addStroke(floatBtn, Theme.Border, 1)
            
            local fDragStart, fStartPos, fDragging
            floatBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    fDragging = true
                    fDragStart = input.Position
                    fStartPos = floatBtn.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if fDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - fDragStart
                    floatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    fDragging = false
                end
            end)

            floatBtn.MouseButton1Click:Connect(toggleMinimize)
        end
        floatBtn.Visible = true
        floatBtn.Size = UDim2.new(0, 0, 0, 0)
        tween(floatBtn, {Size = UDim2.new(0, 40, 0, 40)}, 0.2)
    else
        if floatBtn then
            tween(floatBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.delay(0.2, function() floatBtn.Visible = false end)
        end
        panel.Visible = true
        tween(panelScale, {Scale = 1}, 0.2)
    end
end

minBtn.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        if floatBtn and floatBtn.Visible then
            toggleMinimize()
        elseif panel.Visible then
            toggleMinimize()
        end
    end
end)

-- Connections
MarketplaceService.PromptProductPurchaseFinished:Connect(function(plr, id, bought)
    if suppressCounter == 0 then addLog("Product", id, "Product") end
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, bought)
    if suppressCounter == 0 then addLog("Gamepass", id, "Gamepass") end
end)
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(userId, id, bought)
    if suppressCounter == 0 then addLog("Bulk", id, "Bulk") end
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(userId, id, bought)
    if suppressCounter == 0 then addLog("Purchase", id, "Purchase") end
end)

-- Entrance Animation
panelScale.Scale = 0
panel.BackgroundTransparency = 1
tween(panelScale, {Scale = 1}, 0.3)
tween(panel, {BackgroundTransparency = 0}, 0.3)
