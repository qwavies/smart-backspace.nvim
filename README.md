<h1 align="center">✨ Smart Backspace for Neovim ✨</h1>

<p align="center">Neovim plugin to save time removing indentation written in lua. Inspired by the JetBrains IDE <a href="https://www.jetbrains.com/idea/">IntelliJ</a>'s backspace functionality.</p>

## 🚀 Demo

https://github.com/user-attachments/assets/395f18ee-1346-4ac2-8b5c-79597cffe995

## 📦 Installation

### 📋 Requirements

- Neovim `0.8.0+`

> [!WARNING]
> If using with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), in `require("nvim-autopairs").setup({})`, ensure that `map_bs = false`.

### Using 📦 [vim.pack](https://neovim.io/doc/user/pack/#_plugin-manager):

```lua
vim.pack.add({"https://github.com/qwavies/smart-backspace.nvim"})
require("smart-backspace").setup()
```

<details>
<summary>Other Plugin Manager Instructions</summary>

### For 💤 [lazy.nvim](https://lazy.folke.io) users:

```lua
{
  "qwavies/smart-backspace.nvim"
}
```

### For 📦 [packer.nvim](https://github.com/wbthomason/packer.nvim) users:

```lua
use {
  "qwavies/smart-backspace.nvim"
}
```

### For 🔌 [vim-plug](https://github.com/junegunn/vim-plug) users:

```vim
Plug "qwavies/smart-backspace.nvim"
```
</details>

## ⚙  Configuration

### 💤 Lazy Loading

If you want to lazy load Smart Backspace, you can create an autocmd with an event condition. For example, using 📦 [vim.pack](https://neovim.io/doc/user/pack/#_plugin-manager):

```lua
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = function()
    vim.pack.add({"https://github.com/qwavies/smart-backspace.nvim"})
    require("smart-backspace").setup()
  end
})
```
<details>
<summary>Other Plugin Manager Instructions</summary>

### Using [lazy.nvim](https://lazy.folke.io):

```lua
{
  "qwavies/smart-backspace.nvim",
  event = {"InsertEnter", "CmdlineEnter"}
}
```
</details>

### 🧩 Default configuration

Using 📦 [vim.pack](https://neovim.io/doc/user/pack/#_plugin-manager):

```lua
vim.pack.add({"https://github.com/qwavies/smart-backspace.nvim"})
require("smart-backspace").setup({
  enabled = true, -- enables/disables smart-backspace
  silent = true, -- if set to false, it will send a notification if smart-backspace is toggled
  auto_keymap = true, -- determines if keymaps are assigned for you
  disabled_filetypes = { -- filetypes to automatically disable smart-backspace
    "", -- no extension
    "py",
    "hs",
    "md",
    "txt",
  }
})
```

<details>
<summary>Other Plugin Manager Instructions</summary>

### Using [lazy.nvim](https://lazy.folke.io):

```lua
{
  "qwavies/smart-backspace.nvim",
  opts = {
    enabled = true, -- enables/disables smart-backspace
    silent = true, -- if set to false, it will send a notification if smart-backspace is toggled
    auto_keymap = true, -- determines if keymaps are assigned for you
    disabled_filetypes = { -- filetypes to automatically disable smart-backspace
      "", -- no extension
      "py",
      "hs",
      "md",
      "txt",
    }
  }
}
```
</details>

### ⚡ Toggling smart-backspace

Using the `:SmartBackspaceToggle` command, smart-backspace can be toggled on/off.

You can force a certain state with either `:SmartBackspaceToggle on` or `:SmartBackspaceToggle off`

If you want to set a keybind to toggle smart-backspace, you can implement the following into your neovim config:

```lua
vim.keymap.set("n", "<leader>bs", "<cmd>SmartBackspaceToggle<CR>", { desc = "Toggle Smart Backspace" })
```

### 🎯 Setting your own keybinds

Keymaps are by default assigned to your `<BS>` and `<C-BS>` keys.

If you want more fine-grain control by opting out of the default keybinds, you can set turn `auto_keymap` off such as seen below:

```lua
require("smart-backspace").setup({
  auto_keymap = false,
})
```

Below are the following recommended keymaps that you can change to your own discretion:

```lua
vim.keymap.set("i", "<BS>", require("smart-backspace.backspace").smart_backspace, { desc = "Smart backspace" })
vim.keymap.set("i", "<C-BS>", require("smart-backspace.backspace").regular_backspace, { desc = "Simple backspace" })
```

## 🥇 Load times

Smart-Backspace prides itself in its almost instant load times.

Compare load times against some other plugins!

<img width="3839" height="2072" alt="image" src="https://github.com/user-attachments/assets/1be85339-88c0-4305-b0a0-fd54f295b7ac" />

## 👨‍💻 Planned Changes/Additions

- [x] A `:SmartBackspaceToggle` command
- [x] True compatibility with [nvim-autopairs](https://github.com/windwp/nvim-autopairs), or act as an alternative
  - [x] Delete pairs of brackets like [nvim-autopairs](https://github.com/windwp/nvim-autopairs)
  - [x] Send warning when smart-backspace has been overriden by another file/plugin
- [x] Using `<C-BS>` to use as a regular backspace
- [x] User configuration for more flexibility (feel free to recommend me more configuration changes!)
