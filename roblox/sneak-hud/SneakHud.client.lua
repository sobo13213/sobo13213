-- SneakHud (LocalScript) — pune-l în StarterPlayer > StarterPlayerScripts
-- Indicatorul de zgomot din Figma: difuzor + "HOLD CTRL TO SNEAK".
-- 0 = stai pe loc, 1 = ghemuit (CTRL), 2 = mers normal, 3 = alergat (SHIFT)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Înlocuiește cu ID-urile primite după ce urci PNG-urile (Creator Hub / Asset Manager)
local ICONS = {
	[0] = "rbxassetid://0000000000", -- sound_0_stai.png
	[1] = "rbxassetid://0000000000", -- sound_1_ghemuit.png
	[2] = "rbxassetid://0000000000", -- sound_2_mers.png
	[3] = "rbxassetid://0000000000", -- sound_3_alergat.png
}

-- true = arată grila 2x2 din Figma (toate cele 4 stări); false = un singur indicator live
local SHOW_ALL_STATES = false

local LABELS = {
	[0] = "STAI PE LOC",
	[1] = "GHEMUIT (CTRL) — linia 1",
	[2] = "MERS NORMAL — liniile 1–2",
	[3] = "ALERGAT (SHIFT) — toate roșii",
}

local FONT_LABEL = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
local FONT_HINT = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SneakHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Un rând: [eticheta gri] deasupra, [difuzor 88x110] + [HOLD CTRL TO SNEAK] dedesubt
local function makeCell(level, parent)
	local cell = Instance.new("Frame")
	cell.Name = "Cell" .. level
	cell.BackgroundTransparency = 1
	cell.Size = UDim2.fromOffset(320, 132)
	cell.Parent = parent

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = cell

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.LayoutOrder = 1
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromOffset(320, 16)
	label.FontFace = FONT_LABEL
	label.TextSize = 13
	label.TextColor3 = Color3.fromHex("C9D1D0")
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = LABELS[level]
	label.Parent = cell

	local row = Instance.new("Frame")
	row.Name = "Row"
	row.LayoutOrder = 2
	row.BackgroundTransparency = 1
	row.Size = UDim2.fromOffset(320, 110)
	row.Parent = cell

	local rowList = Instance.new("UIListLayout")
	rowList.FillDirection = Enum.FillDirection.Horizontal
	rowList.VerticalAlignment = Enum.VerticalAlignment.Center
	rowList.Padding = UDim.new(0, 14)
	rowList.SortOrder = Enum.SortOrder.LayoutOrder
	rowList.Parent = row

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.LayoutOrder = 1
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromOffset(88, 110)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Image = ICONS[level]
	icon.Parent = row

	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.LayoutOrder = 2
	hint.BackgroundTransparency = 1
	hint.AutomaticSize = Enum.AutomaticSize.X
	hint.Size = UDim2.fromOffset(0, 24)
	hint.FontFace = FONT_HINT
	hint.TextSize = 17
	hint.TextColor3 = Color3.new(1, 1, 1)
	hint.Text = "HOLD CTRL TO SNEAK"
	hint.Parent = row

	-- conturul negru (-webkit-text-stroke din HTML)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 1.5
	stroke.Parent = hint

	return cell, label, icon
end

if SHOW_ALL_STATES then
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0, 1)
	panel.Position = UDim2.new(0, 24, 1, -28)
	panel.Size = UDim2.fromOffset(680, 292)
	panel.BackgroundTransparency = 1
	panel.Parent = gui

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(320, 132)
	grid.CellPadding = UDim2.fromOffset(40, 28)
	grid.SortOrder = Enum.SortOrder.Name
	grid.Parent = panel

	for level = 0, 3 do
		makeCell(level, panel)
	end
	return
end

-- Indicator live, colț stânga-jos
local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.AnchorPoint = Vector2.new(0, 1)
holder.Position = UDim2.new(0, 24, 1, -28)
holder.Size = UDim2.fromOffset(320, 132)
holder.BackgroundTransparency = 1
holder.Parent = gui

local _, label, icon = makeCell(0, holder)

local function isDown(...)
	for _, key in { ... } do
		if UserInputService:IsKeyDown(key) then
			return true
		end
	end
	return false
end

local current = -1
local function setLevel(level)
	if level == current then
		return
	end
	current = level
	icon.Image = ICONS[level]
	label.Text = LABELS[level]
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local moving = humanoid ~= nil and humanoid.MoveDirection.Magnitude > 0.05

	if not moving then
		setLevel(0)
	elseif isDown(Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl) then
		setLevel(1)
	elseif isDown(Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift) then
		setLevel(3)
	else
		setLevel(2)
	end
end)
