--[[
	AzyUI v1.0
	A modern, animated, and customizable UI library for Roblox.
	Created by: Your AI assistant
]]

return function()
	--// Services
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")

	--// Main Library Table
	local Azy = {}
	Azy.__index = Azy

	--// Configuration & Themes
	local Themes = {
		Nighty = {
			Background = Color3.fromRGB(24, 25, 30),
			Primary = Color3.fromRGB(35, 38, 46),
			Secondary = Color3.fromRGB(54, 58, 70),
			Accent = Color3.fromRGB(110, 94, 204),
			Text = Color3.fromRGB(220, 221, 222),
			MutedText = Color3.fromRGB(150, 150, 150),
			Success = Color3.fromRGB(80, 194, 118),
		},
		Dark = {
			Background = Color3.fromRGB(18, 18, 18),
			Primary = Color3.fromRGB(28, 28, 28),
			Secondary = Color3.fromRGB(44, 44, 44),
			Accent = Color3.fromRGB(52, 120, 246), -- A nice blue
			Text = Color3.fromRGB(240, 240, 240),
			MutedText = Color3.fromRGB(170, 170, 170),
			Success = Color3.fromRGB(80, 194, 118),
		},
		White = {
			Background = Color3.fromRGB(245, 245, 245),
			Primary = Color3.fromRGB(255, 255, 255),
			Secondary = Color3.fromRGB(230, 230, 230),
			Accent = Color3.fromRGB(255, 82, 82), -- A nice red/coral
			Text = Color3.fromRGB(20, 20, 20),
			MutedText = Color3.fromRGB(100, 100, 100),
			Success = Color3.fromRGB(0, 180, 100),
		}
	}

	--// Helper Functions
	local function Create(instanceType, properties)
		local inst = Instance.new(instanceType)
		for prop, value in pairs(properties or {}) do
			inst[prop] = value
		end
		return inst
	end

	local function Animate(instance, goal, duration, style, direction)
		duration = duration or 0.2
		style = style or Enum.EasingStyle.Quad
		direction = direction or Enum.EasingDirection.Out
		local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), goal)
		tween:Play()
		return tween
	end

	local function MakeDraggable(guiObject, handle)
		local dragging = false
		local dragInput = nil
		local dragStart = nil
		local startPos = nil

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = guiObject.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
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


	--============================================================================--
	--                                 WINDOW                                     --
	--============================================================================--
	function Azy:Window(config)
		local Window = {}
		setmetatable(Window, Azy)

		--// Configuration
		Window.Title = config.Title or "Azy UI"
		Window.Footer = config.Footer
		Window.Theme = Themes[config.Theme] or Themes.Nighty
		Window.Icon = config.Icon
		Window.Tabs = {}
		Window.ActiveTab = nil

		--// Create GUI
		Window.ScreenGui = Create("ScreenGui", {
			Name = "Azy_Window_"..Window.Title,
			Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false
		})

		--// Main Frame (with blur)
		Window.MainFrame = Create("Frame", {
			Name = "MainFrame",
			Size = UDim2.new(0, 550, 0, 380),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Window.Theme.Background,
			BorderSizePixel = 0,
			Parent = Window.ScreenGui
		})

		Create("UIBlur", {
			Size = 12,
			Parent = Window.MainFrame,
		})
		Create("UIRound", { CornerRadius = UDim.new(0, 8), Parent = Window.MainFrame })
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2), -- Controls blur transparency
				NumberSequenceKeypoint.new(1, 0.2)
			}),
			Parent = Window.MainFrame
		})
		Create("UIStroke", {
			Color = Window.Theme.Secondary,
			Thickness = 1,
			Parent = Window.MainFrame
		})

		--// Header
		local Header = Create("Frame", {
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = Window.Theme.Primary,
			BorderSizePixel = 0,
			Parent = Window.MainFrame
		})
		Create("UIRound", { CornerRadius = UDim.new(0, 8), Parent = Header })

		local TitleLabel = Create("TextLabel", {
			Name = "TitleLabel",
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Window.Theme.Primary,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = " "..Window.Title,
			TextColor3 = Window.Theme.Text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Header
		})

		if Window.Icon then
			local iconId = "rbxassetid://".. (tonumber(Window.Icon) or Window.Icon)
			local IconImage = Create("ImageLabel", {
				Name = "Icon",
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(0, 8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = iconId,
				Parent = TitleLabel
			})
			TitleLabel.Text = "  "..Window.Title
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
		end

		--// Footer
		if Window.Footer then
			local FooterFrame = Create("Frame", {
				Name = "Footer",
				Size = UDim2.new(1, 0, 0, 25),
				Position = UDim2.new(0, 0, 1, -25),
				BackgroundColor3 = Window.Theme.Primary,
				BorderSizePixel = 0,
				Parent = Window.MainFrame,
			})
			Create("UIRound", { CornerRadius = UDim.new(0, 8), Parent = FooterFrame })
			Create("TextLabel", {
				Name = "FooterLabel",
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = Window.Footer,
				TextColor3 = Window.Theme.MutedText,
				TextSize = 12,
				Parent = FooterFrame
			})
		end


		--// Content Area
		Window.TabContainer = Create("Frame", {
			Name = "TabContainer",
			Size = UDim2.new(0, 120, 1, -40 - (Window.Footer and 25 or 0)),
			Position = UDim2.new(0, 0, 0, 40),
			BackgroundColor3 = Window.Theme.Primary,
			BorderSizePixel = 0,
			Parent = Window.MainFrame
		})
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Parent = Window.TabContainer
		})
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			Parent = Window.TabContainer
		})


		Window.ContentContainer = Create("Frame", {
			Name = "ContentContainer",
			Size = UDim2.new(1, -120, 1, -40 - (Window.Footer and 25 or 0)),
			Position = UDim2.new(0, 120, 0, 40),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = Window.MainFrame
		})
		
		MakeDraggable(Window.MainFrame, Header)
		
		function Window:SetActiveTab(tabToActivate)
			if Window.ActiveTab == tabToActivate then return end
			
			for _, tab in pairs(Window.Tabs) do
				local isTarget = (tab == tabToActivate)
				Animate(tab.Button, { BackgroundColor3 = isTarget and Window.Theme.Secondary or Window.Theme.Primary }, 0.2)
				Animate(tab.Indicator, { Visible = isTarget }, 0.2)
				if isTarget then
					tab.Content.Visible = true
					Animate(tab.Content, {GroupTransparency = 0, Position = UDim2.new(0, 10, 0, 10)}, 0.3)
				else
					Animate(tab.Content, {GroupTransparency = 1, Position = UDim2.new(0, -10, 0, 10)}, 0.3):GetPropertyChangedSignal("Status"):Connect(function()
						if tab.Content.GroupTransparency == 1 then
							tab.Content.Visible = false
						end
					end)
				end
			end
			Window.ActiveTab = tabToActivate
		end
		
		return Window
	end

	--============================================================================--
	--                                  TABS                                      --
	--============================================================================--
	function Azy:NewTab(config)
		local Tab = {}
		local Window = self -- self is the window object
		
		Tab.Name = config.Name or "New Tab"
		Tab.Icon = config.Icon
		
		--// Create Tab Button
		Tab.Button = Create("TextButton", {
			Name = Tab.Name,
			Size = UDim2.new(1, -20, 0, 30),
			BackgroundColor3 = Window.Theme.Primary,
			AutoButtonColor = false,
			Text = "",
			Parent = Window.TabContainer
		})
		Create("UIRound", { CornerRadius = UDim.new(0, 6), Parent = Tab.Button })
		
		Tab.Indicator = Create("Frame", {
			Name = "Indicator",
			Size = UDim2.new(0, 3, 0.7, 0),
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Window.Theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			Parent = Tab.Button
		})
		Create("UIRound", { Parent = Tab.Indicator })
		
		local TabLabel = Create("TextLabel", {
			Name = "TabLabel",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "  "..Tab.Name,
			TextSize = 14,
			TextColor3 = Window.Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Tab.Button
		})
		
		--// Create Content Page
		Tab.Content = Create("CanvasGroup", {
			Name = "Content_"..Tab.Name,
			Size = UDim2.new(1, -20, 1, -20),
			Position = UDim2.new(0, -10, 0, 10),
			GroupTransparency = 1,
			Visible = false,
			BackgroundTransparency = 1,
			Parent = Window.ContentContainer
		})

		local ScrollingContent = Create("ScrollingFrame", {
			Name = "ScrollingContent",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarImageColor3 = Window.Theme.Accent,
			ScrollBarThickness = 4,
			Parent = Tab.Content
		})
		
		local Layout = Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Parent = ScrollingContent
		})
		
		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
		end)
		
		Tab.Button.MouseEnter:Connect(function()
			if Window.ActiveTab ~= Tab then
				Animate(Tab.Button, { BackgroundColor3 = Window.Theme.Secondary }, 0.2)
			end
		end)
		Tab.Button.MouseLeave:Connect(function()
			if Window.ActiveTab ~= Tab then
				Animate(Tab.Button, { BackgroundColor3 = Window.Theme.Primary }, 0.2)
			end
		end)
		Tab.Button.MouseButton1Click:Connect(function()
			Window:SetActiveTab(Tab)
		end)
		
		table.insert(Window.Tabs, Tab)
		if not Window.ActiveTab then
			Window:SetActiveTab(Tab)
		end
		
		--// Methods for this tab
		local TabMethods = {}
		
		function TabMethods:NewLabel(labelConfig)
			local label = Create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = labelConfig.Text or "Label",
				TextColor3 = labelConfig.Color or Window.Theme.MutedText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ScrollingContent
			})
			return label
		end
		
		function TabMethods:NewButton(buttonConfig)
			local button = Create("TextButton", {
				Name = "Button",
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = Window.Theme.Secondary,
				Text = buttonConfig.Text or "Button",
				Font = Enum.Font.GothamSemibold,
				TextSize = 14,
				TextColor3 = Window.Theme.Text,
				AutoButtonColor = false,
				Parent = ScrollingContent,
			})
			Create("UIRound", { CornerRadius = UDim.new(0, 6), Parent = button })
			
			button.MouseEnter:Connect(function() Animate(button, { BackgroundColor3 = Window.Theme.Accent }, 0.2) end)
			button.MouseLeave:Connect(function() Animate(button, { BackgroundColor3 = Window.Theme.Secondary }, 0.2) end)
			button.MouseButton1Click:Connect(function()
				Animate(button, { Size = UDim2.new(1, 0, 0, 32) }, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Completed:Wait()
				Animate(button, { Size = UDim2.new(1, 0, 0, 35) }, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				if buttonConfig.Callback then
					task.spawn(buttonConfig.Callback)
				end
			end)
			
			return button
		end
		
		function TabMethods:NewToggle(toggleConfig)
			local Toggle = {}
			local state = toggleConfig.Default or false
			
			local container = Create("Frame", {
				Name = "ToggleContainer",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Parent = ScrollingContent
			})

			local label = Create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(0.7, 0, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = toggleConfig.Text or "Toggle",
				TextColor3 = Window.Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container
			})
			
			local toggleButton = Create("TextButton", {
				Name = "ToggleButton",
				Size = UDim2.new(0, 44, 0, 24),
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = state and Window.Theme.Success or Window.Theme.Secondary,
				Text = "",
				AutoButtonColor = false,
				Parent = container
			})
			Create("UIRound", { CornerRadius = UDim.new(1, 0), Parent = toggleButton })
			
			local knob = Create("Frame", {
				Name = "Knob",
				Size = UDim2.new(0, 20, 0, 20),
				Position = state and UDim2.fromScale(1, 0.5) or UDim2.fromScale(0, 0.5),
				AnchorPoint = state and Vector2.new(1.1, 0.5) or Vector2.new(-0.1, 0.5),
				BackgroundColor3 = Color3.new(1,1,1),
				BorderSizePixel = 0,
				Parent = toggleButton
			})
			Create("UIRound", { CornerRadius = UDim.new(1, 0), Parent = knob })

			Toggle.Toggled = Instance.new("BindableEvent")
			Toggle.Value = state

			local function SetState(newState)
				state = newState
				Toggle.Value = newState
				Toggle.Toggled:Fire(newState)

				Animate(toggleButton, { BackgroundColor3 = state and Window.Theme.Success or Window.Theme.Secondary })
				if state then
					Animate(knob, { Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(1.1, 0.5) })
				else
					Animate(knob, { Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(-0.1, 0.5) })
				end
			end
			
			toggleButton.MouseButton1Click:Connect(function()
				SetState(not state)
				if toggleConfig.Callback then
					task.spawn(toggleConfig.Callback, state)
				end
			end)

			return Toggle
		end
		
		setmetatable(Tab, {__index = TabMethods})
		return Tab
	end

	return Azy
end
