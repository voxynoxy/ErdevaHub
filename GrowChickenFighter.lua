local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local viewportSize = workspace.CurrentCamera.ViewportSize

local CONFIG = {
    Name = "ERDEVA HUB",
    Width = math.min(viewportSize.X - 20, 380),
    Height = math.min(viewportSize.Y - 20, 520),
    Background = Color3.fromRGB(12, 12, 12),
    Secondary = Color3.fromRGB(18, 18, 18),
    Card = Color3.fromRGB(15, 15, 15),
    Border = Color3.fromRGB(45, 45, 45),
    Red = Color3.fromRGB(220, 40, 40),
    RedDark = Color3.fromRGB(80, 25, 25),
    RedHover = Color3.fromRGB(255, 55, 55),
    Text = Color3.fromRGB(225, 225, 225),
    SubText = Color3.fromRGB(145, 145, 145)
}

pcall(function()
    local old = CoreGui:FindFirstChild("ERDEVA_HUB")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ERDEVA_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
Main.Position = UDim2.new(0.5, -CONFIG.Width/2, 0.5, -CONFIG.Height/2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 1
MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = CONFIG.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = CONFIG.Border
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.fromOffset(30, 42)
TitleIcon.Position = UDim2.fromOffset(8, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "󰅶"
TitleIcon.TextColor3 = CONFIG.Red
TitleIcon.TextSize = 20
TitleIcon.Font = Enum.Font.GothamMedium
TitleIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(120, 42)
Title.Position = UDim2.fromOffset(40, 0)
Title.BackgroundTransparency = 1
Title.Text = "ERDEVA HUB"
Title.TextColor3 = CONFIG.Text
Title.TextSize = 15
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.fromOffset(0, 28)
SearchBox.Position = UDim2.new(0.45, 0, 0, 7)
SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "󰋽 Search..."
SearchBox.PlaceholderColor3 = CONFIG.SubText
SearchBox.TextColor3 = CONFIG.Text
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = TopBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 16)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = CONFIG.Border
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBox

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.fromOffset(30, 42)
minimizeBtn.Position = UDim2.new(1, -65, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "󰥃"
minimizeBtn.TextColor3 = CONFIG.SubText
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.Gotham
minimizeBtn.Parent = TopBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 42)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "󰅙"
closeBtn.TextColor3 = CONFIG.SubText
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.Gotham
closeBtn.Parent = TopBar

closeBtn.MouseEnter:Connect(function()
    closeBtn.TextColor3 = CONFIG.Red
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.TextColor3 = CONFIG.SubText
end)
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.fromOffset(CONFIG.Width, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        Main:TweenSize(UDim2.fromOffset(CONFIG.Width, CONFIG.Height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

local dragging = false
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -42)
Sidebar.Position = UDim2.fromOffset(0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.fromOffset(1, Sidebar.AbsoluteSize.Y)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = CONFIG.Border
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -180, 1, -42)
Content.Position = UDim2.fromOffset(180, 42)
Content.BackgroundColor3 = CONFIG.Background
Content.BorderSizePixel = 0
Content.Parent = Main

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -20, 0, 35)
PageTitle.Position = UDim2.fromOffset(10, 5)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Main"
PageTitle.TextColor3 = CONFIG.Text
PageTitle.TextSize = 16
PageTitle.Font = Enum.Font.GothamMedium
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

local SidebarButtons = {}

local function CreateSidebarButton(name, icon, text, y)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -8, 0, 38)
    Button.Position = UDim2.fromOffset(4, y)
    Button.BackgroundColor3 = CONFIG.Secondary
    Button.BackgroundTransparency = 1
    Button.BorderSizePixel = 0
    Button.Text = icon .. "  " .. text
    Button.TextColor3 = CONFIG.SubText
    Button.TextSize = 13
    Button.Font = Enum.Font.Gotham
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Sidebar
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.Parent = Button
    
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.fromOffset(3, 26)
    Accent.Position = UDim2.fromOffset(0, 6)
    Accent.BackgroundColor3 = CONFIG.Red
    Accent.BorderSizePixel = 0
    Accent.Visible = false
    Accent.Parent = Button
    
    SidebarButtons[name] = {Button = Button, Accent = Accent}
    return Button
end

local InfoButton = CreateSidebarButton("Info", "󰋼", "Info", 8)
local MainButton = CreateSidebarButton("Main", "󰅶", "Main", 50)
local SettingsButton = CreateSidebarButton("Settings", "󰓦", "Settings", 92)

local function SelectSidebar(name)
    for btnName, data in pairs(SidebarButtons) do
        data.Button.BackgroundTransparency = 1
        data.Button.TextColor3 = CONFIG.SubText
        data.Accent.Visible = false
    end
    local selected = SidebarButtons[name]
    if selected then
        selected.Button.BackgroundColor3 = Color3.fromRGB(30, 18, 18)
        selected.Button.BackgroundTransparency = 0
        selected.Button.TextColor3 = CONFIG.Text
        selected.Accent.Visible = true
    end
end

local function CreateCard(parent, title, position, size)
    local Card = Instance.new("Frame")
    Card.Size = size
    Card.Position = position
    Card.BackgroundColor3 = CONFIG.Card
    Card.BorderSizePixel = 0
    Card.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Border
    Stroke.Thickness = 1
    Stroke.Parent = Card
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundTransparency = 1
    Header.Parent = Card
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
    HeaderTitle.Position = UDim2.fromOffset(10, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = title
    HeaderTitle.TextColor3 = CONFIG.Text
    HeaderTitle.TextSize = 13
    HeaderTitle.Font = Enum.Font.Gotham
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.fromOffset(0, 35)
    Line.BackgroundColor3 = CONFIG.Border
    Line.BorderSizePixel = 0
    Line.Parent = Card
    
    return Card
end

local ToggleStates = {}

local function CreateToggle(parent, text, y, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -75, 0, 30)
    Label.Position = UDim2.fromOffset(8, y)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = CONFIG.SubText
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.fromOffset(36, 20)
    Toggle.Position = UDim2.new(1, -42, 0, y + 5)
    Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    Toggle.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.fromOffset(16, 16)
    Circle.Position = UDim2.fromOffset(2, 2)
    Circle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Circle.BorderSizePixel = 0
    Circle.Parent = Toggle
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    local state = false
    ToggleStates[text] = false
    
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        ToggleStates[text] = state
        if state then
            Toggle.BackgroundColor3 = CONFIG.Red
            Circle.Position = UDim2.new(1, -18, 0, 2)
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            Circle.Position = UDim2.fromOffset(2, 2)
        end
        if callback then callback(state) end
    end)
    
    return Toggle
end

local DiscordCard = CreateCard(Content, "󰎂 Discord", UDim2.fromOffset(8, 45), UDim2.fromOffset(164, 100))
local Discord1 = Instance.new("TextButton")
Discord1.Size = UDim2.new(1, -16, 0, 28)
Discord1.Position = UDim2.fromOffset(8, 42)
Discord1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Discord1.BorderSizePixel = 0
Discord1.Text = "󰎂 Join for Money"
Discord1.TextColor3 = CONFIG.SubText
Discord1.TextSize = 11
Discord1.Font = Enum.Font.Gotham
Discord1.Parent = DiscordCard
local Discord1Corner = Instance.new("UICorner")
Discord1Corner.CornerRadius = UDim.new(0, 14)
Discord1Corner.Parent = Discord1

local Discord2 = Discord1:Clone()
Discord2.Position = UDim2.fromOffset(8, 72)
Discord2.Text = "󰎂 Join for Keyless Scripts"
Discord2.Parent = DiscordCard

local PlotCard = CreateCard(Content, "󰅶 Plot", UDim2.fromOffset(180, 45), UDim2.fromOffset(164, 185))
CreateToggle(PlotCard, "Auto Rebirth", 42)
CreateToggle(PlotCard, "Auto Upgrade Coop", 75)
CreateToggle(PlotCard, "Auto Upgrade Feeder", 108)
CreateToggle(PlotCard, "Auto Buy Feeders", 141)

local FarmCard = CreateCard(Content, "󰄱 Farm", UDim2.fromOffset(8, 235), UDim2.fromOffset(164, 250))
CreateToggle(FarmCard, "Auto Open Eggs", 42)
CreateToggle(FarmCard, "Auto Fuse Chickens", 75)
CreateToggle(FarmCard, "Auto Grab Scraps", 108)
CreateToggle(FarmCard, "Auto Recycle Scrap", 141)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, -20, 0, 22)
SliderLabel.Position = UDim2.fromOffset(8, 172)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Recycle when scrap"
SliderLabel.TextColor3 = CONFIG.SubText
SliderLabel.TextSize = 11
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = FarmCard

local SliderValue = Instance.new("TextLabel")
SliderValue.Size = UDim2.fromOffset(40, 22)
SliderValue.Position = UDim2.new(1, -46, 0, 172)
SliderValue.BackgroundTransparency = 1
SliderValue.Text = "10/20"
SliderValue.TextColor3 = CONFIG.Red
SliderValue.TextSize = 11
SliderValue.Font = Enum.Font.Gotham
SliderValue.TextXAlignment = Enum.TextXAlignment.Right
SliderValue.Parent = FarmCard

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(1, -24, 0, 5)
Slider.Position = UDim2.fromOffset(12, 198)
Slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
Slider.BorderSizePixel = 0
Slider.Parent = FarmCard
local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = Slider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = CONFIG.Red
SliderFill.BorderSizePixel = 0
SliderFill.Parent = Slider
local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local Thumb = Instance.new("Frame")
Thumb.Size = UDim2.fromOffset(14, 14)
Thumb.Position = UDim2.new(0.5, -7, 0.5, -7)
Thumb.BackgroundColor3 = CONFIG.Red
Thumb.BorderSizePixel = 0
Thumb.Parent = Slider
local ThumbCorner = Instance.new("UICorner")
ThumbCorner.CornerRadius = UDim.new(1, 0)
ThumbCorner.Parent = Thumb

local sliderDragging = false
Thumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliderDragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliderDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local startX = Slider.AbsolutePosition.X
        local width = Slider.AbsoluteSize.X
        local percent = math.clamp((mouseX - startX) / width, 0, 1)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        Thumb.Position = UDim2.new(percent, -7, 0.5, -7)
        local value = math.floor(percent * 20 + 0.5)
        SliderValue.Text = value .. "/20"
    end
end)

CreateToggle(FarmCard, "Auto Upgrade Recycler", 215)

local BattleCard = CreateCard(Content, "󰯫 Battle", UDim2.fromOffset(8, 495), UDim2.fromOffset(164, 135))
CreateToggle(BattleCard, "Auto Start Tower", 42)
CreateToggle(BattleCard, "Auto No Thanks", 75)
CreateToggle(BattleCard, "Auto Start Chaos", 108)

InfoButton.MouseButton1Click:Connect(function()
    PageTitle.Text = "󰋼 Info"
    SelectSidebar("Info")
end)
MainButton.MouseButton1Click:Connect(function()
    PageTitle.Text = "󰅶 Main"
    SelectSidebar("Main")
end)
SettingsButton.MouseButton1Click:Connect(function()
    PageTitle.Text = "󰓦 Settings"
    SelectSidebar("Settings")
end)

SelectSidebar("Main")

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, object in ipairs(Content:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") then
            if object ~= PageTitle then
                local text = object.Text:lower()
                if query == "" then
                    object.Visible = true
                else
                    object.Visible = string.find(text, query, 1, true) ~= nil
                end
            end
        end
    end
end)

print("[ERDEVA HUB] Loaded")
