<h1 align="center">✨ Smart Backspace for Neovim ✨</h1>

<p align="center">Neovim plugin to save time removing indentation written in lua. Inspired by <a href="https://www.jetbrains.com/idea/">IntelliJ</a>'s backspace functionality.</p>

## 🚀 Demo

https://github.com/user-attachments/assets/395f18ee-1346-4ac2-8b5c-79597cffe995

## 📦 Installation

### 📋 Requirements

- Neovim 0.8.0 or higher

> [!WARNING]
> If using with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), in `opts`, ensure that `map_bs = false`.

### For 💤 [lazy.nvim](https://lazy.folke.io) users:

```lua
{
    "qwavies/smart-backspace.nvim",
    event = "InsertEnter",
}
```

### For 📦 [packer.nvim](https://github.com/wbthomason/packer.nvim) users:

```lua
use {
    "qwavies/smart-backspace.nvim",
    event = "InsertEnter",
}
```

### For 🔌 [vim-plug](https://github.com/junegunn/vim-plug) users:

```vim
Plug "qwavies/smart-backspace.nvim"
```

## ⚙  Configuration

**Coming soon!**

## 👨‍💻 Planned Changes/Additions

- [x] A `:SmartBackspaceToggle` command
- [ ] True compatibility with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), or act as an alternative
  - [x] Delete pairs of brackets like [nvim-autopairs](https://github.com/windwp/nvim-autopairs)
  - [ ] Remove the need to set `map_bs = false`
- [x] Using `<C-BS>` to use as a regular backspace
- [x] User configuration for more flexibility (feel free to recommend me more configuration changes!)
