local completion_preview = require("supermaven-nvim.completion_preview")
local log = require("supermaven-nvim.logger")
local config = require("supermaven-nvim.config")
local commands = require("supermaven-nvim.commands")
local api = require("supermaven-nvim.api")

local M = {}

M.setup = function(args)
  config.setup(args)

  if config.disable_inline_completion then
    completion_preview.disable_inline_completion = true
  elseif not config.disable_keymaps then
    if config.keymaps.accept_suggestion ~= nil then
      local accept_suggestion_key = config.keymaps.accept_suggestion
      -- Set keymaps for both insert and normal modes
      vim.keymap.set(
        "i",
        accept_suggestion_key,
        completion_preview.on_accept_suggestion,
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        accept_suggestion_key,
        completion_preview.on_accept_suggestion,
        { noremap = true, silent = true }
      )
    end

    if config.keymaps.accept_word ~= nil then
      local accept_word_key = config.keymaps.accept_word
      vim.keymap.set(
        "i",
        accept_word_key,
        completion_preview.on_accept_suggestion_word,
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        accept_word_key,
        completion_preview.on_accept_suggestion_word,
        { noremap = true, silent = true }
      )
    end

    if config.keymaps.clear_suggestion ~= nil then
      local clear_suggestion_key = config.keymaps.clear_suggestion
      vim.keymap.set("i", clear_suggestion_key, completion_preview.on_dispose_inlay, { noremap = true, silent = true })
      vim.keymap.set("n", clear_suggestion_key, completion_preview.on_dispose_inlay, { noremap = true, silent = true })
    end
    
    -- Add Escape key to clear suggestions in normal mode
    vim.keymap.set("n", "<Esc>", function()
      if completion_preview.has_suggestion() then
        completion_preview.on_dispose_inlay()
      else
        -- If no suggestion, execute normal Escape behavior
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end
    end, { noremap = true, silent = true })
  end

  commands.setup()

  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    local cmp_source = require("supermaven-nvim.cmp")
    cmp.register_source("supermaven", cmp_source.new())
  else
    if config.disable_inline_completion then
      log:warn(
        "nvim-cmp is not available, but inline completion is disabled. Supermaven nvim-cmp source will not be registered."
      )
    end
  end

  api.start()
end

return M
