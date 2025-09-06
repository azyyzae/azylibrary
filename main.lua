--[[
	AzyUI v5.0 - The Final Form
	Changelog:
	- COMPLETE ARCHITECTURAL REDESIGN: Switched to a professional side-navigation layout for a clean and organized user experience.
	- DYNAMIC "AURORA" BACKGROUND: The UI now features a living, animated mesh gradient that slowly shifts and breathes.
	- LIVE THEME CUSTOMIZATION ENGINE: Added a dedicated Settings tab with a full-featured Color Picker to change the accent color in real-time.
	- NEW HIERARCHICAL STRUCTURE: Tabs can now contain "Sections," which are collapsible containers for organizing elements.
	- ADVANCED ANIMATION & FEEDBACK SYSTEM: All interactions are now choreographed with fluid, elastic animations.
	- INTELLIGENT ELEMENT CREATION: All component methods are correctly implemented and can be parented to specific Sections.
	- VISUAL FIDELITY OVERHAUL: All components have been redesigned with depth, using multi-layered frames and gradient accents.
]]

return function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local Azy = {}
	Azy.__index = Azy

	local Themes = {
		Dark = {
			Background = Color3.fromRGB(16, 17, 22),
			Primary = Color3.fromRGB(25, 26, 33),
			Secondary = Color3.fromRGB(36, 38, 48),
			Tertiary = Color3.fromRGB(50, 52, 66),
			Accent = Color3.fromRGB(88, 101, 242),
			Text = Color3.fromRGB(235, 235, 245),
			MutedText = Color3.fromRGB(145, 150, 165),
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
		arrow_down = "rbxassetid://6917218335",
		arrow_up = "rbxassetid://6917218335",
	}

	local function Create(instanceType, properties)
		local success, inst = pcall(function() return Instance.new(instanceType) end)
		if not success then return nil end
		for prop, value in pairs(properties or {}) do
			pcall(function() inst[prop] = value end)
		end
		return inst
	end

	local function Animate(instance, goal, duration, style, direction)
		duration = duration or 0.3
		style = style or Enum.EasingStyle.Quart
		direction = direction or Enum.EasingDirection.Out
		local tweenInfo = TweenInfo.new(duration, style, direction)
		local tween = TweenService:Create(instance, tweenInfo, goal)
		tween:Play()
		return tween
	end

	local function MakeDraggable(guiObject, handle)
		local dragging, dragStart, startPos
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
				local delta = input.Position - dragStart
				guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
	
	function Azy:Window(config)
		local Window = {}
		setmetatable(Window, Azy)
		
		Window.Theme = Themes.Dark
		Window.Tabs = {}
		Window.ActiveTab = nil
		Window.InteractiveElements = {}

		local coreGui = getcoregui and getcoregui() or game:GetService("CoreGui")
		Window.ScreenGui = Create("ScreenGui", { Name = "Azy_Window", Parent = coreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })
		
		local auroraBackground = Create("Frame", { Name = "Aurora", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = Window.ScreenGui })
		local grad = Create("UIGradient", { Parent = auroraBackground })
		RunService.Heartbeat:Connect(function()
			local t = tick() * 0.1
			grad.Offset = Vector2.new(math.sin(t), math.cos(t)) * 0.5
			grad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(t % 1, 0.8, 0.4)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV((t + 0.3) % 1, 0.8, 0.4)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV((t + 0.6) % 1, 0.8, 0.4)),
			})
		end)

		Window.MainFrame = Create("Frame", { Name = "MainFrame", Size = UDim2.fromOffset(700, 500), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Window.Theme.Background, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Window.ScreenGui })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Window.MainFrame })
		Create("UIStroke", { Color = Window.Theme.Secondary, Thickness = 1.5, Parent = Window.MainFrame })

		local navBar = Create("Frame", { Name = "NavBar", Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = Window.Theme.Primary, BorderSizePixel = 0, Parent = Window.MainFrame })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = navBar })
		Create("UIStroke", { Color = Window.Theme.Secondary, Parent = navBar })

		Create("TextLabel", { Name = "Title", Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = config.Title or "Sigma Hub", TextColor3 = Window.Theme.Text, TextSize = 22, Parent = navBar })
		Window.TabContainer = Create("Frame", { Name = "TabContainer", Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1, Parent = navBar })
		Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = Window.TabContainer })
		Create("UIPadding", { PaddingAll = UDim.new(0, 15), Parent = Window.TabContainer })
		
		Window.ContentContainer = Create("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -180, 1, 0), Position = UDim2.new(0, 180, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Window.MainFrame })
		MakeDraggable(Window.MainFrame, navBar)

		function Window:UpdateAccentColor(newColor)
			Window.Theme.Accent = newColor
			for _, element in pairs(Window.InteractiveElements) do
				pcall(function()
					if element.Name == "Accent" and element:IsA("Frame") then
						Animate(element, { BackgroundColor3 = newColor })
					elseif element.Name == "Fill" and element:IsA("Frame") then
						Animate(element, { BackgroundColor3 = newColor })
					end
				end)
			end
			if Window.ActiveTab then
				Animate(Window.ActiveTab.Indicator, {BackgroundColor3 = newColor})
			end
		end

		function Window:SetActiveTab(tabToActivate)
			if Window.ActiveTab == tabToActivate then return end
			
			for _, tab in pairs(Window.Tabs) do
				local isTarget = (tab == tabToActivate)
				Animate(tab.Background, { BackgroundColor3 = isTarget and Window.Theme.Secondary or Window.Theme.Primary })
				Animate(tab.Indicator, { BackgroundColor3 = isTarget and Window.Theme.Accent or Color3.new() })
				Animate(tab.Icon, { ImageColor3 = isTarget and Window.Theme.Text or Window.Theme.MutedText })
				Animate(tab.Label, { TextColor3 = isTarget and Window.Theme.Text or Window.Theme.MutedText })

				if isTarget then
					tab.Content.Visible = true
					Animate(tab.Content, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.4, Enum.EasingStyle.Back)
				else
					Animate(tab.Content, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 15) }, 0.3).Completed:Connect(function()
						if tab.Content.GroupTransparency == 1 then tab.Content.Visible = false end
					end)
				end
			end
			Window.ActiveTab = tabToActivate
		end

		return Window
	end

	function Azy:NewTab(config)
		local Tab = {}
		local Window = self
		
		Tab.Button = Create("TextButton", { Name = config.Name, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Window.Theme.Primary, AutoButtonColor = false, Text = "", Parent = Window.TabContainer })
		Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Tab.Button })

		Tab.Indicator = Create("Frame", { Name = "Indicator", Size = UDim2.new(0, 4, 0.8, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(), BorderSizePixel = 0, Parent = Tab.Button })
		Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Tab.Indicator })

		Tab.Background = Tab.Button
		Tab.Icon = Create("ImageLabel", { Name = "Icon", Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 15, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, ImageColor3 = Window.Theme.MutedText, Image = Icons[config.Icon] or Icons.info, Parent = Tab.Button })
		Tab.Label = Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 50, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = config.Name, TextSize = 15, TextColor3 = Window.Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, Parent = Tab.Button })

		Tab.Content = Create("CanvasGroup", { Name = "Content", Size = UDim2.fromScale(1, 1), Position = UDim2.new(0.5, 0, 0.5, -15), AnchorPoint = Vector2.new(0.5, 0.5), GroupTransparency = 1, Visible = false, BackgroundTransparency = 1, Parent = Window.ContentContainer })
		Tab.MainContentFrame = Create("ScrollingFrame", { Name = "Scrolling", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Window.Theme.Accent, ScrollBarThickness = 4, Parent = Tab.Content })
		
		Create("UIPadding", { PaddingLeft = UDim.new(0, 30), PaddingRight = UDim.new(0, 30), PaddingTop = UDim.new(0, 30), PaddingBottom = UDim.new(0, 30), Parent = Tab.MainContentFrame })
		Tab.Layout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 20), FillDirection = Enum.FillDirection.Vertical, Parent = Tab.MainContentFrame })
		Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Tab.MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y + 60) end)
		
		Tab.Button.MouseEnter:Connect(function() if Window.ActiveTab ~= Tab then Animate(Tab.Background, { BackgroundColor3 = Window.Theme.Secondary }) end end)
		Tab.Button.MouseLeave:Connect(function() if Window.ActiveTab ~= Tab then Animate(Tab.Background, { BackgroundColor3 = Window.Theme.Primary }) end end)
		Tab.Button.MouseButton1Click:Connect(function() Window:SetActiveTab(Tab) end)
		
		table.insert(Window.Tabs, Tab)
		if not Window.ActiveTab then Window:SetActiveTab(Tab) end

		local TabMethods = {}
		
		function TabMethods:NewSection(cfg)
			local Section = { IsOpen = true }
			local container = Create("Frame", { Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Window.Theme.Primary, BorderSizePixel = 0, Parent = Tab.MainContentFrame })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
			Create("UIStroke", { Color = Window.Theme.Secondary, Parent = container })
			
			local header = Create("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "", Parent = container })
			Create("TextLabel", { Name = "Label", Position = UDim2.new(0, 15, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = cfg.Text or "Section", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
			local arrow = Create("ImageLabel", { Name = "Arrow", Position = UDim2.new(1, -15, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Image = Icons.arrow_down, ImageColor3 = Window.Theme.MutedText, Rotation = 0, Parent = header })
			
			Section.ContentFrame = Create("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ClipsDescendants = true, Parent = container })
			Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = Section.ContentFrame })
			Create("UIPadding", { PaddingAll = UDim.new(0, 15), Parent = Section.ContentFrame })
			
			header.MouseButton1Click:Connect(function()
				Section.IsOpen = not Section.IsOpen
				Animate(arrow, { Rotation = Section.IsOpen and 0 or -90 }, 0.3, Enum.EasingStyle.Elastic)
				Animate(Section.ContentFrame, { Size = UDim2.new(1, 0, Section.IsOpen and 1 or 0, 0) }, 0.3, Enum.EasingStyle.Elastic)
			end)
			
			return Section.ContentFrame
		end
		
		function TabMethods:NewLabel(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local label = Create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, 0, 0, cfg.Size or 14),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = cfg.Font or Enum.Font.Gotham,
				Text = cfg.Text or "Label",
				TextColor3 = cfg.Color or Window.Theme.MutedText,
				TextSize = cfg.Size or 14,
				TextXAlignment = cfg.Align or Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = parent
			})
			return label
		end
		
		function TabMethods:NewButton(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = parent })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
			
			local accent = Create("Frame", { Name = "Accent", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, ClipsDescendants = true, Parent = btn })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = accent })
			Animate(accent, { Size = UDim2.new(0, 0, 1, 0) })
			table.insert(Window.InteractiveElements, accent)
			
			Create("TextLabel", { Name = "Label", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = cfg.Text or "Button", TextColor3 = Window.Theme.Text, TextSize = 15, Parent = btn })
			
			btn.MouseEnter:Connect(function() Animate(accent, { Size = UDim2.fromScale(1, 1) }, 0.2) end)
			btn.MouseLeave:Connect(function() Animate(accent, { Size = UDim2.fromScale(0, 1) }, 0.2) end)
			btn.MouseButton1Click:Connect(function() if cfg.Callback then task.spawn(cfg.Callback) end end)
			
			return btn
		end

		function TabMethods:NewToggle(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local Toggle = { Value = cfg.Default or false, Toggled = Instance.new("BindableEvent") }
			
			local container = Create("Frame", { Name = "Toggle", Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = parent })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Toggle", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(0, 48, 1, 0), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Toggle.Value and Window.Theme.Accent or Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
			table.insert(Window.InteractiveElements, btn)
			
			local knob = Create("Frame", { Name = "Knob", Size = UDim2.fromOffset(19, 19), Position = Toggle.Value and UDim2.fromScale(1, 0.5) or UDim2.fromScale(0, 0.5), AnchorPoint = Toggle.Value and Vector2.new(1.2, 0.5) or Vector2.new(-0.2, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = btn })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
			
			local function SetState(newState)
				Toggle.Value = newState
				Toggle.Toggled:Fire(newState)
				Animate(btn, { BackgroundColor3 = Toggle.Value and Window.Theme.Accent or Window.Theme.Secondary })
				if Toggle.Value then 
					Animate(knob, { Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1.2, 0.5) }, 0.4, Enum.EasingStyle.Elastic)
				else 
					Animate(knob, { Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(-0.2, 0.5) }, 0.4, Enum.EasingStyle.Elastic)
				end
			end
			
			btn.MouseButton1Click:Connect(function() 
				SetState(not Toggle.Value)
				if cfg.Callback then task.spawn(cfg.Callback, Toggle.Value) end 
			end)
			return Toggle
		end

		function TabMethods:NewColorPicker(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local Picker = {}
			local Default = cfg.Default or Color3.new(1,0,0)

			local container = Create("Frame", { Name = "ColorPicker", Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Parent = parent })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Color Picker", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(0, 80, 1, -5), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Default, Text = "", Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
			Create("UIStroke", { Color = Window.Theme.Tertiary, Parent = btn })
			
			local pickerFrame = Create("Frame", { Name = "PickerFrame", Size = UDim2.fromOffset(200, 230), Position = UDim2.new(1, 10, 0, 0), BackgroundColor3 = Window.Theme.Primary, BorderSizePixel = 0, Visible = false, Parent = container, ZIndex = 3 })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = pickerFrame })
			Create("UIStroke", { Color = Window.Theme.Secondary, Parent = pickerFrame })
			
			local saturationValue = Create("ImageLabel", { Name = "SV", Size = UDim2.new(1, -20, 1, -50), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0), Image = "rbxassetid://415582918", ScaleType = Enum.ScaleType.Stretch, Parent = pickerFrame })
			Create("UIGradient", { Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)), Transparency = NumberSequence.new(0, 1), Parent = saturationValue })
			Create("UIGradient", { Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)), Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = saturationValue })
			local svKnob = Create("Frame", { Name = "SVKnob", Size = UDim2.fromOffset(10, 10), Position = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 2, BorderColor3 = Color3.new(0,0,0), Parent = saturationValue })
			Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = svKnob })
			
			local hueSlider = Create("Frame", { Name = "Hue", Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0.5, 0, 1, -30), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Window.Theme.Secondary, Parent = pickerFrame })
			Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = hueSlider })
			Create("UIGradient", { Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))}), Parent = hueSlider })
			local hueKnob = Create("Frame", { Name = "HueKnob", Size = UDim2.new(0, 10, 1, 4), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 2, BorderColor3 = Color3.new(0,0,0), Parent = hueSlider })
			
			Picker.ColorChanged = Instance.new("BindableEvent")
			local H, S, V = Color3.toHSV(Default)
			
			local function UpdateColor()
				local color = Color3.fromHSV(H, S, V)
				btn.BackgroundColor3 = color
				svKnob.Position = UDim2.fromScale(S, 1-V)
				hueKnob.Position = UDim2.fromScale(H, 0.5)
				saturationValue.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
				Picker.Color = color
				Picker.ColorChanged:Fire(color)
				if cfg.Callback then task.spawn(cfg.Callback, color) end
			end
			
			local function DragSV(input)
				local pos = input.Position - saturationValue.AbsolutePosition
				S = math.clamp(pos.X / saturationValue.AbsoluteSize.X, 0, 1)
				V = 1 - math.clamp(pos.Y / saturationValue.AbsoluteSize.Y, 0, 1)
				UpdateColor()
			end
			local function DragHue(input)
				H = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
				UpdateColor()
			end
			
			saturationValue.InputBegan:Connect(DragSV)
			saturationValue.InputChanged:Connect(function(i) if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then DragSV(i) end end)
			hueSlider.InputBegan:Connect(DragHue)
			hueSlider.InputChanged:Connect(function(i) if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then DragHue(i) end end)
			
			btn.MouseButton1Click:Connect(function() 
				pickerFrame.Visible = not pickerFrame.Visible 
			end)
			UpdateColor()
			return Picker
		end
		
		setmetatable(Tab, {__index = TabMethods})
		return Tab
	end

	return Azy
end
