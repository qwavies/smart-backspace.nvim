<h1 align="center">✨ Smart Backspace for Neovim</h1>

_Neovim plugin to save time removing indentation. Inspired by [Intellij](https://www.jetbrains.com/idea/)'s backspace functionality_

## 🚀 Demo

**Coming soon!**




## 📦 Installation

> [!CAUTION]
> If using with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), in `opts`, ensure that `map_bs = false`.

### Requirements

- Neovim 0.5.0 or higher

### For [lazy.nvim](https://lazy.folke.io) users:

```lua
{
    "qwavies/smart-backspace.nvim",
    event = "InsertEnter",
    config = function()
        require("smart-backspace").setup()
    end
}
```

### For [vim-plug](https://github.com/junegunn/vim-plug) users:

```vim
Plug "qwavies/smart-backspace.nvim"

lua << EOF
require("smart-backspace").setup()
EOF
```

### For [packer](https://github.com/wbthomason/packer.nvim) users:

```lua
use {
    "qwavies/smart-backspace.nvim",
    event = "InsertEnter",
    config = function()
        require("smart-backspace").setup()
    end
}
```

## ⚙  Configuration

**Coming soon!**

## 👨‍💻 Planned Changes/Additions

- [ ] A `:SmartBackspaceToggle` command
- [ ] True compatibility with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), or act as an alternative
- [ ] Using `<S-BS>` to use as a regular backspace
- [ ] User configuration for more flexibility
