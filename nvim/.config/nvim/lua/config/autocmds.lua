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
