local M = {}

-- Define the Unix socket path
M.kitty_socket_path = 'unix:@mykitty'
M.matplotlib_backend = 'module://itermplot' -- Set your Matplotlib backend

-- Function to start the Kitty listener and launch Python REPL
function M.start_python_repl()
  -- Start the listener in a new Kitty window
  local listener_cmd = string.format('kitty --listen-on %s', M.kitty_socket_path)
  vim.fn.system(listener_cmd)

  -- Wait a moment to ensure the listener is up
  vim.fn.sleep(100) -- sleep in milliseconds

  -- Send the command to set the Matplotlib backend and launch the Python REPL
  local send_cmds =
    string.format('kitty @ --to %s send-text \'import matplotlib; matplotlib.use("%s")\\npython3\\n\'', M.kitty_socket_path, M.matplotlib_backend)
  vim.fn.system(send_cmds)

  print('Started Python REPL in Kitty with Matplotlib backend set to ' .. M.matplotlib_backend)
end

-- Function to send highlighted code to the Python REPL
function M.send_to_python_repl()
  -- Get the selected text in visual mode
  local _, start_row, start_col, _ = unpack(vim.fn.getpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getpos "'>")

  -- Ensure the code works correctly regardless of selection order
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  -- Get the selected lines as text
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  -- Adjust the first and last lines based on the column selections
  lines[1] = string.sub(lines[1], start_col)
  lines[#lines] = string.sub(lines[#lines], 1, end_col)

  -- Join lines into a single string for sending
  local code = table.concat(lines, '\n')

  -- Send the code to the Python REPL window using Kitty's `@` commands
  local send_cmd = string.format("kitty @ --to %s send-text '%s\\n'", M.kitty_socket_path, vim.fn.escape(code, "'"))
  vim.fn.system(send_cmd)
  print 'Sent code to Python REPL'
end

-- Function to set up keymaps
function M.setup()
  -- Keymap to start the Python REPL (e.g., <leader>rp)
  vim.api.nvim_set_keymap('n', '<leader>rp', ":lua require'custom.plugins.pyrepl'.start_python_repl()<CR>", { noremap = true, silent = true })
  -- Keymap to send highlighted code to the REPL (e.g., <leader>rs)
  vim.api.nvim_set_keymap('v', '<leader>rs', ":lua require'custom.plugins.pyrepl'.send_to_python_repl()<CR>", { noremap = true, silent = true })
end

return M
