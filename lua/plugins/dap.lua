return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }
    -- Configure Delve adapter for Go debugging
    dap.adapters.delve = function(callback, config)
      if config.request == "attach" then
        -- Attach to a running process or remote headless dlv server
        if config.mode == "remote" then
          -- Attach to remote headless dlv server
          callback({
            type = "server",
            host = config.host or "127.0.0.1",
            port = config.port or "38697",
          })
        else
          -- Attach to local process
          local pid = config.pid
          if type(pid) == "function" then
            pid = pid()
          end
          callback({
            type = "server",
            port = "${port}",
            executable = {
              command = "dlv",
              args = {
                "attach",
                tostring(pid),
                "--headless",
                "--listen=127.0.0.1:${port}",
                "--accept-multiclient",
                "--log",
                "--log-output=dap",
              },
              detached = vim.fn.has("win32") == 0,
            },
          })
        end
      else
        -- Launch mode
        callback({
          type = "server",
          port = "${port}",
          executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
            detached = vim.fn.has("win32") == 0,
          },
        })
      end
    end

    -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
    dap.configurations.go = {
      {
        type = "delve",
        name = "Debug (go.mod)",
        request = "launch",
        program = "${workspaceFolder}",
      },
      {
        type = "delve",
        name = "Debug current file",
        request = "launch",
        program = "${file}",
      },
      {
        type = "delve",
        name = "Debug test (current file)",
        request = "launch",
        mode = "test",
        program = "${file}",
      },
      {
        type = "delve",
        name = "Debug test (go.mod package)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
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
      },
    }

    dap.configurations.c = {
      {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      },
    }

    if vim.fn.executable("netcoredbg") == 1 then
      dap.adapters.netcoredbg = {
        type = "executable",
        command = vim.fn.exepath("netcoredbg"),
        args = { "--interpreter=vscode" },
        options = { detached = false },
      }

      local barotrauma = require("util.barotrauma")
      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "Barotrauma Client (Debug)",
          request = "launch",
          program = function()
            local bin_dir = barotrauma.client_bin_dir("Debug")
            local dll = bin_dir and (bin_dir .. "/Barotrauma.dll")
            if dll and vim.fn.filereadable(dll) == 1 then
              return dll
            end
            return vim.fn.input(
              "Path to dll: ",
              (bin_dir or vim.fn.getcwd()) .. "/Barotrauma.dll",
              "file"
            )
          end,
          cwd = function()
            return barotrauma.client_bin_dir("Debug") or "${workspaceFolder}"
          end,
        },
        {
          type = "netcoredbg",
          name = "Barotrauma Server (Debug)",
          request = "launch",
          program = function()
            local root = barotrauma.root()
            local suffix = vim.uv.os_uname().sysname == "Linux" and "Linux"
              or vim.uv.os_uname().sysname == "Darwin" and "Mac"
              or "Windows"
            local dll = root and (root .. "/Barotrauma/bin/Debug" .. suffix .. "/net8.0/DedicatedServer.dll")
            if dll and vim.fn.filereadable(dll) == 1 then
              return dll
            end
            return vim.fn.input("Path to dll: ", (root or vim.fn.getcwd()) .. "/", "file")
          end,
          cwd = function()
            local root = barotrauma.root()
            local suffix = vim.uv.os_uname().sysname == "Linux" and "Linux"
              or vim.uv.os_uname().sysname == "Darwin" and "Mac"
              or "Windows"
            return root and (root .. "/Barotrauma/bin/Debug" .. suffix .. "/net8.0") or "${workspaceFolder}"
          end,
        },
        {
          type = "netcoredbg",
          name = "Launch .NET DLL",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
      }
    end
  end,
}
