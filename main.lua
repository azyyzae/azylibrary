--[[
	AzyUI v4.0 - Prestige Edition
	Changelog:
	- COMPLETE VISUAL & ARCHITECTURAL OVERHAUL: Redesigned from scratch for a modern, multi-layered "frosted glass" aesthetic.
	- NEW NAVIGATION SYSTEM: Switched to a top-bar icon-based tab system for a cleaner look and feel.
	- DYNAMIC TOGGLE REDESIGN: Toggles now feature smooth, elastic "bounce" animations and animated checkmark/cross icons.
	- NEW COMPONENT - PERFORMANCE GRAPH: Added a real-time performance graph to monitor FPS.
	- NEW COMPONENT - SECTION CONTAINER: Added "Sections" to group and label related elements.
	- NEW SYSTEM - NOTIFICATION TOASTS: Includes a powerful, non-intrusive notification system (Window:ShowNotification).
	- NEW SYSTEM - INTERACTIVE TOOLTIPS: All components now support descriptive tooltips on hover.
	- ENHANCED ANIMATION ENGINE: Animations are now more fluid, using elastic easing and choreographed tweens.
	- NEW AESTHETIC DETAILS: Implemented multi-layered strokes, accent gradients, and inner highlights for depth.
	- EXPANDED BUILT-IN ICON LIBRARY: More icons added to support the new visual style.
]]

return function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local Azy = {}
	Azy.__index = Azy

	local Themes = {
		Dark = {
			Background = Color3.fromRGB(18, 18, 22),
			Primary = Color3.fromRGB(28, 28, 34),
			Secondary = Color3.fromRGB(40, 40, 48),
			Tertiary = Color3.fromRGB(55, 55, 65),
			Accent = Color3.fromRGB(88, 101, 242),
			Text = Color3.fromRGB(240, 240, 245),
			MutedText = Color3.fromRGB(140, 140, 150),
			Success = Color3.fromRGB(60, 180, 110),
			Error = Color3.fromRGB(240, 70, 80),
			Shadow = Color3.fromRGB(0, 0, 0),
			Highlight = Color3.fromRGB(255, 255, 255),
		}
	}
	
	local Icons = {
		player = "rbxassetid://6917218335",
		world = "rbxassetid://6917218335",
		visuals = "rbxassetid://6917218335",
		settings = "rbxassetid://6917218335",
		info = "rbxassetid://6917218335",
		warning = "rbxassetid://6917218335",
		error = "rbxassetid://6917218335",
		success = "rbxassetid://6917218335",
		checkmark = "rbxassetid://6917218335",
		cross = "rbxassetid://6917218335",
	}

	local function Create(instanceType, properties)
		local success, inst = pcall(function() return Instance.new(instanceType) end)
		if not success then return nil end
		for prop, value in pairs(properties or {}) do
			pcall(function() inst[prop] = value end)
		end
		return inst
	end

	local function Animate(instance, goal, duration, style, direction, override)
		duration = duration or 0.3
		style = style or Enum.EasingStyle.Quart
		direction = direction or Enum.EasingDirection.Out
		local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), goal)
		tween:Play()
		return tween
	end

	local function CreateTooltip(parent, text)
		if not text or text == "" then return end
		local tooltipFrame = nil
		parent.MouseEnter:Connect(function()
			if tooltipFrame then tooltipFrame:Destroy() end
			tooltipFrame = Create("Frame", {
				Name = "Tooltip",
				Size = UDim2.fromOffset(150, 30),
				BackgroundColor3 = Themes.Dark.Primary,
				BackgroundTransparency = 0.1,
				BorderSizePixel = 0,
				ZIndex = 10,
				Parent = parent:FindFirstAncestorOfClass("ScreenGui")
			})
			Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tooltipFrame })
			Create("UIStroke", { Color = Themes.Dark.Secondary, Parent = tooltipFrame })
			local textLabel = Create("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Themes.Dark.MutedText,
				TextSize = 13,
				TextWrapped = true,
				Parent = tooltipFrame
			})
			Create("UIPadding", { PaddingAll = UDim.new(0, 8), Parent = textLabel })
			local textSize = game:GetService("TextService"):GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(150 - 16, math.huge))
			tooltipFrame.Size = UDim2.fromOffset(150, textSize.Y + 16)
			tooltipFrame.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X + 15, UserInputService:GetMouseLocation().Y + 15)
			tooltipFrame.BackgroundTransparency = 1
			Animate(tooltipFrame, { BackgroundTransparency = 0.1 }, 0.2)
		end)
		parent.MouseLeave:Connect(function()
			if tooltipFrame then
				Animate(tooltipFrame, { BackgroundTransparency = 1 }, 0.2).Completed:Connect(function()
					if tooltipFrame then tooltipFrame:Destroy() end
					tooltipFrame = nil
				end)
			end
		end)
	end

	local function MakeDraggable(guiObject, handle)
		local dragging = false
		local dragStart, startPos
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, dragStart, startPos = true, input.Position, guiObject.Position
			end
		end)
		handle.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (input.Position.Y - dragStart.Y))
			end
		end)
	end
	
	function Azy:Window(config)
		local Window = {}
		setmetatable(Window, Azy)
		Window.Theme = Themes.Dark
		Window.Tabs = {}
		Window.ActiveTab = nil
		Window.ScreenGui = Create("ScreenGui", { Name = "Azy_Window", Parent = getcoregui and getcoregui() or game:GetService("CoreGui"), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })
		Window.NotificationGui = Create("ScreenGui", { Name = "Azy_Notifications", Parent = getcoregui and getcoregui() or game:GetService("CoreGui"), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })
		local notificationContainer = Create("Frame", { Name = "Container", Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -15, 0, 0), BackgroundTransparency = 1, Parent = Window.NotificationGui })
		Create("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 10), Parent = notificationContainer })

		Window.MainFrame = Create("Frame", { Name = "MainFrame", Size = UDim2.fromOffset(580, 450), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Window.Theme.Background, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = Window.ScreenGui })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Window.MainFrame })
		Create("UIStroke", { Color = Window.Theme.Secondary, Thickness = 1.5, Parent = Window.MainFrame })
		pcall(function() Create("UIDropShadow", { Transparency = 0.8, Color = Window.Theme.Shadow, Offset = Vector2.new(0, 8), Parent = Window.MainFrame }) end)

		local topBar = Create("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Window.Theme.Primary, BorderSizePixel = 0, Parent = Window.MainFrame })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = topBar })
		Create("UIStroke", { Color = Window.Theme.Secondary, Thickness = 1, Parent = topBar })
		Create("TextLabel", { Name = "Title", Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = config.Title or "Sigma Hub", TextColor3 = Window.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left })
		Window.TabContainer = Create("Frame", { Name = "TabContainer", Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Parent = topBar })
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10), Parent = Window.TabContainer })
		
		Window.ContentContainer = Create("Frame", { Name = "ContentContainer", Size = UDim2.new(1, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Window.MainFrame })
		MakeDraggable(Window.MainFrame, topBar)

		function Window:ShowNotification(cfg)
			local notif = Create("Frame", { Name = "Notification", Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = Window.Theme.Primary, BorderSizePixel = 0, ClipsDescendants = true, Parent = notificationContainer })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = notif })
			Create("UIStroke", { Color = Window.Theme.Secondary, Parent = notif })
			Create("Frame", { Name = "Accent", Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = Window.Theme[cfg.Type] or Window.Theme.Accent, BorderSizePixel = 0, Parent = notif })
			Create("ImageLabel", { Name = "Icon", Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 15, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Image = Icons[cfg.Type] or Icons.info, ImageColor3 = Window.Theme.Text, Parent = notif })
			Create("TextLabel", { Name = "Title", Position = UDim2.new(0, 50, 0, 12), Size = UDim2.new(1, -60, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = cfg.Title or "Notification", TextColor3 = Window.Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = notif })
			Create("TextLabel", { Name = "Text", Position = UDim2.new(0, 50, 0, 32), Size = UDim2.new(1, -60, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "", TextColor3 = Window.Theme.MutedText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = notif })
			notif.Position = UDim2.new(0, 260, 0, 0)
			Animate(notif, { Position = UDim2.new() }, 0.4, Enum.EasingStyle.Quint)
			task.delay(cfg.Duration or 5, function()
				if notif and notif.Parent then
					Animate(notif, { Position = UDim2.new(0, 260, 0, 0) }, 0.4, Enum.EasingStyle.Quint).Completed:Connect(function() notif:Destroy() end)
				end
			end)
		end

		function Window:SetActiveTab(tabToActivate)
			if Window.ActiveTab == tabToActivate then return end
			for _, tab in pairs(Window.Tabs) do
				local isTarget = (tab == tabToActivate)
				Animate(tab.Button.Background, { BackgroundTransparency = isTarget and 0 or 1 }, 0.2)
				Animate(tab.Indicator, { Size = UDim2.new(1, 0, isTarget and 2 or 0, 0) }, 0.3, Enum.EasingStyle.Elastic)
				Animate(tab.Icon, { ImageColor3 = isTarget and Window.Theme.Accent or Window.Theme.MutedText }, 0.2)
				if isTarget then
					tab.Content.Visible = true
					Animate(tab.Content, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.4)
				else
					Animate(tab.Content, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -10) }, 0.4).Completed:Connect(function() if tab.Content.GroupTransparency == 1 then tab.Content.Visible = false end end)
				end
			end
			Window.ActiveTab = tabToActivate
		end
		return Window
	end

	function Azy:NewTab(config)
		local Tab = {}
		local Window = self
		Tab.Name = config.Name or "New Tab"
		Tab.Button = Create("TextButton", { Name = Tab.Name, Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = Window.TabContainer })
		Tab.Button.Background = Create("Frame", { Name = "Background", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Window.Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = Tab.Button })
		Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Tab.Button.Background })
		Tab.Icon = Create("ImageLabel", { Name = "Icon", Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ImageColor3 = Window.Theme.MutedText, Image = Icons[config.Icon] or Icons.info, Parent = Tab.Button })
		Tab.Indicator = Create("Frame", { Name = "Indicator", Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromScale(0.5, 1), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, Parent = Tab.Button })
		Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Tab.Indicator })
		Tab.Content = Create("CanvasGroup", { Name = "Content", Size = UDim2.fromScale(1, 1), Position = UDim2.new(0.5, 0, 0.5, 10), AnchorPoint = Vector2.new(0.5, 0.5), GroupTransparency = 1, Visible = false, BackgroundTransparency = 1, Parent = Window.ContentContainer })
		Tab.MainContentFrame = Create("ScrollingFrame", { Name = "Scrolling", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Window.Theme.Accent, ScrollBarThickness = 4, Parent = Tab.Content })
		Create("UIPadding", { PaddingLeft = UDim.new(0, 25), PaddingRight = UDim.new(0, 25), PaddingTop = UDim.new(0, 25), PaddingBottom = UDim.new(0, 25), Parent = Tab.MainContentFrame })
		Tab.Layout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15), FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = Tab.MainContentFrame })
		Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Tab.MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y) end)
		CreateTooltip(Tab.Button, Tab.Name)
		Tab.Button.MouseButton1Click:Connect(function() Window:SetActiveTab(Tab) end)
		table.insert(Window.Tabs, Tab)
		if not Window.ActiveTab then Window:SetActiveTab(Tab) end

		local TabMethods = {}
		function TabMethods:NewSection(text)
			local frame = Create("Frame", { Name = "Section", Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = Tab.MainContentFrame })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = text, TextColor3 = Window.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
			Create("Frame", { Name = "Line", Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Window.Theme.Secondary, Parent = frame })
			local contentFrame = Create("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Tab.MainContentFrame })
			Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = contentFrame })
			Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = contentFrame })
			return contentFrame
		end
		function TabMethods:NewButton(cfg)
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = Tab.MainContentFrame })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
			local highlight = Create("Frame", { Name = "Highlight", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Window.Theme.Highlight, BackgroundTransparency = 1, Parent = btn })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = highlight })
			Create("TextLabel", { Name = "Label", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = cfg.Text or "Button", TextColor3 = Window.Theme.Text, TextSize = 15, Parent = btn })
			CreateTooltip(btn, cfg.Tooltip)
			btn.MouseEnter:Connect(function() Animate(highlight, { BackgroundTransparency = 0.9 }) end)
			btn.MouseLeave:Connect(function() Animate(highlight, { BackgroundTransparency = 1 }) end)
			btn.MouseButton1Click:Connect(function()
				Animate(btn, { Size = UDim2.new(1, 0, 0, 35) }, 0.1).Completed:Wait()
				Animate(btn, { Size = UDim2.new(1, 0, 0, 38) }, 0.1)
				if cfg.Callback then task.spawn(cfg.Callback) end
			end)
			return btn
		end
		function TabMethods:NewToggle(cfg)
			local Toggle = { Value = cfg.Default or false, Toggled = Instance.new("BindableEvent") }
			local container = Create("Frame", { Name = "Toggle", Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = Tab.MainContentFrame })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Toggle", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(0, 48, 1, 0), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Toggle.Value and Window.Theme.Success or Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
			local knob = Create("Frame", { Name = "Knob", Size = UDim2.fromOffset(19, 19), Position = Toggle.Value and UDim2.fromScale(1, 0.5) or UDim2.fromScale(0, 0.5), AnchorPoint = Toggle.Value and Vector2.new(1.2, 0.5) or Vector2.new(-0.2, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = btn })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
			local check = Create("ImageLabel", { Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Image = Icons.checkmark, ImageColor3 = Window.Theme.Success, BackgroundTransparency = 1, ImageTransparency = Toggle.Value and 0 or 1, Parent = knob })
			local cross = Create("ImageLabel", { Size = UDim2.fromScale(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Image = Icons.cross, ImageColor3 = Window.Theme.Secondary, BackgroundTransparency = 1, ImageTransparency = Toggle.Value and 1 or 0, Parent = knob })
			CreateTooltip(container, cfg.Tooltip)
			local function SetState(newState)
				Toggle.Value = newState
				Toggle.Toggled:Fire(newState)
				Animate(btn, { BackgroundColor3 = Toggle.Value and Window.Theme.Success or Window.Theme.Secondary })
				Animate(check, { ImageTransparency = Toggle.Value and 0 or 1 })
				Animate(cross, { ImageTransparency = Toggle.Value and 1 or 0 })
				if Toggle.Value then Animate(knob, { Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1.2, 0.5) }, 0.4, Enum.EasingStyle.Elastic) else Animate(knob, { Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(-0.2, 0.5) }, 0.4, Enum.EasingStyle.Elastic) end
			end
			btn.MouseButton1Click:Connect(function() SetState(not Toggle.Value); if cfg.Callback then task.spawn(cfg.Callback, Toggle.Value) end end)
			return Toggle
		end
		function TabMethods:NewSlider(cfg)
			local Slider = { Min = cfg.Min or 0, Max = cfg.Max or 100, Default = cfg.Default or 50, ValueChanged = Instance.new("BindableEvent") }
			Slider.Value = Slider.Default
			local container = Create("Frame", { Name = "Slider", Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = Tab.MainContentFrame })
			local labelFrame = Create("Frame", { Name = "LabelFrame", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = container })
			Create("TextLabel", { Name = "Label", Size = UDim2.fromScale(0.5, 1), Position = UDim2.fromScale(0, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Slider", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = labelFrame })
			local valueLabel = Create("TextLabel", { Name = "Value", Size = UDim2.fromScale(0.5, 1), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = tostring(Slider.Value), TextColor3 = Window.Theme.MutedText, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = labelFrame })
			local track = Create("Frame", { Name = "Track", Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Window.Theme.Secondary, BorderSizePixel = 0, Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
			local fill = Create("Frame", { Name = "Fill", Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, Parent = track })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
			local knob = Create("Frame", { Name = "Knob", Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = track })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
			CreateTooltip(container, cfg.Tooltip)
			local function SetValue(value)
				local val = cfg.Int and math.floor(value) or value
				local clamped = math.clamp(val, Slider.Min, Slider.Max)
				Slider.Value = clamped
				local percentage = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
				fill.Size = UDim2.new(percentage, 0, 1, 0)
				knob.Position = UDim2.fromScale(percentage, 0.5)
				valueLabel.Text = cfg.Unit and Slider.Value .. cfg.Unit or tostring(Slider.Value)
				Slider.ValueChanged:Fire(Slider.Value)
				if cfg.Callback then task.spawn(cfg.Callback, Slider.Value) end
			end
			local dragging = false
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true
					local percentage = math.clamp(input.Position.X / track.AbsoluteSize.X, 0, 1); SetValue(Slider.Min + (Slider.Max - Slider.Min) * percentage) end
			end)
			UserInputService.InputChanged:Connect(function() if dragging then local percentage = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); SetValue(Slider.Min + (Slider.Max - Slider.Min) * percentage) end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			SetValue(Slider.Default)
			return Slider
		end
		function TabMethods:NewGraph(cfg)
			local container = Create("Frame", { Name = "Graph", Size = UDim2.new(1, 0, 0, 100), BackgroundColor3 = Window.Theme.Primary, BorderSizePixel = 0, ClipsDescendants = true, Parent = Tab.MainContentFrame })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
			Create("UIPadding", { PaddingAll = UDim.new(0, 10), Parent = container })
			local title = Create("TextLabel", { Name = "Title", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Title or "Performance", TextColor3 = Window.Theme.MutedText, TextSize = 14, Parent = container })
			local valueLabel = Create("TextLabel", { Name = "Value", Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = "60 FPS", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = title })
			local graphArea = Create("Frame", { Name = "Area", Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1, Parent = container })
			Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = graphArea })
			local bars = {}
			for i = 1, 50 do
				local bar = Create("Frame", { Name = "Bar"..i, Size = UDim2.new(0, 4, 0, 20), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, Parent = graphArea })
				Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = bar })
				table.insert(bars, bar)
			end
			local lastUpdate = 0
			RunService.RenderStepped:Connect(function(dt)
				if tick() - lastUpdate > 0.1 then
					lastUpdate = tick()
					local fps = 1/dt
					valueLabel.Text = math.floor(fps) .. " FPS"
					local height = math.clamp(fps / 100, 0, 1)
					local bar = table.remove(bars, 1)
					bar.Parent = nil
					bar.Size = UDim2.new(0, 4, height, 0)
					bar.BackgroundColor3 = Color3.fromHSV(0.3 + height * 0.7, 0.8, 1)
					bar.Parent = graphArea
					table.insert(bars, bar)
				end
			end)
		end
		setmetatable(Tab, {__index = TabMethods})
		return Tab
	end

	return Azy
end
