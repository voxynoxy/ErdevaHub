--[[
    ERDEVA HUB
    Dark Red / Black UI
    Roblox LocalScript
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    Name = "ERDEVA HUB",

    Background = Color3.fromRGB(12, 12, 12),
    Secondary = Color3.fromRGB(18, 18, 18),
    Card = Color3.fromRGB(15, 15, 15),
    Border = Color3.fromRGB(45, 45, 45),

    Red = Color3.fromRGB(220, 40, 40),
    RedDark = Color3.fromRGB(80, 25, 25),
    RedHover = Color3.fromRGB(255, 55, 55),

    Text = Color3.fromRGB(225, 225, 225),
    SubText = Color3.fromRGB(145, 145, 145),

    Width = 730,
    Height = 600
}

--==================================================
-- CLEAN OLD GUI
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("ERDEVA_HUB")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ERDEVA_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
Main.Position = UDim2.new(0.5, -CONFIG.Width / 2, 0.5, -CONFIG.Height / 2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 1
MainStroke.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = CONFIG.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = CONFIG.Border
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(210, 48)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "ERDEVA HUB"
Title.TextColor3 = CONFIG.Text
Title.TextSize = 17
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

--==================================================
-- SEARCH
--==================================================

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.fromOffset(150, 32)
SearchBox.Position = UDim2.new(1, -205, 0, 8)
SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = CONFIG.SubText
SearchBox.TextColor3 = CONFIG.Text
SearchBox.TextSize = 13
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

--==================================================
-- MINIMIZE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(35, 48)
Minimize.Position = UDim2.new(1, -52, 0, 0)
Minimize.BackgroundTransparency = 1
Minimize.Text = "—"
Minimize.TextColor3 = CONFIG.SubText
Minimize.TextSize = 20
Minimize.Font = Enum.Font.Gotham
Minimize.Parent = TopBar

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 48)
Close.Position = UDim2.new(1, -15, 0, 0)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = CONFIG.SubText
Close.TextSize = 25
Close.Font = Enum.Font.Gotham
Close.Parent = TopBar

Close.MouseEnter:Connect(function()
    Close.TextColor3 = CONFIG.Red
end)

Close.MouseLeave:Connect(function()
    Close.TextColor3 = CONFIG.SubText
end)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 218, 1, -48)
Sidebar.Position = UDim2.fromOffset(0, 48)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.fromOffset(1, Sidebar.AbsoluteSize.Y)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = CONFIG.Border
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -218, 1, -48)
Content.Position = UDim2.fromOffset(218, 48)
Content.BackgroundColor3 = CONFIG.Background
Content.BorderSizePixel = 0
Content.Parent = Main

--==================================================
-- PAGE TITLE
--==================================================

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -30, 0, 45)
PageTitle.Position = UDim2.fromOffset(15, 5)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Main"
PageTitle.TextColor3 = CONFIG.Text
PageTitle.TextSize = 17
PageTitle.Font = Enum.Font.GothamMedium
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

--==================================================
-- DRAG SYSTEM
--==================================================

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

--==================================================
-- SIDEBAR BUTTON SYSTEM
--==================================================

local SidebarButtons = {}

local function CreateSidebarButton(name, text, y)

    local Button = Instance.new("TextButton")

    Button.Name = name
    Button.Size = UDim2.new(1, -8, 0, 42)
    Button.Position = UDim2.fromOffset(4, y)

    Button.BackgroundColor3 = CONFIG.Secondary
    Button.BackgroundTransparency = 1

    Button.BorderSizePixel = 0

    Button.Text = text
    Button.TextColor3 = CONFIG.SubText
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham

    Button.TextXAlignment = Enum.TextXAlignment.Left

    Button.Parent = Sidebar

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.Parent = Button

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.fromOffset(3, 30)
    Accent.Position = UDim2.fromOffset(0, 6)
    Accent.BackgroundColor3 = CONFIG.Red
    Accent.BorderSizePixel = 0
    Accent.Visible = false
    Accent.Parent = Button

    SidebarButtons[name] = {
        Button = Button,
        Accent = Accent
    }

    return Button
end

local InfoButton = CreateSidebarButton(
    "Info",
    "ⓘ   Info",
    10
)

local MainButton = CreateSidebarButton(
    "Main",
    "◯   Main",
    55
)

local SettingsButton = CreateSidebarButton(
    "Settings",
    "⚙   Settings",
    100
)

--==================================================
-- CARD CREATOR
--==================================================

local function CreateCard(parent, title, position, size)

    local Card = Instance.new("Frame")

    Card.Size = size
    Card.Position = position

    Card.BackgroundColor3 = CONFIG.Card
    Card.BorderSizePixel = 0

    Card.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Card

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Border
    Stroke.Thickness = 1
    Stroke.Parent = Card

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.Parent = Card

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -50, 1, 0)
    HeaderTitle.Position = UDim2.fromOffset(15, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = title
    HeaderTitle.TextColor3 = CONFIG.Text
    HeaderTitle.TextSize = 14
    HeaderTitle.Font = Enum.Font.Gotham
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.fromOffset(30, 42)
    Arrow.Position = UDim2.new(1, -38, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "⌄"
    Arrow.TextColor3 = CONFIG.Text
    Arrow.TextSize = 20
    Arrow.Font = Enum.Font.Gotham
    Arrow.Parent = Header

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.fromOffset(0, 42)
    Line.BackgroundColor3 = CONFIG.Border
    Line.BorderSizePixel = 0
    Line.Parent = Card

    return Card
end

--==================================================
-- TOGGLE
--==================================================

local ToggleStates = {}

local function CreateToggle(parent, text, y, callback)

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -85, 0, 32)
    Label.Position = UDim2.fromOffset(10, y)

    Label.BackgroundTransparency = 1

    Label.Text = text
    Label.TextColor3 = CONFIG.SubText
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = parent

    local Toggle = Instance.new("TextButton")

    Toggle.Size = UDim2.fromOffset(40, 22)
    Toggle.Position = UDim2.new(1, -48, 0, y + 5)

    Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    Toggle.BorderSizePixel = 0

    Toggle.Text = ""
    Toggle.AutoButtonColor = false

    Toggle.Parent = parent

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Circle = Instance.new("Frame")

    Circle.Size = UDim2.fromOffset(18, 18)
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

            Circle.Position = UDim2.new(
                1,
                -20,
                0,
                2
            )

        else

            Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)

            Circle.Position = UDim2.fromOffset(2, 2)

        end

        if callback then
            callback(state)
        end

    end)

    return Toggle
end

--==================================================
-- DISCORD CARD
--==================================================

local DiscordCard = CreateCard(
    Content,
    "Discord",
    UDim2.fromOffset(10, 55),
    UDim2.fromOffset(240, 125)
)

local Discord1 = Instance.new("TextButton")
Discord1.Size = UDim2.new(1, -20, 0, 30)
Discord1.Position = UDim2.fromOffset(10, 52)
Discord1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Discord1.BorderSizePixel = 0
Discord1.Text = "Join Discord to Make Money"
Discord1.TextColor3 = CONFIG.SubText
Discord1.TextSize = 12
Discord1.Font = Enum.Font.Gotham
Discord1.Parent = DiscordCard

local Discord1Corner = Instance.new("UICorner")
Discord1Corner.CornerRadius = UDim.new(0, 15)
Discord1Corner.Parent = Discord1

local Discord2 = Discord1:Clone()
Discord2.Position = UDim2.fromOffset(10, 87)
Discord2.Text = "Join Discord for Keyless Scripts"
Discord2.Parent = DiscordCard

--==================================================
-- PLOT CARD
--==================================================

local PlotCard = CreateCard(
    Content,
    "Plot",
    UDim2.fromOffset(260, 55),
    UDim2.fromOffset(220, 210)
)

CreateToggle(
    PlotCard,
    "Auto Rebirth",
    50
)

CreateToggle(
    PlotCard,
    "Auto Upgrade Coop",
    85
)

CreateToggle(
    PlotCard,
    "Auto Upgrade Feeder",
    120
)

CreateToggle(
    PlotCard,
    "Auto Buy Feeders",
    155
)

--==================================================
-- FARM CARD
--==================================================

local FarmCard = CreateCard(
    Content,
    "Farm",
    UDim2.fromOffset(10, 190),
    UDim2.fromOffset(240, 285)
)

CreateToggle(
    FarmCard,
    "Auto Open Eggs",
    50
)

CreateToggle(
    FarmCard,
    "Auto Fuse Chickens",
    85
)

CreateToggle(
    FarmCard,
    "Auto Grab Scraps",
    120
)

CreateToggle(
    FarmCard,
    "Auto Recycle Scrap",
    155
)

--==================================================
-- SLIDER
--==================================================

local SliderLabel = Instance.new("TextLabel")

SliderLabel.Size = UDim2.new(1, -20, 0, 25)
SliderLabel.Position = UDim2.fromOffset(10, 188)

SliderLabel.BackgroundTransparency = 1

SliderLabel.Text = "Recycle when scrap"
SliderLabel.TextColor3 = CONFIG.SubText
SliderLabel.TextSize = 13
SliderLabel.Font = Enum.Font.Gotham

SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

SliderLabel.Parent = FarmCard

local SliderValue = Instance.new("TextLabel")

SliderValue.Size = UDim2.fromOffset(50, 25)
SliderValue.Position = UDim2.new(1, -60, 0, 188)

SliderValue.BackgroundTransparency = 1

SliderValue.Text = "10/20"
SliderValue.TextColor3 = CONFIG.Red
SliderValue.TextSize = 13
SliderValue.Font = Enum.Font.Gotham

SliderValue.TextXAlignment = Enum.TextXAlignment.Right

SliderValue.Parent = FarmCard

local Slider = Instance.new("Frame")

Slider.Size = UDim2.new(1, -30, 0, 6)
Slider.Position = UDim2.fromOffset(15, 218)

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

Thumb.Size = UDim2.fromOffset(16, 16)

Thumb.Position = UDim2.new(
    0.5,
    -8,
    0.5,
    -8
)

Thumb.BackgroundColor3 = CONFIG.Red
Thumb.BorderSizePixel = 0

Thumb.Parent = Slider

local ThumbCorner = Instance.new("UICorner")
ThumbCorner.CornerRadius = UDim.new(1, 0)
ThumbCorner.Parent = Thumb

local sliderDragging = false

Thumb.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end

end)

UserInputService.InputChanged:Connect(function(input)

    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

        local mouseX = input.Position.X
        local startX = Slider.AbsolutePosition.X
        local width = Slider.AbsoluteSize.X

        local percent = math.clamp(
            (mouseX - startX) / width,
            0,
            1
        )

        SliderFill.Size = UDim2.new(
            percent,
            0,
            1,
            0
        )

        Thumb.Position = UDim2.new(
            percent,
            -8,
            0.5,
            -8
        )

        local value = math.floor(percent * 20 + 0.5)

        SliderValue.Text = value .. "/20"

    end

end)

CreateToggle(
    FarmCard,
    "Auto Upgrade Recycler",
    235
)

--==================================================
-- BATTLE CARD
--==================================================

local BattleCard = CreateCard(
    Content,
    "Battle",
    UDim2.fromOffset(10, 485),
    UDim2.fromOffset(240, 150)
)

CreateToggle(
    BattleCard,
    "Auto Start Tower",
    50
)

CreateToggle(
    BattleCard,
    "Auto No Thanks",
    85
)

CreateToggle(
    BattleCard,
    "Auto Start Chaos",
    120
)

--==================================================
-- SIDEBAR SELECTION
--==================================================

local function SelectSidebar(name)

    for buttonName, data in pairs(SidebarButtons) do

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

--==================================================
-- BUTTON EVENTS
--==================================================

InfoButton.MouseButton1Click:Connect(function()

    PageTitle.Text = "Info"

end)

MainButton.MouseButton1Click:Connect(function()

    PageTitle.Text = "Main"

end)

SettingsButton.MouseButton1Click:Connect(function()

    PageTitle.Text = "Settings"

end)

SelectSidebar("Main")

--==================================================
-- MINIMIZE
--==================================================

local minimized = false

Minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    Sidebar.Visible = not minimized
    Content.Visible = not minimized

    if minimized then

        Main.Size = UDim2.fromOffset(
            CONFIG.Width,
            48
        )

    else

        Main.Size = UDim2.fromOffset(
            CONFIG.Width,
            CONFIG.Height
        )

    end

end)

--==================================================
-- SEARCH
--==================================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()

    local query = SearchBox.Text:lower()

    for _, object in ipairs(Content:GetDescendants()) do

        if object:IsA("TextLabel") or object:IsA("TextButton") then

            if object ~= PageTitle then

                local text = object.Text:lower()

                if query == "" then

                    object.Visible = true

                else

                    object.Visible = string.find(
                        text,
                        query,
                        1,
                        true
                    ) ~= nil

                end

            end

        end

    end

end)

--==================================================
-- EXAMPLE CALLBACKS
--==================================================

CreateToggle(
    -- dummy parent won't be used
    Instance.new("Frame"),
    "Example",
    0,
    function(enabled)

        print(
            "[ERDEVA HUB] Example:",
            enabled
        )

    end
)

--==================================================
-- LOADED
--==================================================

print("[ERDEVA HUB] Loaded")
