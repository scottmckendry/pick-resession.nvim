# 🔭 pick-resession.nvim

A picker plugin for the wonderful [resession.nvim](https://github.com/stevearc/resession.nvim) plugin, with support for both Telescope and Snacks pickers.

![image](https://github.com/scottmckendry/pick-resession.nvim/assets/39483124/93fb9c3d-1345-4f74-a37d-b8e520116362)

## 📦 Installation & Setup

### With Telescope

```lua
{
    "nvim-telescope/telescope.nvim",
    dependencies = { "scottmckendry/pick-resession.nvim" },
    config = function()
        telescope.setup({
            -- Other telescope config...
            extensions = {
                resession = {
                    prompt_title = "Find Sessions", -- telescope prompt title
                    dir = "session", -- directory where resession stores sessions
                },
            },
        })
    end,
}
```

### With Snacks Picker

```lua
-- No setup is required when using the defaults
-- Can be added a dependency for snacks or ressession configs, if desired
{ "scottmckendry/pick-resession.nvim" },
```

## ⏪ Recommended Resession Configuration

```lua
return {
    "stevearc/resession.nvim",
    config = function()
        local resession = require("resession")
        resession.setup({})

        -- Automatically save sessions on by working directory on exit
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                resession.save(vim.fn.getcwd(), { notify = true })
            end,
        })

        -- Automatically load sessions on startup by working directory
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                -- Only load the session if nvim was started with no args
                if vim.fn.argc(-1) == 0 then
                    resession.load(vim.fn.getcwd(), { silence_errors = true })
                end
            end,
            nested = true,
        })
    end,
}
```

## 🚀 Usage

With Telescope:

```vim
:Telescope resession
```

```lua
require("telescope").extensions.resession.resession()
```

With Snacks Picker:

```lua
require("pick-resession").pick()
```


**Key Maps:**

| Picker | Mode           | Key Mapping | Description                 |
| ------ | -------------- | ----------- | --------------------------- |
| Both   | Normal, Insert | `<CR>`      | Load the selected session   |
| Both   | Normal, Insert | `<C-d>`     | Delete the selected session |

## 🎨 Customization

### Telescope Configuration

```lua
extensions = {
    resession = {
        prompt_title = "Your custom prompt title",
        path_substitutions = {
            { find = "/home/username", replace = "🏠" },
        },
    },
},
```

### Snacks Picker Configuration

```lua
require("pick-resession").setup({
    prompt_title = "Your custom prompt title",
    layout = "dropdown", -- "default", "dropdown", "ivy", "select", "vscode"
    default_icon = {
        icon = "📁",
        highlight = "Directory"
    },
    -- These are processed in order, so put more specific matches first
    path_icons = {
        { match = "/home/username/projects", icon = "🛠️", highlight = "Special" },
        { match = "/home/username", icon = "🏠", highlight = "Directory" },
    },
})
```

### Example Snacks Picker Session Filtering

```lua
local function generate_sessions()
    local cwd = vim.fn.getcwd()
    local sessions = {}
    for idx, session in ipairs(require("resession").list({ dir = "gitsession" })) do
        local formatted = session:gsub("__", ":/"):gsub("_", "/")

        if formatted:match("^" .. cwd) then
            sessions[#sessions + 1] = {
                score = 0,
                text = session,
                value = session,
                idx = idx,
                display_value = formatted,
                file = formatted,
            }
        end
    end
    return sessions
end

-- Running `.pick()` will only return sesssions stored in the `gitsession`
-- directory and that originate from the current working directory.
require("pick-resession").pick({
    snacks_finder = generate_sessions,
    dir = "gitsession",
})

```
