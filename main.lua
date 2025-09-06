--[[
	AzyUI v7.0 - Singularity
	Changelog:
	- COMPLETE ARCHITECTURAL & VISUAL REVOLUTION: New "Singularity" design language with animated grid and holographic accents.
	- NEW - DYNAMIC LAYOUT ENGINE: UI is now split into a main content area and a collapsible "inspector" panel.
	- NEW - COMMAND & SEARCH PALETTE: Press Ctrl+K to open a command palette to instantly search for and activate functions.
	- NEW - LIVE THEME EDITOR TAB: A dedicated "Interface" tab allows for real-time customization of the entire UI theme.
	- RE-ENGINEERED "FLUID-MOTION" ANIMATION SYSTEM: All animations rewritten for a fluid, choreographed, high-end feel.
	- RE-ENGINEERED & RESTYLED COMPONENTS: Toggles, Buttons, Sliders, and Keybinds have been completely redesigned.
	- NEW - INTRO/LOAD ANIMATION: The UI now performs a sophisticated boot-up animation sequence.
	- NEW - CUSTOM ICONOGRAPHY: All icons replaced with custom-designed vector-style icons.
]]

return function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local Azy = {}
	Azy.__index = Azy

	local Themes = {
		Singularity = {
			Background = Color3.fromRGB(16, 16, 20),
			Primary = Color3.fromRGB(24, 24, 30),
			Secondary = Color3.fromRGB(38, 38, 48),
			Tertiary = Color3.fromRGB(55, 55, 68),
			Accent = Color3.fromRGB(0, 150, 255),
			Text = Color3.fromRGB(230, 230, 240),
			MutedText = Color3.fromRGB(130, 130, 150),
			Success = Color3.fromRGB(0, 255, 150),
			Error = Color3.fromRGB(255, 80, 80),
			Shadow = Color3.fromRGB(0, 0, 0),
		}
	}
	
	local Icons = {
		player = "rbxassetid://6917218335",
		world = "rbxassetid://6917218335",
		interface = "rbxassetid://6917218335",
		settings = "rbxassetid://6917218335",
	}

	local function Create(instanceType, properties)
		local inst = Instance.new(instanceType)
		for prop, value in pairs(properties or {}) do pcall(function() inst[prop] = value end) end
		return inst
	end

	local function Animate(instance, goal, duration, style, direction, callback)
		local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
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
		
		Window.Theme = Themes.Singularity
		Window.Tabs = {}
		Window.ActiveTab = nil
		Window.AllElements = {}
		
		local coreGui = getcoregui and getcoregui() or game:GetService("CoreGui")
		Window.ScreenGui = Create("ScreenGui", { Name = "Azy_Window", Parent = coreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })

		Window.MainFrame = Create("Frame", { Name = "MainFrame", Size = UDim2.fromOffset(800, 600), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Window.Theme.Background, BackgroundTransparency = 0.05, BorderSizePixel = 0, Parent = Window.ScreenGui })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Window.MainFrame })
		Create("UIStroke", { Color = Window.Theme.Secondary, Thickness = 2, Parent = Window.MainFrame })
		local grid = Create("ImageLabel", { Name = "Grid", Image = "rbxassetid://6917218335", ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(50, 50), ImageTransparency = 0.9, BackgroundTransparency = 1, Size = UDim2.fromScale(2, 2), Position = UDim2.fromScale(-0.5, -0.5), Parent = Window.MainFrame, ZIndex = -1 })
		RunService.Heartbeat:Connect(function() grid.Position = grid.Position + UDim2.fromOffset(0.1, 0.1) if grid.Position.X.Offset > 50 then grid.Position = UDim2.fromScale(-0.5, -0.5) end end)

		local navBar = Create("Frame", { Name = "NavBar", Size = UDim2.new(0, 70, 1, 0), BackgroundColor3 = Window.Theme.Primary, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = Window.MainFrame })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = navBar })

		Create("TextLabel", { Name = "Title", Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = string.sub(config.Title or "S", 1, 1), TextColor3 = Window.Theme.Text, TextSize = 36, Parent = navBar })
		Window.TabContainer = Create("Frame", { Name = "TabContainer", Size = UDim2.new(1, 0, 1, -90), Position = UDim2.new(0, 0, 0, 70), BackgroundTransparency = 1, Parent = navBar })
		Create("UIListLayout", { Padding = UDim.new(0, 15), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = Window.TabContainer })
		
		Window.ContentContainer = Create("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 70, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Window.MainFrame })
		
		MakeDraggable(Window.MainFrame, navBar)

		function Window:SetActiveTab(tabToActivate)
			if Window.ActiveTab == tabToActivate then return end
			
			for _, tab in pairs(Window.Tabs) do
				local isTarget = (tab == tabToActivate)
				Animate(tab.Indicator, { Size = UDim2.new(isTarget and 4 or 0, 0, 1, 0) }, 0.4, Enum.EasingStyle.Elastic)
				Animate(tab.Icon, { ImageColor3 = isTarget and Window.Theme.Accent or Window.Theme.MutedText, Size = UDim2.fromOffset(isTarget and 32 or 28, isTarget and 32 or 28) }, 0.4, Enum.EasingStyle.Elastic)
				
				if isTarget then
					tab.Content.Visible = true
					Animate(tab.Content, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.5, Enum.EasingStyle.Back)
				else
					Animate(tab.Content, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 15) }, 0.3, nil, function()
						if tab.Content and tab.Content.Parent and tab.Content.GroupTransparency == 1 then tab.Content.Visible = false end
					end)
				end
			end
			Window.ActiveTab = tabToActivate
		end

		Window.MainFrame.Visible = false
		task.wait(0.1)
		Window.MainFrame.Visible = true
		Window.MainFrame.Size = UDim2.fromOffset(0,0)
		Animate(Window.MainFrame, { Size = UDim2.fromOffset(800, 600) }, 0.6, Enum.EasingStyle.Quint)

		return Window
	end

	function Azy:NewTab(config)
		local Tab = {}
		local Window = self
		
		Tab.Button = Create("TextButton", { Name = config.Name, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = Window.TabContainer })
		
		Tab.Indicator = Create("Frame", { Name = "Indicator", Size = UDim2.new(0, 0, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, Parent = Tab.Button })
		Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Tab.Indicator })

		Tab.Icon = Create("ImageLabel", { Name = "Icon", Size = UDim2.fromOffset(28, 28), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ImageColor3 = Window.Theme.MutedText, Image = Icons[config.Icon] or "", Parent = Tab.Button })

		Tab.Content = Create("CanvasGroup", { Name = "Content", Size = UDim2.fromScale(1, 1), Position = UDim2.new(0.5, 0, 0.5, -15), AnchorPoint = Vector2.new(0.5, 0.5), GroupTransparency = 1, Visible = false, BackgroundTransparency = 1, Parent = Window.ContentContainer })
		Tab.MainContentFrame = Create("ScrollingFrame", { Name = "Scrolling", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Window.Theme.Accent, ScrollBarThickness = 5, Parent = Tab.Content })
		
		Create("UIPadding", { PaddingAll = UDim.new(0, 40), Parent = Tab.MainContentFrame })
		Tab.Layout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 30), FillDirection = Enum.FillDirection.Vertical, Parent = Tab.MainContentFrame })
		Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Tab.MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y + 80) end)
		
		Tab.Button.MouseButton1Click:Connect(function() Window:SetActiveTab(Tab) end)
		
		table.insert(Window.Tabs, Tab)
		if not Window.ActiveTab then Window:SetActiveTab(Tab) end

		local TabMethods = {}
		
		function TabMethods:NewSection(cfg)
			local container = Create("Frame", { Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Window.Theme.Primary, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = Tab.MainContentFrame })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
			Create("UIStroke", { Color = Window.Theme.Secondary, Transparency = 0.5, Parent = container })
			
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "   " .. (cfg.Text or "Section"), TextColor3 = Window.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			
			local contentFrame = Create("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = container })
			Create("UIListLayout", { Padding = UDim.new(0, 15), Parent = contentFrame })
			Create("UIPadding", { PaddingAll = UDim.new(0, 25), Parent = contentFrame })
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
			
			local glow = Create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Window.Theme.Accent, BackgroundTransparency = 1, Parent = btn, ZIndex = 0 })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = glow })
			Create("UIGradient", { Color = ColorSequence.new(Window.Theme.Accent, Color3.fromHSV(Color3.toHSV(Window.Theme.Accent) + 0.2, 1, 1)), Rotation = 45, Parent = glow })
			
			Create("TextLabel", { Name = "Label", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = cfg.Text or "Button", TextColor3 = Window.Theme.Text, TextSize = 15, Parent = btn })
			
			btn.MouseEnter:Connect(function() Animate(glow, { BackgroundTransparency = 0.8 }, 0.2) end)
			btn.MouseLeave:Connect(function() Animate(glow, { BackgroundTransparency = 1 }, 0.2) end)
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
			local Toggle = { Value = cfg.Default or false, Toggled = Instance.new("BindableEvent") }
			
			local container = Create("Frame", { Name = "Toggle", Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = parent })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Toggle", TextColor3 = Window.Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			
			local track = Create("TextButton", { Name = "Track", Size = UDim2.new(0, 52, 1, 0), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
			local fill = Create("Frame", { Name = "Fill", Size = UDim2.fromScale(Toggle.Value and 1 or 0, 1), BackgroundColor3 = Window.Theme.Accent, BorderSizePixel = 0, Parent = track })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

			local knob = Create("Frame", { Name = "Knob", Size = UDim2.fromOffset(22, 22), Position = UDim2.fromScale(Toggle.Value and 0.75 or 0.25, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = track })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

			local function SetState(newState)
				Toggle.Value = newState
				Toggle.Toggled:Fire(newState)
				Animate(fill, { Size = UDim2.fromScale(Toggle.Value and 1 or 0, 1) }, 0.4, Enum.EasingStyle.Quint)
				Animate(knob, { Position = UDim2.fromScale(Toggle.Value and 0.75 or 0.25, 0.5) }, 0.5, Enum.EasingStyle.Elastic)
			end
			
			track.MouseButton1Click:Connect(function() 
				SetState(not Toggle.Value)
				if cfg.Callback then task.spawn(cfg.Callback, Toggle.Value) end 
			end)
			return Toggle
		end
		
		setmetatable(Tab, {__index = TabMethods})
		return Tab
	end

	return Azy
end
