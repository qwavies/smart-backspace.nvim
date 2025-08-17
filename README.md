<h1 align="center">✨ Smart Backspace for Neovim ✨</h1>

<p align="center">Neovim plugin to save time removing indentation. Inspired by <a href="https://www.jetbrains.com/idea/">Intellij</a>'s backspace functionality</p>

## 🚀 Demo

**Coming soon!**

## 📦 Installation

### 📋 Requirements

- Neovim 0.5.0 or higher

> [!WARNING]
> If using with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), in `opts`, ensure that `map_bs = false`.

### 💤 For [lazy.nvim](https://lazy.folke.io) users:

```lua
{
    "qwavies/smart-backspace.nvim",
    event = "InsertEnter",
}
```

### 📦 For [packer.nvim](https://github.com/wbthomason/packer.nvim) users:

```lua
use {
    "qwavies/smart-backspace.nvim",
    event = "InsertEnter",
}
```

### 🔌 For [vim-plug](https://github.com/junegunn/vim-plug) users:

```vim
Plug "qwavies/smart-backspace.nvim"

lua << EOF
require("smart-backspace").setup()
EOF
```

## ⚙  Configuration

**Coming soon!**

## 👨‍💻 Planned Changes/Additions

- [ ] A `:SmartBackspaceToggle` command
- [ ] True compatibility with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), or act as an alternative
- [x] Using `<C-BS>` to use as a regular backspace
- [ ] User configuration for more flexibility
