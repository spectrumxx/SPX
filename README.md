# SpectrumX UI Library v2.1

Uma biblioteca UI profissional para Roblox com suporte completo a ícones Lucide, botão flutuante arrastável e design moderno.

## 📁 Arquivos

- **`SpectrumX.lua`** - Biblioteca principal
- **`Icons.lua`** - Coleção de ícones Lucide (rbxassetid://)
- **`Example.lua`** - Exemplo completo de uso

## 🚀 Instalação

Coloque os arquivos `SpectrumX.lua` e `Icons.lua` no mesmo diretório e carregue:

```lua
local SpectrumX = loadstring(readfile("SpectrumX.lua"))()
local Icons = loadstring(readfile("Icons.lua"))()
```

## 🎨 Criando uma Janela

```lua
local Window = SpectrumX:CreateWindow({
    Title = "Meu Script",
    Icon = Icons["zap"],              -- Ícone Lucide
    -- ou Icon = "rbxassetid://123456" -- Asset ID do catálogo
    -- ou Icon = "⚡"                   -- Emoji
    FloatButton = true,               -- Habilita botão flutuante
    FloatIcon = Icons["settings"]     -- Ícone do botão flutuante
})
```

## 📑 Criando Tabs

```lua
local MainTab = Window:CreateTab({
    Name = "Principal",
    Icon = Icons["home"]
})

local VisualTab = Window:CreateTab({
    Name = "Visual", 
    Icon = Icons["eye"]
})
```

## 🧩 Elementos Disponíveis

### Toggle
```lua
Window:CreateToggle(parent, {
    Text = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Estado:", state)
    end
})
```

### Button
```lua
Window:CreateButton(parent, {
    Text = "Executar",
    Style = "accent", -- "default", "accent", "warning", "info", "danger"
    Icon = Icons["play"], -- Ícone opcional
    Callback = function()
        print("Clicado!")
    end
})
```

### Slider
```lua
Window:CreateSlider(parent, {
    Text = "Velocidade",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Valor:", value)
    end
})
```

### Dropdown
```lua
Window:CreateDropdown(parent, {
    Label = "Selecionar",
    Options = {"Opção 1", "Opção 2", "Opção 3"},
    Default = "Opção 1",
    Callback = function(selected)
        print("Selecionado:", selected)
    end
})
```

### Multi Dropdown
```lua
Window:CreateMultiDropdown(parent, {
    Label = "Multi Seleção",
    Options = {"A", "B", "C"},
    Default = {"A"},
    Callback = function(selected)
        -- selected é uma tabela
        print(table.concat(selected, ", "))
    end
})
```

### Input
```lua
Window:CreateInput(parent, {
    Label = "Nome",
    Placeholder = "Digite aqui...",
    Default = "",
    Callback = function(text)
        print("Texto:", text)
    end
})
```

### Number Input
```lua
Window:CreateNumberInput(parent, {
    Label = "Quantidade",
    Default = 1,
    Min = 0,
    Max = 100,
    Callback = function(value)
        print("Número:", value)
    end
})
```

### Checkbox
```lua
Window:CreateCheckbox(parent, {
    Text = "Ativar",
    Default = false,
    Callback = function(state)
        print("Checkbox:", state)
    end
})
```

### Label
```lua
Window:CreateLabel(parent, {
    Text = "Mensagem informativa",
    Color = SpectrumX.Theme.TextSecondary,
    Wrapped = true,
    AutoSize = true
})
```

### Separator
```lua
Window:CreateSeparator(parent)
```

### Section
```lua
Window:CreateSection(parent, "Título da Seção", Color3.fromRGB(255, 0, 0))
```

### Color Picker
```lua
Window:CreateColorPicker(parent, {
    Label = "Cor",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Cor:", color)
    end
})
```

### Keybind
```lua
Window:CreateKeybind(parent, {
    Label = "Tecla",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("Tecla:", key)
    end
})
```

### Status Card (Draggable)
```lua
local Status = Window:CreateStatusCard(parent, {
    Title = "Status"
})

Status:SetStatus("Online", SpectrumX.Theme.Success)
Status:SetInfo("Tudo funcionando!")
Status:SetProgress(0.75)
Status:AnimateLoading(true, 2)
```

## 🔔 Notificações

```lua
Window:Notify({
    Text = "Mensagem de sucesso!",
    Type = "success", -- "success", "info", "warning", "error"
    Duration = 4,
    Icon = Icons["check-circle"] -- Opcional
})
```

## 🎯 Ícones Lucide Disponíveis

### Navegação
- `arrow-down`, `arrow-up`, `arrow-left`, `arrow-right`
- `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`
- `chevrons-down`, `chevrons-up`, `chevrons-left`, `chevrons-right`

### Ações
- `check`, `check-circle`, `check-circle-2`, `check-square`
- `x`, `x-circle`, `x-square`, `x-octagon`
- `plus`, `plus-circle`, `plus-square`
- `minus`, `minus-circle`, `minus-square`
- `trash`, `trash-2`, `edit`, `edit-2`, `edit-3`
- `copy`, `save`, `download`, `upload`
- `refresh-cw`, `refresh-ccw`, `rotate-cw`, `rotate-ccw`
- `search`, `zoom-in`, `zoom-out`

### UI
- `menu`, `grid`, `list`, `layout`
- `sidebar`, `sidebar-open`, `sidebar-close`
- `maximize`, `maximize-2`, `minimize`, `minimize-2`

### Mídia
- `play`, `play-circle`, `pause`, `pause-circle`
- `skip-forward`, `skip-back`, `rewind`, `fast-forward`
- `volume`, `volume-1`, `volume-2`, `volume-x`
- `mic`, `mic-off`, `video`, `video-off`, `image`, `music`

### Comunicação
- `message-circle`, `message-square`, `mail`, `send`
- `bell`, `bell-off`, `bell-plus`, `bell-minus`, `bell-ring`
- `phone`, `phone-call`, `phone-off`, `share`, `share-2`

### Status
- `info`, `alert-circle`, `alert-triangle`, `alert-octagon`
- `help-circle`, `star`, `star-half`, `heart`, `thumbs-up`, `thumbs-down`

### Configurações
- `settings`, `settings-2`, `sliders`, `sliders-horizontal`, `cog`
- `tool`, `wrench`, `hammer`, `scissors`

### Segurança
- `key`, `lock`, `unlock`, `shield`, `shield-check`, `shield-alert`, `shield-off`
- `eye`, `eye-off`

### Arquivos
- `file`, `file-text`, `file-plus`, `file-minus`, `file-check`, `file-x`, `file-code`
- `folder`, `folder-open`, `folder-plus`, `folder-minus`, `folder-check`, `folder-x`

### Código
- `code`, `code-2`, `terminal`, `braces`, `command`, `cpu`, `database`, `server`
- `git-branch`, `git-commit`, `git-merge`, `git-pull-request`

### Tempo
- `clock`, `timer`, `timer-off`, `timer-reset`, `hourglass`, `calendar`
- `watch`, `alarm-clock`, `alarm-clock-off`, `history`

### Pessoas
- `user`, `users`, `user-plus`, `user-minus`, `user-check`, `user-x`
- `smile`, `frown`, `meh`, `heart`, `heart-off`, `heart-pulse`

### Dinheiro
- `dollar-sign`, `euro`, `pound-sterling`, `credit-card`, `wallet`
- `piggy-bank`, `receipt`, `banknote`, `coins`, `gem`, `diamond`
- `shopping-bag`, `shopping-cart`, `gift`, `gift-card`, `tag`, `tags`

### E muito mais!

## 🎨 Temas

```lua
-- Modificar tema
SpectrumX:SetTheme({
    Background = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(220, 35, 35),
    Text = Color3.fromRGB(255, 255, 255)
})

-- Acessar cores do tema atual
print(SpectrumX.Theme.Accent)
print(SpectrumX.Theme.Success)
print(SpectrumX.Theme.Error)
```

## 🔧 Funções Úteis

```lua
-- Esconder/mostrar janela
Window:SetVisible(false)
Window:SetVisible(true)
Window:Toggle()

-- Mudar posição e tamanho
Window:SetPosition(UDim2.new(0.5, 0, 0.5, 0))
Window:SetSize(UDim2.new(0, 600, 0, 400))

-- Destruir UI
Window:Destroy()

-- Pegar referência ao MainFrame
local frame = Window:GetWindow()

-- Acessar ícones
local Icons = SpectrumX:GetIcons()
print(Icons["home"])

-- Mudar ícone do dropdown
SpectrumX:SetDropdownArrowIcon(Icons["chevron-down"])
```

## 📱 Botão Flutuante

O botão flutuante é criado automaticamente quando `FloatButton = true`:

- ✅ **Arrastável** - Desktop e Mobile
- 📍 **Posição** - Meio da tela, um pouco mais pra esquerda (35%)
- 🔘 **Corner Radius** - 0.15 (arredondado mas não muito)
- 🎨 **Suporte a ícones** - Lucide, Asset ID ou texto

```lua
local Window = SpectrumX:CreateWindow({
    Title = "Script",
    FloatButton = true,
    FloatIcon = Icons["settings"],           -- Ícone Lucide
    -- ou FloatIconAssetId = "rbxassetid://..." -- Asset ID do catálogo
})

-- Acessar o botão flutuante
Window.FloatBtn.Visible = false  -- Esconder
Window.FloatBtn.Position = UDim2.new(0.5, 0, 0.8, 0)  -- Mudar posição
```

## 🎨 Estilos de Botão

- `"default"` - Fundo escuro com borda
- `"accent"` - Cor de destaque (vermelho por padrão)
- `"warning"` - Amarelo/laranja
- `"info"` - Azul
- `"danger"` - Vermelho

## 📋 Exemplo Completo

Veja o arquivo `Example.lua` para um exemplo completo de todas as funcionalidades!

## 📝 Notas

- A biblioteca é **100% compatível** com versões anteriores
- Suporte a **mobile** com escala automática
- **Sem dependências externas** (exceto Icons.lua opcional)
- Código **puro Lua** para Roblox

## 🏷️ Versão

**v2.1** - Integração com ícones Lucide, botão flutuante arrastável, suporte a Asset IDs

---

Criado com ❤️ para a comunidade Roblox
