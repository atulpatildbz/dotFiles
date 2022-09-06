local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local Terminal = require("toggleterm.terminal").Terminal

-- our picker function: vimCustomRunner
-- This function will run command that user chooses
function vimCustomRunner(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "colors",
    --[[ finder = finders.new_table {
      results = { "red", "green", "blue" }
    }, ]]
    finder = finders.new_table {
      results = {
        { "Code Generator", "npm run generate" },
        { "Code Generator with bypass", "npm run generate -- --bypass=true" },
        { "Get all props with python", "python D:\\personal\\python\\getAllProps.py " .. vim.fn.expand("%:p")}
      },
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],
          ordinal = entry[1],
        }
      end
    },
    sorter = conf.generic_sorter(opts),                     -- default sorter allows for fuzzy matching
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()             -- replace the default action 
        actions.close(prompt_bufnr)                         -- close the prompt
        local selection = action_state.get_selected_entry()
        local doNotCloseCommand = " && timeout 3600 > nul"
        -- print(vim.inspect(selection))
        -- selection.value[2]
        local commandToRun = Terminal:new({ cmd = selection.value[2] .. doNotCloseCommand })
        commandToRun:toggle()
      end)
      return true
    end,
  }):find()
end

-- to execute the function
-- vimCustomRunner()
-- colors(require("telescope.themes").get_dropdown{})


-- create command for spectre
vim.cmd [[command! -nargs=0 Spectre :lua require('spectre').open()]]
