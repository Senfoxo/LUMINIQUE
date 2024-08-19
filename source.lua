local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local InputService = game:GetService('UserInputService')
local CoreGui = game:GetService('CoreGui')

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local protectgui = protectgui or (syn and syn.protect_gui) or (function() end)

local function CreateButton(parent)
	local button = Instance.new('TextButton')
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.TextTransparency = 1
	button.Text = ""
	button.Parent = parent
	button.ZIndex = 5000
	return button
end

local function ConnectButtonEffect(UIFrame, UIStroke, intensity)
	if not UIStroke then return end
	
	intensity = intensity or 0.2
	local originalColor = UIStroke.Color
	local hoverColor = Color3.fromHSV(originalColor:ToHSV() + Vector3.new(0, 0, intensity))
	
	UIFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(UIStroke, TweenInfo.new(0.2), {Color = hoverColor}):Play()
		end
	end)
	
	UIFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(UIStroke, TweenInfo.new(0.2), {Color = originalColor}):Play()
		end
	end)
end

local function AutoCanvasSize(scrollFrame)
	local layout = scrollFrame:WaitForChild('UIListLayout')
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end)
end

local function GetIcon(name, image)
	local assetId = "rbxassetid://3926305904"
	local iconData = {
		["ads"] = {Vector2.new(205, 565), Vector2.new(35, 35)},
		["list"] = {Vector2.new(485, 205), Vector2.new(35, 35)},
		["folder"] = {Vector2.new(805, 45), Vector2.new(35, 35)},
		["earth"] = {Vector2.new(604, 324), Vector2.new(35, 35)},
		["locked"] = {Vector2.new(524, 644), Vector2.new(35, 35)},
		["home"] = {Vector2.new(964, 205), Vector2.new(35, 35)},
		["mouse"] = {"rbxassetid://3515393063"},
		["user"] = {"rbxassetid://10494577250"}
	}
	local icon = iconData[name:lower()]
	if icon then
		image.Image = assetId
		image.ImageRectOffset = icon[1]
		image.ImageRectSize = icon[2]
	end
end

local NEVERLOSE = {
	Themes = {
		Background = Color3.fromRGB(40, 40, 40),
		Primary = Color3.fromRGB(0, 122, 204),
		Secondary = Color3.fromRGB(30, 30, 30),
		Tertiary = Color3.fromRGB(50, 50, 50),
		Highlight = Color3.fromRGB(70, 70, 70)
	},
	Version = "1.0",
	Name = "NEVERLOSE"
}

function NEVERLOSE:CreateWindow(name, customSize)
	local window = {}
	local screenGui = Instance.new("ScreenGui")
	local frame = Instance.new("Frame")
	local header = Instance.new("TextLabel")
	local tabContainer = Instance.new("Frame")
	local tabButtons = Instance.new("ScrollingFrame")
	local tabLayout = Instance.new("UIListLayout")

	screenGui.Parent = CoreGui
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	protectgui(screenGui)

	frame.Parent = screenGui
	frame.BackgroundColor3 = self.Themes.Background
	frame.BorderSizePixel = 0
	frame.Size = customSize or UDim2.new(0.25, 0, 0.35, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)

	header.Parent = frame
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0.15, 0)
	header.Font = Enum.Font.GothamBold
	header.Text = name or self.Name
	header.TextColor3 = self.Themes.Primary
	header.TextScaled = true

	tabContainer.Parent = frame
	tabContainer.Size = UDim2.new(1, 0, 0.85, 0)
	tabContainer.Position = UDim2.new(0, 0, 0.15, 0)
	tabContainer.BackgroundColor3 = self.Themes.Secondary

	tabButtons.Parent = tabContainer
	tabButtons.Size = UDim2.new(0.25, 0, 1, 0)
	tabButtons.BackgroundTransparency = 1
	tabButtons.ScrollBarThickness = 4
	tabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
	AutoCanvasSize(tabButtons)

	tabLayout.Parent = tabButtons
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	function window:AddTab(tabName, icon)
		local tab = {}
		local tabButton = Instance.new("TextButton")
		local tabContent = Instance.new("Frame")
		local tabList = Instance.new("UIListLayout")

		tabButton.Parent = tabButtons
		tabButton.BackgroundTransparency = 1
		tabButton.Size = UDim2.new(1, 0, 0, 40)
		tabButton.Text = tabName or "Tab"
		tabButton.Font = Enum.Font.GothamBold
		tabButton.TextColor3 = self.Themes.Primary
		tabButton.TextSize = 16

		tabContent.Parent = tabContainer
		tabContent.Visible = false
		tabContent.Size = UDim2.new(0.75, 0, 1, 0)
		tabContent.Position = UDim2.new(0.25, 0, 0, 0)
		tabContent.BackgroundTransparency = 1

		tabList.Parent = tabContent
		tabList.SortOrder = Enum.SortOrder.LayoutOrder
		tabList.Padding = UDim.new(0, 5)

		tabButton.MouseButton1Click:Connect(function()
			for _, sibling in ipairs(tabContainer:GetChildren()) do
				if sibling:IsA("Frame") then
					sibling.Visible = false
				end
			end
			tabContent.Visible = true
		end)

		function tab:AddSection(sectionName)
			local section = {}
			local sectionFrame = Instance.new("Frame")
			local sectionHeader = Instance.new("TextLabel")
			local sectionLayout = Instance.new("UIListLayout")

			sectionFrame.Parent = tabContent
			sectionFrame.Size = UDim2.new(1, 0, 0, 100)
			sectionFrame.BackgroundTransparency = 0.9
			sectionFrame.BackgroundColor3 = self.Themes.Tertiary
			sectionFrame.BorderSizePixel = 0

			sectionHeader.Parent = sectionFrame
			sectionHeader.Size = UDim2.new(1, -10, 0, 30)
			sectionHeader.Position = UDim2.new(0.5, 0, 0, 0)
			sectionHeader.AnchorPoint = Vector2.new(0.5, 0)
			sectionHeader.BackgroundTransparency = 1
			sectionHeader.Font = Enum.Font.GothamBold
			sectionHeader.Text = sectionName or "Section"
			sectionHeader.TextColor3 = self.Themes.Primary
			sectionHeader.TextSize = 18
			sectionHeader.TextXAlignment = Enum.TextXAlignment.Left

			sectionLayout.Parent = sectionFrame
			sectionLayout.Padding = UDim.new(0, 5)
			sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder

			function section:AddButton(buttonName, callback)
				local button = Instance.new("TextButton")
				button.Parent = sectionFrame
				button.BackgroundTransparency = 0.9
				button.Size = UDim2.new(1, -10, 0, 40)
				button.Font = Enum.Font.Gotham
				button.Text = buttonName or "Button"
				button.TextColor3 = self.Themes.Primary
				button.TextSize = 16
				button.MouseButton1Click:Connect(callback)
			end

			function section:AddToggle(toggleName, default, callback)
				local toggle = Instance.new("Frame")
				local label = Instance.new("TextLabel")
				local switch = Instance.new("Frame")
				local switchIndicator = Instance.new("Frame")

				toggle.Parent = sectionFrame
				toggle.Size = UDim2.new(1, -10, 0, 40)
				toggle.BackgroundTransparency = 0.9

				label.Parent = toggle
				label.Size = UDim2.new(0.8, 0, 1, 0)
				label.Font = Enum.Font.Gotham
				label.Text = toggleName or "Toggle"
				label.TextColor3 = self.Themes.Primary
				label.TextSize = 16
				label.TextXAlignment = Enum.TextXAlignment.Left

				switch.Parent = toggle
				switch.Size = UDim2.new(0.15, 0, 0.6, 0)
				switch.AnchorPoint = Vector2.new(1, 0.5)
				switch.Position = UDim2.new(0.95, 0, 0.5, 0)
				switch.BackgroundColor3 = self.Themes.Highlight
				switch.BackgroundTransparency = 0.9

				switchIndicator.Parent = switch
				switchIndicator.Size = UDim2.new(0.5, 0, 1, 0)
				switchIndicator.BackgroundColor3 = default and self.Themes.Primary or self.Themes.Tertiary
				switchIndicator.Position = default and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
				switchIndicator.AnchorPoint = Vector2.new(1, 0)

				CreateButton(toggle).MouseButton1Click:Connect(function()
					default = not default
					callback(default)
					TweenService:Create(switchIndicator, TweenInfo.new(0.3), {
						Position = default and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
						BackgroundColor3 = default and self.Themes.Primary or self.Themes.Tertiary
					}):Play()
				end)
			end

			return section
		end

		return tab
	end

	return window
end
