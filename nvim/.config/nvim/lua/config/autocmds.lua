vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local highlight = ({ "ErrorMsg", "WarningMsg" })[result.type] or "Normal"
  vim.api.nvim_echo(
    { { ("LSP[%s] %s"):format(client and client.name or ctx.client_id, result.message), highlight } },
    true,
    {
      kind = "lsp_message",
    }
  )
end

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local value = ev.data.params.value
    if type(value) ~= "table" or not value.kind then
      return
    end
    local done = value.kind == "end"
    vim.api.nvim_echo({ { value.message or (done and "Done" or value.title or "Working...") } }, false, {
      id = ("lsp.%d.%s"):format(ev.data.client_id, ev.data.params.token),
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = done and "success" or "running",
      percent = done and 100 or value.percentage,
    })
  end,
})

-- When the snacks terminal is shown, starship's $fill makes the first prompt
-- line exactly the terminal width, so the cursor is rendered one row too high
-- (on the status line) due to libvterm pending-wrap. Re-send the PTY winsize to
-- make the shell redraw its ZLE and resync the cursor.
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= "snacks_terminal" then
      return
    end
    local job = vim.b[ev.buf].terminal_job_id
    if job then
      vim.fn.jobresize(job, vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0))
    end
  end,
})
