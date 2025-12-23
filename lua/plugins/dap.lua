return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    -- Configure Delve adapter for Go debugging
    dap.adapters.delve = function(callback, config)
      if config.request == 'attach' then
        -- Attach to a running process or remote headless dlv server
        if config.mode == 'remote' then
          -- Attach to remote headless dlv server
          callback({
            type = 'server',
            host = config.host or '127.0.0.1',
            port = config.port or '38697'
          })
        else
          -- Attach to local process
          local pid = config.pid
          if type(pid) == "function" then
            pid = pid()
          end
          callback({
            type = 'server',
            port = '${port}',
            executable = {
              command = 'dlv',
              args = { 'attach', tostring(pid), '--headless', '--listen=127.0.0.1:${port}', '--accept-multiclient', '--log', '--log-output=dap' },
              detached = vim.fn.has("win32") == 0,
            }
          })
        end
      else
        -- Launch mode
        callback({
          type = 'server',
          port = '${port}',
          executable = {
            command = 'dlv',
            args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
            detached = vim.fn.has("win32") == 0,
          }
        })
      end
    end

    -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
    dap.configurations.go = {
      {
        type = "delve",
        name = "Debug (go.mod)",
        request = "launch",
        program = "${workspaceFolder}"
      },
      {
        type = "delve",
        name = "Debug current file",
        request = "launch",
        program = "${file}"
      },
      {
        type = "delve",
        name = "Debug test (current file)",
        request = "launch",
        mode = "test",
        program = "${file}"
      },
      {
        type = "delve",
        name = "Debug test (go.mod package)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}"
      },
      {
        type = "delve",
        name = "Attach to process",
        request = "attach",
        mode = "local",
        pid = require("dap.utils").pick_process,
      },
      {
        type = "delve",
        name = "Attach to remote (headless dlv)",
        request = "attach",
        mode = "remote",
        host = "127.0.0.1",
        port = 38697,
      }
    }
  end
}
