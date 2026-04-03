--[[
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                    SpectrumX UI Library - Example                        ║
    ║                    Demonstração de uso completa                          ║
    ╚══════════════════════════════════════════════════════════════════════════╝
--]]

-- Carregar a biblioteca e ícones
local SpectrumX = loadstring(readfile("SpectrumX.lua"))()
local Icons = loadstring(readfile("Icons.lua"))()

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 1: Janela Básica com Ícones Lucide
-- ═══════════════════════════════════════════════════════════════════════════

local Window = SpectrumX:CreateWindow({
    Title = "Meu Script Premium",
    Icon = Icons["zap"], -- Ícone Lucide (raio/energia)
    -- ou pode usar: Icon = "rbxassetid://10709767827"
    -- ou: Icon = "⚡" (emoji)
    FloatButton = true, -- Habilita botão flutuante
    FloatIcon = Icons["settings"], -- Ícone do botão flutuante
})

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 2: Criando Tabs com Ícones Lucide
-- ═══════════════════════════════════════════════════════════════════════════

local MainTab = Window:CreateTab({
    Name = "Principal",
    Icon = Icons["home"] -- Ícone de casa
})

local VisualTab = Window:CreateTab({
    Name = "Visual",
    Icon = Icons["eye"] -- Ícone de olho
})

local SettingsTab = Window:CreateTab({
    Name = "Config",
    Icon = Icons["settings"] -- Ícone de engrenagem
})

local PlayerTab = Window:CreateTab({
    Name = "Jogador",
    Icon = Icons["user"] -- Ícone de usuário
})

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 3: Seções e Elementos na Tab Principal
-- ═══════════════════════════════════════════════════════════════════════════

-- Seção na coluna esquerda
Window:CreateSection(MainTab.Left, "Funcionalidades Principais", SpectrumX.Theme.Accent)

-- Toggle
local AutoFarmToggle = Window:CreateToggle(MainTab.Left, {
    Text = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
        -- Sua lógica aqui
    end
})

-- Botão com ícone
Window:CreateButton(MainTab.Left, {
    Text = "Teleportar para Base",
    Style = "accent",
    Icon = Icons["map-pin"], -- Ícone de localização
    Callback = function()
        print("Teleportando...")
        -- Sua lógica de teleporte
    end
})

-- Slider
Window:CreateSlider(MainTab.Left, {
    Text = "Velocidade",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        print("Velocidade:", value)
        -- Aplicar velocidade ao jogador
    end
})

-- Dropdown
Window:CreateDropdown(MainTab.Left, {
    Label = "Selecionar Arma",
    Options = {"Espada", "Pistola", "Rifle", "Sniper", "Lança"},
    Default = "Espada",
    Callback = function(selected)
        print("Arma selecionada:", selected)
    end
})

-- Multi Dropdown
Window:CreateMultiDropdown(MainTab.Left, {
    Label = "Habilidades Ativas",
    Options = {"Super Velocidade", "Super Pulo", "Invisibilidade", "Voo", "Regeneração"},
    Default = {"Super Velocidade"},
    Callback = function(selected)
        print("Habilidades:", table.concat(selected, ", "))
    end
})

-- Seção na coluna direita
Window:CreateSection(MainTab.Right, "Configurações", SpectrumX.Theme.Info)

-- Input
Window:CreateInput(MainTab.Right, {
    Label = "Nome do Jogador",
    Placeholder = "Digite o nome...",
    Default = "",
    Callback = function(text)
        print("Nome:", text)
    end
})

-- Number Input
Window:CreateNumberInput(MainTab.Right, {
    Label = "Quantidade",
    Default = 1,
    Min = 1,
    Max = 999,
    Callback = function(value)
        print("Quantidade:", value)
    end
})

-- Checkbox
Window:CreateCheckbox(MainTab.Right, {
    Text = "Modo Silencioso",
    Default = false,
    Callback = function(state)
        print("Modo Silencioso:", state)
    end
})

-- Label
Window:CreateLabel(MainTab.Right, {
    Text = "Esta é uma mensagem informativa que pode ter várias linhas se necessário.",
    Color = SpectrumX.Theme.TextSecondary
})

-- Separador
Window:CreateSeparator(MainTab.Right)

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 4: Tab Visual (ESP, Chams, etc)
-- ═══════════════════════════════════════════════════════════════════════════

Window:CreateSection(VisualTab.Left, "ESP", SpectrumX.Theme.Success)

Window:CreateToggle(VisualTab.Left, {
    Text = "ESP Jogadores",
    Default = false,
    Callback = function(state)
        print("ESP Jogadores:", state)
    end
})

Window:CreateToggle(VisualTab.Left, {
    Text = "ESP Caixas",
    Default = false,
    Callback = function(state)
        print("ESP Caixas:", state)
    end
})

Window:CreateToggle(VisualTab.Left, {
    Text = "ESP Itens",
    Default = false,
    Callback = function(state)
        print("ESP Itens:", state)
    end
})

Window:CreateSlider(VisualTab.Left, {
    Text = "Distância ESP",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Callback = function(value)
        print("Distância ESP:", value)
    end
})

Window:CreateSection(VisualTab.Right, "Chams", SpectrumX.Theme.Warning)

Window:CreateToggle(VisualTab.Right, {
    Text = "Chams Jogadores",
    Default = false,
    Callback = function(state)
        print("Chams:", state)
    end
})

Window:CreateColorPicker(VisualTab.Right, {
    Label = "Cor dos Chams",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Cor selecionada:", color)
    end
})

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 5: Tab Configurações
-- ═══════════════════════════════════════════════════════════════════════════

Window:CreateSection(SettingsTab.Left, "Interface", SpectrumX.Theme.Accent)

Window:CreateKeybind(SettingsTab.Left, {
    Label = "Tecla para Menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("Nova tecla do menu:", key)
    end
})

Window:CreateDropdown(SettingsTab.Left, {
    Label = "Tema",
    Options = {"Dark", "Darker", "Amoled", "Custom"},
    Default = "Dark",
    Callback = function(selected)
        print("Tema:", selected)
    end
})

Window:CreateSection(SettingsTab.Right, "Notificações", SpectrumX.Theme.Info)

Window:CreateToggle(SettingsTab.Right, {
    Text = "Notificações Ativas",
    Default = true,
    Callback = function(state)
        print("Notificações:", state)
    end
})

Window:CreateSlider(SettingsTab.Right, {
    Text = "Duração (segundos)",
    Min = 1,
    Max = 10,
    Default = 4,
    Callback = function(value)
        print("Duração:", value)
    end
})

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 6: Tab Jogador
-- ═══════════════════════════════════════════════════════════════════════════

Window:CreateSection(PlayerTab.Left, "Movimento", SpectrumX.Theme.Accent)

Window:CreateToggle(PlayerTab.Left, {
    Text = "Fly",
    Default = false,
    Callback = function(state)
        print("Fly:", state)
    end
})

Window:CreateToggle(PlayerTab.Left, {
    Text = "No Clip",
    Default = false,
    Callback = function(state)
        print("No Clip:", state)
    end
})

Window:CreateSlider(PlayerTab.Left, {
    Text = "Pulo Multiplicador",
    Min = 1,
    Max = 5,
    Default = 1,
    Callback = function(value)
        print("Pulo:", value)
    end
})

Window:CreateSection(PlayerTab.Right, "Combate", SpectrumX.Theme.Error)

Window:CreateToggle(PlayerTab.Right, {
    Text = "Aimbot",
    Default = false,
    Callback = function(state)
        print("Aimbot:", state)
    end
})

Window:CreateToggle(PlayerTab.Right, {
    Text = "Silent Aim",
    Default = false,
    Callback = function(state)
        print("Silent Aim:", state)
    end
})

Window:CreateSlider(PlayerTab.Right, {
    Text = "FOV",
    Min = 30,
    Max = 360,
    Default = 90,
    Callback = function(value)
        print("FOV:", value)
    end
})

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 7: Status Card (Draggable)
-- ═══════════════════════════════════════════════════════════════════════════

local StatusCard = Window:CreateStatusCard(MainTab.Left, {
    Title = "Status do Script"
})

-- Atualizar status
StatusCard:SetStatus("Online", SpectrumX.Theme.Success)
StatusCard:SetInfo("Script carregado com sucesso!")
StatusCard:SetProgress(0.75)

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 8: Notificações
-- ═══════════════════════════════════════════════════════════════════════════

-- Notificação de sucesso
Window:Notify({
    Text = "Script carregado com sucesso!",
    Type = "success",
    Duration = 4,
    Icon = Icons["check-circle"] -- Ícone Lucide opcional
})

-- Notificação de info
Window:Notify({
    Text = "Bem-vindo ao SpectrumX UI Library v2.1",
    Type = "info",
    Duration = 5
})

-- Notificação de aviso
Window:Notify({
    Text = "Alguns recursos podem não funcionar em todos os jogos.",
    Type = "warning",
    Duration = 6
})

-- Notificação de erro
Window:Notify({
    Text = "Falha ao conectar ao servidor!",
    Type = "error",
    Duration = 4
})

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 9: Acessando e Modificando Elementos
-- ═══════════════════════════════════════════════════════════════════════════

-- Mudar texto de um toggle
-- AutoFarmToggle.SetText("Novo Nome")

-- Mudar estado de um toggle
-- AutoFarmToggle.SetState(true)

-- Pegar estado atual
-- local estado = AutoFarmToggle.GetState()
-- print(estado)

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 10: Usando Asset IDs do Catálogo
-- ═══════════════════════════════════════════════════════════════════════════

-- Você também pode usar Asset IDs diretamente do catálogo Roblox:
--[[
local Window2 = SpectrumX:CreateWindow({
    Title = "Outro Script",
    Icon = "rbxassetid://123456789", -- Seu próprio ícone do catálogo
    FloatIconAssetId = "rbxassetid://987654321", -- Ícone customizado para botão flutuante
})
--]]

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 11: Botão Flutuante Customizado
-- ═══════════════════════════════════════════════════════════════════════════

-- O botão flutuante já é criado automaticamente, mas você pode customizar:
-- Ele aparece no meio da tela, um pouco mais pra esquerda (35% da tela)
-- Com cantos arredondados (0.15 de corner radius)
-- E é arrastável tanto no desktop quanto no mobile!

-- Para esconder/mostrar o botão flutuante:
-- Window.FloatBtn.Visible = false

-- Para mudar a posição:
-- Window.FloatBtn.Position = UDim2.new(0.5, 0, 0.8, 0)

-- ═══════════════════════════════════════════════════════════════════════════
-- EXEMPLO 12: Funções Úteis da Biblioteca
-- ═══════════════════════════════════════════════════════════════════════════

-- Esconder/mostrar a janela
-- Window:SetVisible(false)
-- Window:SetVisible(true)

-- Toggle visibilidade
-- Window:Toggle()

-- Mudar posição
-- Window:SetPosition(UDim2.new(0.5, 0, 0.5, 0))

-- Mudar tamanho
-- Window:SetSize(UDim2.new(0, 600, 0, 400))

-- Destruir a UI
-- Window:Destroy()

-- Pegar referência ao MainFrame
-- local frame = Window:GetWindow()

-- Acessar ícones Lucide
-- local icon = Icons["home"]
-- print(icon) -- rbxassetid://10723407389

-- Acessar ícones pela biblioteca
-- local icons = SpectrumX:GetIcons()
-- print(icons["settings"])

-- Mudar ícone do dropdown
-- SpectrumX:SetDropdownArrowIcon("chevron-down")
-- ou
-- SpectrumX:SetDropdownArrowIcon(Icons["chevron-down"])

print("✅ SpectrumX UI Library v2.1 carregada com sucesso!")
print("📦 Ícones Lucide disponíveis:", Icons and "Sim" or "Não")
print("🎨 Tabs criadas:", #Window.Tabs)
