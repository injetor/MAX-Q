-- MAX-Q UI Library (Premium Edition)
local Library = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localplr = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Secondary = Color3.fromRGB(10, 10, 10),
    Tertiary = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(220, 220, 220),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(170, 170, 170),
    Success = Color3.fromRGB(100, 255, 150),
    Danger = Color3.fromRGB(255, 100, 100),
    Border = Color3.fromRGB(25, 25, 25)
}

local function create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do inst[k] = v end
    return inst
end
local function addCorner(parent, radius) return create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent}) end
local function addStroke(parent, color, thickness) return create("UIStroke", {Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent}) end
local function tween(obj, props, time, style) local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props) tw:Play() return tw end

local function getUIContainer()
    local success, result = pcall(function() if gethui then return gethui() end return game:GetService("CoreGui") end)
    return (success and result) and result or localplr:WaitForChild("PlayerGui")
end

local guiParent = getUIContainer()
if guiParent:FindFirstChild("MaxQ-Library") then guiParent["MaxQ-Library"]:Destroy() end

local screenGui = create("ScreenGui", { Name = "MaxQ-Library", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = guiParent })

-- Tooltip System
local tooltipBox = create("TextLabel", { Size = UDim2.new(0, 20, 0, 20), BackgroundColor3 = Theme.Tertiary, TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, ZIndex = 1000, Visible = false, Parent = screenGui })
addCorner(tooltipBox, 4) addStroke(tooltipBox, Theme.Border, 1)
create("UIPadding", {PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,4), Parent=tooltipBox})
tooltipBox.AutomaticSize = Enum.AutomaticSize.XY

local function attachTooltip(obj, text)
    if not text or text == "" then return end
    obj.MouseEnter:Connect(function()
        tooltipBox.Text = text tooltipBox.Visible = true
        local pos = UserInputService:GetMouseLocation()
        tooltipBox.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
    end)
    obj.MouseMoved:Connect(function()
        local pos = UserInputService:GetMouseLocation()
        tooltipBox.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
    end)
    obj.MouseLeave:Connect(function() tooltipBox.Visible = false end)
end

-- Keybinds Panel
local kbPanel = create("Frame", { Size = UDim2.new(0, 160, 0, 30), Position = UDim2.new(0, 20, 0, 20), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, Parent = screenGui })
addCorner(kbPanel, 6) addStroke(kbPanel, Theme.Border, 1)

local kbTitle = create("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Secondary, Text = "Keybinds", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, Parent = kbPanel })
addCorner(kbTitle, 6) create("Frame", { Size = UDim2.new(1,0,0,6), Position = UDim2.new(0,0,1,-6), BackgroundColor3 = Theme.Secondary, BorderSizePixel = 0, Parent = kbTitle })
create("Frame", { Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = kbTitle })

local kbList = create("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Parent = kbPanel })
local kbLayout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = kbList })
create("UIPadding", {PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), Parent = kbList})

local kbDragStart, kbStartPos, kbDragging
kbTitle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then kbDragging = true kbDragStart = input.Position kbStartPos = kbPanel.Position end end)
UserInputService.InputChanged:Connect(function(input) if kbDragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - kbDragStart kbPanel.Position = UDim2.new(kbStartPos.X.Scale, kbStartPos.X.Offset + delta.X, kbStartPos.Y.Scale, kbStartPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then kbDragging = false end end)

Library.ActiveKeybinds = {}
local function updateKbPanel()
    for _, child in ipairs(kbList:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
    local count = 0
    for title, keyName in pairs(Library.ActiveKeybinds) do
        count = count + 1
        create("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = title .. " [" .. keyName .. "]", TextColor3 = Theme.TextDark, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = kbList })
    end
    if count > 0 then
        kbPanel.Visible = true
        tween(kbPanel, {Size = UDim2.new(0, 160, 0, 30 + kbLayout.AbsoluteContentSize.Y + 8)}, 0.2)
    else
        kbPanel.Visible = false
    end
end

-- Notification System Global
local toastArea = create("Frame", { Size = UDim2.new(0, 240, 1, -20), Position = UDim2.new(1, -260, 0, 10), BackgroundTransparency = 1, ClipsDescendants = false, ZIndex = 100, Parent = screenGui })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), Parent = toastArea })

function Library:Notify(title, message, duration)
    duration = duration or 3
    local toast = create("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Secondary, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = toastArea })
    addCorner(toast, 6)
    local stroke = addStroke(toast, Theme.Border, 1) stroke.Transparency = 1
    
    local titleLbl = create("TextLabel", { Size = UDim2.new(1, -12, 0, 20), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, Parent = toast })
    local msgLbl = create("TextLabel", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 12, 0, 26), BackgroundTransparency = 1, Text = message, TextColor3 = Theme.TextDark, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextTransparency = 1, Parent = toast })
    
    local scale = create("UIScale", {Scale = 0.8, Parent = toast})
    tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back) tween(toast, {BackgroundTransparency = 0}, 0.3) tween(stroke, {Transparency = 0}, 0.3) tween(titleLbl, {TextTransparency = 0}, 0.3) tween(msgLbl, {TextTransparency = 0}, 0.3)
    
    task.delay(duration, function()
        if not toast.Parent then return end
        tween(scale, {Scale = 0.8}, 0.3, Enum.EasingStyle.Back) tween(toast, {BackgroundTransparency = 1}, 0.3) tween(stroke, {Transparency = 1}, 0.3) tween(titleLbl, {TextTransparency = 1}, 0.3) tween(msgLbl, {TextTransparency = 1}, 0.3)
        task.delay(0.3, function() toast:Destroy() end)
    end)
end

-- Dialog Box System
function Library:CreateDialog(title, text, callbackYes, callbackNo)
    local blocker = create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1, Text = "", ZIndex = 200, Parent = screenGui })
    tween(blocker, {BackgroundTransparency = 0.5}, 0.2)

    local dialog = create("Frame", { Size = UDim2.new(0, 300, 0, 140), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Background, ClipsDescendants = true, ZIndex = 201, Parent = blocker })
    addCorner(dialog, 6) addStroke(dialog, Theme.Border, 1)

    local scale = create("UIScale", {Scale = 0.8, Parent = dialog})
    tween(scale, {Scale = 1}, 0.2, Enum.EasingStyle.Back)

    create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 202, Parent = dialog })
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDark, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, ZIndex = 202, Parent = dialog })

    local btnYes = create("TextButton", { Size = UDim2.new(0.5, -15, 0, 30), Position = UDim2.new(0, 10, 1, -40), BackgroundColor3 = Theme.Success, Text = "Confirmar", TextColor3 = Color3.fromRGB(0,0,0), TextSize = 12, Font = Enum.Font.GothamMedium, ZIndex = 202, Parent = dialog })
    addCorner(btnYes, 4)
    local btnNo = create("TextButton", { Size = UDim2.new(0.5, -15, 0, 30), Position = UDim2.new(0.5, 5, 1, -40), BackgroundColor3 = Theme.Danger, Text = "Cancelar", TextColor3 = Color3.fromRGB(0,0,0), TextSize = 12, Font = Enum.Font.GothamMedium, ZIndex = 202, Parent = dialog })
    addCorner(btnNo, 4)

    local function closeDialog()
        tween(scale, {Scale = 0.8}, 0.2, Enum.EasingStyle.Back)
        tween(blocker, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.2, function() blocker:Destroy() end)
    end

    btnYes.MouseButton1Click:Connect(function() closeDialog() if callbackYes then callbackYes() end end)
    btnNo.MouseButton1Click:Connect(function() closeDialog() if callbackNo then callbackNo() end end)
end

local function BuildElements(parentContainer)
    local Elements = {}

    function Elements:CreateSection(title, tooltip)
        local sf = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer, ClipsDescendants = true })
        addCorner(sf, 4) addStroke(sf, Theme.Border, 1) attachTooltip(sf, tooltip)

        local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "   " .. title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = sf })
        local icon = create("TextLabel", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -28, 0, 8), BackgroundTransparency = 1, Text = "+", TextColor3 = Theme.TextDark, TextSize = 14, Font = Enum.Font.GothamBold, Parent = sf })

        local cont = create("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 36), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Parent = sf })
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = cont })
        create("UIPadding", { PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), Parent = cont })

        local open = false
        local function upd()
            if open then icon.Text = "-" tween(sf, {Size = UDim2.new(1, 0, 0, 36 + cont.AbsoluteSize.Y)}, 0.25)
            else icon.Text = "+" tween(sf, {Size = UDim2.new(1, 0, 0, 36)}, 0.25) end
        end

        btn.MouseButton1Click:Connect(function() open = not open upd() end)
        cont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if open then upd() end end)

        return BuildElements(cont)
    end

    function Elements:CreateToggle(title, default, callback, tooltip)
        local toggled = default or false
        local tf = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(tf, 4) addStroke(tf, Theme.Border, 1) attachTooltip(tf, tooltip)
        
        create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = tf })
        local btn = create("TextButton", { Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -48, 0.5, -9), BackgroundColor3 = toggled and Theme.Success or Theme.Tertiary, Text = "", AutoButtonColor = false, Parent = tf })
        addCorner(btn, 9) addStroke(btn, Theme.Border, 1)
        local circ = create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Theme.Text, Parent = btn })
        addCorner(circ, 7)
        
        local function updateState(newState)
            toggled = newState
            tween(btn, {BackgroundColor3 = toggled and Theme.Success or Theme.Tertiary}, 0.25)
            tween(circ, {Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.25, Enum.EasingStyle.Back)
            if callback then callback(toggled) end
        end
        
        btn.MouseButton1Click:Connect(function() updateState(not toggled) end)
        if callback then task.spawn(function() callback(toggled) end) end
        return { Set = function(self, state) updateState(state) end, Value = function() return toggled end }
    end

    function Elements:CreateSlider(title, min, max, default, callback, tooltip)
        local value = default or min
        local sf = create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(sf, 4) addStroke(sf, Theme.Border, 1) attachTooltip(sf, tooltip)
        
        create("TextLabel", { Size = UDim2.new(1, -12, 0, 20), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = sf })
        local val = create("TextLabel", { Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -42, 0, 6), BackgroundTransparency = 1, Text = tostring(value), TextColor3 = Theme.TextDark, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right, Parent = sf })
        local bg = create("Frame", { Size = UDim2.new(1, -24, 0, 4), Position = UDim2.new(0, 12, 1, -14), BackgroundColor3 = Theme.Tertiary, Parent = sf })
        addCorner(bg, 2)
        local fill = create("Frame", { Size = UDim2.new((value - min)/(max - min), 0, 1, 0), BackgroundColor3 = Theme.Accent, Parent = bg })
        addCorner(fill, 2)
        local btn = create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = bg })
        
        local function updateValue(p)
            value = math.floor(min + ((max - min) * p))
            tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
            val.Text = tostring(value)
            if callback then callback(value) end
        end
        
        local drag = false
        btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true updateValue(math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
        UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then updateValue(math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)) end end)
        
        if callback then task.spawn(function() callback(value) end) end
        return { Set = function(self, num) updateValue(math.clamp((num-min)/(max-min), 0, 1)) end, Value = function() return value end }
    end

    function Elements:CreateDropdown(title, optionsList, default, callback, tooltip)
        local selected = default or (optionsList and optionsList[1]) or ""
        local df = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer, ClipsDescendants = true })
        addCorner(df, 4) addStroke(df, Theme.Border, 1) attachTooltip(df, tooltip)
    
        create("TextLabel", { Size = UDim2.new(1, -120, 0, 36), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = df })
        local dropBtn = create("TextButton", { Size = UDim2.new(0, 100, 0, 24), Position = UDim2.new(1, -112, 0, 6), BackgroundColor3 = Theme.Tertiary, Text = tostring(selected), TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, Parent = df })
        addCorner(dropBtn, 4) addStroke(dropBtn, Theme.Border, 1)
    
        local listFrame = create("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = df })
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = listFrame })
    
        local open = false
        local function toggleDrop()
            open = not open
            tween(df, {Size = open and UDim2.new(1, 0, 0, 140) or UDim2.new(1, 0, 0, 36)}, 0.25)
            tween(listFrame, {Size = open and UDim2.new(1, -24, 0, 90) or UDim2.new(1, -24, 0, 0)}, 0.25)
        end
        dropBtn.MouseButton1Click:Connect(toggleDrop)
    
        local function populate(opts)
            for _, child in pairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _, opt in ipairs(opts) do
                local optBtn = create("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.Background, Text = tostring(opt), TextColor3 = Theme.TextDark, TextSize = 12, Font = Enum.Font.Gotham, Parent = listFrame })
                addCorner(optBtn, 4)
                optBtn.MouseEnter:Connect(function() tween(optBtn, {BackgroundColor3 = Theme.Tertiary}, 0.15) end)
                optBtn.MouseLeave:Connect(function() tween(optBtn, {BackgroundColor3 = Theme.Background}, 0.15) end)
                optBtn.MouseButton1Click:Connect(function() selected = opt dropBtn.Text = tostring(opt) toggleDrop() if callback then callback(selected) end end)
            end
        end
        if optionsList then populate(optionsList) end
        if callback then task.spawn(function() callback(selected) end) end
        return { Refresh = function(self, newOpts) populate(newOpts) end, Set = function(self, val) selected = val dropBtn.Text = tostring(val) if callback then callback(selected) end end, Value = function() return selected end }
    end

    function Elements:CreateKeybind(title, defaultKey, callback, tooltip)
        local currentKey = defaultKey or Enum.KeyCode.E
        local kf = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(kf, 4) addStroke(kf, Theme.Border, 1) attachTooltip(kf, tooltip)
        
        create("TextLabel", { Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = kf })
        local keyBtn = create("TextButton", { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -72, 0.5, -12), BackgroundColor3 = Theme.Tertiary, Text = currentKey.Name, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamBold, Parent = kf })
        addCorner(keyBtn, 4) addStroke(keyBtn, Theme.Border, 1)
        
        local listening = false
        keyBtn.MouseButton1Click:Connect(function() listening = true keyBtn.Text = "..." keyBtn.TextColor3 = Theme.Accent end)
        
        Library.ActiveKeybinds[title] = currentKey.Name
        updateKbPanel()

        UserInputService.InputBegan:Connect(function(input, gpe)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false currentKey = input.KeyCode keyBtn.Text = currentKey.Name keyBtn.TextColor3 = Theme.Text
                Library.ActiveKeybinds[title] = currentKey.Name updateKbPanel()
            elseif not gpe and not listening and input.KeyCode == currentKey then
                local s = create("UIScale", {Scale=0.9, Parent=keyBtn}) tween(s, {Scale=1}, 0.2, Enum.EasingStyle.Back) task.delay(0.2, function() s:Destroy() end)
                if callback then callback() end
            end
        end)
        return { Set = function(self, key) currentKey = key keyBtn.Text = currentKey.Name Library.ActiveKeybinds[title] = currentKey.Name updateKbPanel() end, Value = function() return currentKey end }
    end

    function Elements:CreateButton(title, callback, tooltip)
        local bf = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(bf, 4) addStroke(bf, Theme.Border, 1) attachTooltip(bf, tooltip)
        local btn = create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, Parent = bf })
        btn.MouseEnter:Connect(function() tween(bf, {BackgroundColor3 = Theme.Tertiary}, 0.15) end)
        btn.MouseLeave:Connect(function() tween(bf, {BackgroundColor3 = Theme.Secondary}, 0.15) end)
        btn.MouseButton1Click:Connect(function()
            local s = create("UIScale", {Scale=0.95, Parent=bf}) tween(s, {Scale=1}, 0.2, Enum.EasingStyle.Back) task.delay(0.2, function() s:Destroy() end)
            if callback then callback() end 
        end)
    end
    
    function Elements:CreateTextBox(title, default, callback, tooltip)
        local bf = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(bf, 4) addStroke(bf, Theme.Border, 1) attachTooltip(bf, tooltip)
        create("TextLabel", { Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = bf })
        local tbox = create("TextBox", { Size = UDim2.new(0, 80, 0, 22), Position = UDim2.new(1, -92, 0.5, -11), BackgroundColor3 = Theme.Tertiary, Text = default or "", PlaceholderText = "Input...", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, Parent = bf })
        addCorner(tbox, 4) addStroke(tbox, Theme.Border, 1)
        tbox.FocusLost:Connect(function(enter) if enter and callback then callback(tbox.Text) end end)
        return { Set = function(self, text) tbox.Text = text end, Value = function() return tbox.Text end }
    end

    function Elements:CreateDivider(text)
        local dv = create("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = parentContainer })
        if text then create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDark, TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = dv })
        else create("Frame", { Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0.5, 0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = dv }) end
    end

    function Elements:CreateLabel(text)
        local lf = create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(lf, 4) addStroke(lf, Theme.Border, 1)
        local lbl = create("TextLabel", { Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDark, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Center, Parent = lf })
        return { Set = function(self, newText) lbl.Text = newText end }
    end

    function Elements:CreateParagraph(title, content)
        local pf = create("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Theme.Secondary, Parent = parentContainer })
        addCorner(pf, 4) addStroke(pf, Theme.Border, 1)
        create("TextLabel", { Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 8), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = pf })
        local cont = create("TextLabel", { Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 28), BackgroundTransparency = 1, Text = content, TextColor3 = Theme.TextDark, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Parent = pf })
        task.delay(0.1, function() pf.Size = UDim2.new(1, 0, 0, cont.AbsoluteSize.Y + 40) end)
        cont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() pf.Size = UDim2.new(1, 0, 0, cont.AbsoluteSize.Y + 40) end)
        return { Set = function(self, newTitle, newContent) if newTitle then pf:FindFirstChildOfClass("TextLabel").Text = newTitle end if newContent then cont.Text = newContent end end }
    end

    function Elements:CreateMultiDropdown(title, optionsList, defaultList, callback, tooltip)
        local selected = {}
        for _, v in ipairs(defaultList or {}) do selected[v] = true end
        local df = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer, ClipsDescendants = true })
        addCorner(df, 4) addStroke(df, Theme.Border, 1) attachTooltip(df, tooltip)
        create("TextLabel", { Size = UDim2.new(1, -140, 0, 36), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = df })
        local function getSelectedStr() local t = {} for k, v in pairs(selected) do if v then table.insert(t, tostring(k)) end end if #t == 0 then return "None" end return table.concat(t, ", ") end
        local dropBtn = create("TextButton", { Size = UDim2.new(0, 120, 0, 24), Position = UDim2.new(1, -132, 0, 6), BackgroundColor3 = Theme.Tertiary, Text = getSelectedStr(), TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, TextTruncate = Enum.TextTruncate.AtEnd, Parent = df })
        addCorner(dropBtn, 4) addStroke(dropBtn, Theme.Border, 1)
        local listFrame = create("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = df })
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = listFrame })
        local open = false
        local function toggleDrop()
            open = not open
            tween(df, {Size = open and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 36)}, 0.25)
            tween(listFrame, {Size = open and UDim2.new(1, -24, 0, 110) or UDim2.new(1, -24, 0, 0)}, 0.25)
        end
        dropBtn.MouseButton1Click:Connect(toggleDrop)
        local function populate(opts)
            for _, child in pairs(listFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
            for _, opt in ipairs(opts) do
                local optF = create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.Background, Parent = listFrame }) addCorner(optF, 4)
                local btn = create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "   " .. tostring(opt), TextColor3 = Theme.TextDark, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = optF })
                local box = create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -20, 0.5, -7), BackgroundColor3 = selected[opt] and Theme.Success or Theme.Tertiary, Parent = optF })
                addCorner(box, 3) addStroke(box, Theme.Border, 1)
                local function upd() box.BackgroundColor3 = selected[opt] and Theme.Success or Theme.Tertiary btn.TextColor3 = selected[opt] and Theme.Text or Theme.TextDark end
                upd()
                btn.MouseButton1Click:Connect(function() selected[opt] = not selected[opt] upd() dropBtn.Text = getSelectedStr() if callback then local t = {} for k, v in pairs(selected) do if v then table.insert(t, k) end end callback(t) end end)
            end
        end
        if optionsList then populate(optionsList) end
        if callback then task.spawn(function() local t = {} for k, v in pairs(selected) do if v then table.insert(t, k) end end callback(t) end) end
        return { Refresh = function(self, newOpts) populate(newOpts) end, Value = function() local t = {} for k, v in pairs(selected) do if v then table.insert(t, k) end end return t end }
    end

    function Elements:CreateSearchableDropdown(title, optionsList, default, callback, tooltip)
        local selected = default or (optionsList and optionsList[1]) or ""
        local df = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer, ClipsDescendants = true })
        addCorner(df, 4) addStroke(df, Theme.Border, 1) attachTooltip(df, tooltip)
        create("TextLabel", { Size = UDim2.new(1, -120, 0, 36), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = df })
        local dropBtn = create("TextButton", { Size = UDim2.new(0, 100, 0, 24), Position = UDim2.new(1, -112, 0, 6), BackgroundColor3 = Theme.Tertiary, Text = tostring(selected), TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, Parent = df })
        addCorner(dropBtn, 4) addStroke(dropBtn, Theme.Border, 1)
        local searchBox = create("TextBox", { Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 0, 40), BackgroundColor3 = Theme.Tertiary, Text = "", PlaceholderText = "Search...", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, Parent = df })
        addCorner(searchBox, 4) addStroke(searchBox, Theme.Border, 1)
        local listFrame = create("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 72), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = df })
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = listFrame })
        local open = false
        local function toggleDrop()
            open = not open
            tween(df, {Size = open and UDim2.new(1, 0, 0, 180) or UDim2.new(1, 0, 0, 36)}, 0.25)
            tween(listFrame, {Size = open and UDim2.new(1, -24, 0, 98) or UDim2.new(1, -24, 0, 0)}, 0.25)
            if not open then searchBox.Text = "" end
        end
        dropBtn.MouseButton1Click:Connect(toggleDrop)
        local optBtns = {}
        local function populate(opts)
            for _, child in pairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            optBtns = {}
            for _, opt in ipairs(opts) do
                local optBtn = create("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.Background, Text = tostring(opt), TextColor3 = Theme.TextDark, TextSize = 12, Font = Enum.Font.Gotham, Parent = listFrame })
                addCorner(optBtn, 4)
                optBtn.MouseEnter:Connect(function() tween(optBtn, {BackgroundColor3 = Theme.Tertiary}, 0.15) end)
                optBtn.MouseLeave:Connect(function() tween(optBtn, {BackgroundColor3 = Theme.Background}, 0.15) end)
                optBtn.MouseButton1Click:Connect(function() selected = opt dropBtn.Text = tostring(opt) toggleDrop() if callback then callback(selected) end end)
                table.insert(optBtns, {btn = optBtn, txt = string.lower(tostring(opt))})
            end
        end
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(searchBox.Text)
            for _, v in ipairs(optBtns) do v.btn.Visible = (q == "" or string.find(v.txt, q)) ~= nil end
        end)
        if optionsList then populate(optionsList) end
        if callback then task.spawn(function() callback(selected) end) end
        return { Refresh = function(self, newOpts) populate(newOpts) end, Set = function(self, val) selected = val dropBtn.Text = tostring(val) if callback then callback(selected) end end, Value = function() return selected end }
    end

    function Elements:CreateColorPicker(title, defaultColor, callback, tooltip)
        local color = defaultColor or Color3.fromRGB(255, 255, 255)
        local cf = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, Parent = parentContainer, ClipsDescendants = true })
        addCorner(cf, 4) addStroke(cf, Theme.Border, 1) attachTooltip(cf, tooltip)
        create("TextLabel", { Size = UDim2.new(1, -60, 0, 36), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = cf })
        local colorBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -42, 0, 8), BackgroundColor3 = color, Text = "", Parent = cf })
        addCorner(colorBtn, 4) addStroke(colorBtn, Theme.Border, 1)
        local palette = create("Frame", { Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 40), BackgroundTransparency = 1, Parent = cf })
        create("UIGridLayout", { CellSize = UDim2.new(0, 24, 0, 24), CellPadding = UDim2.new(0, 6, 0, 6), Parent = palette })
        local colors = { Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0), Theme.Accent }
        local open = false
        colorBtn.MouseButton1Click:Connect(function()
            open = not open
            tween(cf, {Size = open and UDim2.new(1, 0, 0, 80) or UDim2.new(1, 0, 0, 36)}, 0.25)
            tween(palette, {Size = open and UDim2.new(1, -24, 0, 30) or UDim2.new(1, -24, 0, 0)}, 0.25)
        end)
        for _, c in ipairs(colors) do
            local pb = create("TextButton", { BackgroundColor3 = c, Text = "", Parent = palette })
            addCorner(pb, 4) addStroke(pb, Theme.Border, 1)
            pb.MouseButton1Click:Connect(function()
                color = c colorBtn.BackgroundColor3 = color open = false
                tween(cf, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                tween(palette, {Size = UDim2.new(1, -24, 0, 0)}, 0.2)
                if callback then callback(color) end
            end)
        end
        if callback then task.spawn(function() callback(color) end) end
        return { Set = function(self, newCol) color = newCol colorBtn.BackgroundColor3 = color if callback then callback(color) end end, Value = function() return color end }
    end

    return Elements
end

function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "MAX-Q"
    local size = options.Size or UDim2.new(0, 520, 0, 360)
    local hideKey = options.HideKey or Enum.KeyCode.RightShift

    local panel = create("Frame", { Size = size, Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, ClipsDescendants = true, Parent = screenGui })
    addCorner(panel, 6); addStroke(panel, Theme.Border, 1)

    local titleBar = create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Secondary, BorderSizePixel = 0, Parent = panel })
    addCorner(titleBar, 6)
    create("Frame", { Size = UDim2.new(1,0,0,6), Position = UDim2.new(0,0,1,-6), BackgroundColor3 = Theme.Secondary, BorderSizePixel = 0, Parent = titleBar })
    create("Frame", { Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = titleBar })
    create("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar })

    local closeBtn = create("TextButton", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Text = "-", TextColor3 = Theme.TextDark, TextSize = 18, Font = Enum.Font.GothamMedium, Parent = titleBar })
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, {TextColor3 = Theme.Danger}, 0.15) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, {TextColor3 = Theme.TextDark}, 0.15) end)

    local contentArea = create("Frame", { Size = UDim2.new(1, 0, 1, -37), Position = UDim2.new(0, 0, 0, 37), BackgroundTransparency = 1, Parent = panel })
    local isMinimized = false
    closeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(contentArea, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Exponential)
            tween(panel, {Size = UDim2.new(0, size.X.Offset, 0, 36)}, 0.3, Enum.EasingStyle.Exponential)
            closeBtn.Text = "+"
        else
            tween(contentArea, {Size = UDim2.new(1, 0, 1, -37)}, 0.3, Enum.EasingStyle.Exponential)
            tween(panel, {Size = size}, 0.3, Enum.EasingStyle.Exponential)
            closeBtn.Text = "-"
        end
    end)

    local dragStart, startPos, dragging
    titleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = panel.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == hideKey then panel.Visible = not panel.Visible end
    end)

    local tabContainer = create("Frame", { Size = UDim2.new(0, 130, 1, 0), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = contentArea })
    create("Frame", { Size = UDim2.new(0,1,1,0), Position = UDim2.new(0,130,0,0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, Parent = contentArea })
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = tabContainer })
    create("UIPadding", { PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), Parent = tabContainer })
    local pageContainer = create("Frame", { Size = UDim2.new(1, -131, 1, 0), Position = UDim2.new(0, 131, 0, 0), BackgroundTransparency = 1, Parent = contentArea })

    local activeTabBtn, activePage
    local Window = {}

    function Window:CreateTab(name)
        local tabBtn = create("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Secondary, BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextDark, TextSize = 13, Font = Enum.Font.Gotham, BorderSizePixel = 0, AutoButtonColor = false, Parent = tabContainer })
        addCorner(tabBtn, 4)
        local page = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.TextDark, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = pageContainer })
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = page })
        create("UIPadding", { PaddingTop = UDim.new(0,12), PaddingBottom = UDim.new(0,12), PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), Parent = page })

        tabBtn.MouseButton1Click:Connect(function()
            if activeTabBtn then tween(activeTabBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}, 0.2) activePage.Visible = false end
            activeTabBtn = tabBtn activePage = page tween(tabBtn, {BackgroundTransparency = 0, TextColor3 = Theme.Text}, 0.2) page.Visible = true
            local s = create("UIScale", {Scale=0.95, Parent=page}) tween(s, {Scale=1}, 0.2, Enum.EasingStyle.Back) task.delay(0.2, function() s:Destroy() end)
        end)
        if not activePage then activeTabBtn = tabBtn activePage = page tabBtn.BackgroundTransparency = 0 tabBtn.TextColor3 = Theme.Text page.Visible = true end

        return BuildElements(page)
    end

    return Window
end

return Library
