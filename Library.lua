local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Version = "1.0.0",
    Windows = {},
    ActiveNotifications = {}
}

local WindowClass = {}
WindowClass.__index = WindowClass

local TabClass = {}
TabClass.__index = TabClass

local SectionClass = {}
SectionClass.__index = SectionClass

local Themes = {
    Dark = {
        Name = "Dark",
        BackgroundTop = Color3.fromRGB(10, 10, 10),
        BackgroundBottom = Color3.fromRGB(26, 26, 26),
        Surface = Color3.fromRGB(14, 14, 16),
        SurfaceAlt = Color3.fromRGB(20, 20, 24),
        SurfaceLight = Color3.fromRGB(28, 28, 34),
        Primary = Color3.fromRGB(124, 58, 237),
        PrimaryAlt = Color3.fromRGB(99, 102, 241),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(229, 229, 229),
        TextDim = Color3.fromRGB(163, 163, 163),
        Border = Color3.fromRGB(39, 39, 42),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(245, 158, 11),
        Error = Color3.fromRGB(239, 68, 68),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

-- Carrega ícones Lucide do mesmo repositório via HttpGet
local LucideAssets = {}
pcall(function()
    local raw = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/spectrumxx/SPX/refs/heads/main/Icons.lua"
    ))()
    if raw and raw.assets then
        LucideAssets = raw.assets
    end
end)

local IconMap = {
    home = "⌂",
    settings = "⚙",
    menu = "☰",
    user = "👤",
    search = "⌕",
    bell = "🔔",
    info = "ⓘ",
    star = "★",
    folder = "🗀",
    shield = "🛡",
    zap = "⚡",
    play = "▶",
    terminal = ">_",
    grid = "☷",
    sliders = "≡",
    toolbox = "🧰",
    panel = "▣"
}

local function cloneTable(tbl)
    local new = {}
    for k, v in pairs(tbl or {}) do
        if type(v) == "table" then
            new[k] = cloneTable(v)
        else
            new[k] = v
        end
    end
    return new
end

local function merge(a, b)
    local out = cloneTable(a or {})
    for k, v in pairs(b or {}) do
        if type(v) == "table" and type(out[k]) == "table" then
            out[k] = merge(out[k], v)
        else
            out[k] = v
        end
    end
    return out
end

local function New(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, time, props, style, direction)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function MakeCorner(parent, radius)
    return New("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 10)
    })
end

local function MakeStroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Parent = parent,
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    })
end

local function MakePadding(parent, l, r, t, b)
    return New("UIPadding", {
        Parent = parent,
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0)
    })
end

local function MakeList(parent, fill, padding, sortOrder)
    return New("UIListLayout", {
        Parent = parent,
        FillDirection = fill or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, padding or 0),
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    })
end

local function MakeGradient(parent, c1, c2, rotation)
    return New("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 90
    })
end

local function ResolveIcon(icon)
    if not icon or icon == "" then
        return nil
    end

    if type(icon) == "string" then
        -- Já é um assetid ou URL direto
        if string.find(icon, "rbxassetid://") or string.find(icon, "http") then
            return icon
        end

        local lower = string.lower(icon)

        -- Tenta achar no dicionário Lucide (ex: "lucide-star" ou só "star" com prefixo)
        if LucideAssets[lower] then
            return LucideAssets[lower]
        end
        -- Tenta com prefixo "lucide-" automático
        if LucideAssets["lucide-" .. lower] then
            return LucideAssets["lucide-" .. lower]
        end

        -- Fallback: IconMap de emoji
        return IconMap[lower] or icon
    end

    return icon
end

local function IsImageIcon(icon)
    if type(icon) ~= "string" then return false end
    return string.find(icon, "rbxassetid://") ~= nil
        or string.find(icon, "http") ~= nil
end

local function CreateIcon(parent, icon, color, size, posX)
    if not icon or icon == "" then
        return nil
    end

    -- Resolve primeiro (pode converter nome lucide → assetid)
    local resolved = ResolveIcon(icon)
    if not resolved or resolved == "" then
        return nil
    end

    if IsImageIcon(resolved) then
        return New("ImageLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(size or 16, size or 16),
            Position = UDim2.new(0, posX or 0, 0.5, -((size or 16) / 2)),
            Image = resolved,
            ImageColor3 = color or Color3.new(1, 1, 1)
        })
    else
        return New("TextLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(size or 16, size or 16),
            Position = UDim2.new(0, posX or 0, 0.5, -((size or 16) / 2)),
            Text = resolved,
            Font = Enum.Font.GothamBold,
            TextColor3 = color or Color3.new(1, 1, 1),
            TextSize = size or 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    end
end

local function GetViewport()
    local cam = workspace.CurrentCamera
    if cam then
        return cam.ViewportSize
    end
    return Vector2.new(1280, 720)
end

local function GetBreakpoint()
    local vp = GetViewport()
    if vp.X < 600 then
        return "Mobile"
    elseif vp.X < 900 then
        return "Tablet"
    end
    return "Desktop"
end

local function GetGuiParent()
    if gethui then
        local ok, ui = pcall(gethui)
        if ok and ui then
            return ui
        end
    end

    local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return playerGui or CoreGui
end

local function ProtectGui(gui)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
end

local function MakeDraggable(handle, target, callback)
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        target.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )

        if callback then
            callback(target.Position)
        end
    end)
end

local function CreateSignal()
    local bind = Instance.new("BindableEvent")
    return {
        Fire = function(_, ...)
            bind:Fire(...)
        end,
        Connect = function(_, fn)
            return bind.Event:Connect(fn)
        end,
        Destroy = function()
            bind:Destroy()
        end
    }
end

local function ApplyHover(button, frame, baseColor, hoverColor, stroke, hoverStroke)
    button.MouseEnter:Connect(function()
        Tween(frame, 0.15, {BackgroundColor3 = hoverColor or baseColor})
        if stroke then
            Tween(stroke, 0.15, {Color = hoverStroke or stroke.Color})
        end
    end)

    button.MouseLeave:Connect(function()
        Tween(frame, 0.15, {BackgroundColor3 = baseColor})
        if stroke then
            Tween(stroke, 0.15, {Color = hoverStroke and stroke.Color or stroke.Color})
        end
    end)
end

local function SetVisibleRecursive(guiObject, state)
    if guiObject:IsA("GuiObject") then
        guiObject.Visible = state
    end
end

function Library:GetTheme(theme)
    if type(theme) == "table" then
        return merge(Themes.Dark, theme)
    end

    return cloneTable(Themes[theme or "Dark"] or Themes.Dark)
end

function Library:Notify(options)
    options = options or {}

    local gui = self._notifyGui
    if not gui then
        gui = New("ScreenGui", {
            Name = "SpectrumXNotifications_" .. HttpService:GenerateGUID(false),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = GetGuiParent()
        })
        ProtectGui(gui)
        self._notifyGui = gui

        local holder = New("Frame", {
            Parent = gui,
            Name = "Holder",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -18, 0, 18),
            Size = UDim2.new(0, 340, 1, -36)
        })

        local list = MakeList(holder, Enum.FillDirection.Vertical, 10)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        holder.ChildAdded:Connect(function()
            holder.CanvasSize = UDim2.new()
        end)

        self._notifyHolder = holder
    end

    local theme = self:GetTheme("Dark")
    local ntype = string.lower(options.Type or "info")

    local accent = theme.Primary
    if ntype == "success" then accent = theme.Success end
    if ntype == "warning" then accent = theme.Warning end
    if ntype == "error" then accent = theme.Error end

    local toast = New("Frame", {
        Parent = self._notifyHolder,
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    MakeCorner(toast, 10)
    MakeStroke(toast, theme.Border, 1, 0)
    MakePadding(toast, 12, 12, 12, 12)

    local accentBar = New("Frame", {
        Parent = toast,
        BackgroundColor3 = accent,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.fromOffset(0, 0)
    })
    MakeCorner(accentBar, 10)

    local title = New("TextLabel", {
        Parent = toast,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -14, 0, 18),
        Text = options.Title or "Notification",
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local content = New("TextLabel", {
        Parent = toast,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 20),
        Size = UDim2.new(1, -14, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = options.Content or options.Text or "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextWrapped = true,
        TextColor3 = theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    toast.Position = UDim2.new(1, 40, 0, 0)
    toast.BackgroundTransparency = 0.35
    Tween(toast, 0.22, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.08
    })

    local duration = options.Duration
    if duration ~= nil then
        task.delay(duration, function()
            if toast and toast.Parent then
                local tw = Tween(toast, 0.2, {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 40, 0, 0)
                })
                tw.Completed:Wait()
                toast:Destroy()
            end
        end)
    end
end

function WindowClass:_applyResponsive()
    local breakpoint = GetBreakpoint()
    self.Breakpoint = breakpoint

    local vp = GetViewport()
    local baseX = self.Config.Size.X.Offset > 0 and self.Config.Size.X.Offset or 550
    local baseY = self.Config.Size.Y.Offset > 0 and self.Config.Size.Y.Offset or 600

    local width = baseX
    local height = baseY

    if self.Config.Responsive ~= false then
        if breakpoint == "Mobile" then
            width = math.min(vp.X - 18, 420)
            height = math.min(vp.Y - 18, 540)
        elseif breakpoint == "Tablet" then
            width = math.min(vp.X - 32, math.max(500, baseX))
            height = math.min(vp.Y - 32, math.max(420, baseY))
        else
            width = math.min(vp.X - 48, baseX)
            height = math.min(vp.Y - 48, baseY)
        end
    end

    self.Frame.Size = UDim2.fromOffset(width, height)

    if breakpoint == "Mobile" then
        self.BodyList.FillDirection = Enum.FillDirection.Vertical
        self.TabsFrame.Size = UDim2.new(1, 0, 0, 54)
        self.TabsList.FillDirection = Enum.FillDirection.Horizontal
        self.TabsList.Padding = UDim.new(0, 8)
        self.ContentFrame.Size = UDim2.new(1, 0, 1, -54)
    else
        self.BodyList.FillDirection = Enum.FillDirection.Horizontal
        self.TabsFrame.Size = UDim2.new(0, self.Config.TabWidth, 1, 0)
        self.TabsList.FillDirection = Enum.FillDirection.Vertical
        self.TabsList.Padding = UDim.new(0, 8)
        self.ContentFrame.Size = UDim2.new(1, -self.Config.TabWidth, 1, 0)
    end

    for _, tab in ipairs(self.Tabs) do
        if breakpoint == "Mobile" then
            tab.Button.Size = UDim2.fromOffset(110, 38)
        else
            tab.Button.Size = UDim2.new(1, 0, 0, 38)
        end
    end
end

function WindowClass:SetVisible(state)
    self.Visible = state

    if state then
        self.Frame.Visible = true
        self.Scale.Scale = 0.97
        self.Frame.BackgroundTransparency = 0.15
        Tween(self.Scale, 0.18, {Scale = 1})
        Tween(self.Frame, 0.18, {BackgroundTransparency = 0.05})
    else
        local tw1 = Tween(self.Scale, 0.16, {Scale = 0.97})
        Tween(self.Frame, 0.16, {BackgroundTransparency = 0.2})
        tw1.Completed:Connect(function()
            if self.Visible == false and self.Frame then
                self.Frame.Visible = false
            end
        end)
    end
end

function WindowClass:Toggle()
    self:SetVisible(not self.Visible)
end

function WindowClass:SelectTab(target)
    local index = target
    if type(target) == "table" then
        for i, tab in ipairs(self.Tabs) do
            if tab == target then
                index = i
                break
            end
        end
    end

    self.SelectedTab = index

    for i, tab in ipairs(self.Tabs) do
        local selected = (i == index)
        tab.Page.Visible = selected
        Tween(tab.ButtonFrame, 0.16, {
            BackgroundColor3 = selected and self.Theme.SurfaceLight or self.Theme.SurfaceAlt
        })
        Tween(tab.ButtonStroke, 0.16, {
            Color = selected and self.Theme.Primary or self.Theme.Border
        })
        if tab.TextLabel then
            Tween(tab.TextLabel, 0.16, {
                TextColor3 = selected and self.Theme.Text or self.Theme.TextDim
            })
        end
        if tab.IconLabel then
            if tab.IconLabel:IsA("TextLabel") then
                Tween(tab.IconLabel, 0.16, {
                    TextColor3 = selected and self.Theme.Primary or self.Theme.TextDim
                })
            elseif tab.IconLabel:IsA("ImageLabel") then
                Tween(tab.IconLabel, 0.16, {
                    ImageColor3 = selected and self.Theme.Primary or self.Theme.TextDim
                })
            end
        end
    end
end

function WindowClass:_createFloatingButton()
    local cfg = self.Config.FloatingButton or {}
    if cfg.Enabled == false then
        return
    end

    local size = cfg.Size or 54
    local cornerScale = 0.15

    -- Posição: centro da tela, bem pra esquerda
    local holder = New("Frame", {
        Parent = self.Gui,
        Name = "FloatingButtonHolder",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 18, 0.5, 0),
        Size = UDim2.fromOffset(size + 24, size + 24)
    })

    local glow = New("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(size + 14, size + 14),
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.8
    })
    -- Corner igual ao botão, não circular
    New("UICorner", {
        Parent = glow,
        CornerRadius = UDim.new(cornerScale, 0)
    })
    local glowStroke = MakeStroke(glow, self.Theme.Primary, 1.2, 0.5)

    local buttonFrame = New("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = self.Theme.SurfaceAlt
    })
    New("UICorner", {
        Parent = buttonFrame,
        CornerRadius = UDim.new(cornerScale, 0)
    })
    MakeGradient(buttonFrame, self.Theme.SurfaceAlt, self.Theme.Surface, 90)
    local stroke = MakeStroke(buttonFrame, self.Theme.Primary, 1.1, 0)

    local scale = New("UIScale", {
        Parent = buttonFrame,
        Scale = 1
    })

    local button = New("TextButton", {
        Parent = buttonFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ""
    })

    -- Suporte completo a ícone: lucide nome, assetid rbx, catálogo URL, emoji
    local iconSrc = cfg.Icon or "settings"
    local resolvedIcon = ResolveIcon(iconSrc)
    local fbIcon

    if resolvedIcon and IsImageIcon(resolvedIcon) then
        fbIcon = New("ImageLabel", {
            Parent = buttonFrame,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(math.floor(size * 0.45), math.floor(size * 0.45)),
            Image = resolvedIcon,
            ImageColor3 = self.Theme.Text
        })
    elseif resolvedIcon then
        fbIcon = New("TextLabel", {
            Parent = buttonFrame,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(math.floor(size * 0.5), math.floor(size * 0.5)),
            Text = resolvedIcon,
            Font = Enum.Font.GothamBold,
            TextColor3 = self.Theme.Text,
            TextSize = math.floor(size * 0.35),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    end

    button.MouseEnter:Connect(function()
        Tween(scale, 0.14, {Scale = 1.08})
        Tween(glow, 0.14, {BackgroundTransparency = 0.68})
        Tween(glowStroke, 0.14, {Transparency = 0.25})
    end)

    button.MouseLeave:Connect(function()
        Tween(scale, 0.14, {Scale = 1})
        Tween(glow, 0.14, {BackgroundTransparency = 0.8})
        Tween(glowStroke, 0.14, {Transparency = 0.5})
    end)

    button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Sempre arrastável, funciona em mobile (Touch) e desktop (Mouse)
    local dragging = false
    local dragStart = nil
    local holderStartPos = nil

    buttonFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            holderStartPos = holder.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        holder.Position = UDim2.new(
            holderStartPos.X.Scale, holderStartPos.X.Offset + delta.X,
            holderStartPos.Y.Scale, holderStartPos.Y.Offset + delta.Y
        )
    end)

    self.FloatingButton = holder
end

function WindowClass:_createResizeHandle()
    local grip = New("TextButton", {
        Parent = self.Frame,
        BackgroundTransparency = 1,
        Text = "",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.fromOffset(18, 18),
        ZIndex = 10
    })

    local lines = New("TextLabel", {
        Parent = grip,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "⋰",
        Font = Enum.Font.GothamBold,
        TextColor3 = self.Theme.TextDim,
        TextSize = 14
    })

    local resizing = false
    local startPos
    local startSize

    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            startPos = input.Position
            startSize = self.Frame.AbsoluteSize

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - startPos
        local newX = math.max(420, startSize.X + delta.X)
        local newY = math.max(320, startSize.Y + delta.Y)

        self.Config.Size = UDim2.fromOffset(newX, newY)
        self.Frame.Size = UDim2.fromOffset(newX, newY)
    end)
end

function WindowClass:AddTab(options)
    options = options or {}

    local tab = setmetatable({}, TabClass)
    tab.Window = self
    tab.Title = options.Title or options.Name or ("Tab " .. tostring(#self.Tabs + 1))
    tab.Icon = options.Icon or ""

    local buttonFrame = New("Frame", {
        Parent = self.TabsScroll,
        BackgroundColor3 = self.Theme.SurfaceAlt,
        Size = UDim2.new(1, 0, 0, 38)
    })
    MakeCorner(buttonFrame, 10)
    local btnStroke = MakeStroke(buttonFrame, self.Theme.Border, 1, 0)

    local button = New("TextButton", {
        Parent = buttonFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ""
    })

    local icon = CreateIcon(buttonFrame, tab.Icon, self.Theme.TextDim, 15, 10)
    local textX = icon and 32 or 12

    local text = New("TextLabel", {
        Parent = buttonFrame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(textX, 0),
        Size = UDim2.new(1, -textX - 8, 1, 0),
        Text = tab.Title,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local page = New("ScrollingFrame", {
        Parent = self.ContentPages,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    })
    MakePadding(page, 12, 12, 12, 12)
    local pageList = MakeList(page, Enum.FillDirection.Vertical, 12)

    tab.Button = buttonFrame
    tab.ButtonFrame = buttonFrame
    tab.ButtonStroke = btnStroke
    tab.ButtonInner = button
    tab.IconLabel = icon
    tab.TextLabel = text
    tab.Page = page
    tab.PageList = pageList
    tab.Sections = {}

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    button.MouseEnter:Connect(function()
        if self.Tabs[self.SelectedTab] ~= tab then
            Tween(buttonFrame, 0.15, {BackgroundColor3 = self.Theme.SurfaceLight})
        end
    end)

    button.MouseLeave:Connect(function()
        if self.Tabs[self.SelectedTab] ~= tab then
            Tween(buttonFrame, 0.15, {BackgroundColor3 = self.Theme.SurfaceAlt})
        end
    end)

    table.insert(self.Tabs, tab)
    self:_applyResponsive()

    if #self.Tabs == 1 then
        self:SelectTab(1)
    end

    return tab
end

function TabClass:AddSection(title)
    local section = setmetatable({}, SectionClass)
    section.Tab = self
    section.Window = self.Window
    section.Title = title or "Section"

    local frame = New("Frame", {
        Parent = self.Page,
        BackgroundColor3 = self.Window.Theme.Surface,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0)
    })
    MakeCorner(frame, 12)
    MakeStroke(frame, self.Window.Theme.Border, 1, 0)
    MakeGradient(frame, self.Window.Theme.Surface, self.Window.Theme.SurfaceAlt, 90)
    MakePadding(frame, 12, 12, 12, 12)

    local titleLabel = New("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Text = section.Title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = self.Window.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local container = New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    local list = MakeList(container, Enum.FillDirection.Vertical, 10)

    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local current = container.Size
        container.Size = UDim2.new(1, 0, current.Y.Scale, current.Y.Offset)
    end)

    section.Frame = frame
    section.Container = container
    section.List = list

    table.insert(self.Sections, section)
    return section
end

function SectionClass:_createElement(height)
    local frame = New("Frame", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 42),
        AutomaticSize = Enum.AutomaticSize.None
    })
    return frame
end

function SectionClass:AddLabel(options)
    if type(options) == "string" then
        options = { Title = options }
    end
    options = options or {}

    local frame = New("Frame", {
        Parent = self.Container,
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    MakeCorner(frame, 10)
    MakeStroke(frame, self.Window.Theme.Border, 1, 0)
    MakePadding(frame, 12, 12, 10, 10)

    local label = New("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = options.Title or options.Text or "Label",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextWrapped = true,
        TextColor3 = self.Window.Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    return {
        Instance = frame,
        SetText = function(_, text)
            label.Text = text
        end
    }
end

function SectionClass:AddButton(options)
    options = options or {}
    local frame = self:_createElement(42)

    local buttonFrame = New("Frame", {
        Parent = frame,
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        Size = UDim2.fromScale(1, 1)
    })
    MakeCorner(buttonFrame, 10)
    local stroke = MakeStroke(buttonFrame, self.Window.Theme.Border, 1, 0)

    local button = New("TextButton", {
        Parent = buttonFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ""
    })

    local icon = CreateIcon(buttonFrame, options.Icon, self.Window.Theme.Primary, 15, 12)
    local textX = icon and 34 or 12

    local title = New("TextLabel", {
        Parent = buttonFrame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(textX, 0),
        Size = UDim2.new(1, -textX - 12, 1, 0),
        Text = options.Title or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Window.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    button.MouseEnter:Connect(function()
        Tween(buttonFrame, 0.14, {BackgroundColor3 = self.Window.Theme.SurfaceLight})
        Tween(stroke, 0.14, {Color = self.Window.Theme.Primary})
    end)

    button.MouseLeave:Connect(function()
        Tween(buttonFrame, 0.14, {BackgroundColor3 = self.Window.Theme.SurfaceAlt})
        Tween(stroke, 0.14, {Color = self.Window.Theme.Border})
    end)

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)

    return {
        Instance = frame
    }
end

function SectionClass:AddToggle(options)
    options = options or {}
    local theme = self.Window.Theme
    local state = options.Default == true
    local changed = CreateSignal()

    local frame = self:_createElement(48)

    local bg = New("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.SurfaceAlt,
        Size = UDim2.fromScale(1, 1)
    })
    MakeCorner(bg, 10)
    MakeStroke(bg, theme.Border, 1, 0)

    local title = New("TextLabel", {
        Parent = bg,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = options.Title or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switch = New("Frame", {
        Parent = bg,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = state and theme.Primary or theme.SurfaceLight
    })
    MakeCorner(switch, 999)
    local switchStroke = MakeStroke(switch, state and theme.Primary or theme.Border, 1, 0)

    local knob = New("Frame", {
        Parent = switch,
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromOffset(state and 22 or 2, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    })
    MakeCorner(knob, 999)

    local click = New("TextButton", {
        Parent = bg,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ""
    })

    local element = {}

    function element:SetValue(v)
        state = v == true

        Tween(switch, 0.16, {
            BackgroundColor3 = state and theme.Primary or theme.SurfaceLight
        })

        Tween(switchStroke, 0.16, {
            Color = state and theme.Primary or theme.Border
        })

        Tween(knob, 0.16, {
            Position = UDim2.fromOffset(state and 22 or 2, 2)
        })

        element.Value = state

        if options.Callback then
            options.Callback(state)
        end

        changed:Fire(state)
    end

    function element:GetValue()
        return state
    end

    function element:OnChanged(fn)
        return changed:Connect(fn)
    end

    click.MouseButton1Click:Connect(function()
        element:SetValue(not state)
    end)

    element.Instance = frame
    element.Value = state

    return element
end


function SectionClass:AddSlider(options)
    options = options or {}
    local theme = self.Window.Theme
    local min = tonumber(options.Min or 0) or 0
    local max = tonumber(options.Max or 100) or 100
    local value = tonumber(options.Default or min) or min
    local rounding = tonumber(options.Rounding or 0) or 0
    local changed = CreateSignal()

    local frame = self:_createElement(62)

    local bg = New("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.SurfaceAlt,
        Size = UDim2.fromScale(1, 1)
    })
    MakeCorner(bg, 10)
    MakeStroke(bg, theme.Border, 1, 0)

    local title = New("TextLabel", {
        Parent = bg,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -90, 0, 16),
        Text = options.Title or "Slider",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = New("TextLabel", {
        Parent = bg,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.fromOffset(70, 16),
        Text = tostring(value),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local bar = New("Frame", {
        Parent = bg,
        Position = UDim2.fromOffset(12, 34),
        Size = UDim2.new(1, -24, 0, 8),
        BackgroundColor3 = theme.SurfaceLight
    })
    MakeCorner(bar, 999)

    local fill = New("Frame", {
        Parent = bar,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.Primary
    })
    MakeCorner(fill, 999)

    local knob = New("Frame", {
        Parent = bar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    })
    MakeCorner(knob, 999)

    local input = New("TextButton", {
        Parent = bg,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ""
    })

    local dragging = false
    local element = {}

    local function roundNumber(n)
        if rounding <= 0 then
            return math.floor(n + 0.5)
        end
        local mult = 10 ^ rounding
        return math.floor(n * mult + 0.5) / mult
    end

    local function setFromPercent(percent)
        percent = math.clamp(percent, 0, 1)
        local raw = min + ((max - min) * percent)
        value = roundNumber(raw)

        local newPercent = (value - min) / (max - min)
        fill.Size = UDim2.new(newPercent, 0, 1, 0)
        knob.Position = UDim2.new(newPercent, 0, 0.5, 0)
        valueLabel.Text = tostring(value)

        element.Value = value

        if options.Callback then
            options.Callback(value)
        end

        changed:Fire(value)
    end

    function element:SetValue(v)
        v = math.clamp(tonumber(v) or min, min, max)
        local percent = (v - min) / (max - min)
        setFromPercent(percent)
    end

    function element:GetValue()
        return value
    end

    function element:OnChanged(fn)
        return changed:Connect(fn)
    end

    local function updateFromInput(posX)
        local percent = (posX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        setFromPercent(percent)
    end

    input.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(inp.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(inp.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    element.Instance = frame
    element.Value = value
    element:SetValue(value)

    return element
end


function SectionClass:AddInput(options)
    options = options or {}
    local value = tostring(options.Default or "")
    local changed = CreateSignal()

    local frame = self:_createElement(56)

    local bg = New("Frame", {
        Parent = frame,
        BackgroundColor3 = self.Window.Theme.SurfaceAlt,
        Size = UDim2.fromScale(1, 1)
    })
    MakeCorner(bg, 10)
    MakeStroke(bg, self.Window.Theme.Border, 1, 0)

    local title = New("TextLabel", {
        Parent = bg,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 6),
        Size = UDim2.new(1, -24, 0, 14),
        Text = options.Title or "Input",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Window.Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local box = New("TextBox", {
        Parent = bg,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 22),
        Size = UDim2.new(1, -24, 0, 24),
        Text = value,
        PlaceholderText = options.Placeholder or "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.Window.Theme.Text,
        PlaceholderColor3 = self.Window.Theme.TextDim,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local element = {}

    function element:SetValue(v)
        value = tostring(v or "")
        box.Text = value
        if options.Callback then
            options.Callback(value)
        end
        changed:Fire(value)
    end

    function element:GetValue()
        return value
    end

    function element:OnChanged(fn)
        return changed:Connect(fn)
    end

    box:GetPropertyChangedSignal("Text"):Connect(function()
        if options.Numeric then
            box.Text = box.Text:gsub("[^%d%.%-]", "")
        end

        value = box.Text

        if not options.Finished then
            if options.Callback then
                options.Callback(value)
            end
            changed:Fire(value)
        end
    end)

    box.FocusLost:Connect(function()
        value = box.Text
        if options.Callback then
            options.Callback(value)
        end
        changed:Fire(value)
    end)

    return setmetatable(element, {
        __index = {
            Instance = frame
        }
    })
end

function SectionClass:AddDropdown(options)
    options = options or {}

    local theme = self.Window.Theme
    local values = options.Values or {}
    local isMulti = options.Multi == true
    local selected = isMulti and {} or nil
    local changed = CreateSignal()
    local opened = false

    if isMulti then
        if type(options.Default) == "table" then
            for k, v in pairs(options.Default) do
                if type(k) == "number" then
                    selected[v] = true
                elseif v then
                    selected[k] = true
                end
            end
        end
    else
        selected = options.Default
        if type(selected) == "number" then
            selected = values[selected]
        end
    end

    local frame = New("Frame", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    local main = New("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.SurfaceAlt,
        Size = UDim2.new(1, 0, 0, 42)
    })
    MakeCorner(main, 10)
    local mainStroke = MakeStroke(main, theme.Border, 1, 0)

    local title = New("TextLabel", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0, 110, 1, 0),
        Text = options.Title or "Dropdown",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = New("TextLabel", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(122, 0),
        Size = UDim2.new(1, -152, 1, 0),
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextDim,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local arrow = New("ImageLabel", {
        Parent = main,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Image = "rbxassetid://10709767827",
        ImageColor3 = theme.TextDim,
        Rotation = 0
    })

    local toggleButton = New("TextButton", {
        Parent = main,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ""
    })

    local dropdownHolder = New("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.Surface,
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false
    })
    MakeCorner(dropdownHolder, 10)
    MakeStroke(dropdownHolder, theme.Border, 1, 0)
    MakePadding(dropdownHolder, 8, 8, 8, 8)

    local searchBox
    local searchText = ""

    if options.Search then
        searchBox = New("TextBox", {
            Parent = dropdownHolder,
            BackgroundColor3 = theme.SurfaceAlt,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "",
            PlaceholderText = "Search...",
            ClearTextOnFocus = false,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = theme.Text,
            PlaceholderColor3 = theme.TextDim
        })
        MakeCorner(searchBox, 8)
        MakeStroke(searchBox, theme.Border, 1, 0)
        MakePadding(searchBox, 10, 10, 0, 0)
    end

    local listFrame = New("ScrollingFrame", {
        Parent = dropdownHolder,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, options.Search and 38 or 0),
        Size = UDim2.new(1, 0, 0, 0),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Border
    })

    local listLayout = MakeList(listFrame, Enum.FillDirection.Vertical, 6)
    local itemRefs = {}

    local function getMultiText()
        local result = {}
        for name, state in pairs(selected) do
            if state then
                table.insert(result, tostring(name))
            end
        end

        table.sort(result)

        if #result == 0 then
            return options.Placeholder or "Selecionar..."
        end

        return table.concat(result, ", ")
    end

    local function updateLabel()
        if isMulti then
            valueLabel.Text = getMultiText()
        else
            valueLabel.Text = selected and tostring(selected) or (options.Placeholder or "Selecionar...")
        end
    end

    local function emit()
        if options.Callback then
            if isMulti then
                local copy = {}
                for k, v in pairs(selected) do
                    copy[k] = v
                end
                options.Callback(copy)
                changed:Fire(copy)
            else
                options.Callback(selected)
                changed:Fire(selected)
            end
        else
            if isMulti then
                local copy = {}
                for k, v in pairs(selected) do
                    copy[k] = v
                end
                changed:Fire(copy)
            else
                changed:Fire(selected)
            end
        end
    end

    local function isVisibleOption(v)
        if searchText == "" then
            return true
        end

        return string.find(string.lower(tostring(v)), string.lower(searchText), 1, true) ~= nil
    end

    local function rebuild()
        for _, obj in ipairs(itemRefs) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        table.clear(itemRefs)

        local visibleCount = 0

        for _, value in ipairs(values) do
            if isVisibleOption(value) then
                visibleCount += 1

                local item = New("Frame", {
                    Parent = listFrame,
                    BackgroundColor3 = theme.SurfaceAlt,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                MakeCorner(item, 8)
                local itemStroke = MakeStroke(item, theme.Border, 1, 0)

                local itemButton = New("TextButton", {
                    Parent = item,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = ""
                })

                local selectedState = isMulti and selected[value] or selected == value

                local mark = New("TextLabel", {
                    Parent = item,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(10, 0),
                    Size = UDim2.fromOffset(18, 32),
                    Text = selectedState and "✓" or "",
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = theme.Primary,
                    TextXAlignment = Enum.TextXAlignment.Center
                })

                local text = New("TextLabel", {
                    Parent = item,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(30, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Text = tostring(value),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = selectedState and theme.Text or theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                if selectedState then
                    item.BackgroundColor3 = theme.SurfaceLight
                    itemStroke.Color = theme.Primary
                end

                itemButton.MouseEnter:Connect(function()
                    if not (isMulti and selected[value]) and not (not isMulti and selected == value) then
                        Tween(item, 0.12, {BackgroundColor3 = theme.SurfaceLight})
                    end
                end)

                itemButton.MouseLeave:Connect(function()
                    if not (isMulti and selected[value]) and not (not isMulti and selected == value) then
                        Tween(item, 0.12, {BackgroundColor3 = theme.SurfaceAlt})
                    end
                end)

                itemButton.MouseButton1Click:Connect(function()
                    if isMulti then
                        selected[value] = not selected[value]
                    else
                        selected = value
                        opened = false
                    end

                    updateLabel()
                    emit()
                    rebuild()

                    if not isMulti then
                        local totalHeight = options.Search and 38 or 0
                        dropdownHolder.Visible = true
                        Tween(dropdownHolder, 0.18, {Size = UDim2.new(1, 0, 0, 0)})
                        Tween(arrow, 0.18, {Rotation = 0})
                        task.delay(0.18, function()
                            if not opened and dropdownHolder then
                                dropdownHolder.Visible = false
                            end
                        end)
                    end
                end)

                table.insert(itemRefs, item)
            end
        end

        local maxVisible = math.min(visibleCount, 5)
        local targetHeight = (options.Search and 38 or 0) + (maxVisible * 38)

        listFrame.Size = UDim2.new(1, 0, 0, math.max(0, targetHeight - (options.Search and 38 or 0)))
    end

    local function setOpen(state)
        opened = state
        dropdownHolder.Visible = true

        if opened then
            rebuild()
            local visibleCount = 0
            for _, value in ipairs(values) do
                if isVisibleOption(value) then
                    visibleCount += 1
                end
            end

            local maxVisible = math.min(visibleCount, 5)
            local targetHeight = (options.Search and 38 or 0) + (maxVisible * 38)

            Tween(dropdownHolder, 0.18, {
                Size = UDim2.new(1, 0, 0, targetHeight)
            })
            Tween(arrow, 0.18, {Rotation = 180})
            Tween(mainStroke, 0.18, {Color = theme.Primary})
        else
            Tween(dropdownHolder, 0.18, {
                Size = UDim2.new(1, 0, 0, 0)
            })
            Tween(arrow, 0.18, {Rotation = 0})
            Tween(mainStroke, 0.18, {Color = theme.Border})

            task.delay(0.18, function()
                if not opened and dropdownHolder then
                    dropdownHolder.Visible = false
                end
            end)
        end
    end

    toggleButton.MouseButton1Click:Connect(function()
        setOpen(not opened)
    end)

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            searchText = searchBox.Text or ""
            rebuild()
        end)
    end

    local element = {}

    function element:SetValue(v)
        if isMulti then
            selected = {}
            if type(v) == "table" then
                for k, state in pairs(v) do
                    if type(k) == "number" then
                        selected[state] = true
                    elseif state then
                        selected[k] = true
                    end
                end
            end
        else
            if table.find(values, v) then
                selected = v
            end
        end

        updateLabel()
        rebuild()
        emit()
    end

    function element:GetValue()
        if isMulti then
            local copy = {}
            for k, v in pairs(selected) do
                copy[k] = v
            end
            return copy
        end

        return selected
    end

    function element:OnChanged(fn)
        return changed:Connect(fn)
    end

    function element:Refresh(newValues)
        values = newValues or {}
        rebuild()
        updateLabel()
    end

    element.Instance = frame
    updateLabel()
    rebuild()

    return element
end

function TabClass:CreateSection(title)
    return self:AddSection(title)
end

function WindowClass:CreateTab(options)
    return self:AddTab(options)
end

function WindowClass:Notify(options)
    return Library:Notify(options)
end

function WindowClass:Destroy()
    if self.Gui then
        self.Gui:Destroy()
    end

    for i, win in ipairs(Library.Windows) do
        if win == self then
            table.remove(Library.Windows, i)
            break
        end
    end
end

function WindowClass:SetTitle(text)
    self.Config.Title = text or self.Config.Title
    if self.TitleLabel then
        self.TitleLabel.Text = self.Config.Title
    end
end

function WindowClass:SetSubtitle(text)
    self.Config.Subtitle = text or ""
    if self.SubtitleLabel then
        self.SubtitleLabel.Text = self.Config.Subtitle
    end
end

function WindowClass:SetTheme(themeInput)
    local newTheme = Library:GetTheme(themeInput)

    if self.Config.PrimaryColor then
        newTheme.Primary = self.Config.PrimaryColor
    end

    self.Theme = newTheme

    if self.Frame then
        self.Frame.BackgroundColor3 = newTheme.Surface
    end

    if self.WindowGradient then
        self.WindowGradient.Color = ColorSequence.new(newTheme.BackgroundTop, newTheme.BackgroundBottom)
    end

    if self.MainStroke then
        self.MainStroke.Color = newTheme.Border
    end
end

local function CreateWindowShell(window)
    local theme = window.Theme

    local gui = New("ScreenGui", {
        Name = "SpectrumX_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GetGuiParent()
    })
    ProtectGui(gui)

    local root = New("Frame", {
        Parent = gui,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1)
    })

    local shadow = New("Frame", {
        Parent = root,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = window.Config.Size,
        BackgroundColor3 = theme.Shadow,
        BackgroundTransparency = 0.7
    })
    MakeCorner(shadow, 12)

    local frame = New("Frame", {
        Parent = root,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = window.Config.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = window.Config.Size,
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.05,
        ClipsDescendants = true
    })
    MakeCorner(frame, 12)
    local scale = New("UIScale", {
        Parent = frame,
        Scale = 1
    })

    local gradient = MakeGradient(frame, theme.BackgroundTop, theme.BackgroundBottom, 90)
    local stroke = MakeStroke(frame, theme.Border, 1, 0)

    local acrylic = New("Frame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.97,
        Size = UDim2.fromScale(1, 1)
    })
    MakeGradient(acrylic, Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), 0)

    local titleBar = New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52)
    })
    MakePadding(titleBar, 14, 14, 10, 8)

    local titleIcon = CreateIcon(titleBar, window.Config.Icon or "panel", theme.Primary, 16, 0)
    if titleIcon then
        titleIcon.Position = UDim2.new(0, 0, 0.5, -8)
    end

    local titleX = titleIcon and 24 or 0

    local titleLabel = New("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(titleX, 0),
        Size = UDim2.new(1, -100 - titleX, 0, 18),
        Text = window.Config.Title or "SpectrumX",
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local subtitleLabel = New("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(titleX, 18),
        Size = UDim2.new(1, -100 - titleX, 0, 14),
        Text = window.Config.Subtitle or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local controls = New("Frame", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(68, 28)
    })

    local controlsList = MakeList(controls, Enum.FillDirection.Horizontal, 8)
    controlsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsList.VerticalAlignment = Enum.VerticalAlignment.Center

    local minimizeWrap = New("Frame", {
        Parent = controls,
        BackgroundColor3 = theme.SurfaceAlt,
        Size = UDim2.fromOffset(28, 28)
    })
    MakeCorner(minimizeWrap, 8)
    MakeStroke(minimizeWrap, theme.Border, 1, 0)

    local minimize = New("TextButton", {
        Parent = minimizeWrap,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.TextMuted
    })

    local closeWrap = New("Frame", {
        Parent = controls,
        BackgroundColor3 = theme.SurfaceAlt,
        Size = UDim2.fromOffset(28, 28)
    })
    MakeCorner(closeWrap, 8)
    MakeStroke(closeWrap, theme.Border, 1, 0)

    local close = New("TextButton", {
        Parent = closeWrap,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.TextMuted
    })

    local divider = New("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 52),
        Size = UDim2.new(1, 0, 0, 1)
    })

    local body = New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 53),
        Size = UDim2.new(1, 0, 1, -53)
    })

    local bodyList = MakeList(body, Enum.FillDirection.Horizontal, 0)

    local tabsFrame = New("Frame", {
        Parent = body,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, window.Config.TabWidth, 1, 0)
    })

    local tabsScroll = New("ScrollingFrame", {
        Parent = tabsFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Border
    })
    MakePadding(tabsScroll, 10, 10, 10, 10)
    local tabsList = MakeList(tabsScroll, Enum.FillDirection.Vertical, 8)

    local contentFrame = New("Frame", {
        Parent = body,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -window.Config.TabWidth, 1, 0)
    })

    local contentPages = New("Frame", {
        Parent = contentFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1)
    })

    window.Gui = gui
    window.Root = root
    window.Shadow = shadow
    window.Frame = frame
    window.Scale = scale
    window.WindowGradient = gradient
    window.MainStroke = stroke
    window.Acrylic = acrylic
    window.TitleBar = titleBar
    window.TitleLabel = titleLabel
    window.SubtitleLabel = subtitleLabel
    window.Body = body
    window.BodyList = bodyList
    window.TabsFrame = tabsFrame
    window.TabsScroll = tabsScroll
    window.TabsList = tabsList
    window.ContentFrame = contentFrame
    window.ContentPages = contentPages

    minimize.MouseButton1Click:Connect(function()
        window:Toggle()
    end)

    close.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    minimize.MouseEnter:Connect(function()
        Tween(minimizeWrap, 0.14, {BackgroundColor3 = theme.SurfaceLight})
    end)
    minimize.MouseLeave:Connect(function()
        Tween(minimizeWrap, 0.14, {BackgroundColor3 = theme.SurfaceAlt})
    end)

    close.MouseEnter:Connect(function()
        Tween(closeWrap, 0.14, {BackgroundColor3 = theme.Error})
    end)
    close.MouseLeave:Connect(function()
        Tween(closeWrap, 0.14, {BackgroundColor3 = theme.SurfaceAlt})
    end)

    if window.Config.Draggable ~= false then
        MakeDraggable(titleBar, frame, function(pos)
            shadow.Position = UDim2.new(
                pos.X.Scale, pos.X.Offset,
                pos.Y.Scale, pos.Y.Offset + 4
            )
        end)
    end

    frame:GetPropertyChangedSignal("Position"):Connect(function()
        shadow.Position = UDim2.new(
            frame.Position.X.Scale, frame.Position.X.Offset,
            frame.Position.Y.Scale, frame.Position.Y.Offset + 4
        )
    end)

    frame:GetPropertyChangedSignal("Size"):Connect(function()
        shadow.Size = frame.Size
    end)

    window:_createResizeHandle()
    window:_createFloatingButton()
    window:_applyResponsive()

    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if window and window.Frame and window.Frame.Parent then
                window:_applyResponsive()
            end
        end)
    end
end

function WindowClass:CreateButton(parent, options)
    if parent and parent.AddButton then
        options = options or {}
        if options.Text and not options.Title then
            options.Title = options.Text
        end
        return parent:AddButton(options)
    end
end

function WindowClass:CreateToggle(parent, options)
    if parent and parent.AddToggle then
        options = options or {}
        if options.Text and not options.Title then
            options.Title = options.Text
        end
        return parent:AddToggle(options)
    end
end

function WindowClass:CreateSlider(parent, options)
    if parent and parent.AddSlider then
        options = options or {}
        if options.Text and not options.Title then
            options.Title = options.Text
        end
        return parent:AddSlider(options)
    end
end

function WindowClass:CreateDropdown(parent, options)
    if parent and parent.AddDropdown then
        options = options or {}
        if options.Text and not options.Title then
            options.Title = options.Text
        end
        return parent:AddDropdown(options)
    end
end

function WindowClass:CreateInput(parent, options)
    if parent and parent.AddInput then
        options = options or {}
        if options.Text and not options.Title then
            options.Title = options.Text
        end
        return parent:AddInput(options)
    end
end

function WindowClass:CreateNumberInput(parent, options)
    options = options or {}
    options.Numeric = true
    return self:CreateInput(parent, options)
end

function WindowClass:CreateLabel(parent, options)
    if parent and parent.AddLabel then
        options = options or {}
        if options.Text and not options.Title then
            options.Title = options.Text
        end
        return parent:AddLabel(options)
    end
end

function Library:SetVisible(state)
    for _, window in ipairs(self.Windows) do
        if window and window.SetVisible then
            window:SetVisible(state)
        end
    end
end

function Library:Toggle()
    for _, window in ipairs(self.Windows) do
        if window and window.Toggle then
            window:Toggle()
        end
    end
end

function Library:Destroy()
    for i = #self.Windows, 1, -1 do
        local window = self.Windows[i]
        if window and window.Destroy then
            window:Destroy()
        end
    end

    if self._notifyGui then
        self._notifyGui:Destroy()
        self._notifyGui = nil
    end
end

function Library:CreateWindow(options)
    options = options or {}

    local defaultConfig = {
        Title = "SpectrumX",
        Subtitle = "",
        Icon = "panel",
        Size = UDim2.fromOffset(550, 600),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        TabWidth = 160,
        Theme = "Dark",
        PrimaryColor = nil,
        Responsive = true,
        Acrylic = true,
        Draggable = true,
        Resizable = true,
        FloatingButton = {
            Enabled = true,
            Icon = "settings",
            Size = 54
        }
    }

    local config = merge(defaultConfig, options)
    local theme = self:GetTheme(config.Theme)

    if config.PrimaryColor then
        theme.Primary = config.PrimaryColor
    end

    local window = setmetatable({
        Config = config,
        Theme = theme,
        Tabs = {},
        SelectedTab = 1,
        Visible = true,
        Breakpoint = "Desktop"
    }, WindowClass)

    CreateWindowShell(window)

    table.insert(self.Windows, window)

    return window
end

return Library
