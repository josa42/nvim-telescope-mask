local M = {}

local mask
local config = {
  blend = 30,
}

local mask_remove = function()
  if mask then
    if vim.api.nvim_win_is_valid(mask.win) then
      vim.api.nvim_win_close(mask.win, true)
    end
    if vim.api.nvim_buf_is_valid(mask.buf) then
      vim.api.nvim_buf_delete(mask.buf, { force = true })
    end
    mask = nil
  end
end

local mask_add = function()
  mask_remove()

  mask = {}

  mask.buf = vim.api.nvim_create_buf(false, true)
  mask.win = vim.api.nvim_open_win(mask.buf, false, {
    -- fixed.
    relative = 'editor',
    focusable = false,
    zindex = 10,
    -- variables.
    row = 0,
    col = 0,
    height = vim.o.lines,
    width = vim.o.columns,
    border = 'none',

    style = 'minimal',
    noautocmd = true,
  })

  vim.wo[mask.win].list = false
  vim.wo[mask.win].winblend = config.blend
  vim.wo[mask.win].winhighlight = 'Normal:Normal'
end

local mask_resize = function()
  if mask and vim.api.nvim_win_is_valid(mask.win) then
    vim.api.nvim_win_set_config(mask.win, {
      relative = 'editor',
      row = 0,
      col = 0,
      height = vim.o.lines,
      width = vim.o.columns,
    })
  end
end

function M.config(opts)
  -- TODO input validation
  config = vim.tbl_extend('force', config, opts or {})
end

function M.setup()
  local group = vim.api.nvim_create_augroup('telescope-mask', { clear = true })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = function(opts)
      if vim.bo[opts.buf].filetype == 'TelescopePrompt' then
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
