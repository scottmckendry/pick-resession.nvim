local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local themes = require("telescope.themes")
local utils = require("telescope._extensions.resession.utils")

local M = {}

-- Delete the selected session
---@param prompt_bufnr number
function M.delete_session(prompt_bufnr)
    local opts = require("telescope._extensions.resession.config").opts
    local session = action_state.get_selected_entry()
    local encoded = utils.encode_session(session[1], opts)
    require("resession").delete(encoded, { dir = opts.dir })

    -- Refresh the picker
    actions.close(prompt_bufnr)
    M.resession_picker()
end

--- Load the selected session
---@param prompt_bufnr number
function M.load_session(prompt_bufnr)
    local opts = require("telescope._extensions.resession.config").opts
    local session = action_state.get_selected_entry()
    local encoded = utils.encode_session(session[1], opts)
    actions.close(prompt_bufnr)
    require("resession").load(encoded, { dir = opts.dir })
end

--- Render the session picker
---@param layout nil|table
function M.resession_picker(layout)
    local opts = require("telescope._extensions.resession.config").opts
    if layout == nil or vim.deep_equal(layout, {}) then
        layout = opts.layout
        if layout == nil then
            layout = themes.get_dropdown()
        end
    end
    local resession_opts = {
        prompt_title = opts.prompt_title,
        finder = require("telescope.finders").new_table({
            results = utils.get_results(opts),
        }),

        attach_mappings = function(_, map)
            map("i", "<CR>", M.load_session)
            map("n", "<CR>", M.load_session)
            map("i", "<C-d>", M.delete_session)
            map("n", "<C-d>", M.delete_session)
            return true
        end,

        sorter = sorters.get_fzy_sorter(),
    }

    return pickers.new(layout, resession_opts):find()
end

return M
