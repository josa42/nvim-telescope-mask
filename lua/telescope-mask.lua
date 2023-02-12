local M = {}

local mask
local config = {
  blend = 30,
}

local mask_remove = function()
  if mask then
    vim.api.nvim_win_close(mask.win, true)
    vim.api.nvim_buf_delete(mask.buf, { force = true })
    mask = nil
  end
end

local mask_add = function()
  mask_remove()

  local editor = vim.api.nvim_list_uis()[1]

  mask = {}

  mask.win = vim.api.nvim_open_win(0, true, {
    -- fixed.
    relative = 'editor',
    focusable = true,
    zindex = 10,
    -- variables.
    row = 0,
    col = 0,
    height = editor.height,
    width = editor.width,
    border = 'none',

    style = 'minimal',
    noautocmd = true,
  })

  vim.cmd.enew()
  mask.buf = vim.api.nvim_get_current_buf()

  vim.opt_local.winblend = config.blend
  vim.opt_local.winhighlight = { Normal = 'Normal' }
end

local mask_resize = function()
  if mask then
    local editor = vim.api.nvim_list_uis()[1]
    vim.api.nvim_win_set_width(mask.win, editor.width)
    vim.api.nvim_win_set_height(mask.win, editor.height)
  end
end

local group = vim.api.nvim_create_augroup('telescope-mask', { clear = true })

function M.config(opts)
  -- TODO input validation
  config = vim.tbl_extend('force', config, opts)
end

function M.setup()
  print('setup')
  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = function(opts)
      local filetype = vim.api.nvim_buf_get_option(opts.buf, 'filetype')
      if filetype == 'TelescopePrompt' then
        mask_remove()
      end
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'TelescopeFindPre',
    callback = function()
      mask_add()
    end,
  })

  vim.api.nvim_create_autocmd('VimResized', {
    group = group,
    callback = function()
      mask_resize()
    end,
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = function(opts)
      local filetype = vim.api.nvim_buf_get_option(opts.buf, 'filetype')
      if filetype == 'TelescopePrompt' then
        mask_remove()
      end
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'TelescopeFindPre',
    callback = function()
      mask_add()
    end,
  })

  vim.api.nvim_create_autocmd('VimResized', {
    group = group,
    callback = function()
      mask_resize()
    end,
  })
end

return M
