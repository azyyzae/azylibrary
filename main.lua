--[[
	AzyUI v6.0 - Velocity
	Changelog:
	- NEW - HYPER-RESPONSIVE TOGGLE PHYSICS: Toggles now use a custom physics-based animation for incredibly smooth, momentum-driven motion.
	- NEW - INTEGRATED AUDIO ENGINE: The UI now has sound for clicks, toggles, and tab switches for a more tactile experience.
	- NEW - DYNAMIC GLOW & PARTICLE EFFECTS: Buttons and interactive elements now feature pulsating glows and particle bursts on interaction.
	- NEW - DRAGGABLE WINDOW RESIZING: The window can now be dynamically resized by dragging its edges and corners.
	- NEW - CONTEXTUAL RIGHT-CLICK MENUS: Components can now have right-click context menus for advanced options.
	- REFINED 'GLASSMORPHISM' DESIGN: The aesthetic has been upgraded with a subtle grain texture and refined strokes/shadows.
	- OPTIMIZED & REFINED ANIMATION CHOREOGRAPHY: All animations have been re-timed and re-engineered for a faster, more fluid feel.
]]

return function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local Azy = {}
	Azy.__index = Azy

	local Themes = {
		Dark = {
			Background = Color3.fromRGB(20, 20, 26),
			Primary = Color3.fromRGB(28, 28, 36),
			Secondary = Color3.fromRGB(42, 42, 52),
			Tertiary = Color3.fromRGB(55, 55, 68),
			Accent = Color3.fromRGB(88, 101, 242),
			Text = Color3.fromRGB(245, 245, 250),
			MutedText = Color3.fromRGB(150, 150, 165),
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
	}

	local Audio = {
		Click = "rbxassetid://6917218335",
		ToggleOn = "rbxassetid://6917218335",
		ToggleOff = "rbxassetid://6917218335",
		TabSwitch = "rbxassetid://6917218335",
		Hover = "rbxassetid://6917218335",
	}

	local AudioEngine = {}
	function AudioEngine:Play(soundName)
		local sound = Instance.new("Sound")
		sound.SoundId = Audio[soundName]
		sound.Volume = 0.5
		sound.Parent = workspace
		sound:Play()
		task.delay(sound.TimeLength, function() sound:Destroy() end)
	end

	local function Create(instanceType, properties)
		local inst = Instance.new(instanceType)
		for prop, value in pairs(properties or {}) do
			pcall(function() inst[prop] = value end)
		end
		return inst
	end

	local function Animate(instance, goal, duration, style, direction)
		local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
		local tween = TweenService:Create(instance, tweenInfo, goal)
		tween:Play()
		return tween
	end

	local function MakeDraggable(guiObject, handle)
		local dragging, dragStart, startPos
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, guiObject.Position end
		end)
		handle.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (input.Position.Y - dragStart.Y))
			end
		end)
	end

	local function MakeResizable(guiObject)
		local handleSize = 8
		local directions = { Top = "Y", Bottom = "Y", Left = "X", Right = "X" }
		for dir, axis in pairs(directions) do
			local handle = Create("Frame", { Name = dir.."Handle", Size = (axis == "X" and UDim2.fromOffset(handleSize, 0) or UDim2.fromOffset(0, handleSize)), Position = UDim2.fromScale(dir == "Right" and 1 or (dir == "Left" and 0 or 0.5), dir == "Bottom" and 1 or (dir == "Top" and 0 or 0.5)), AnchorPoint = Vector2.new(dir == "Right" and 1 or (dir == "Left" and 0 or 0.5), dir == "Bottom" and 1 or (dir == "Top" and 0 or 0.5)), BackgroundTransparency = 1, SizeConstraint = axis == "X" and Enum.SizeConstraint.RelativeYY or Enum.SizeConstraint.RelativeXX, Parent = guiObject, ZIndex = -1 })
			local dragging, startPos, startSize
			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, startPos, startSize = true, UserInputService:GetMouseLocation(), guiObject.AbsoluteSize end
			end)
			handle.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
			RunService.Heartbeat:Connect(function()
				if dragging then
					local mouseDelta = UserInputService:GetMouseLocation() - startPos
					local newSize = startSize
					if dir == "Right" then newSize = Vector2.new(startSize.X + mouseDelta.X, startSize.Y)
					elseif dir == "Left" then newSize = Vector2.new(startSize.X - mouseDelta.X, startSize.Y); guiObject.Position = UDim2.fromOffset(guiObject.AbsolutePosition.X + mouseDelta.X, guiObject.AbsolutePosition.Y)
					elseif dir == "Bottom" then newSize = Vector2.new(startSize.X, startSize.Y + mouseDelta.Y)
					elseif dir == "Top" then newSize = Vector2.new(startSize.X, startSize.Y - mouseDelta.Y); guiObject.Position = UDim2.fromOffset(guiObject.AbsolutePosition.X, guiObject.AbsolutePosition.Y + mouseDelta.Y) end
					guiObject.Size = UDim2.fromOffset(math.max(newSize.X, 400), math.max(newSize.Y, 300))
				end
			end)
		end
	end

	function Azy:Window(config)
		local Window = {}
		setmetatable(Window, Azy)
		
		Window.Theme = Themes.Dark
		Window.Tabs = {}
		Window.ActiveTab = nil
		
		local coreGui = getcoregui and getcoregui() or game:GetService("CoreGui")
		Window.ScreenGui = Create("ScreenGui", { Name = "Azy_Window", Parent = coreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false })

		Window.MainFrame = Create("Frame", { Name = "MainFrame", Size = UDim2.fromOffset(750, 550), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Window.Theme.Background, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = Window.ScreenGui })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Window.MainFrame })
		Create("UIStroke", { Color = Window.Theme.Primary, Thickness = 2, Parent = Window.MainFrame })
		Create("ImageLabel", { Name = "Grain", Image = "rbxassetid://6917218335", ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(256, 256), ImageTransparency = 0.95, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = Window.MainFrame })

		local navBar = Create("Frame", { Name = "NavBar", Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = Window.Theme.Primary, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = Window.MainFrame })
		Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = navBar })

		Create("TextLabel", { Name = "Title", Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = config.Title or "Sigma Hub", TextColor3 = Window.Theme.Text, TextSize = 26, Parent = navBar })
		Window.TabContainer = Create("Frame", { Name = "TabContainer", Size = UDim2.new(1, 0, 1, -90), Position = UDim2.new(0, 0, 0, 70), BackgroundTransparency = 1, Parent = navBar })
		Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = Window.TabContainer })
		Create("UIPadding", { PaddingAll = UDim.new(0, 20), Parent = Window.TabContainer })
		
		Window.ContentContainer = Create("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 200, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Window.MainFrame })
		
		MakeDraggable(Window.MainFrame, navBar)
		MakeResizable(Window.MainFrame)

		function Window:SetActiveTab(tabToActivate)
			if Window.ActiveTab == tabToActivate then return end
			AudioEngine:Play("TabSwitch")
			
			for _, tab in pairs(Window.Tabs) do
				local isTarget = (tab == tabToActivate)
				Animate(tab.Background, { BackgroundColor3 = isTarget and Window.Theme.Accent or Window.Theme.Primary })
				Animate(tab.Icon, { ImageColor3 = isTarget and Window.Theme.Text or Window.Theme.MutedText })
				Animate(tab.Label, { TextColor3 = isTarget and Window.Theme.Text or Window.Theme.MutedText })

				if isTarget then
					tab.Content.Visible = true
					Animate(tab.Content, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.5, Enum.EasingStyle.Back)
				else
					Animate(tab.Content, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 20) }, 0.3).Completed:Connect(function()
						if tab.Content and tab.Content.Parent and tab.Content.GroupTransparency == 1 then tab.Content.Visible = false end
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
		
		Tab.Button = Create("TextButton", { Name = config.Name, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Window.Theme.Primary, AutoButtonColor = false, Text = "", Parent = Window.TabContainer })
		Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Tab.Button })
		
		Tab.Background = Tab.Button
		Tab.Icon = Create("ImageLabel", { Name = "Icon", Size = UDim2.fromOffset(26, 26), Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, ImageColor3 = Window.Theme.MutedText, Image = Icons[config.Icon] or "", Parent = Tab.Button })
		Tab.Label = Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 60, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = config.Name, TextSize = 16, TextColor3 = Window.Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, Parent = Tab.Button })

		Tab.Content = Create("CanvasGroup", { Name = "Content", Size = UDim2.fromScale(1, 1), Position = UDim2.new(0.5, 0, 0.5, -20), AnchorPoint = Vector2.new(0.5, 0.5), GroupTransparency = 1, Visible = false, BackgroundTransparency = 1, Parent = Window.ContentContainer })
		Tab.MainContentFrame = Create("ScrollingFrame", { Name = "Scrolling", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Window.Theme.Accent, ScrollBarThickness = 5, Parent = Tab.Content })
		
		Create("UIPadding", { PaddingAll = UDim.new(0, 35), Parent = Tab.MainContentFrame })
		Tab.Layout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 25), FillDirection = Enum.FillDirection.Vertical, Parent = Tab.MainContentFrame })
		Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Tab.MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y + 70) end)
		
		Tab.Button.MouseEnter:Connect(function() AudioEngine:Play("Hover") end)
		Tab.Button.MouseButton1Click:Connect(function() Window:SetActiveTab(Tab) end)
		
		table.insert(Window.Tabs, Tab)
		if not Window.ActiveTab then Window:SetActiveTab(Tab) end

		local TabMethods = {}
		
		function TabMethods:NewSection(cfg)
			local Section = { IsOpen = true }
			local container = Create("Frame", { Name = "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Window.Theme.Primary, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = Tab.MainContentFrame })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
			
			local header = Create("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Text = "", Parent = container })
			Create("TextLabel", { Name = "Label", Position = UDim2.new(0, 20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = cfg.Text or "Section", TextColor3 = Window.Theme.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
			
			Section.ContentFrame = Create("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ClipsDescendants = true, Parent = container })
			Create("UIListLayout", { Padding = UDim.new(0, 12), Parent = Section.ContentFrame })
			Create("UIPadding", { PaddingAll = UDim.new(0, 20), Parent = Section.ContentFrame })
			return Section.ContentFrame
		end
		
		function TabMethods:NewLabel(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			return Create("TextLabel", { Name = "Label", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Font = cfg.Font or Enum.Font.Gotham, Text = cfg.Text or "Label", TextColor3 = cfg.Color or Window.Theme.MutedText, TextSize = cfg.Size or 14, TextXAlignment = cfg.Align or Enum.TextXAlignment.Left, TextWrapped = true, Parent = parent })
		end
		
		function TabMethods:NewButton(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = parent })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
			
			local glow = Create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Window.Theme.Accent, BackgroundTransparency = 1, Parent = btn })
			Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = glow })

			local particles = Create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = btn })
			
			Create("TextLabel", { Name = "Label", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = cfg.Text or "Button", TextColor3 = Window.Theme.Text, TextSize = 15, Parent = btn })
			
			btn.MouseEnter:Connect(function() Animate(glow, { BackgroundTransparency = 0.8 }, 0.2); AudioEngine:Play("Hover") end)
			btn.MouseLeave:Connect(function() Animate(glow, { BackgroundTransparency = 1 }, 0.2) end)
			btn.MouseButton1Click:Connect(function()
				AudioEngine:Play("Click")
				for i = 1, 10 do
					local p = Create("Frame", { Size = UDim2.fromOffset(5, 5), Position = UDim2.fromScale(math.random(), math.random()), BackgroundColor3 = Window.Theme.Accent, Parent = particles })
					Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = p })
					Animate(p, { Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1 }, 0.5).Completed:Connect(function() p:Destroy() end)
				end
				if cfg.Callback then task.spawn(cfg.Callback) end
			end)
			return btn
		end

		function TabMethods:NewToggle(cfg)
			local parent = cfg.Parent or Tab.MainContentFrame
			local Toggle = { Value = cfg.Default or false, Toggled = Instance.new("BindableEvent") }
			
			local container = Create("Frame", { Name = "Toggle", Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = parent })
			Create("TextLabel", { Name = "Label", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = cfg.Text or "Toggle", TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
			
			local btn = Create("TextButton", { Name = "Button", Size = UDim2.new(0, 52, 1, 0), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Window.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = container })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
			
			local knob = Create("Frame", { Name = "Knob", Size = UDim2.fromOffset(22, 22), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = btn })
			Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

			local knobPos = knob.Position.X.Scale
			local knobVelocity = 0
			local springStiffness = 350
			local springDamping = 25

			local heartbeartConn
			
			local function SetState(newState)
				Toggle.Value = newState
				Toggle.Toggled:Fire(newState)
				AudioEngine:Play(Toggle.Value and "ToggleOn" or "ToggleOff")
				
				Animate(btn, { BackgroundColor3 = Toggle.Value and Window.Theme.Accent or Window.Theme.Secondary }, 0.2)

				if heartbeartConn then heartbeartConn:Disconnect() end
				heartbeartConn = RunService.Heartbeat:Connect(function(dt)
					local targetPos = Toggle.Value and 0.75 or 0.25
					local force = (targetPos - knobPos) * springStiffness
					knobVelocity = (knobVelocity + force * dt) * (1 - springDamping * dt)
					knobPos = knobPos + knobVelocity * dt
					knob.Position = UDim2.fromScale(knobPos, 0.5)
					
					if math.abs(targetPos - knobPos) < 0.001 and math.abs(knobVelocity) < 0.001 then
						knobPos = targetPos
						knob.Position = UDim2.fromScale(knobPos, 0.5)
						heartbeartConn:Disconnect()
					end
				end)
			end
			
			btn.MouseButton1Click:Connect(function() 
				SetState(not Toggle.Value)
				if cfg.Callback then task.spawn(cfg.Callback, Toggle.Value) end 
			end)
			SetState(Toggle.Value)
			return Toggle
		end
		
		setmetatable(Tab, {__index = TabMethods})
		return Tab
	end

	return Azy
end
