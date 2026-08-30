local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local VP = workspace.CurrentCamera.ViewportSize
local isMobile = VP.X < 600

local W = isMobile and math.min(VP.X - 20, 360) or 680
local H = isMobile and math.min(VP.Y - 60, 520) or 560

local CONFIG = {
	Background  = Color3.fromRGB(10, 10, 10),
	Secondary   = Color3.fromRGB(16, 16, 16),
	Card        = Color3.fromRGB(14, 14, 14),
	Border      = Color3.fromRGB(40, 40, 40),
	Red         = Color3.fromRGB(220, 38, 38),
	Text        = Color3.fromRGB(230, 230, 230),
	Sub         = Color3.fromRGB(130, 130, 130),
}

pcall(function()
	local old = CoreGui:FindFirstChild("ERDEVA_HUB")
	if old then old:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "ERDEVA_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(W, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = CONFIG.Red
MainStroke.Thickness = 1.2

local function Tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = CONFIG.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0.5, 0)
TopFix.Position = UDim2.new(0, 0, 0.5, 0)
TopFix.BackgroundColor3 = CONFIG.Secondary
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = CONFIG.Border
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

local RedBar = Instance.new("Frame")
RedBar.Size = UDim2.fromOffset(3, 22)
RedBar.Position = UDim2.fromOffset(12, 12)
RedBar.BackgroundColor3 = CONFIG.Red
RedBar.BorderSizePixel = 0
RedBar.Parent = TopBar
Instance.new("UICorner", RedBar).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(180, 24)
Title.Position = UDim2.fromOffset(22, 5)
Title.BackgroundTransparency = 1
Title.Text = "ERDEVA HUB"
Title.TextColor3 = CONFIG.Text
Title.TextSize = isMobile and 13 or 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.fromOffset(180, 16)
SubLbl.Position = UDim2.fromOffset(22, 27)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "v1.0  Chicken Farm"
SubLbl.TextColor3 = CONFIG.Red
SubLbl.TextSize = 9
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.Parent = TopBar

local function MakeTopBtn(icon, xOff)
	local B = Instance.new("TextButton")
	B.Size = UDim2.fromOffset(30, 30)
	B.Position = UDim2.new(1, xOff, 0, 8)
	B.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	B.BorderSizePixel = 0
	B.Text = icon
	B.TextColor3 = CONFIG.Sub
	B.TextSize = 14
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = TopBar
	Instance.new("UICorner", B).CornerRadius = UDim.new(0, 7)
	B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = Color3.fromRGB(40,40,40)}) end)
	B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = Color3.fromRGB(28,28,28)}) end)
	return B
end

local BtnClose = MakeTopBtn("✕", -8)
local BtnMin   = MakeTopBtn("—", -44)

BtnClose.MouseEnter:Connect(function() Tween(BtnClose, {TextColor3 = CONFIG.Red}) end)
BtnClose.MouseLeave:Connect(function() Tween(BtnClose, {TextColor3 = CONFIG.Sub}) end)
BtnClose.MouseButton1Click:Connect(function() Gui:Destroy() end)

local SIDEBAR_W = isMobile and 46 or 182

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -46)
Sidebar.Position = UDim2.fromOffset(0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.fromOffset(1, 9999)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = CONFIG.Border
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0, 4)
SideList.FillDirection = Enum.FillDirection.Vertical
SideList.SortOrder = Enum.SortOrder.LayoutOrder

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 4)
SidePad.PaddingRight = UDim.new(0, 4)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -SIDEBAR_W, 1, -46)
Content.Position = UDim2.fromOffset(SIDEBAR_W, 46)
Content.BackgroundColor3 = CONFIG.Background
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = CONFIG.Red
Content.CanvasSize = UDim2.fromOffset(0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local ContentPad = Instance.new("UIPadding", Content)
ContentPad.PaddingTop = UDim.new(0, 8)
ContentPad.PaddingLeft = UDim.new(0, 8)
ContentPad.PaddingRight = UDim.new(0, 8)
ContentPad.PaddingBottom = UDim.new(0, 12)

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = {}
local SideButtons = {}
local currentPage = nil

local function SetPage(name)
	for n, data in pairs(Pages) do
		data.Frame.Visible = (n == name)
	end
	for n, btn in pairs(SideButtons) do
		if n == name then
			Tween(btn.Bg, {BackgroundColor3 = Color3.fromRGB(30,10,10), BackgroundTransparency = 0})
			Tween(btn.Lbl, {TextColor3 = CONFIG.Text})
			btn.Dot.Visible = true
		else
			Tween(btn.Bg, {BackgroundTransparency = 1})
			Tween(btn.Lbl, {TextColor3 = CONFIG.Sub})
			btn.Dot.Visible = false
		end
	end
	currentPage = name
end

local function AddSideButton(name, icon, order)
	local Bg = Instance.new("TextButton")
	Bg.Size = UDim2.new(1, 0, 0, isMobile and 40 or 38)
	Bg.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
	Bg.BackgroundTransparency = 1
	Bg.BorderSizePixel = 0
	Bg.Text = ""
	Bg.AutoButtonColor = false
	Bg.LayoutOrder = order
	Bg.Parent = Sidebar
	Instance.new("UICorner", Bg).CornerRadius = UDim.new(0, 8)

	local Dot = Instance.new("Frame")
	Dot.Size = UDim2.fromOffset(3, 20)
	Dot.Position = UDim2.fromOffset(0, (isMobile and 40 or 38)/2 - 10)
	Dot.BackgroundColor3 = CONFIG.Red
	Dot.BorderSizePixel = 0
	Dot.Visible = false
	Dot.Parent = Bg
	Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

	local Lbl = Instance.new("TextLabel")
	Lbl.Size = UDim2.new(1, 0, 1, 0)
	Lbl.BackgroundTransparency = 1
	Lbl.Text = isMobile and icon or (icon .. "  " .. name)
	Lbl.TextColor3 = CONFIG.Sub
	Lbl.TextSize = isMobile and 18 or 13
	Lbl.Font = Enum.Font.GothamMedium
	Lbl.TextXAlignment = isMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
	Lbl.Parent = Bg

	if not isMobile then
		local Pad = Instance.new("UIPadding", Bg)
		Pad.PaddingLeft = UDim.new(0, 12)
	end

	Bg.MouseEnter:Connect(function()
		if currentPage ~= name then
			Tween(Bg, {BackgroundTransparency = 0.7})
		end
	end)
	Bg.MouseLeave:Connect(function()
		if currentPage ~= name then
			Tween(Bg, {BackgroundTransparency = 1})
		end
	end)
	Bg.MouseButton1Click:Connect(function() SetPage(name) end)

	SideButtons[name] = {Bg = Bg, Lbl = Lbl, Dot = Dot}

	local PageFrame = Instance.new("Frame")
	PageFrame.Size = UDim2.new(1, 0, 0, 0)
	PageFrame.AutomaticSize = Enum.AutomaticSize.Y
	PageFrame.BackgroundTransparency = 1
	PageFrame.BorderSizePixel = 0
	PageFrame.Visible = false
	PageFrame.Parent = Content

	local FL = Instance.new("UIListLayout", PageFrame)
	FL.Padding = UDim.new(0, 8)
	FL.FillDirection = Enum.FillDirection.Vertical
	FL.SortOrder = Enum.SortOrder.LayoutOrder

	Pages[name] = {Frame = PageFrame, Layout = FL, order = 0}
end

AddSideButton("Main",     "🏠", 1)
AddSideButton("Farm",     "🐔", 2)
AddSideButton("Battle",   "⚔️", 3)
AddSideButton("Info",     "ℹ️", 4)
AddSideButton("Settings", "⚙️", 5)

local function MakeCard(page, title, icon, order)
	local data = Pages[page]
	local Card = Instance.new("Frame")
	Card.Size = UDim2.new(1, 0, 0, 0)
	Card.AutomaticSize = Enum.AutomaticSize.Y
	Card.BackgroundColor3 = CONFIG.Card
	Card.BorderSizePixel = 0
	Card.LayoutOrder = order or data.order
	data.order = data.order + 1
	Card.Parent = data.Frame
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
	local CS = Instance.new("UIStroke", Card)
	CS.Color = CONFIG.Border
	CS.Thickness = 1

	local Head = Instance.new("Frame")
	Head.Size = UDim2.new(1, 0, 0, 40)
	Head.BackgroundTransparency = 1
	Head.Parent = Card

	local HeadLine = Instance.new("Frame")
	HeadLine.Size = UDim2.new(1, 0, 0, 1)
	HeadLine.Position = UDim2.new(0, 0, 1, -1)
	HeadLine.BackgroundColor3 = CONFIG.Border
	HeadLine.BorderSizePixel = 0
	HeadLine.Parent = Head

	local HIcon = Instance.new("TextLabel")
	HIcon.Size = UDim2.fromOffset(28, 40)
	HIcon.Position = UDim2.fromOffset(12, 0)
	HIcon.BackgroundTransparency = 1
	HIcon.Text = icon
	HIcon.TextColor3 = CONFIG.Red
	HIcon.TextSize = 15
	HIcon.Font = Enum.Font.GothamBold
	HIcon.Parent = Head

	local HTitle = Instance.new("TextLabel")
	HTitle.Size = UDim2.new(1, -50, 1, 0)
	HTitle.Position = UDim2.fromOffset(38, 0)
	HTitle.BackgroundTransparency = 1
	HTitle.Text = title
	HTitle.TextColor3 = CONFIG.Text
	HTitle.TextSize = 12
	HTitle.Font = Enum.Font.GothamMedium
	HTitle.TextXAlignment = Enum.TextXAlignment.Left
	HTitle.Parent = Head

	local Body = Instance.new("Frame")
	Body.Size = UDim2.new(1, 0, 0, 0)
	Body.AutomaticSize = Enum.AutomaticSize.Y
	Body.BackgroundTransparency = 1
	Body.Position = UDim2.fromOffset(0, 40)
	Body.Parent = Card

	local BPad = Instance.new("UIPadding", Body)
	BPad.PaddingTop = UDim.new(0, 6)
	BPad.PaddingBottom = UDim.new(0, 10)
	BPad.PaddingLeft = UDim.new(0, 10)
	BPad.PaddingRight = UDim.new(0, 10)

	local BLayout = Instance.new("UIListLayout", Body)
	BLayout.Padding = UDim.new(0, 2)
	BLayout.FillDirection = Enum.FillDirection.Vertical
	BLayout.SortOrder = Enum.SortOrder.LayoutOrder

	return Body
end

local ToggleStates = {}
local function AddToggle(body, label, callback)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 40)
	Row.BackgroundTransparency = 1
	Row.Parent = body

	local Lbl = Instance.new("TextLabel")
	Lbl.Size = UDim2.new(1, -58, 1, 0)
	Lbl.Position = UDim2.fromOffset(2, 0)
	Lbl.BackgroundTransparency = 1
	Lbl.Text = label
	Lbl.TextColor3 = CONFIG.Sub
	Lbl.TextSize = 12
	Lbl.Font = Enum.Font.Gotham
	Lbl.TextXAlignment = Enum.TextXAlignment.Left
	Lbl.Parent = Row

	local Track = Instance.new("TextButton")
	Track.Size = UDim2.fromOffset(42, 22)
	Track.Position = UDim2.new(1, -44, 0.5, -11)
	Track.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	Track.BorderSizePixel = 0
	Track.Text = ""
	Track.AutoButtonColor = false
	Track.Parent = Row
	Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

	local Circle = Instance.new("Frame")
	Circle.Size = UDim2.fromOffset(16, 16)
	Circle.Position = UDim2.fromOffset(3, 3)
	Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	Circle.BorderSizePixel = 0
	Circle.Parent = Track
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

	local state = false
	ToggleStates[label] = false

	Track.MouseButton1Click:Connect(function()
		state = not state
		ToggleStates[label] = state
		if state then
			Tween(Track, {BackgroundColor3 = CONFIG.Red})
			Tween(Circle, {Position = UDim2.fromOffset(23, 3)})
			Tween(Lbl, {TextColor3 = CONFIG.Text})
		else
			Tween(Track, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
			Tween(Circle, {Position = UDim2.fromOffset(3, 3)})
			Tween(Lbl, {TextColor3 = CONFIG.Sub})
		end
		if callback then callback(state) end
	end)

	return Track
end

local mainBody = MakeCard("Main", "Overview", "🏠", 0)

local WelcomeRow = Instance.new("Frame")
WelcomeRow.Size = UDim2.new(1, 0, 0, 52)
WelcomeRow.BackgroundColor3 = Color3.fromRGB(20, 8, 8)
WelcomeRow.BorderSizePixel = 0
WelcomeRow.Parent = mainBody
Instance.new("UICorner", WelcomeRow).CornerRadius = UDim.new(0, 8)

local WIcon = Instance.new("TextLabel")
WIcon.Size = UDim2.fromOffset(40, 52)
WIcon.Position = UDim2.fromOffset(8, 0)
WIcon.BackgroundTransparency = 1
WIcon.Text = "👋"
WIcon.TextSize = 22
WIcon.Font = Enum.Font.Gotham
WIcon.Parent = WelcomeRow

local WLbl = Instance.new("TextLabel")
WLbl.Size = UDim2.new(1, -52, 1, 0)
WLbl.Position = UDim2.fromOffset(46, 0)
WLbl.BackgroundTransparency = 1
WLbl.Text = "Welcome, " .. player.DisplayName .. "!\nErdeva Hub is ready."
WLbl.TextColor3 = CONFIG.Text
WLbl.TextSize = 11
WLbl.Font = Enum.Font.Gotham
WLbl.TextXAlignment = Enum.TextXAlignment.Left
WLbl.TextYAlignment = Enum.TextYAlignment.Center
WLbl.Parent = WelcomeRow

local discBody = MakeCard("Main", "Discord", "💬", 1)

local function DiscordBtn(text)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 36)
	Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	Btn.BorderSizePixel = 0
	Btn.Text = "  " .. text
	Btn.TextColor3 = CONFIG.Sub
	Btn.TextSize = 11
	Btn.Font = Enum.Font.Gotham
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	Btn.AutoButtonColor = false
	Btn.Parent = discBody
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
	Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(35,35,35)}) end)
	Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(22,22,22)}) end)
	return Btn
end

DiscordBtn("💰  Join Discord to Make Money")
DiscordBtn("🔑  Join Discord for Keyless Scripts")

local farmBody = MakeCard("Farm", "Auto Farm", "🐔", 0)
AddToggle(farmBody, "Auto Open Eggs")
AddToggle(farmBody, "Auto Fuse Chickens")
AddToggle(farmBody, "Auto Grab Scraps")
AddToggle(farmBody, "Auto Recycle Scrap")
AddToggle(farmBody, "Auto Upgrade Recycler")

local plotBody = MakeCard("Farm", "Plot", "🌱", 1)
AddToggle(plotBody, "Auto Rebirth")
AddToggle(plotBody, "Auto Upgrade Coop")
AddToggle(plotBody, "Auto Upgrade Feeder")
AddToggle(plotBody, "Auto Buy Feeders")

local sliderBody = MakeCard("Farm", "Recycle Threshold", "🎚️", 2)

local SliderRow = Instance.new("Frame")
SliderRow.Size = UDim2.new(1, 0, 0, 32)
SliderRow.BackgroundTransparency = 1
SliderRow.Parent = sliderBody

local SliderLbl = Instance.new("TextLabel")
SliderLbl.Size = UDim2.new(1, -60, 1, 0)
SliderLbl.BackgroundTransparency = 1
SliderLbl.Text = "Recycle when scrap:"
SliderLbl.TextColor3 = CONFIG.Sub
SliderLbl.TextSize = 12
SliderLbl.Font = Enum.Font.Gotham
SliderLbl.TextXAlignment = Enum.TextXAlignment.Left
SliderLbl.Parent = SliderRow

local SliderVal = Instance.new("TextLabel")
SliderVal.Size = UDim2.fromOffset(55, 32)
SliderVal.Position = UDim2.new(1, -55, 0, 0)
SliderVal.BackgroundTransparency = 1
SliderVal.Text = "10 / 20"
SliderVal.TextColor3 = CONFIG.Red
SliderVal.TextSize = 12
SliderVal.Font = Enum.Font.GothamBold
SliderVal.TextXAlignment = Enum.TextXAlignment.Right
SliderVal.Parent = SliderRow

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, 0, 0, 6)
SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = sliderBody
Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = CONFIG.Red
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local Thumb = Instance.new("Frame")
Thumb.Size = UDim2.fromOffset(18, 18)
Thumb.Position = UDim2.new(0.5, -9, 0.5, -9)
Thumb.BackgroundColor3 = CONFIG.Red
Thumb.BorderSizePixel = 0
Thumb.Parent = SliderTrack
Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
local ThumbGlow = Instance.new("UIStroke", Thumb)
ThumbGlow.Color = Color3.fromRGB(255, 80, 80)
ThumbGlow.Thickness = 2

local sliderDrag = false

Thumb.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		sliderDrag = true
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		sliderDrag = false
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if sliderDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local pct = math.clamp((i.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
		SliderFill.Size = UDim2.new(pct, 0, 1, 0)
		Thumb.Position = UDim2.new(pct, -9, 0.5, -9)
		SliderVal.Text = math.floor(pct * 20 + 0.5) .. " / 20"
	end
end)

local battleBody = MakeCard("Battle", "Battle", "⚔️", 0)
AddToggle(battleBody, "Auto Start Tower")
AddToggle(battleBody, "Auto No Thanks")
AddToggle(battleBody, "Auto Start Chaos")

local infoBody = MakeCard("Info", "Credits", "📋", 0)

local function InfoRow(label, val)
	local R = Instance.new("Frame")
	R.Size = UDim2.new(1, 0, 0, 32)
	R.BackgroundTransparency = 1
	R.Parent = infoBody
	local L = Instance.new("TextLabel", R)
	L.Size = UDim2.new(0.6, 0, 1, 0)
	L.BackgroundTransparency = 1
	L.Text = label
	L.TextColor3 = CONFIG.Sub
	L.TextSize = 12
	L.Font = Enum.Font.Gotham
	L.TextXAlignment = Enum.TextXAlignment.Left
	local V = Instance.new("TextLabel", R)
	V.Size = UDim2.new(0.4, 0, 1, 0)
	V.Position = UDim2.new(0.6, 0, 0, 0)
	V.BackgroundTransparency = 1
	V.Text = val
	V.TextColor3 = CONFIG.Red
	V.TextSize = 12
	V.Font = Enum.Font.GothamBold
	V.TextXAlignment = Enum.TextXAlignment.Right
end

InfoRow("Script", "ERDEVA HUB")
InfoRow("Version", "v1.0")
InfoRow("Game", "Chicken Farm")
InfoRow("Author", "Erdeva")

local settBody = MakeCard("Settings", "Interface", "⚙️", 0)
AddToggle(settBody, "Show Notifications")
AddToggle(settBody, "Sound Effects")

local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = Main.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

local minimized = false
BtnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	Sidebar.Visible = not minimized
	Content.Visible = not minimized
	Main.Size = minimized and UDim2.fromOffset(W, 46) or UDim2.fromOffset(W, H)
end)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local vp = workspace.CurrentCamera.ViewportSize
	W = math.min(vp.X - 20, isMobile and 360 or 680)
	H = math.min(vp.Y - 60, isMobile and 520 or 560)
	if not minimized then
		Main.Size = UDim2.fromOffset(W, H)
	else
		Main.Size = UDim2.fromOffset(W, 46)
	end
	Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
end)

SetPage("Main")

print("[ERDEVA HUB] Loaded")
