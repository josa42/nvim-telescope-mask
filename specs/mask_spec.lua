local mask = require('telescope-mask')

local find_mask_win = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).zindex == 10 then
      return win
    end
  end
end

local open_picker = function()
  require('telescope.pickers')
    .new({}, {
      finder = require('telescope.finders').new_table({ results = { 'a', 'b' } }),
    })
    :find()
  vim.wait(50)
end

local close_picker = function()
  require('telescope.actions').close(vim.api.nvim_get_current_buf())
  vim.wait(50)
end

describe('telescope-mask', function()
  before_each(function()
    mask.config({ blend = 30 })
    mask.setup()
  end)

  after_each(function()
    if vim.bo.filetype == 'TelescopePrompt' then
      close_picker()
    end
  end)

  it('registers its autocmds once when setup is called repeatedly', function()
    mask.setup()
    assert.equals(3, #vim.api.nvim_get_autocmds({ group = 'telescope-mask' }))
  end)

  it('accepts config without options', function()
    assert.has_no.errors(function()
      mask.config()
    end)
  end)

  it('covers the editor while a picker is open', function()
    local orig_win = vim.api.nvim_get_current_win()
    mask.config({ blend = 50 })
    open_picker()

    local win = find_mask_win()
    assert.is_not_nil(win)
    local cfg = vim.api.nvim_win_get_config(win)
    assert.is_false(cfg.focusable)
    assert.equals(vim.o.columns, cfg.width)
    assert.equals(50, vim.wo[win].winblend)
    assert.are_not.equals(win, vim.api.nvim_get_current_win())

    close_picker()
    assert.equals(orig_win, vim.api.nvim_get_current_win())
  end)

  it('removes the mask window and buffer when the picker closes', function()
    open_picker()
    local win = find_mask_win()
    local buf = vim.api.nvim_win_get_buf(win)

    close_picker()
    assert.is_false(vim.api.nvim_win_is_valid(win))
    assert.is_false(vim.api.nvim_buf_is_valid(buf))
  end)

  it('resizes the mask on VimResized', function()
    open_picker()
    vim.o.columns = vim.o.columns - 10
    vim.api.nvim_exec_autocmds('VimResized', {})

    assert.equals(vim.o.columns, vim.api.nvim_win_get_width(find_mask_win()))
  end)

  it('closes the picker cleanly when the mask was already closed', function()
    open_picker()
    vim.api.nvim_win_close(find_mask_win(), true)

    assert.has_no.errors(close_picker)
    assert.is_nil(find_mask_win())
  end)
end)
