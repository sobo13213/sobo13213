-- InteractionPrompt (LocalScript) — pune-l în StarterPlayer > StarterPlayerScripts
-- Promptul din Figma ("Interaction Prompt"): pătrat crem cu tasta, titlu + acțiune
-- cu Patrick Hand, bară albă jos care se umple cât ții apăsat.
-- Folosește ProximityPrompt-urile din joc: Name = ObjectText, Action = ActionText.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- true = toate ProximityPrompt-urile din joc folosesc stilul ăsta
-- false = doar cele la care ai pus manual Style = Custom
local FORCE_CUSTOM_STYLE = true

-- unde apare pe ecran (centrat, puțin sub mijloc)
local SCREEN_POSITION = UDim2.new(0.5, 0, 0.5, 120)

local FONT = Font.fromEnum(Enum.Font.PatrickHand)

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "InteractionPrompt"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Card: fundal rgba(20,16,16,0.55), colțuri 4px, padding 10/26/14/10, gap 14, min 260px
local card = Instance.new("TextButton")
card.Name = "Card"
card.Text = ""
card.AutoButtonColor = false
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = SCREEN_POSITION
card.AutomaticSize = Enum.AutomaticSize.XY
card.Size = UDim2.fromOffset(0, 0)
card.BackgroundColor3 = Color3.fromRGB(20, 16, 16)
card.BackgroundTransparency = 0.45
card.ClipsDescendants = true
card.Parent = gui

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

local minSize = Instance.new("UISizeConstraint")
minSize.MinSize = Vector2.new(260, 0)
minSize.Parent = card

-- conținutul stă într-un frame separat, ca bara de jos să nu intre în layout
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.AutomaticSize = Enum.AutomaticSize.XY
content.Size = UDim2.fromOffset(0, 0)
content.Parent = card

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 26)
padding.PaddingBottom = UDim.new(0, 14)
padding.Parent = content

local row = Instance.new("UIListLayout")
row.FillDirection = Enum.FillDirection.Horizontal
row.VerticalAlignment = Enum.VerticalAlignment.Center
row.Padding = UDim.new(0, 14)
row.SortOrder = Enum.SortOrder.LayoutOrder
row.Parent = content

-- Tasta: 64x64, #F4F1EA, colțuri 3px, litera 26px #1A1A1A
local key = Instance.new("Frame")
key.Name = "Key"
key.LayoutOrder = 1
key.Size = UDim2.fromOffset(64, 64)
key.BackgroundColor3 = Color3.fromHex("F4F1EA")
key.Parent = content
Instance.new("UICorner", key).CornerRadius = UDim.new(0, 3)

local keyLabel = Instance.new("TextLabel")
keyLabel.Name = "KeyLabel"
keyLabel.BackgroundTransparency = 1
keyLabel.Size = UDim2.fromScale(1, 1)
keyLabel.FontFace = FONT
keyLabel.TextSize = 26
keyLabel.TextColor3 = Color3.fromHex("1A1A1A")
keyLabel.Text = "E"
keyLabel.Parent = key

-- Texte: titlu 26/28 alb, acțiune 18/20 #E8E4DC, gap 2
local texts = Instance.new("Frame")
texts.Name = "Text"
texts.LayoutOrder = 2
texts.BackgroundTransparency = 1
texts.AutomaticSize = Enum.AutomaticSize.XY
texts.Size = UDim2.fromOffset(0, 0)
texts.Parent = content

local column = Instance.new("UIListLayout")
column.Padding = UDim.new(0, 2)
column.SortOrder = Enum.SortOrder.LayoutOrder
column.Parent = texts

local function makeText(name, order, size, lineHeight, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.LayoutOrder = order
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.fromOffset(0, lineHeight)
	label.FontFace = FONT
	label.TextSize = size
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = texts
	return label
end

local nameLabel = makeText("Name", 1, 26, 28, Color3.new(1, 1, 1))
local actionLabel = makeText("Action", 2, 18, 20, Color3.fromHex("E8E4DC"))

-- Bara de jos: 4px, fundal alb 12%, umplere albă cu strălucire
local track = Instance.new("Frame")
track.Name = "ProgressTrack"
track.AnchorPoint = Vector2.new(0, 1)
track.Position = UDim2.fromScale(0, 1)
track.Size = UDim2.new(1, 0, 0, 4)
track.BackgroundColor3 = Color3.new(1, 1, 1)
track.BackgroundTransparency = 0.88
track.BorderSizePixel = 0
track.ZIndex = 2
track.Parent = card

local bar = Instance.new("Frame")
bar.Name = "ProgressBar"
bar.Size = UDim2.fromScale(0, 1)
bar.BackgroundColor3 = Color3.new(1, 1, 1)
bar.BorderSizePixel = 0
bar.ZIndex = 3
bar.Parent = track

local glow = Instance.new("UIStroke")
glow.Color = Color3.new(1, 1, 1)
glow.Thickness = 2
glow.Transparency = 0.6
glow.Parent = bar

-- Logica promptului
local current = nil
local holdStart = nil

local function keyText(prompt)
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "TAP"
	end
	local name = prompt.KeyboardKeyCode.Name
	return #name <= 3 and name or name:sub(1, 3)
end

local function setProgress(alpha)
	bar.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
end

local function show(prompt)
	current = prompt
	holdStart = nil
	keyLabel.Text = keyText(prompt)
	nameLabel.Text = prompt.ObjectText
	actionLabel.Text = prompt.ActionText
	nameLabel.Visible = prompt.ObjectText ~= ""
	setProgress(0)
	gui.Enabled = true
end

local function hide(prompt)
	if prompt ~= current then
		return
	end
	current = nil
	holdStart = nil
	gui.Enabled = false
end

ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.Style == Enum.ProximityPromptStyle.Custom then
		show(prompt)
	end
end)

ProximityPromptService.PromptHidden:Connect(hide)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	if prompt == current then
		holdStart = os.clock()
	end
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
	if prompt == current then
		holdStart = nil
		setProgress(0)
	end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	if prompt == current then
		setProgress(1)
	end
end)

RunService.RenderStepped:Connect(function()
	if current and holdStart and current.HoldDuration > 0 then
		setProgress((os.clock() - holdStart) / current.HoldDuration)
	end
end)

-- pe telefon: apăsarea pe card ține promptul
card.InputBegan:Connect(function(input)
	if current and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		current:InputHoldBegin()
	end
end)

card.InputEnded:Connect(function(input)
	if current and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		current:InputHoldEnd()
	end
end)

if FORCE_CUSTOM_STYLE then
	local function apply(object)
		if object:IsA("ProximityPrompt") then
			object.Style = Enum.ProximityPromptStyle.Custom
		end
	end
	for _, object in workspace:GetDescendants() do
		apply(object)
	end
	workspace.DescendantAdded:Connect(apply)
end
