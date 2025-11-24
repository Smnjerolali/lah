local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local ModernUI = {
	Flags = {},
	Theme = {
		Background = Color3.fromRGB(30, 30, 30),
		Header = Color3.fromRGB(25, 25, 25),
		Sidebar = Color3.fromRGB(35, 35, 35),
		Element = Color3.fromRGB(45, 45, 45),
		Section = Color3.fromRGB(40, 40, 40),
		Text = Color3.fromRGB(240, 240, 240),
		TextDark = Color3.fromRGB(180, 180, 180),
		Accent = Color3.fromRGB(0, 122, 204),
		Divider = Color3.fromRGB(60, 60, 60),
		CornerRadius = UDim.new(0, 6)
	},
	Folder = "ModernUI"
}

-- Utility Functions
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

local function Create(className, properties)
	local instance = Instance.new(className)
	for k, v in pairs(properties) do
		instance[k] = v
	end
	return instance
end

function ModernUI:SaveConfig(name)
	if not isfolder(self.Folder) then makefolder(self.Folder) end
	local json = HttpService:JSONEncode(self.Flags)
	writefile(self.Folder .. "/" .. name .. ".json", json)
end

function ModernUI:LoadConfig(name)
	if isfile(self.Folder .. "/" .. name .. ".json") then
		local json = readfile(self.Folder .. "/" .. name .. ".json")
		local data = HttpService:JSONDecode(json)
		for flag, value in pairs(data) do
			self.Flags[flag] = value
			-- Note: This simple load doesn't automatically update UI elements unless they listen to Flags or we implement a callback system for flags.
			-- For a proper system, we'd need to fire callbacks.
			if self.ConfigCallbacks and self.ConfigCallbacks[flag] then
				self.ConfigCallbacks[flag](value)
			end
		end
	end
end

ModernUI.ConfigCallbacks = {}

function ModernUI:CreateWindow(options)
	options = options or {}
	local Title = options.Title or "Modern UI"
	
	local ScreenGui = Create("ScreenGui", {
		Name = "ModernUI_" .. Title,
		Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = ModernUI.Theme.Background,
		Position = UDim2.new(0.5, -300, 0.5, -200),
		Size = UDim2.new(0, 600, 0, 400),
		BorderSizePixel = 0
	})
	Create("UICorner", { Parent = MainFrame, CornerRadius = ModernUI.Theme.CornerRadius })

	local Header = Create("Frame", {
		Name = "Header",
		Parent = MainFrame,
		BackgroundColor3 = ModernUI.Theme.Header,
		Size = UDim2.new(1, 0, 0, 40),
		BorderSizePixel = 0
	})
	Create("UICorner", { Parent = Header, CornerRadius = ModernUI.Theme.CornerRadius })
	
	local HeaderCover = Create("Frame", {
		Name = "HeaderCover",
		Parent = Header,
		BackgroundColor3 = ModernUI.Theme.Header,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -10),
		Size = UDim2.new(1, 0, 0, 10)
	})

	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = Title,
		TextColor3 = ModernUI.Theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	MakeDraggable(Header, MainFrame)

	local NotificationContainer = Create("Frame", {
		Name = "Notifications",
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -320, 1, -20),
		Size = UDim2.new(0, 300, 1, 0),
		AnchorPoint = Vector2.new(0, 1)
	})
	
	local NotificationList = Create("UIListLayout", {
		Parent = NotificationContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10)
	})

	local TabContainer = Create("Frame", {
		Name = "TabContainer",
		Parent = MainFrame,
		BackgroundColor3 = ModernUI.Theme.Sidebar,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(0, 150, 1, -40),
		BorderSizePixel = 0
	})
	Create("UICorner", { Parent = TabContainer, CornerRadius = UDim.new(0, 0) })
	
	local TabListLayout = Create("UIListLayout", {
		Parent = TabContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})
	Create("UIPadding", {
		Parent = TabContainer,
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	})

	local PageContainer = Create("Frame", {
		Name = "PageContainer",
		Parent = MainFrame,
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 160, 0, 50),
		Size = UDim2.new(1, -170, 1, -60),
		ClipsDescendants = true
	})

	local Window = {}
	local FirstTab = true

	function Window:Notify(options)
		options = options or {}
		local Title = options.Title or "Notification"
		local Content = options.Content or "Message"
		local Duration = options.Duration or 3

		local NotifyFrame = Create("Frame", {
			Name = "Notify",
			Parent = NotificationContainer,
			BackgroundColor3 = ModernUI.Theme.Header,
			Size = UDim2.new(1, 0, 0, 80),
			BackgroundTransparency = 1
		})
		Create("UICorner", { Parent = NotifyFrame, CornerRadius = ModernUI.Theme.CornerRadius })

		local NTitle = Create("TextLabel", {
			Parent = NotifyFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 5),
			Size = UDim2.new(1, -20, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = Title,
			TextColor3 = ModernUI.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		})

		local NContent = Create("TextLabel", {
			Parent = NotifyFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 25),
			Size = UDim2.new(1, -20, 1, -30),
			Font = Enum.Font.Gotham,
			Text = Content,
			TextColor3 = ModernUI.Theme.TextDark,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTransparency = 1
		})

		TweenService:Create(NotifyFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
		TweenService:Create(NTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
		TweenService:Create(NContent, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

		task.delay(Duration, function()
			TweenService:Create(NotifyFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			TweenService:Create(NTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			TweenService:Create(NContent, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			wait(0.5)
			NotifyFrame:Destroy()
		end)
	end

	function Window:Dialog(options)
		options = options or {}
		local Title = options.Title or "Dialog"
		local Content = options.Content or "Are you sure?"
		local Callback = options.Callback or function() end
		
		local Overlay = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Color3.new(0,0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 10
		})
		
		local DialogFrame = Create("Frame", {
			Parent = Overlay,
			BackgroundColor3 = ModernUI.Theme.Background,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 0),
			ClipsDescendants = true
		})
		Create("UICorner", { Parent = DialogFrame, CornerRadius = ModernUI.Theme.CornerRadius })
		
		local DTitle = Create("TextLabel", {
			Parent = DialogFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 10),
			Size = UDim2.new(1, -30, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = Title,
			TextColor3 = ModernUI.Theme.Text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local DContent = Create("TextLabel", {
			Parent = DialogFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 0, 40),
			Size = UDim2.new(1, -30, 0, 60),
			Font = Enum.Font.Gotham,
			Text = Content,
			TextColor3 = ModernUI.Theme.TextDark,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true
		})
		
		local ButtonContainer = Create("Frame", {
			Parent = DialogFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 15, 1, -45),
			Size = UDim2.new(1, -30, 0, 35)
		})
		
		local function CreateDialogBtn(text, color, cb)
			local Btn = Create("TextButton", {
				Parent = ButtonContainer,
				BackgroundColor3 = color,
				Size = UDim2.new(0.5, -5, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = text,
				TextColor3 = ModernUI.Theme.Text,
				TextSize = 14
			})
			Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 4) })
			Btn.MouseButton1Click:Connect(function()
				TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(DialogFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
				wait(0.2)
				Overlay:Destroy()
				if cb then cb() end
			end)
			return Btn
		end
		
		local Confirm = CreateDialogBtn("Confirm", ModernUI.Theme.Accent, function() Callback(true) end)
		local Cancel = CreateDialogBtn("Cancel", ModernUI.Theme.Element, function() Callback(false) end)
		Cancel.Position = UDim2.new(0.5, 5, 0, 0)
		
		TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
		TweenService:Create(DialogFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 300, 0, 150)}):Play()
	end

	function Window:CreateTab(name, iconId)
		local TabButton = Create("TextButton", {
			Name = name .. "Tab",
			Parent = TabContainer,
			BackgroundColor3 = ModernUI.Theme.Background,
			Size = UDim2.new(1, 0, 0, 35),
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Text = iconId and "      " .. name or name,
			TextColor3 = ModernUI.Theme.TextDark,
			TextSize = 14,
			TextXAlignment = iconId and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			BorderSizePixel = 0
		})
		Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 4) })
		Create("UIPadding", { Parent = TabButton, PaddingLeft = UDim.new(0, 10) })

		if iconId then
			local Icon = Create("ImageLabel", {
				Parent = TabButton,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = iconId,
				ImageColor3 = ModernUI.Theme.TextDark
			})
		end

		local Page = Create("ScrollingFrame", {
			Name = name .. "Page",
			Parent = PageContainer,
			Active = true,
			BackgroundColor3 = ModernUI.Theme.Background,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			Visible = false
		})
		Create("UIListLayout", {
			Parent = Page,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		})
		Create("UIPadding", {
			Parent = Page,
			PaddingTop = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5)
		})

		local function Activate()
			for _, child in pairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = ModernUI.Theme.Background, TextColor3 = ModernUI.Theme.TextDark}):Play()
					local icon = child:FindFirstChild("ImageLabel")
					if icon then TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = ModernUI.Theme.TextDark}):Play() end
				end
			end
			for _, child in pairs(PageContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then
					child.Visible = false
				end
			end
			
			TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = ModernUI.Theme.Accent, TextColor3 = ModernUI.Theme.Text}):Play()
			local icon = TabButton:FindFirstChild("ImageLabel")
			if icon then TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = ModernUI.Theme.Text}):Play() end
			Page.Visible = true
		end

		TabButton.MouseButton1Click:Connect(Activate)

		if FirstTab then
			FirstTab = false
			Activate()
		end

		local function CreateElements(ParentContainer)
			local Container = {}

			function Container:CreateSection(text)
				local SectionFrame = Create("Frame", {
					Name = "Section",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Section,
					Size = UDim2.new(1, 0, 0, 0),
					BorderSizePixel = 0,
					ClipsDescendants = true
				})
				Create("UICorner", { Parent = SectionFrame, CornerRadius = UDim.new(0, 4) })
				
				local Header = Create("TextLabel", {
					Parent = SectionFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 5),
					Size = UDim2.new(1, -20, 0, 20),
					Font = Enum.Font.GothamBold,
					Text = text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local ContentContainer = Create("Frame", {
					Parent = SectionFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(1, 0, 0, 0)
				})
				
				local List = Create("UIListLayout", {
					Parent = ContentContainer,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8)
				})
				Create("UIPadding", {
					Parent = ContentContainer,
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10)
				})
				
				List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					ContentContainer.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 10)
					SectionFrame.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 40)
				end)
				
				return CreateElements(ContentContainer)
			end

			function Container:CreateButton(options)
				options = options or {}
				local Text = options.Text or "Button"
				local Callback = options.Callback or function() end

				local ButtonFrame = Create("TextButton", {
					Name = "Button",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 40),
					AutoButtonColor = false,
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = ButtonFrame, CornerRadius = UDim.new(0, 4) })

				ButtonFrame.MouseButton1Click:Connect(function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
					Callback()
					wait(0.1)
					TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = ModernUI.Theme.Element}):Play()
				end)
			end

			function Container:CreateToggle(options)
				options = options or {}
				local Text = options.Text or "Toggle"
				local Default = options.Default or false
				local Flag = options.Flag
				local Callback = options.Callback or function() end

				if Flag then
					Default = ModernUI.Flags[Flag] or Default
				end

				local State = Default

				local ToggleFrame = Create("TextButton", {
					Name = "Toggle",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 40),
					AutoButtonColor = false,
					Text = "",
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = ToggleFrame, CornerRadius = UDim.new(0, 4) })

				local Label = Create("TextLabel", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -60, 1, 0),
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Indicator = Create("Frame", {
					Parent = ToggleFrame,
					BackgroundColor3 = State and ModernUI.Theme.Accent or Color3.fromRGB(80, 80, 80),
					Position = UDim2.new(1, -50, 0.5, -10),
					Size = UDim2.new(0, 40, 0, 20),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = Indicator, CornerRadius = UDim.new(1, 0) })

				local Circle = Create("Frame", {
					Parent = Indicator,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = Circle, CornerRadius = UDim.new(1, 0) })

				local function Toggle(val)
					State = val
					if Flag then ModernUI.Flags[Flag] = State end
					Callback(State)

					if State then
						TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = ModernUI.Theme.Accent}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
					else
						TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
					end
				end
				
				-- Initial State
				if State then
					Indicator.BackgroundColor3 = ModernUI.Theme.Accent
					Circle.Position = UDim2.new(1, -18, 0.5, -8)
				end

				ToggleFrame.MouseButton1Click:Connect(function()
					Toggle(not State)
				end)
				
				if Flag then
					ModernUI.ConfigCallbacks[Flag] = Toggle
				end
			end

			function Container:CreateSlider(options)
				options = options or {}
				local Text = options.Text or "Slider"
				local Min = options.Min or 0
				local Max = options.Max or 100
				local Default = options.Default or Min
				local Flag = options.Flag
				local Callback = options.Callback or function() end

				if Flag then
					Default = ModernUI.Flags[Flag] or Default
				end

				local Value = Default

				local SliderFrame = Create("Frame", {
					Name = "Slider",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 50),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = SliderFrame, CornerRadius = UDim.new(0, 4) })

				local Label = Create("TextLabel", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 5),
					Size = UDim2.new(1, -20, 0, 20),
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local ValueLabel = Create("TextLabel", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 5),
					Size = UDim2.new(1, -20, 0, 20),
					Font = Enum.Font.Gotham,
					Text = tostring(Value),
					TextColor3 = ModernUI.Theme.TextDark,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Right
				})

				local SliderBar = Create("Frame", {
					Parent = SliderFrame,
					BackgroundColor3 = Color3.fromRGB(60, 60, 60),
					Position = UDim2.new(0, 10, 0, 35),
					Size = UDim2.new(1, -20, 0, 6),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = SliderBar, CornerRadius = UDim.new(1, 0) })

				local Fill = Create("Frame", {
					Parent = SliderBar,
					BackgroundColor3 = ModernUI.Theme.Accent,
					Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })

				local Trigger = Create("TextButton", {
					Parent = SliderBar,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})

				local function SetValue(val)
					Value = math.clamp(val, Min, Max)
					if Flag then ModernUI.Flags[Flag] = Value end
					ValueLabel.Text = tostring(Value)
					local Fraction = (Value - Min) / (Max - Min)
					TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(Fraction, 0, 1, 0)}):Play()
					Callback(Value)
				end

				local function Update(input)
					local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					local NewValue = math.floor(Min + ((Max - Min) * SizeX))
					SetValue(NewValue)
				end

				local Dragging = false
				Trigger.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true
						Update(input)
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						Update(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Dragging = false
					end
				end)
				
				if Flag then
					ModernUI.ConfigCallbacks[Flag] = SetValue
				end
			end

			function Container:CreateTextbox(options)
				options = options or {}
				local Text = options.Text or "Textbox"
				local Placeholder = options.Placeholder or "Enter text..."
				local Flag = options.Flag
				local Callback = options.Callback or function() end

				local TextboxFrame = Create("Frame", {
					Name = "Textbox",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 50),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = TextboxFrame, CornerRadius = UDim.new(0, 4) })

				local Label = Create("TextLabel", {
					Parent = TextboxFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 5),
					Size = UDim2.new(1, -20, 0, 20),
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Input = Create("TextBox", {
					Parent = TextboxFrame,
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					Position = UDim2.new(0, 10, 0, 25),
					Size = UDim2.new(1, -20, 0, 20),
					Font = Enum.Font.Gotham,
					PlaceholderText = Placeholder,
					Text = "",
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 13,
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = Input, CornerRadius = UDim.new(0, 4) })

				Input.FocusLost:Connect(function(enterPressed)
					if Flag then ModernUI.Flags[Flag] = Input.Text end
					Callback(Input.Text)
				end)
			end

			function Container:CreateDropdown(options)
				options = options or {}
				local Text = options.Text or "Dropdown"
				local Items = options.Items or {}
				local Flag = options.Flag
				local Callback = options.Callback or function() end

				local DropdownOpen = false

				local DropdownFrame = Create("Frame", {
					Name = "Dropdown",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 40),
					BorderSizePixel = 0,
					ClipsDescendants = true
				})
				Create("UICorner", { Parent = DropdownFrame, CornerRadius = UDim.new(0, 4) })

				local Trigger = Create("TextButton", {
					Parent = DropdownFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),
					Text = ""
				})

				local Label = Create("TextLabel", {
					Parent = DropdownFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -40, 0, 40),
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Arrow = Create("ImageLabel", {
					Parent = DropdownFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -30, 0, 10),
					Size = UDim2.new(0, 20, 0, 20),
					Image = "rbxassetid://6031091004",
					ImageColor3 = ModernUI.Theme.TextDark
				})

				local ItemContainer = Create("Frame", {
					Parent = DropdownFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 40),
					Size = UDim2.new(1, 0, 0, 0),
					ClipsDescendants = true
				})
				
				local UIList = Create("UIListLayout", {
					Parent = ItemContainer,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2)
				})
				Create("UIPadding", {
					Parent = ItemContainer,
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 5)
				})

				local function RefreshItems()
					for _, child in pairs(ItemContainer:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end

					for _, item in pairs(Items) do
						local ItemButton = Create("TextButton", {
							Parent = ItemContainer,
							BackgroundColor3 = Color3.fromRGB(60, 60, 60),
							Size = UDim2.new(1, 0, 0, 30),
							AutoButtonColor = false,
							Font = Enum.Font.Gotham,
							Text = item,
							TextColor3 = ModernUI.Theme.TextDark,
							TextSize = 13,
							BorderSizePixel = 0
						})
						Create("UICorner", { Parent = ItemButton, CornerRadius = UDim.new(0, 4) })

						ItemButton.MouseButton1Click:Connect(function()
							Label.Text = Text .. " - " .. item
							if Flag then ModernUI.Flags[Flag] = item end
							Callback(item)
							DropdownOpen = false
							TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
							TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
						end)
					end
				end

				RefreshItems()

				Trigger.MouseButton1Click:Connect(function()
					DropdownOpen = not DropdownOpen
					local ContentSize = UIList.AbsoluteContentSize.Y + 50
					if DropdownOpen then
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, ContentSize)}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
					else
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
					end
				end)
			end
			
			function Container:CreateLabel(text)
				local LabelFrame = Create("Frame", {
					Name = "Label",
					Parent = ParentContainer,
					BackgroundColor3 = Color3.fromRGB(0,0,0),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
				})
				
				local TextLabel = Create("TextLabel", {
					Parent = LabelFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.Gotham,
					Text = text,
					TextColor3 = ModernUI.Theme.TextDark,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end
			
			function Container:CreateParagraph(options)
				options = options or {}
				local Title = options.Title or "Paragraph"
				local Content = options.Content or "Content..."
				
				local ParagraphFrame = Create("Frame", {
					Name = "Paragraph",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 0),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = ParagraphFrame, CornerRadius = UDim.new(0, 4) })
				
				local PTitle = Create("TextLabel", {
					Parent = ParagraphFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 5),
					Size = UDim2.new(1, -20, 0, 20),
					Font = Enum.Font.GothamBold,
					Text = Title,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local PContent = Create("TextLabel", {
					Parent = ParagraphFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 25),
					Size = UDim2.new(1, -20, 0, 0),
					Font = Enum.Font.Gotham,
					Text = Content,
					TextColor3 = ModernUI.Theme.TextDark,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true
				})
				
				local TextSize = TextService:GetTextSize(Content, 13, Enum.Font.Gotham, Vector2.new(400, math.huge))
				PContent.Size = UDim2.new(1, -20, 0, TextSize.Y + 10)
				ParagraphFrame.Size = UDim2.new(1, 0, 0, TextSize.Y + 40)
			end

			function Container:CreateDivider()
				local Divider = Create("Frame", {
					Name = "Divider",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Divider,
					Size = UDim2.new(1, 0, 0, 1),
					BorderSizePixel = 0
				})
			end

			function Container:CreateSpacer(size)
				local Spacer = Create("Frame", {
					Name = "Spacer",
					Parent = ParentContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, size or 10)
				})
			end

			function Container:CreateKeybind(options)
				options = options or {}
				local Text = options.Text or "Keybind"
				local Default = options.Default or Enum.KeyCode.RightControl
				local Flag = options.Flag
				local Callback = options.Callback or function() end

				if Flag then
					-- Load keycode from string if needed, but for now simple
					-- ModernUI.Flags[Flag] = ...
				end

				local Key = Default

				local KeybindFrame = Create("Frame", {
					Name = "Keybind",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 40),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = KeybindFrame, CornerRadius = UDim.new(0, 4) })

				local Label = Create("TextLabel", {
					Parent = KeybindFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -100, 1, 0),
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local BindButton = Create("TextButton", {
					Parent = KeybindFrame,
					BackgroundColor3 = Color3.fromRGB(60, 60, 60),
					Position = UDim2.new(1, -90, 0.5, -12),
					Size = UDim2.new(0, 80, 0, 24),
					Font = Enum.Font.Gotham,
					Text = Key.Name,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 12,
					AutoButtonColor = false
				})
				Create("UICorner", { Parent = BindButton, CornerRadius = UDim.new(0, 4) })

				local Listening = false

				BindButton.MouseButton1Click:Connect(function()
					Listening = true
					BindButton.Text = "..."
				end)

				UserInputService.InputBegan:Connect(function(input)
					if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
						Key = input.KeyCode
						BindButton.Text = Key.Name
						Listening = false
						if Flag then ModernUI.Flags[Flag] = Key.Name end
						Callback(Key)
					elseif not Listening and input.KeyCode == Key then
						Callback(Key)
					end
				end)
			end

			function Container:CreateColorPicker(options)
				options = options or {}
				local Text = options.Text or "Color Picker"
				local Default = options.Default or Color3.fromRGB(255, 255, 255)
				local Flag = options.Flag
				local Callback = options.Callback or function() end

				local Color = Default

				local PickerFrame = Create("Frame", {
					Name = "ColorPicker",
					Parent = ParentContainer,
					BackgroundColor3 = ModernUI.Theme.Element,
					Size = UDim2.new(1, 0, 0, 40),
					BorderSizePixel = 0
				})
				Create("UICorner", { Parent = PickerFrame, CornerRadius = UDim.new(0, 4) })

				local Label = Create("TextLabel", {
					Parent = PickerFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -60, 1, 0),
					Font = Enum.Font.Gotham,
					Text = Text,
					TextColor3 = ModernUI.Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local ColorPreview = Create("TextButton", {
					Parent = PickerFrame,
					BackgroundColor3 = Color,
					Position = UDim2.new(1, -50, 0.5, -10),
					Size = UDim2.new(0, 40, 0, 20),
					Text = "",
					AutoButtonColor = false
				})
				Create("UICorner", { Parent = ColorPreview, CornerRadius = UDim.new(0, 4) })

				-- Simple Color Picker Popup (RGB Sliders)
				local PickerPopup = Create("Frame", {
					Parent = ScreenGui,
					BackgroundColor3 = ModernUI.Theme.Background,
					Size = UDim2.new(0, 200, 0, 150),
					Visible = false,
					ZIndex = 20
				})
				Create("UICorner", { Parent = PickerPopup, CornerRadius = UDim.new(0, 6) })
				
				local function UpdateColor(newColor)
					Color = newColor
					ColorPreview.BackgroundColor3 = Color
					if Flag then ModernUI.Flags[Flag] = {R=Color.R, G=Color.G, B=Color.B} end
					Callback(Color)
				end

				ColorPreview.MouseButton1Click:Connect(function()
					PickerPopup.Visible = not PickerPopup.Visible
					PickerPopup.Position = UDim2.new(0, ColorPreview.AbsolutePosition.X - 160, 0, ColorPreview.AbsolutePosition.Y + 30)
				end)
				
				-- Add Sliders to Popup (Simplified)
				local R = 0
				local G = 0
				local B = 0
				
				-- Helper for picker sliders
				local function CreatePickerSlider(y, color, onChange)
					local SFrame = Create("Frame", {
						Parent = PickerPopup,
						BackgroundColor3 = Color3.fromRGB(60,60,60),
						Position = UDim2.new(0, 10, 0, y),
						Size = UDim2.new(1, -20, 0, 20)
					})
					local Bar = Create("Frame", {
						Parent = SFrame,
						BackgroundColor3 = color,
						Size = UDim2.new(0,0,1,0)
					})
					local Btn = Create("TextButton", {
						Parent = SFrame,
						BackgroundTransparency = 1,
						Size = UDim2.new(1,0,1,0),
						Text = ""
					})
					Btn.MouseButton1Click:Connect(function() 
						-- Simple click logic, ideally drag
						local Mouse = game.Players.LocalPlayer:GetMouse()
						local RelX = math.clamp((Mouse.X - SFrame.AbsolutePosition.X) / SFrame.AbsoluteSize.X, 0, 1)
						Bar.Size = UDim2.new(RelX, 0, 1, 0)
						onChange(RelX)
					end)
				end
				
				CreatePickerSlider(10, Color3.fromRGB(255,0,0), function(v) 
					local _, g, b = Color.G, Color.B
					UpdateColor(Color3.new(v, Color.G, Color.B))
				end)
				CreatePickerSlider(40, Color3.fromRGB(0,255,0), function(v) 
					UpdateColor(Color3.new(Color.R, v, Color.B))
				end)
				CreatePickerSlider(70, Color3.fromRGB(0,0,255), function(v) 
					UpdateColor(Color3.new(Color.R, Color.G, v))
				end)
			end

			return Container
		end

		return CreateElements(Page)
	end

	return Window
end

return ModernUI
