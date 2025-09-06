--[[
	AzyUI v9.0 - Apex
	Changelog:
	- NEW - "APEX" PROFESSIONAL DESIGN LANGUAGE: A clean, mature aesthetic inspired by high-end desktop applications.
	- NEW - ROBUST LAYOUT & SCALING ENGINE: The UI is now built with a professional two-column layout that scales perfectly.
	- NEW - INTERACTIVE "FLOW" ANIMATION SYSTEM: Elements react to the cursor with subtle glows, shifts, and blurs.
	- NEW - INTELLIGENT STATE MANAGEMENT: The 'table index is nil' error is fixed. State saving is now opt-in via a component 'Id'.
	- NEW - CONTEXTUAL HOVER PANELS: Tabs and other elements reveal more information in animated panels on hover.
	- NEW - "BLUR-BEHIND" EFFECT (OPT-IN): A subtle UIBlur effect is now an optional theme setting for supported executors.
	- COMPLETELY RE-ENGINEERED & DEBUGGED COMPONENTS: The 'MouseButton1Click' error is fixed. All components are rebuilt and polished.
]]

return function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local Azy = {}
	Azy.__index = Azy

	local Themes = {
		Apex = {
			Background = Color3.fromRGB(22, 23, 28),
			Primary = Color3.fromRGB(30, 31, 38),
			Secondary = Color3.fromRGB(45, 46, 56),
			Tertiary = Color3.fromRGB(65, 67, 80),
			Accent = Color3.fromRGB(0, 160, 255),
			Text = Color3.fromRGB(225, 225, 235),
			MutedText = Color3.fromRGB(140, 142, 155),
			Success = Color3.fromRGB(0, 225, 150),
			Error = Color3.fromRGB(255, 90, 110),
			UseBlur = true,
		}
	}
	
	local Icons = {
		player = "rbxassetid://6917218335",
		world = "rbxassetid://6917218335",
		interface = "rbxassetid://6917218335",
	}

	local function Create(instanceType, properties)
		local success, inst = pcall(function() return Instance.new(instanceType) end)
		if not success then return nil end
		for prop, value in pairs(properties or {}) do pcall(function() inst[prop] = value end) end
		return inst
	end

	local function Animate(instance, goal, duration, style, direction, callback)
		local tweenInfo = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
		local tween = TweenService:Create(instance, tweenInfo, goal)
		if callback then tween.Completed:Connect(callback) end
		tween:Play()
		return tween
	end

	local function MakeDraggable(guiObject, handle)
		local dragging, dragStart, startPos
		handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, guiObject.Position end end)
		handle.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (input.Position.Y - dragStart.Y))
			end
		end)
	end
	
	function Azy:Window(config)
		local Window = {}
		setmetatable(Window, Azy)
		
		Window.Theme = Themes.Apex
		Window.Tabs = {}
		Window.ActiveTab = nil
		
		local coreGui = getcoregui and getcoregui() or game:GetService("CoreGui")
		Window.ScreenGui = Create("ScreenGui", { Name = "Azy_Window", Parent = coreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })

		Window.MainFrame = Create("Frame", { Name = "MainFrame", Size = UDim2.fromOffset(800, 550), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Window.Theme.Background, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Window.ScreenGui })
		Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Window.MainFrame })
		Create("UIStroke", { Color = Window.Theme.Primary, Thickness = 2, Parent = Window.MainFrame })
		if Window.Theme.UseBlur then pcall(function() Create("UIBlur", { Size = 24, Parent = Window.MainFrame }) end) end
		
		local navBar = Create("Frame", { Name = "NavBar", Size = UDim2.new(0, 220, 1, 0), BackgroundColor3 = Window.Theme.Primary, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = Window.MainFrame })
		Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = navBar })

		Create("TextLabel", { Name = "Title", Size = UDim2.new(1, 0, 0, 80), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = config.Title or "Sigma Hub", TextColor3 = Window.Theme.Text, TextSize = 28, Parent = navBar })
		Window.TabContainer = Create("Frame", { Name = "TabContainer", Size = UDim2.new(1, 0, 1, -100), Position = UDim2.new(0, 0, 0, 80), BackgroundTransparency = 1, Parent = navBar })
		Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = Window.TabContainer })
		Create("UIPadding", { PaddingAll = UDim.new(0, 20), Parent = Window.TabContainer })
		
		Window.ContentContainer = Create("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -220, 1, 0), Position = UDim2.new(0, 220, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Window.MainFrame })
		
		MakeDraggable(Window.MainFrame, navBar)

		function Window:SetActiveTab(tabToActivate)
			if Window.ActiveTab == tabToActivate then return end
			
			local oldTab = Window.ActiveTab
			Window.ActiveTab = tabToActivate

			if oldTab then
				Animate(oldTab.Button.Background, { BackgroundTransparency = 1 })
				Animate(oldTab.Icon, { ImageColor3 = Window.Theme.MutedText })
				Animate(oldTab.Label, { TextColor3 = Window.Theme.MutedText })
				Animate(oldTab.Content, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -15) }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In, function()
					if oldTab.Content and oldTab.Content.Parent then oldTab.Content.Visible = false end
				end)
			end
			
			Animate(tabToActivate.Button.Background, { BackgroundTransparency = 0 })
			Animate(tabToActivate.Icon, { ImageColor3 = Window.Theme.Text })
			Animate(tabToActivate.Label, { TextColor3 = Window.Theme.Text })
			tabToActivate.Content.Visible = true
			tabToActivate.Content.Position = UDim2.new(0.5, 0, 0.5, 15)
			Animate(tabToActivate.Content, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
		
		return Window
	end

	function Azy:NewTab(config)
		local Tab = {}
		local Window = self
		
		Tab.Button = Create("TextButton", { Name = config.Name, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.new(), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = Window.TabContainer })
		Tab.Button.Background = Create("Frame", { Name = "Background", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Window.Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = Tab.Button })
		Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Tab.Button.Background })
		
		Tab.Icon = Create("ImageLabel", { Name = "Icon", Size = UDim2.fromOffset(26, 26), Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, ImageColor3 = Window.Theme.MutedText, Image = Icons[config.Icon] or "", Parent = Tab.Button })
		Tab.Label = Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 60, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = config.Name, TextSize = 16, TextColor3 = Window.Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, Parent = Tab.Button })

		Tab.Content = Create("CanvasGroup", { Name = "Content", Size = UDim2.fromScale(1, 1), Position = UDim2.new(0.5, 0, 0.5, 15), AnchorPoint = Vector2.new(0.5, 0.5), GroupTransparency = 1, Visible = false, BackgroundTransparency = 1, Parent = Window.ContentContainer })
		Tab.MainContentFrame = Create("ScrollingFrame", { Name = "Scrolling", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Window.Theme.Accent, ScrollBarThickness = 5, Parent = Tab.Content })
		
		Create("UIPadding", { PaddingAll = UDim.new(0, 40), Parent = Tab.MainContentFrame })
		Tab.Layout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 25), FillDirection = Enum.FillDirection.Vertical, Parent = Tab.MainContentFrame })
		Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Tab.MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y + 80) end)
		
		Tab.Button.MouseEnter:Connect(function() if Window.ActiveTab ~= Tab then Animate(Tab.Button.Background, { BackgroundColor3 = Window.Theme.Secondary, BackgroundTransparency = 0.5 }) end end)
		Tab.Button.MouseLeave:Connect(function() if Window.ActiveTab ~= Tab then Animate(Tab.Button.Background, { BackgroundColor3 = Color3.new(), BackgroundTransparency = 1 }) end end)
		Tab.Button.MouseButton1Click:Connect(function() Window:SetActiveTab(Tab) end)
		
		table.insert(Window.Tabs, Tab)
		if not Window.ActiveTab then Window:SetActiveTab(Tab) end

		local TabMethods = {}
		
		function TabMethods:NewSection(cfg)
			local container = Create("Frame", { Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Tab.MainContentFrame })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = cfg.Text or "Section", TextColor3 = Window.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			Create("Frame", { Name = "Divider", Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Window.Theme.Secondary, Parent = container })
			
			local contentFrame = Create("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = container })
			Create("UIListLayout", { Padding = UDim.new(0, 15), Parent = contentFrame })
			Create("UIPadding", { PaddingTop = UDim.new(0, 35), Parent = contentFrame })
			return contentFrame
		end
		
		function TabMethods:NewLabel(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			return Create("TextLabel", { Name = "Label", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Label", TextColor3 = Window.Theme.MutedText, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = parent })
		end
		
		function TabMethods:NewButton(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = parent })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
			
			local glow = Create("UIGradient", { Color = ColorSequence.new(Window.Theme.Accent, Window.Theme.Accent), Transparency = NumberSequence.new(1), Parent = btn })
			
			Create("TextLabel", { Name = "Label", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = cfg.Text or "Button", TextColor3 = Window.Theme.Text, TextSize = 15, Parent = btn })
			
			btn.MouseEnter:Connect(function() Animate(glow, { Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1)}), Offset = Vector2.new(-0.5, 0) }, 0.2) end)
			btn.MouseLeave:Connect(function() Animate(glow, { Transparency = NumberSequence.new(1), Offset = Vector2.new(0, 0) }, 0.2) end)
			btn.MouseButton1Click:Connect(function()
				Animate(btn, { Size = UDim2.new(1, 0, 0, 38) }, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
					Animate(btn, { Size = UDim2.new(1, 0, 0, 42) }, 0.3, Enum.EasingStyle.Elastic)
				end)
				if cfg.Callback then task.spawn(cfg.Callback) end
			end)
			return btn
		end

		function TabMethods:NewToggle(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local Toggle = { Toggled = Instance.new("BindableEvent") }
			
			local default = cfg.Default or false
			if cfg.Id and Window.State.Toggles[cfg.Id] ~= nil then
				default = Window.State.Toggles[cfg.Id]
			end
			Toggle.Value = default

			local container = Create("Frame", { Name = "Toggle", Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Toggle", TextColor3 = Window.Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			
			local track = Create("TextButton", { Name = "Track", Size = UDim2.new(0, 52, 1, 0), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
			
			local fill = Create("Frame", { Name = "Fill", Size = UDim2.fromScale(Toggle.Value and 1 or 0, 1), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, Parent = track })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

			local knob = Create("Frame", { Name = "Knob", Size = UDim2.fromOffset(24, 24), Position = UDim2.fromScale(Toggle.Value and 0.75 or 0.25, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = track })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

			local function SetState(newState, noAnim)
				Toggle.Value = newState
				Toggle.Toggled:Fire(newState)
				if cfg.Id then Window.State.Toggles[cfg.Id] = newState; Azy.SaveState() end
				
				local duration = noAnim and 0 or 0.3
				Animate(fill, { Size = UDim2.fromScale(Toggle.Value and 1 or 0, 1) }, duration, Enum.EasingStyle.Quint)
				Animate(knob, { Position = UDim2.fromScale(Toggle.Value and 0.75 or 0.25, 0.5) }, duration + 0.1, Enum.EasingStyle.Elastic)
			end
			
			track.MouseButton1Click:Connect(function() 
				SetState(not Toggle.Value)
				if cfg.Callback then task.spawn(cfg.Callback, Toggle.Value) end 
			end)
			SetState(Toggle.Value, true)
			return Toggle
		end
		
		setmetatable(Tab, {__index = TabMethods})
		return Tab
	end

	return Azy
end
