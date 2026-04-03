--[[
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                         SpectrumX UI Library v2.1                        ║
    ║                    Professional UI Library for Roblox                    ║
    ║                                                                          ║
    ║    Melhorias na v2.1:                                                    ║
    ║    - Integração completa com ícones Lucide                             ║
    ║    - Botão flutuante arrastável (desktop e mobile)                     ║
    ║    - Suporte a Asset IDs do catálogo                                   ║
    ║    - Dropdown com ícone de seta Lucide                                 ║
    ║    - Cantos arredondados configuráveis                                 ║
    ║    - 100% compatível com versões anteriores                            ║
    ╚══════════════════════════════════════════════════════════════════════════╝
    
    Uso:
        local SpectrumX = loadstring(readfile("SpectrumX.lua"))()
        local Icons = loadstring(readfile("Icons.lua"))()
        
        local Window = SpectrumX:CreateWindow({
            Title = "Meu Script",
            Icon = "⭐",  -- Emoji ou texto
            -- ou Icon = Icons["settings"]  -- Ícone Lucide
        })
        
        local Tab = Window:CreateTab({
            Name = "Main",
            Icon = Icons["home"]  -- Ícone Lucide
        })
--]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

-- ─── SERVIÇOS ─────────────────────────────────────────────────────────────────
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ─── REFERÊNCIA AOS ÍCONES ────────────────────────────────────────────────────
-- Será carregado automaticamente se existir no mesmo diretório
local Icons = nil
local function LoadIcons()
    local success, result = pcall(function()
        return loadstring(readfile("Icons.lua"))()
    end)
    if success then
        Icons = result
        return true
    end
    return false
end

-- Tenta carregar ícones
pcall(LoadIcons)

-- ─── THEME ────────────────────────────────────────────────────────────────────
SpectrumX.Theme = {
    -- Cores base
    Background = Color3.fromRGB(8, 8, 8),
    Header = Color3.fromRGB(12, 12, 12),
    Sidebar = Color3.fromRGB(10, 10, 10),
    Card = Color3.fromRGB(16, 16, 16),
    CardHover = Color3.fromRGB(24, 24, 24),
    Input = Color3.fromRGB(22, 22, 22),
    InputHover = Color3.fromRGB(30, 30, 30),
    
    -- Cores de destaque (vermelho)
    Accent = Color3.fromRGB(220, 35, 35),
    AccentHover = Color3.fromRGB(255, 55, 55),
    AccentSecondary = Color3.fromRGB(255, 100, 100),
    AccentDark = Color3.fromRGB(140, 20, 20),
    
    -- Texto
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(190, 190, 190),
    TextMuted = Color3.fromRGB(120, 120, 120),
    
    -- Estados
    Success = Color3.fromRGB(60, 220, 100),
    Warning = Color3.fromRGB(255, 190, 60),
    Info = Color3.fromRGB(80, 160, 255),
    Error = Color3.fromRGB(255, 55, 55),
    
    -- Bordas
    Border = Color3.fromRGB(35, 35, 35),
    BorderBright = Color3.fromRGB(55, 55, 55),
    
    -- Toggle
    ToggleOff = Color3.fromRGB(35, 35, 35),
    ToggleOn = Color3.fromRGB(220, 35, 35),
}

-- ─── CONFIGURAÇÕES ────────────────────────────────────────────────────────────
SpectrumX.Config = {
    AnimationSpeed = 0.2,
    CornerRadius = 8,
    ShadowEnabled = true,
    ShadowIntensity = 0.7,
    DropdownArrowIcon = "rbxassetid://10709767827", -- lucide-arrow-down
}

-- ─── ESCALA RESPONSIVA ────────────────────────────────────────────────────────
local ScaleData = {
    IsMobile = false,
    ScaleFactor = 1,
    BaseResolution = Vector2.new(1920, 1080)
}

function SpectrumX:UpdateScale()
    local success, camera = pcall(function() return workspace.CurrentCamera end)
    if not success or not camera then return end
    
    local viewport = camera.ViewportSize
    if viewport.X == 0 then return end
    
    ScaleData.IsMobile = UserInputService.TouchEnabled and (viewport.X < 800 or viewport.Y < 600)
    
    local scaleX = viewport.X / ScaleData.BaseResolution.X
    local scaleY = viewport.Y / ScaleData.BaseResolution.Y
    ScaleData.ScaleFactor = math.min(scaleX, scaleY)
end

function SpectrumX:S(value)
    return math.floor(value * ScaleData.ScaleFactor)
end

-- ─── HELPERS ──────────────────────────────────────────────────────────────────
function SpectrumX:IsAssetId(value)
    if type(value) ~= "string" then return false end
    return value:match("^rbxassetid://%d+$") ~= nil
end

function SpectrumX:FormatAssetId(value)
    if self:IsAssetId(value) then
        return value
    end
    -- Se for apenas números, formata como rbxassetid
    if type(value) == "string" and value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    return value
end

function SpectrumX:GetIcon(iconName)
    -- Se já for um Asset ID, retorna direto
    if self:IsAssetId(iconName) then
        return iconName
    end
    
    -- Se for um número, converte para Asset ID
    if type(iconName) == "number" or (type(iconName) == "string" and iconName:match("^%d+$")) then
        return self:FormatAssetId(iconName)
    end
    
    -- Tenta pegar dos ícones Lucide
    if Icons and iconName then
        local icon = Icons[iconName]
        if icon then
            return icon
        end
    end
    
    return nil
end

function SpectrumX:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, self:S(self.Config.CornerRadius))
    corner.Parent = parent
    return corner
end

function SpectrumX:CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

function SpectrumX:CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or self.Theme.Accent),
        ColorSequenceKeypoint.new(1, color2 or self.Theme.AccentDark)
    }
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

function SpectrumX:Tween(object, properties, duration, style, direction)
    duration = duration or self.Config.AnimationSpeed
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, style, direction),
        properties
    )
    tween:Play()
    return tween
end

function SpectrumX:CreateRipple(parent, position)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X - parent.AbsolutePosition.X, 0, position.Y - parent.AbsolutePosition.Y)
    ripple.ZIndex = parent.ZIndex + 10
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    
    self:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, ripple.Position.X.Offset - maxSize/2, 0, ripple.Position.Y.Offset - maxSize/2),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        if ripple and ripple.Parent then
            ripple:Destroy()
        end
    end)
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ─── CONSTRUCTOR ──────────────────────────────────────────────────────────────
function SpectrumX.new()
    local self = setmetatable({}, SpectrumX)
    
    self:UpdateScale()
    self.Tabs = {}
    self.Dropdowns = {}
    self._notifications = {}
    self.CurrentTab = nil
    
    return self
end

-- ─── CREATE WINDOW ────────────────────────────────────────────────────────────
function SpectrumX:CreateWindow(config)
    config = config or {}
    self:UpdateScale()
    
    local windowWidth = self:S(ScaleData.IsMobile and 360 or 520)
    local windowHeight = self:S(ScaleData.IsMobile and 280 or 380)
    local sidebarWidth = self:S(ScaleData.IsMobile and 50 or 70)
    local headerHeight = self:S(42)
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SpectrumX_" .. (config.Title or "Window")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = PlayerGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    self.MainFrame.Size = config.Size or UDim2.new(0, windowWidth, 0, windowHeight)
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.ZIndex = 10
    self.MainFrame.Parent = self.ScreenGui
    self:CreateCorner(self.MainFrame, UDim.new(0, self:S(12)))
    self:CreateStroke(self.MainFrame, self.Theme.Border, 1, 0.5)
    
    -- Shadow
    if self.Config.ShadowEnabled then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0, -self:S(20), 0, -self:S(20))
        shadow.Size = UDim2.new(1, self:S(40), 1, self:S(40))
        shadow.Image = "rbxassetid://6015897843"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 1 - self.Config.ShadowIntensity
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(49, 49, 450, 450)
        shadow.ZIndex = 9
        shadow.Parent = self.MainFrame
    end
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = self.Theme.Header
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.ZIndex = 12
    header.Parent = self.MainFrame
    
    -- Header Icon
    local iconSize = self:S(22)
    local iconOffset = self:S(12)
    
    if config.Icon then
        local iconAsset = self:GetIcon(config.Icon)
        
        if iconAsset then
            -- É um Asset ID (Lucide ou catálogo)
            local iconImg = Instance.new("ImageLabel")
            iconImg.Name = "Icon"
            iconImg.BackgroundTransparency = 1
            iconImg.Position = UDim2.new(0, iconOffset, 0.5, -iconSize/2)
            iconImg.Size = UDim2.new(0, iconSize, 0, iconSize)
            iconImg.Image = iconAsset
            iconImg.ImageColor3 = self.Theme.Accent
            iconImg.ZIndex = 13
            iconImg.Parent = header
        else
            -- É texto/emoji
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Name = "Icon"
            iconLabel.BackgroundTransparency = 1
            iconLabel.Position = UDim2.new(0, iconOffset, 0, 0)
            iconLabel.Size = UDim2.new(0, iconSize, 1, 0)
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.Text = config.Icon
            iconLabel.TextColor3 = self.Theme.Accent
            iconLabel.TextSize = self:S(18)
            iconLabel.ZIndex = 13
            iconLabel.Parent = header
        end
    end
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, config.Icon and iconOffset + iconSize + self:S(8) or iconOffset, 0, 0)
    title.Size = UDim2.new(1, -(config.Icon and iconOffset + iconSize + self:S(8) or iconOffset) - self:S(80), 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title or "SpectrumX"
    title.TextColor3 = self.Theme.Text
    title.TextSize = self:S(14)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 13
    title.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -self:S(32), 0.5, -self:S(10))
    closeBtn.Size = UDim2.new(0, self:S(20), 0, self:S(20))
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = self.Theme.TextMuted
    closeBtn.TextSize = self:S(14)
    closeBtn.ZIndex = 13
    closeBtn.Parent = header
    
    closeBtn.MouseEnter:Connect(function()
        self:Tween(closeBtn, {TextColor3 = self.Theme.Error}, 0.15)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        self:Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.15)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        self.ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinBtn"
    minBtn.BackgroundTransparency = 1
    minBtn.Position = UDim2.new(1, -self:S(56), 0.5, -self:S(10))
    minBtn.Size = UDim2.new(0, self:S(20), 0, self:S(20))
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Text = "−"
    minBtn.TextColor3 = self.Theme.TextMuted
    minBtn.TextSize = self:S(18)
    minBtn.ZIndex = 13
    minBtn.Parent = header
    
    minBtn.MouseEnter:Connect(function()
        self:Tween(minBtn, {TextColor3 = self.Theme.Text}, 0.15)
    end)
    
    minBtn.MouseLeave:Connect(function()
        self:Tween(minBtn, {TextColor3 = self.Theme.TextMuted}, 0.15)
    end)
    
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        self:Tween(self.ContentArea, {Visible = not minimized}, 0)
        self:Tween(self.Sidebar, {Visible = not minimized}, 0)
        minBtn.Text = minimized and "+" or "−"
    end)
    
    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, headerHeight)
    self.Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -headerHeight)
    self.Sidebar.ZIndex = 11
    self.Sidebar.Parent = self.MainFrame
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, self:S(8))
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, self:S(10))
    sidebarPadding.PaddingLeft = UDim.new(0, self:S(ScaleData.IsMobile and 6 or 12))
    sidebarPadding.PaddingRight = UDim.new(0, self:S(ScaleData.IsMobile and 6 or 12))
    sidebarPadding.Parent = self.Sidebar
    
    -- Content Area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, sidebarWidth, 0, headerHeight)
    self.ContentArea.Size = UDim2.new(1, -sidebarWidth, 1, -headerHeight)
    self.ContentArea.ZIndex = 11
    self.ContentArea.Parent = self.MainFrame
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, header)
    
    -- Create floating button if enabled
    if config.FloatButton ~= false then
        self:CreateFloatButton(config)
    end
    
    return self
end


-- ─── CREATE FLOATING BUTTON ───────────────────────────────────────────────────
function SpectrumX:CreateFloatButton(config)
    local floatSize = self:S(50)
    local cornerRadius = 0.15 -- Corner radius configurável (15% do tamanho)
    
    -- Container do botão flutuante
    self.FloatBtn = Instance.new("TextButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.BorderSizePixel = 0
    -- Posição: meio da tela, um pouco mais pra esquerda
    self.FloatBtn.Position = UDim2.new(0.35, 0, 0.5, 0) -- 35% da tela (mais pra esquerda)
    self.FloatBtn.Size = UDim2.new(0, floatSize, 0, floatSize)
    self.FloatBtn.Text = ""
    self.FloatBtn.AutoButtonColor = false
    self.FloatBtn.ZIndex = 100
    self.FloatBtn.Parent = self.ScreenGui
    
    -- Corner radius arredondado mas não muito (0.15)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(cornerRadius, 0)
    corner.Parent = self.FloatBtn
    
    -- Sombra do botão flutuante
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -self:S(8), 0, -self:S(8))
    shadow.Size = UDim2.new(1, self:S(16), 1, self:S(16))
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 99
    shadow.Parent = self.FloatBtn
    
    -- Determina o ícone do botão flutuante
    -- Prioridade: FloatIconAssetId > FloatIcon > IconAssetId > Icon > "S"
    local floatIcon = config.FloatIconAssetId or config.FloatIcon or config.IconAssetId or config.Icon or "S"
    local floatIconAsset = self:GetIcon(floatIcon)
    
    if floatIconAsset then
        -- É um Asset ID (Lucide ou catálogo)
        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "Icon"
        iconImg.BackgroundTransparency = 1
        iconImg.Size = UDim2.new(0.6, 0, 0.6, 0)
        iconImg.Position = UDim2.new(0.2, 0, 0.2, 0)
        iconImg.Image = floatIconAsset
        iconImg.ImageColor3 = Color3.new(1, 1, 1)
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.ZIndex = 102
        iconImg.Parent = self.FloatBtn
    else
        -- Texto/emoji
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.BackgroundTransparency = 1
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.Font = Enum.Font.GothamBlack
        iconLabel.Text = floatIcon
        iconLabel.TextColor3 = Color3.new(1, 1, 1)
        iconLabel.TextSize = self:S(22)
        iconLabel.ZIndex = 102
        iconLabel.Parent = self.FloatBtn
    end
    
    -- Hover effects
    self.FloatBtn.MouseEnter:Connect(function()
        self:Tween(self.FloatBtn, {BackgroundColor3 = self.Theme.AccentHover}, 0.15)
    end)
    
    self.FloatBtn.MouseLeave:Connect(function()
        self:Tween(self.FloatBtn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
    end)
    
    -- Drag do botão flutuante (Desktop e Mobile)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local wasDragging = false
    
    self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            wasDragging = false
            dragStart = input.Position
            startPos = self.FloatBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.FloatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            -- Só considera drag se mover mais de 5 pixels
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                wasDragging = true
            end
            self.FloatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Clique para mostrar/esconder
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not wasDragging then
            local visible = not self.MainFrame.Visible
            self.MainFrame.Visible = visible
            
            if visible then
                self.MainFrame.BackgroundTransparency = 1
                self:Tween(self.MainFrame, {BackgroundTransparency = 0}, 0.25)
            end
        end
    end)
end

-- ─── CREATE TAB ───────────────────────────────────────────────────────────────
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local btnSize = self:S(46)
    
    -- Determina o ícone da tab
    local tabIconAsset = nil
    local tabIconText = nil
    
    if config.Icon then
        tabIconAsset = self:GetIcon(config.Icon)
        if not tabIconAsset then
            tabIconText = config.Icon
        end
    elseif config.IconAssetId then
        tabIconAsset = self:FormatAssetId(config.IconAssetId)
    else
        tabIconText = tabId:sub(1, 1)
    end
    
    -- Botão da tab
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = self.Theme.Card
    tabBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 13
    tabBtn.Parent = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, 10))
    
    -- Ícone da tab
    if tabIconAsset then
        -- Asset ID (Lucide ou catálogo)
        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "Icon"
        iconImg.BackgroundTransparency = 1
        iconImg.Position = UDim2.new(0.5, -12, 0.5, -12)
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.Image = tabIconAsset
        iconImg.ImageColor3 = self.Theme.TextMuted
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.ZIndex = 14
        iconImg.Parent = tabBtn
    else
        -- Texto/emoji
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.BackgroundTransparency = 1
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.Text = tabIconText
        iconLabel.TextColor3 = self.Theme.TextMuted
        iconLabel.TextSize = self:S(16)
        iconLabel.ZIndex = 14
        iconLabel.Parent = tabBtn
    end
    
    -- Tooltip
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tooltip.BorderSizePixel = 0
    tooltip.Position = UDim2.new(1, self:S(10), 0.5, -self:S(11))
    tooltip.Size = UDim2.new(0, 0, 0, self:S(22))
    tooltip.AutomaticSize = Enum.AutomaticSize.X
    tooltip.Font = Enum.Font.GothamSemibold
    tooltip.Text = "  " .. tabId .. "  "
    tooltip.TextColor3 = self.Theme.Text
    tooltip.TextSize = self:S(11)
    tooltip.Visible = false
    tooltip.ZIndex = 1000
    tooltip.Parent = tabBtn
    self:CreateCorner(tooltip, UDim.new(0, 5))
    self:CreateStroke(tooltip, self.Theme.Border, 1, 0.3)
    
    -- Hover effects
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabId then
            self:Tween(tabBtn, {BackgroundColor3 = self.Theme.CardHover}, 0.15)
        end
        tooltip.Visible = true
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabId then
            self:Tween(tabBtn, {BackgroundColor3 = self.Theme.Card}, 0.15)
        end
        tooltip.Visible = false
    end)
    
    -- Container da página
    local page = Instance.new("Frame")
    page.Name = tabId .. "Page"
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.ZIndex = 11
    page.Parent = self.ContentArea
    
    -- Divisor central
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = self.Theme.Border
    divider.BorderSizePixel = 0
    divider.Position = UDim2.new(0.5, -1, 0, 0)
    divider.Size = UDim2.new(0, 1, 1, 0)
    divider.ZIndex = 11
    divider.Parent = page
    
    -- Função helper para criar lado
    local function createSide(position, size, name)
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = name
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Position = position
        scrollFrame.Size = size
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = self.Theme.Accent
        scrollFrame.ScrollBarImageTransparency = 0.5
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ZIndex = 11
        scrollFrame.Parent = page
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, self:S(8))
        layout.Parent = scrollFrame
        
        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, self:S(10))
        padding.Parent = scrollFrame
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + self:S(20))
        end)
        
        return scrollFrame
    end
    
    local left = createSide(UDim2.new(0, 0, 0, 0), UDim2.new(0.49, 0, 1, 0), "Left")
    local right = createSide(UDim2.new(0.51, 0, 0, 0), UDim2.new(0.49, 0, 1, 0), "Right")
    
    -- Salvar dados da tab
    local tabData = {
        Button = tabBtn,
        Container = page,
        Left = left,
        Right = right,
        Id = tabId
    }
    self.Tabs[tabId] = tabData
    
    -- Evento de clique
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabId)
    end)
    
    -- Selecionar primeira tab automaticamente
    if not self.CurrentTab then
        self:SelectTab(tabId)
    end
    
    return tabData
end

-- ─── SELECT TAB ───────────────────────────────────────────────────────────────
function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        local icon = data.Button:FindFirstChild("Icon")
        
        if id == tabId then
            -- Ativar esta tab
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            
            if icon then
                if icon:IsA("TextLabel") then
                    self:Tween(icon, {TextColor3 = Color3.new(1, 1, 1)}, 0.2)
                elseif icon:IsA("ImageLabel") then
                    self:Tween(icon, {ImageColor3 = Color3.new(1, 1, 1)}, 0.2)
                end
            end
        else
            -- Desativar outras tabs
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Card}, 0.2)
            
            if icon then
                if icon:IsA("TextLabel") then
                    self:Tween(icon, {TextColor3 = self.Theme.TextMuted}, 0.2)
                elseif icon:IsA("ImageLabel") then
                    self:Tween(icon, {ImageColor3 = self.Theme.TextMuted}, 0.2)
                end
            end
        end
    end
    
    self.CurrentTab = tabId
end

-- ─── CREATE SECTION ───────────────────────────────────────────────────────────
function SpectrumX:CreateSection(parent, text, color)
    local wrap = Instance.new("Frame")
    wrap.Name = "Section_" .. text
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, 0, 0, self:S(26))
    wrap.ZIndex = 12
    wrap.Parent = parent
    
    -- Linha decorativa
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.BackgroundColor3 = color or self.Theme.Accent
    line.BorderSizePixel = 0
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.ZIndex = 11
    line.Parent = wrap
    
    -- Texto da seção
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundColor3 = self.Theme.Background
    label.BorderSizePixel = 0
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Position = UDim2.new(0, self:S(6), 0, 0)
    label.Size = UDim2.new(0, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.Text = "  " .. text .. "  "
    label.TextColor3 = color or self.Theme.Accent
    label.TextSize = self:S(11)
    label.ZIndex = 13
    label.Parent = wrap
    
    return wrap
end


-- ─── CREATE TOGGLE ────────────────────────────────────────────────────────────
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local height = self:S(46)
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. text
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.5)
    
    -- Efeito hover
    local hoverFill = Instance.new("Frame")
    hoverFill.Name = "HoverFill"
    hoverFill.BackgroundColor3 = Color3.new(1, 1, 1)
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Size = UDim2.new(1, 0, 1, 0)
    hoverFill.ZIndex = 0
    hoverFill.Parent = frame
    self:CreateCorner(hoverFill)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, 0)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:S(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.ZIndex = 13
    label.Parent = frame
    
    -- Track do toggle
    local trackWidth, trackHeight = self:S(46), self:S(24)
    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.AutoButtonColor = false
    track.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    track.Position = UDim2.new(1, -trackWidth - self:S(14), 0.5, -trackHeight/2)
    track.Size = UDim2.new(0, trackWidth, 0, trackHeight)
    track.Text = ""
    track.ZIndex = 14
    track.Parent = frame
    self:CreateCorner(track, UDim.new(1, 0))
    self:CreateStroke(track, default and self.Theme.Accent or self.Theme.Border, 1, default and 0.2 or 0.5)
    
    local trackStroke = track:FindFirstChildOfClass("UIStroke")
    
    -- Knob
    local knobSize = self:S(18)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Position = default and UDim2.new(1, -knobSize - self:S(3), 0.5, -knobSize/2)
                             or UDim2.new(0, self:S(3), 0.5, -knobSize/2)
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.ZIndex = 15
    knob.Parent = track
    self:CreateCorner(knob, UDim.new(1, 0))
    self:CreateStroke(knob, Color3.fromRGB(200, 200, 200), 1, 0.3)
    
    local state = default
    
    local function update(newState, animated)
        local time = animated == false and 0 or 0.2
        state = newState
        
        if state then
            self:Tween(track, {BackgroundColor3 = self.Theme.ToggleOn}, time)
            if trackStroke then
                self:Tween(trackStroke, {Color = self.Theme.Accent, Transparency = 0.2}, time)
            end
            self:Tween(knob, {
                Position = UDim2.new(1, -knobSize - self:S(3), 0.5, -knobSize/2)
            }, time, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self:Tween(track, {BackgroundColor3 = self.Theme.ToggleOff}, time)
            if trackStroke then
                self:Tween(trackStroke, {Color = self.Theme.Border, Transparency = 0.5}, time)
            end
            self:Tween(knob, {
                Position = UDim2.new(0, self:S(3), 0.5, -knobSize/2)
            }, time, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
    
    track.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        update(state)
    end)
    
    -- Hover
    frame.MouseEnter:Connect(function()
        self:Tween(hoverFill, {BackgroundTransparency = 0.97}, 0.15)
    end)
    
    frame.MouseLeave:Connect(function()
        self:Tween(hoverFill, {BackgroundTransparency = 1}, 0.15)
    end)
    
    return {
        Frame = frame,
        GetState = function() return state end,
        SetState = function(s) state = s; callback(state); update(state) end,
    }
end

-- ─── CREATE BUTTON ────────────────────────────────────────────────────────────
function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local style = config.Style or "default"
    local callback = config.Callback or function() end
    local icon = config.Icon -- Suporte a ícone no botão
    
    local height = self:S(40)
    
    local frame = Instance.new("Frame")
    frame.Name = "Button_" .. text
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = self:S(13)
    btn.ZIndex = 13
    btn.Parent = frame
    self:CreateCorner(btn)
    
    -- Adicionar ícone se especificado
    if icon then
        local iconAsset = self:GetIcon(icon)
        local iconSize = self:S(18)
        
        if iconAsset then
            local iconImg = Instance.new("ImageLabel")
            iconImg.Name = "Icon"
            iconImg.BackgroundTransparency = 1
            iconImg.Position = UDim2.new(0, self:S(12), 0.5, -iconSize/2)
            iconImg.Size = UDim2.new(0, iconSize, 0, iconSize)
            iconImg.Image = iconAsset
            iconImg.ImageColor3 = Color3.new(1, 1, 1)
            iconImg.ZIndex = 14
            iconImg.Parent = btn
            
            -- Ajustar texto para dar espaço ao ícone
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = "    " .. text
        end
    end
    
    local color, textColor
    if style == "accent" then
        btn.BackgroundColor3 = self.Theme.Accent
        textColor = Color3.new(1, 1, 1)
        color = self.Theme.Accent
    elseif style == "warning" then
        btn.BackgroundColor3 = Color3.fromRGB(40, 25, 0)
        textColor = self.Theme.Warning
        color = self.Theme.Warning
    elseif style == "info" then
        btn.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
        textColor = self.Theme.Info
        color = self.Theme.Info
    elseif style == "danger" then
        btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        textColor = self.Theme.Error
        color = self.Theme.Error
    else -- default/outline
        btn.BackgroundColor3 = self.Theme.Card
        textColor = self.Theme.Text
        color = self.Theme.Border
    end
    
    btn.TextColor3 = textColor
    
    local stroke = self:CreateStroke(btn, color, 1.2, style == "accent" and 1 or 0.4)
    
    if style == "accent" then
        self:CreateGradient(btn, self.Theme.Accent, self.Theme.AccentDark, 90)
    end
    
    -- Container para ripple
    local rippleHolder = Instance.new("Frame")
    rippleHolder.Name = "RippleHolder"
    rippleHolder.BackgroundTransparency = 1
    rippleHolder.BorderSizePixel = 0
    rippleHolder.Size = UDim2.new(1, 0, 1, 0)
    rippleHolder.ClipsDescendants = true
    rippleHolder.ZIndex = btn.ZIndex + 1
    rippleHolder.Parent = btn
    self:CreateCorner(rippleHolder)
    
    -- Hover
    btn.MouseEnter:Connect(function()
        if style == "accent" then
            self:Tween(btn, {BackgroundColor3 = self.Theme.AccentHover}, 0.15)
        else
            self:Tween(btn, {BackgroundColor3 = self.Theme.CardHover}, 0.15)
            if stroke then
                self:Tween(stroke, {Transparency = 0.1}, 0.15)
            end
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if style == "accent" then
            self:Tween(btn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
        else
            self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.15)
            if stroke then
                self:Tween(stroke, {Transparency = style == "accent" and 1 or 0.4}, 0.15)
            end
        end
    end)
    
    -- Clique
    btn.MouseButton1Click:Connect(function()
        self:CreateRipple(btn, UserInputService:GetMouseLocation())
        callback()
    end)
    
    return {
        Frame = frame,
        Button = btn,
        SetText = function(t) btn.Text = icon and "    " .. t or t end,
        SetCallback = function(cb) callback = cb end,
    }
end

-- ─── CREATE INPUT ─────────────────────────────────────────────────────────────
function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Input"
    local default = config.Default or ""
    local placeholder = config.Placeholder or "Digite aqui..."
    local callback = config.Callback or function() end
    
    local height = self:S(62)
    
    local frame = Instance.new("Frame")
    frame.Name = "Input_" .. labelText
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local stroke = self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, self:S(10))
    label.Size = UDim2.new(1, -self:S(28), 0, self:S(16))
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.TextMuted
    label.TextSize = self:S(10)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- TextBox
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.BackgroundColor3 = self.Theme.Input
    textBox.Position = UDim2.new(0, self:S(12), 0, self:S(28))
    textBox.Size = UDim2.new(1, -self:S(24), 0, self:S(26))
    textBox.Font = Enum.Font.Gotham
    textBox.Text = tostring(default)
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = self.Theme.TextMuted
    textBox.TextColor3 = self.Theme.Text
    textBox.TextSize = self:S(13)
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 14
    textBox.Parent = frame
    self:CreateCorner(textBox, UDim.new(0, 6))
    
    -- Foco
    textBox.Focused:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Accent, Transparency = 0.1}, 0.2)
        self:Tween(label, {TextColor3 = self.Theme.Accent}, 0.2)
    end)
    
    textBox.FocusLost:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        self:Tween(label, {TextColor3 = self.Theme.TextMuted}, 0.2)
        callback(textBox.Text)
    end)
    
    return {
        Frame = frame,
        TextBox = textBox,
        GetText = function() return textBox.Text end,
        SetText = function(t) textBox.Text = t end,
    }
end

-- ─── CREATE NUMBER INPUT ──────────────────────────────────────────────────────
function SpectrumX:CreateNumberInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Number"
    local default = config.Default or 0
    local min = config.Min or -math.huge
    local max = config.Max or math.huge
    local callback = config.Callback or function() end
    
    local height = self:S(62)
    
    local frame = Instance.new("Frame")
    frame.Name = "NumberInput_" .. labelText
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local stroke = self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, self:S(10))
    label.Size = UDim2.new(1, -self:S(28), 0, self:S(16))
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.TextMuted
    label.TextSize = self:S(10)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- TextBox
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.BackgroundColor3 = self.Theme.Input
    textBox.Position = UDim2.new(0, self:S(12), 0, self:S(28))
    textBox.Size = UDim2.new(1, -self:S(24), 0, self:S(26))
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = tostring(default)
    textBox.TextColor3 = self.Theme.Text
    textBox.TextSize = self:S(13)
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 14
    textBox.Parent = frame
    self:CreateCorner(textBox, UDim.new(0, 6))
    
    -- Foco
    textBox.Focused:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Accent, Transparency = 0.1}, 0.2)
        self:Tween(label, {TextColor3 = self.Theme.Accent}, 0.2)
    end)
    
    textBox.FocusLost:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        self:Tween(label, {TextColor3 = self.Theme.TextMuted}, 0.2)
        
        local value = tonumber(textBox.Text)
        if value then
            value = math.clamp(value, min, max)
            textBox.Text = tostring(value)
            callback(value)
        else
            textBox.Text = tostring(default)
        end
    end)
    
    return {
        Frame = frame,
        TextBox = textBox,
        GetValue = function() return tonumber(textBox.Text) end,
        SetValue = function(v)
            v = math.clamp(v, min, max)
            textBox.Text = tostring(v)
        end,
    }
end


-- ─── CREATE SLIDER ────────────────────────────────────────────────────────────
function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local height = self:S(62)
    
    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. text
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, self:S(10))
    label.Size = UDim2.new(0.6, 0, 0, self:S(18))
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:S(12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- Valor display
    local valueBg = Instance.new("Frame")
    valueBg.Name = "ValueBg"
    valueBg.BackgroundColor3 = self.Theme.Accent
    valueBg.Position = UDim2.new(1, -self:S(42), 0, self:S(8))
    valueBg.Size = UDim2.new(0, self:S(36), 0, self:S(22))
    valueBg.ZIndex = 14
    valueBg.Parent = frame
    self:CreateCorner(valueBg, UDim.new(0, 5))
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.TextSize = self:S(11)
    valueLabel.ZIndex = 15
    valueLabel.Parent = valueBg
    
    -- Track background
    local trackHeight = self:S(6)
    local trackBg = Instance.new("Frame")
    trackBg.Name = "TrackBg"
    trackBg.BackgroundColor3 = self.Theme.Input
    trackBg.Position = UDim2.new(0, self:S(14), 1, -self:S(20))
    trackBg.Size = UDim2.new(1, -self:S(28), 0, trackHeight)
    trackBg.ZIndex = 13
    trackBg.Parent = frame
    self:CreateCorner(trackBg, UDim.new(1, 0))
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.ZIndex = 14
    fill.Parent = trackBg
    self:CreateCorner(fill, UDim.new(1, 0))
    self:CreateGradient(fill, self.Theme.Accent, self.Theme.AccentDark, 0)
    
    -- Knob
    local knobSize = self:S(16)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Position = UDim2.new((default - min) / (max - min), -knobSize/2, 0.5, -knobSize/2)
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.ZIndex = 15
    knob.Parent = trackBg
    self:CreateCorner(knob, UDim.new(1, 0))
    self:CreateStroke(knob, self.Theme.Accent, 2, 0)
    
    local dragging = false
    local currentValue = default
    
    local function update(input)
        local percent = math.clamp(
            (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
            0, 1
        )
        local value = math.floor((min + (max - min) * percent) * 100) / 100
        currentValue = value
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -knobSize/2, 0.5, -knobSize/2)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return {
        Frame = frame,
        GetValue = function() return currentValue end,
        SetValue = function(v)
            v = math.clamp(v, min, max)
            currentValue = v
            local percent = (v - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -knobSize/2, 0.5, -knobSize/2)
            valueLabel.Text = tostring(v)
        end,
    }
end

-- ─── HELPER: POSIÇÃO DO DROPDOWN ──────────────────────────────────────────────
local function getDropdownPosition(button, layout, maxHeight)
    local btnPos = button.AbsolutePosition
    local btnSize = button.AbsoluteSize
    local contentHeight = layout.AbsoluteContentSize.Y + 12
    local targetHeight = math.min(contentHeight, maxHeight)
    
    local success, camera = pcall(function() return workspace.CurrentCamera end)
    local screenHeight = (success and camera) and camera.ViewportSize.Y or 768
    
    local targetY = btnPos.Y + btnSize.Y + 4
    if targetY + targetHeight > screenHeight then
        targetY = btnPos.Y - targetHeight - 4
    end
    
    return UDim2.fromOffset(btnPos.X, targetY), targetHeight, contentHeight
end

-- ─── CREATE DROPDOWN ────────────────────────────────────────────────────────────
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local height = self:S(62)
    
    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. labelText
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ClipsDescendants = false
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, self:S(10))
    label.Size = UDim2.new(1, -self:S(28), 0, self:S(14))
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.TextMuted
    label.TextSize = self:S(10)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- Botão do dropdown
    local dropBtn = Instance.new("TextButton")
    dropBtn.Name = "DropBtn"
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.AutoButtonColor = false
    dropBtn.Position = UDim2.new(0, self:S(12), 0, self:S(26))
    dropBtn.Size = UDim2.new(1, -self:S(24), 0, self:S(28))
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.Text = "  " .. (default or "Selecionar...")
    dropBtn.TextColor3 = default and self.Theme.Text or self.Theme.TextMuted
    dropBtn.TextSize = self:S(12)
    dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.ZIndex = 14
    dropBtn.Parent = frame
    self:CreateCorner(dropBtn, UDim.new(0, 6))
    
    local dropStroke = self:CreateStroke(dropBtn, self.Theme.Border, 1, 0.4)
    
    -- Seta usando ícone Lucide (arrow-down)
    local arrowSize = self:S(16)
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -self:S(26), 0.5, -arrowSize/2)
    arrow.Size = UDim2.new(0, arrowSize, 0, arrowSize)
    arrow.Image = self.Config.DropdownArrowIcon -- lucide-arrow-down
    arrow.ImageColor3 = self.Theme.Accent
    arrow.ZIndex = 15
    arrow.Parent = dropBtn
    
    -- Lista do dropdown
    local dropList = Instance.new("ScrollingFrame")
    dropList.Name = "DropList"
    dropList.BackgroundColor3 = self.Theme.Card
    dropList.Size = UDim2.new(0, 0, 0, 0)
    dropList.ScrollBarThickness = 3
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible = false
    dropList.ZIndex = 100
    dropList.BorderSizePixel = 0
    dropList.Parent = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0, 8))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0.2)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, self:S(3))
    listLayout.Parent = dropList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingBottom = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = dropList
    
    local selected = default
    local isOpen = false
    local maxHeight = self:S(200)
    
    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        if dropStroke then
            self:Tween(dropStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        end
        task.wait(0.2)
        if dropList and dropList.Parent then
            dropList.Visible = false
        end
    end
    
    self:_RegisterDropdown(dropList, dropBtn, closeDropdown)
    
    local function populate()
        for _, child in ipairs(dropList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        for _, option in ipairs(options) do
            local isSelected = option == selected
            
            local row = Instance.new("Frame")
            row.BackgroundColor3 = isSelected and Color3.fromRGB(40, 10, 10) or self.Theme.Input
            row.Size = UDim2.new(1, 0, 0, self:S(30))
            row.ZIndex = 101
            row.Parent = dropList
            self:CreateCorner(row, UDim.new(0, 5))
            
            if isSelected then
                self:CreateStroke(row, self.Theme.Accent, 1, 0.2)
                
                -- Indicador
                local dot = Instance.new("Frame")
                dot.BackgroundColor3 = self.Theme.Accent
                dot.Position = UDim2.new(0, self:S(8), 0.5, -self:S(4))
                dot.Size = UDim2.new(0, self:S(8), 0, self:S(8))
                dot.ZIndex = 102
                dot.Parent = row
                self:CreateCorner(dot, UDim.new(1, 0))
            end
            
            local rowBtn = Instance.new("TextButton")
            rowBtn.BackgroundTransparency = 1
            rowBtn.Size = UDim2.new(1, 0, 1, 0)
            rowBtn.Font = Enum.Font.GothamSemibold
            rowBtn.Text = (isSelected and "   " or "  ") .. option
            rowBtn.TextColor3 = isSelected and self.Theme.AccentSecondary or self.Theme.TextSecondary
            rowBtn.TextSize = self:S(12)
            rowBtn.TextXAlignment = Enum.TextXAlignment.Left
            rowBtn.ZIndex = 102
            rowBtn.Parent = row
            
            local rowPad = Instance.new("UIPadding")
            rowPad.PaddingLeft = UDim.new(0, self:S(12))
            rowPad.Parent = rowBtn
            
            rowBtn.MouseButton1Click:Connect(function()
                selected = option
                dropBtn.Text = "  " .. option
                dropBtn.TextColor3 = self.Theme.Text
                callback(option)
                closeDropdown()
            end)
            
            rowBtn.MouseEnter:Connect(function()
                if not isSelected then
                    self:Tween(row, {BackgroundColor3 = self.Theme.CardHover}, 0.1)
                end
            end)
            
            rowBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(row, {BackgroundColor3 = self.Theme.Input}, 0.1)
                end
            end)
        end
    end
    
    dropBtn.MouseEnter:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.InputHover}, 0.15)
    end)
    
    dropBtn.MouseLeave:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.15)
    end)
    
    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
            return
        end
        
        -- Fechar outros dropdowns
        for _, dd in ipairs(self.Dropdowns) do
            if dd ~= dropList then dd.Visible = false end
        end
        
        populate()
        local pos, targetH, contentH = getDropdownPosition(dropBtn, listLayout, maxHeight)
        dropList.Position = pos
        dropList.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
        dropList.CanvasSize = UDim2.new(0, 0, 0, contentH)
        dropList.Visible = true
        
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, targetH)}, 0.25,
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        self:Tween(arrow, {Rotation = 180}, 0.2)
        if dropStroke then
            self:Tween(dropStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
        end
        isOpen = true
    end)
    
    return {
        Frame = frame,
        GetValue = function() return selected end,
        SetValue = function(v)
            selected = v
            dropBtn.Text = "  " .. (v or "Selecionar...")
        end,
        SetOptions = function(newOptions)
            options = newOptions
            if isOpen then populate() end
        end,
    }
end

-- ─── REGISTRAR DROPDOWN ───────────────────────────────────────────────────────
function SpectrumX:_RegisterDropdown(dropList, dropBtn, closeFunc)
    table.insert(self.Dropdowns, dropList)
    
    -- Fechar ao clicar fora
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local listPos = dropList.AbsolutePosition
            local listSize = dropList.AbsoluteSize
            local btnPos = dropBtn.AbsolutePosition
            local btnSize = dropBtn.AbsoluteSize
            
            local inList = pos.X >= listPos.X and pos.X <= listPos.X + listSize.X and
                          pos.Y >= listPos.Y and pos.Y <= listPos.Y + listSize.Y
            local inBtn = pos.X >= btnPos.X and pos.X <= btnPos.X + btnSize.X and
                         pos.Y >= btnPos.Y and pos.Y <= btnPos.Y + btnSize.Y
            
            if not inList and not inBtn then
                closeFunc()
            end
        end
    end)
end


-- ─── CREATE MULTI DROPDOWN ────────────────────────────────────────────────────
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Multi Select"
    local options = config.Options or {}
    local default = config.Default or {}
    local callback = config.Callback or function() end
    
    local height = self:S(62)
    
    local frame = Instance.new("Frame")
    frame.Name = "MultiDropdown_" .. labelText
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ClipsDescendants = false
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, self:S(10))
    label.Size = UDim2.new(1, -self:S(28), 0, self:S(14))
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.TextMuted
    label.TextSize = self:S(10)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- Botão
    local dropBtn = Instance.new("TextButton")
    dropBtn.Name = "DropBtn"
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.AutoButtonColor = false
    dropBtn.Position = UDim2.new(0, self:S(12), 0, self:S(26))
    dropBtn.Size = UDim2.new(1, -self:S(24), 0, self:S(28))
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.Text = "  Selecionar..."
    dropBtn.TextColor3 = self.Theme.TextMuted
    dropBtn.TextSize = self:S(12)
    dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.ZIndex = 14
    dropBtn.Parent = frame
    self:CreateCorner(dropBtn, UDim.new(0, 6))
    
    local dropStroke = self:CreateStroke(dropBtn, self.Theme.Border, 1, 0.4)
    
    -- Seta usando ícone Lucide
    local arrowSize = self:S(16)
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -self:S(26), 0.5, -arrowSize/2)
    arrow.Size = UDim2.new(0, arrowSize, 0, arrowSize)
    arrow.Image = self.Config.DropdownArrowIcon
    arrow.ImageColor3 = self.Theme.Accent
    arrow.ZIndex = 15
    arrow.Parent = dropBtn
    
    -- Lista
    local dropList = Instance.new("ScrollingFrame")
    dropList.Name = "MultiDropList"
    dropList.BackgroundColor3 = self.Theme.Card
    dropList.Size = UDim2.new(0, 0, 0, 0)
    dropList.ScrollBarThickness = 3
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible = false
    dropList.ZIndex = 100
    dropList.BorderSizePixel = 0
    dropList.Parent = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0, 8))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0.2)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, self:S(3))
    listLayout.Parent = dropList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingBottom = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = dropList
    
    local selected = {}
    for _, v in ipairs(default) do table.insert(selected, v) end
    local isOpen = false
    local maxHeight = self:S(200)
    
    local function updateText()
        if #selected == 0 then
            dropBtn.Text = "  Selecionar..."
            dropBtn.TextColor3 = self.Theme.TextMuted
        elseif #selected == 1 then
            dropBtn.Text = "  " .. selected[1]
            dropBtn.TextColor3 = self.Theme.Text
        else
            dropBtn.Text = "  " .. #selected .. " selecionados"
            dropBtn.TextColor3 = self.Theme.Text
        end
    end
    
    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        if dropStroke then
            self:Tween(dropStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        end
        task.wait(0.2)
        if dropList and dropList.Parent then
            dropList.Visible = false
        end
    end
    
    self:_RegisterDropdown(dropList, dropBtn, closeDropdown)
    
    local function getPriority(name)
        for i, v in ipairs(selected) do
            if v == name then return i end
        end
        return nil
    end
    
    local function toggle(name)
        for i, v in ipairs(selected) do
            if v == name then
                table.remove(selected, i)
                return
            end
        end
        table.insert(selected, name)
    end
    
    local function populate()
        for _, child in ipairs(dropList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        for _, option in ipairs(options) do
            local priority = getPriority(option)
            local isSelected = priority ~= nil
            
            local row = Instance.new("Frame")
            row.BackgroundColor3 = isSelected and Color3.fromRGB(40, 10, 10) or self.Theme.Input
            row.Size = UDim2.new(1, 0, 0, self:S(30))
            row.ZIndex = 101
            row.Parent = dropList
            self:CreateCorner(row, UDim.new(0, 5))
            
            if isSelected then
                self:CreateStroke(row, self.Theme.Accent, 1, 0.2)
                
                -- Badge com número
                local badge = Instance.new("TextLabel")
                badge.BackgroundColor3 = self.Theme.Accent
                badge.Position = UDim2.new(0, self:S(6), 0.5, -self:S(9))
                badge.Size = UDim2.new(0, self:S(18), 0, self:S(18))
                badge.Font = Enum.Font.GothamBold
                badge.Text = tostring(priority)
                badge.TextColor3 = Color3.new(1, 1, 1)
                badge.TextSize = self:S(10)
                badge.ZIndex = 102
                badge.Parent = row
                self:CreateCorner(badge, UDim.new(1, 0))
            end
            
            local rowBtn = Instance.new("TextButton")
            rowBtn.BackgroundTransparency = 1
            rowBtn.Size = UDim2.new(1, 0, 1, 0)
            rowBtn.Font = Enum.Font.GothamSemibold
            rowBtn.Text = (isSelected and "      " or "  ") .. option
            rowBtn.TextColor3 = isSelected and self.Theme.AccentSecondary or self.Theme.TextSecondary
            rowBtn.TextSize = self:S(12)
            rowBtn.TextXAlignment = Enum.TextXAlignment.Left
            rowBtn.ZIndex = 102
            rowBtn.Parent = row
            
            local rowPad = Instance.new("UIPadding")
            rowPad.PaddingLeft = UDim.new(0, self:S(12))
            rowPad.Parent = rowBtn
            
            rowBtn.MouseButton1Click:Connect(function()
                toggle(option)
                callback(selected)
                updateText()
                populate()
            end)
            
            rowBtn.MouseEnter:Connect(function()
                if not isSelected then
                    self:Tween(row, {BackgroundColor3 = self.Theme.CardHover}, 0.1)
                end
            end)
            
            rowBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(row, {BackgroundColor3 = self.Theme.Input}, 0.1)
                end
            end)
        end
    end
    
    dropBtn.MouseEnter:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.InputHover}, 0.15)
    end)
    
    dropBtn.MouseLeave:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.15)
    end)
    
    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
            return
        end
        
        for _, dd in ipairs(self.Dropdowns) do
            if dd ~= dropList then dd.Visible = false end
        end
        
        populate()
        local pos, targetH, contentH = getDropdownPosition(dropBtn, listLayout, maxHeight)
        dropList.Position = pos
        dropList.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
        dropList.CanvasSize = UDim2.new(0, 0, 0, contentH)
        dropList.Visible = true
        
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, targetH)}, 0.25,
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        self:Tween(arrow, {Rotation = 180}, 0.2)
        if dropStroke then
            self:Tween(dropStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
        end
        isOpen = true
    end)
    
    updateText()
    
    return {
        Frame = frame,
        GetValues = function() return selected end,
        SetValues = function(v)
            selected = v
            updateText()
        end,
        SetOptions = function(newOptions)
            options = newOptions
            if isOpen then populate() end
        end,
    }
end

-- ─── CREATE CHECKBOX ──────────────────────────────────────────────────────────
function SpectrumX:CreateCheckbox(parent, config)
    config = config or {}
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local height = self:S(42)
    
    local frame = Instance.new("Frame")
    frame.Name = "Checkbox_" .. text
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Checkbox
    local cbSize = self:S(20)
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    checkbox.AutoButtonColor = false
    checkbox.Position = UDim2.new(0, self:S(14), 0.5, -cbSize/2)
    checkbox.Size = UDim2.new(0, cbSize, 0, cbSize)
    checkbox.Font = Enum.Font.GothamBold
    checkbox.Text = default and "✓" or ""
    checkbox.TextColor3 = Color3.new(1, 1, 1)
    checkbox.TextSize = self:S(13)
    checkbox.ZIndex = 14
    checkbox.Parent = frame
    self:CreateCorner(checkbox, UDim.new(0, 5))
    self:CreateStroke(checkbox, default and self.Theme.Accent or self.Theme.Border, 1.5, default and 0.2 or 0.4)
    
    local cbStroke = checkbox:FindFirstChildOfClass("UIStroke")
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(42), 0, 0)
    label.Size = UDim2.new(1, -self:S(56), 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:S(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.ZIndex = 13
    label.Parent = frame
    
    local state = default
    
    checkbox.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        if state then
            self:Tween(checkbox, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            if cbStroke then
                self:Tween(cbStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
            end
            checkbox.Text = "✓"
        else
            self:Tween(checkbox, {BackgroundColor3 = self.Theme.Input}, 0.2)
            if cbStroke then
                self:Tween(cbStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
            end
            checkbox.Text = ""
        end
    end)
    
    return {
        Frame = frame,
        GetState = function() return state end,
        SetState = function(s)
            state = s
            callback(state)
            self:Tween(checkbox, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.2)
            checkbox.Text = state and "✓" or ""
        end,
    }
end

-- ─── CREATE LABEL ─────────────────────────────────────────────────────────────
function SpectrumX:CreateLabel(parent, config)
    config = config or {}
    local text = config.Text or "Label"
    local color = config.Color or self.Theme.TextSecondary
    local autoSize = config.AutoSize ~= false -- Default true
    local wrapped = config.Wrapped ~= false -- Default true
    
    -- Calcular altura baseada no texto
    local minHeight = self:S(36)
    local padding = self:S(20)
    
    local frame = Instance.new("Frame")
    frame.Name = "Label_" .. text:sub(1, 10)
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, minHeight)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label com quebra de linha automática
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, 0)
    label.Size = UDim2.new(1, -self:S(28), 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = color
    label.TextSize = self:S(12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = wrapped
    
    if autoSize then
        label.AutomaticSize = Enum.AutomaticSize.Y
    end
    
    label.ZIndex = 13
    label.Parent = frame
    
    -- Ajustar altura do frame quando o texto mudar
    if autoSize then
        label:GetPropertyChangedSignal("TextBounds"):Connect(function()
            local newHeight = math.max(minHeight, label.TextBounds.Y + padding)
            frame.Size = UDim2.new(1, 0, 0, newHeight)
        end)
        
        task.delay(0.1, function()
            if label and label.Parent then
                local newHeight = math.max(minHeight, label.TextBounds.Y + padding)
                frame.Size = UDim2.new(1, 0, 0, newHeight)
            end
        end)
    end
    
    return {
        Frame = frame,
        Label = label,
        SetText = function(t)
            label.Text = t
        end,
        SetColor = function(c)
            label.TextColor3 = c
        end,
    }
end

-- ─── CREATE SEPARATOR ─────────────────────────────────────────────────────────
function SpectrumX:CreateSeparator(parent)
    local wrap = Instance.new("Frame")
    wrap.Name = "Separator"
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, 0, 0, self:S(12))
    wrap.ZIndex = 12
    wrap.Parent = parent
    
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.BackgroundColor3 = self.Theme.Border
    line.BorderSizePixel = 0
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.ZIndex = 12
    line.Parent = wrap
    
    self:CreateGradient(line, Color3.new(0, 0, 0), self.Theme.BorderBright, 0)
    
    return wrap
end

-- ─── CREATE STATUS CARD ───────────────────────────────────────────────────────
function SpectrumX:CreateStatusCard(parent, config)
    config = config or {}
    local title = config.Title or "Status"
    
    local height = self:S(110)
    
    local frame = Instance.new("Frame")
    frame.Name = "StatusCard"
    frame.BackgroundColor3 = self.Theme.Card
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.Active = true
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    
    -- Stroke animado
    local stroke = self:CreateStroke(frame, self.Theme.Accent, 1.5, 0)
    
    spawn(function()
        while frame and frame.Parent do
            self:Tween(stroke, {Transparency = 0.1}, 1)
            task.wait(1)
            if not frame or not frame.Parent then break end
            self:Tween(stroke, {Transparency = 0.6}, 1)
            task.wait(1)
        end
    end)
    
    -- Barra lateral
    local leftBar = Instance.new("Frame")
    leftBar.Name = "LeftBar"
    leftBar.BackgroundColor3 = self.Theme.Accent
    leftBar.BorderSizePixel = 0
    leftBar.Position = UDim2.new(0, 0, 0, 0)
    leftBar.Size = UDim2.new(0, 3, 1, 0)
    leftBar.ZIndex = 13
    leftBar.Parent = frame
    self:CreateCorner(leftBar, UDim.new(0, 10))
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = self.Theme.Header
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, self:S(34))
    header.Parent = frame
    self:CreateCorner(header, UDim.new(0, 10))
    
    local headerCover = Instance.new("Frame")
    headerCover.BackgroundColor3 = self.Theme.Header
    headerCover.BorderSizePixel = 0
    headerCover.Size = UDim2.new(1, 0, 0, 10)
    headerCover.Position = UDim2.new(0, 0, 1, -10)
    headerCover.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "Title"
    headerTitle.BackgroundTransparency = 1
    headerTitle.Position = UDim2.new(0, self:S(16), 0, 0)
    headerTitle.Size = UDim2.new(1, -self:S(16), 1, 0)
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.Text = title
    headerTitle.TextColor3 = self.Theme.Text
    headerTitle.TextSize = self:S(12)
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = 14
    headerTitle.Parent = header
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, self:S(14), 0, self:S(38))
    content.Size = UDim2.new(1, -self:S(28), 1, -self:S(48))
    content.ZIndex = 13
    content.Parent = frame
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, self:S(20))
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.Text = "● Idle"
    statusLabel.TextColor3 = self.Theme.TextMuted
    statusLabel.TextSize = self:S(12)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 14
    statusLabel.Parent = content
    
    -- Info
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.BackgroundTransparency = 1
    infoLabel.Position = UDim2.new(0, 0, 0, self:S(22))
    infoLabel.Size = UDim2.new(1, 0, 0, self:S(16))
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "Aguardando..."
    infoLabel.TextColor3 = self.Theme.TextMuted
    infoLabel.TextSize = self:S(10)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.ZIndex = 14
    infoLabel.Parent = content
    
    -- Barra de progresso
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.BackgroundColor3 = self.Theme.Input
    barBg.Position = UDim2.new(0, 0, 1, -self:S(6))
    barBg.Size = UDim2.new(1, 0, 0, self:S(5))
    barBg.ClipsDescendants = true
    barBg.ZIndex = 13
    barBg.Parent = content
    self:CreateCorner(barBg, UDim.new(1, 0))
    
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BackgroundColor3 = self.Theme.Accent
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BorderSizePixel = 0
    bar.ZIndex = 14
    bar.Parent = barBg
    self:CreateCorner(bar, UDim.new(1, 0))
    self:CreateGradient(bar, self.Theme.Accent, self.Theme.AccentDark, 0)
    
    self:MakeDraggable(frame, header)
    
    return {
        Frame = frame,
        SetStatus = function(status, color)
            statusLabel.Text = "● " .. status
            statusLabel.TextColor3 = color or self.Theme.TextMuted
        end,
        SetInfo = function(info)
            infoLabel.Text = info
        end,
        SetProgress = function(percent)
            bar.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
        end,
        AnimateLoading = function(active, duration)
            if active then
                spawn(function()
                    while active and frame and frame.Parent do
                        bar.Size = UDim2.new(0, 0, 1, 0)
                        local tween = self:Tween(bar, {Size = UDim2.new(1, 0, 1, 0)}, duration or 1.5)
                        tween.Completed:Wait()
                        task.wait(0.1)
                    end
                end)
            else
                bar.Size = UDim2.new(0, 0, 1, 0)
            end
        end,
    }
end


-- ─── NOTIFICATIONS ────────────────────────────────────────────────────────────
function SpectrumX:Notify(config)
    config = config or {}
    local text = config.Text or "Notificação"
    local ntype = config.Type or "info"
    local duration = config.Duration or 4
    local iconName = config.Icon -- Suporte a ícone customizado
    
    self:UpdateScale()
    
    local notifWidth = self:S(ScaleData.IsMobile and 300 or 340)
    local notifHeight = self:S(ScaleData.IsMobile and 70 or 76)
    
    -- Cores por tipo
    local color = self.Theme.Info
    local iconText = "ℹ"
    
    if ntype == "success" then
        color = self.Theme.Success
        iconText = "✓"
    elseif ntype == "warning" then
        color = self.Theme.Warning
        iconText = "⚠"
    elseif ntype == "error" then
        color = self.Theme.Error
        iconText = "✕"
    end
    
    -- Se tiver ícone customizado, usa ele
    local iconAsset = nil
    if iconName then
        iconAsset = self:GetIcon(iconName)
    end
    
    -- Container da notificação
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.BackgroundColor3 = self.Theme.Card
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0, notifWidth, 0, notifHeight)
    notif.ZIndex = 2000
    notif.Parent = self.ScreenGui
    self:CreateCorner(notif, UDim.new(0, 10))
    
    -- Barra lateral colorida
    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.BackgroundColor3 = color
    colorBar.BorderSizePixel = 0
    colorBar.Size = UDim2.new(0, 4, 1, -self:S(16))
    colorBar.Position = UDim2.new(0, 0, 0, self:S(8))
    colorBar.ZIndex = 2002
    colorBar.Parent = notif
    self:CreateCorner(colorBar, UDim.new(1, 0))
    
    -- Barra superior decorativa
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = color
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(0.35, 0, 0, 2)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.ZIndex = 2002
    topBar.Parent = notif
    self:CreateCorner(topBar, UDim.new(1, 0))
    
    -- Ícone
    if iconAsset then
        -- Usar ícone Lucide/Asset
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, self:S(16), 0, 0)
        icon.Size = UDim2.new(0, self:S(28), 1, 0)
        icon.Image = iconAsset
        icon.ImageColor3 = color
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 2002
        icon.Parent = notif
    else
        -- Usar texto/emoji
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, self:S(16), 0, 0)
        icon.Size = UDim2.new(0, self:S(28), 1, 0)
        icon.Font = Enum.Font.GothamBlack
        icon.Text = iconText
        icon.TextColor3 = color
        icon.TextSize = self:S(20)
        icon.ZIndex = 2002
        icon.Parent = notif
    end
    
    -- Texto com padding adequado
    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.BackgroundTransparency = 1
    textContainer.Position = UDim2.new(0, self:S(50), 0, self:S(8))
    textContainer.Size = UDim2.new(1, -self:S(65), 1, -self:S(16))
    textContainer.ZIndex = 2002
    textContainer.Parent = notif
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.Text = text
    textLabel.TextColor3 = self.Theme.Text
    textLabel.TextSize = self:S(12)
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.ZIndex = 2003
    textLabel.Parent = textContainer
    
    -- Barra de progresso (timer)
    local progBg = Instance.new("Frame")
    progBg.Name = "ProgressBg"
    progBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    progBg.BorderSizePixel = 0
    progBg.Position = UDim2.new(0, 0, 1, -3)
    progBg.Size = UDim2.new(1, 0, 0, 3)
    progBg.ClipsDescendants = true
    progBg.ZIndex = 2002
    progBg.Parent = notif
    self:CreateCorner(progBg, UDim.new(1, 0))
    
    local progBar = Instance.new("Frame")
    progBar.Name = "ProgressBar"
    progBar.BackgroundColor3 = color
    progBar.Size = UDim2.new(1, 0, 1, 0)
    progBar.BorderSizePixel = 0
    progBar.ZIndex = 2003
    progBar.Parent = progBg
    
    -- Botão de fechar invisível
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(1, 0, 1, 0)
    closeBtn.Text = ""
    closeBtn.ZIndex = 2010
    closeBtn.Parent = notif
    
    -- Adicionar à lista de notificações
    table.insert(self._notifications, notif)
    
    -- Função para obter viewport
    local function getViewport()
        local success, camera = pcall(function() return workspace.CurrentCamera end)
        return (success and camera) and camera.ViewportSize or Vector2.new(1366, 768)
    end
    
    -- Reorganizar notificações
    local function restack()
        local viewport = getViewport()
        local offset = self:S(14)
        
        for i = #self._notifications, 1, -1 do
            local n = self._notifications[i]
            if n and n.Parent then
                local targetY = viewport.Y - notifHeight - offset
                self:Tween(n, {
                    Position = UDim2.fromOffset(viewport.X - notifWidth - self:S(16), targetY)
                }, 0.3)
                offset = offset + notifHeight + self:S(8)
            end
        end
    end
    
    -- Fechar notificação
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        
        -- Remover da lista
        for i, n in ipairs(self._notifications) do
            if n == notif then
                table.remove(self._notifications, i)
                break
            end
        end
        
        -- Animação de saída
        local viewport = getViewport()
        self:Tween(notif, {
            Position = UDim2.fromOffset(viewport.X + notifWidth + 50, notif.AbsolutePosition.Y),
            BackgroundTransparency = 1
        }, 0.3)
        
        -- Também fade out nos filhos
        for _, child in ipairs(notif:GetDescendants()) do
            if child:IsA("GuiObject") and child ~= notif then
                self:Tween(child, {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}, 0.3)
            end
        end
        
        restack()
        task.wait(0.35)
        
        if notif and notif.Parent then
            notif:Destroy()
        end
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    
    -- Animação de entrada
    local viewport = getViewport()
    notif.Position = UDim2.fromOffset(viewport.X + notifWidth + 50, viewport.Y - notifHeight - self:S(14))
    
    self:Tween(notif, {
        Position = UDim2.fromOffset(viewport.X - notifWidth - self:S(16), viewport.Y - notifHeight - self:S(14))
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    restack()
    
    -- Animação do timer
    self:Tween(progBar, {Size = UDim2.new(0, 0, 1, 0)}, duration)
    
    -- Auto-fechar
    task.delay(duration, function()
        if not dismissed then
            dismiss()
        end
    end)
end

-- ─── CREATE COLOR PICKER ──────────────────────────────────────────────────────
function SpectrumX:CreateColorPicker(parent, config)
    config = config or {}
    local labelText = config.Label or "Color"
    local default = config.Default or Color3.fromRGB(255, 0, 0)
    local callback = config.Callback or function() end
    
    local height = self:S(46)
    
    local frame = Instance.new("Frame")
    frame.Name = "ColorPicker_" .. labelText
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, 0)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:S(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- Preview do color
    local previewSize = self:S(28)
    local preview = Instance.new("TextButton")
    preview.Name = "Preview"
    preview.BackgroundColor3 = default
    preview.Position = UDim2.new(1, -previewSize - self:S(14), 0.5, -previewSize/2)
    preview.Size = UDim2.new(0, previewSize, 0, previewSize)
    preview.Text = ""
    preview.AutoButtonColor = false
    preview.ZIndex = 14
    preview.Parent = frame
    self:CreateCorner(preview, UDim.new(0, 6))
    self:CreateStroke(preview, self.Theme.Border, 2, 0)
    
    -- Valor RGB
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.25, 0, 1, 0)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Text = string.format("%d, %d, %d", math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255))
    valueLabel.TextColor3 = self.Theme.TextMuted
    valueLabel.TextSize = self:S(11)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 13
    valueLabel.Parent = frame
    
    local currentColor = default
    
    -- Simples color picker (abre input de RGB)
    preview.MouseButton1Click:Connect(function()
        -- Aqui você pode implementar um color picker mais complexo
        -- Por enquanto, apenas cicla entre algumas cores pré-definidas
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 0, 0),
        }
        
        local currentIndex = 1
        for i, c in ipairs(colors) do
            if c == currentColor then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex % #colors + 1
        currentColor = colors[currentIndex]
        
        preview.BackgroundColor3 = currentColor
        valueLabel.Text = string.format("%d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        callback(currentColor)
    end)
    
    return {
        Frame = frame,
        GetColor = function() return currentColor end,
        SetColor = function(c)
            currentColor = c
            preview.BackgroundColor3 = c
            valueLabel.Text = string.format("%d, %d, %d", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
            callback(c)
        end,
    }
end

-- ─── CREATE KEYBIND ───────────────────────────────────────────────────────────
function SpectrumX:CreateKeybind(parent, config)
    config = config or {}
    local labelText = config.Label or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    
    local height = self:S(46)
    
    local frame = Instance.new("Frame")
    frame.Name = "Keybind_" .. labelText
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.ZIndex = 12
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:S(14), 0, 0)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:S(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = frame
    
    -- Botão do keybind
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Name = "KeybindBtn"
    keybindBtn.BackgroundColor3 = self.Theme.Input
    keybindBtn.AutoButtonColor = false
    keybindBtn.Position = UDim2.new(1, -self:S(80), 0.5, -self:S(14))
    keybindBtn.Size = UDim2.new(0, self:S(70), 0, self:S(28))
    keybindBtn.Font = Enum.Font.GothamBold
    keybindBtn.Text = default ~= Enum.KeyCode.Unknown and default.Name or "None"
    keybindBtn.TextColor3 = self.Theme.Text
    keybindBtn.TextSize = self:S(11)
    keybindBtn.ZIndex = 14
    keybindBtn.Parent = frame
    self:CreateCorner(keybindBtn, UDim.new(0, 6))
    
    local listening = false
    local currentKey = default
    
    keybindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keybindBtn.Text = "..."
        keybindBtn.TextColor3 = self.Theme.Accent
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode
            keybindBtn.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None"
            keybindBtn.TextColor3 = self.Theme.Text
            callback(currentKey)
        end
    end)
    
    return {
        Frame = frame,
        GetKey = function() return currentKey end,
        SetKey = function(k)
            currentKey = k
            keybindBtn.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None"
        end,
    }
end

-- ─── DESTROY ──────────────────────────────────────────────────────────────────
function SpectrumX:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- ─── GET WINDOW ───────────────────────────────────────────────────────────────
function SpectrumX:GetWindow()
    return self.MainFrame
end

-- ─── SET VISIBLE ──────────────────────────────────────────────────────────────
function SpectrumX:SetVisible(visible)
    if self.MainFrame then
        self.MainFrame.Visible = visible
    end
    if self.FloatBtn then
        -- Opcional: também esconder botão flutuante
        -- self.FloatBtn.Visible = not visible
    end
end

-- ─── TOGGLE VISIBILITY ────────────────────────────────────────────────────────
function SpectrumX:Toggle()
    if self.MainFrame then
        self:SetVisible(not self.MainFrame.Visible)
    end
end

-- ─── SET POSITION ─────────────────────────────────────────────────────────────
function SpectrumX:SetPosition(position)
    if self.MainFrame then
        self.MainFrame.Position = position
    end
end

-- ─── SET SIZE ─────────────────────────────────────────────────────────────────
function SpectrumX:SetSize(size)
    if self.MainFrame then
        self.MainFrame.Size = size
    end
end

-- ─── UPDATE THEME ─────────────────────────────────────────────────────────────
function SpectrumX:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if self.Theme[key] then
            self.Theme[key] = value
        end
    end
end

-- ─── GET ICONS ────────────────────────────────────────────────────────────────
function SpectrumX:GetIcons()
    return Icons
end

-- ─── SET DROPDOWN ARROW ICON ──────────────────────────────────────────────────
function SpectrumX:SetDropdownArrowIcon(icon)
    if self:IsAssetId(icon) then
        self.Config.DropdownArrowIcon = icon
    elseif Icons and Icons[icon] then
        self.Config.DropdownArrowIcon = Icons[icon]
    end
end

-- Retornar a biblioteca
return SpectrumX
