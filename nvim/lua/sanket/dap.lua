local dap = require("dap")
require("dapui").setup()
require("nvim-dap-virtual-text").setup()
require("dap-go").setup()

dap.defaults.fallback.terminal_win_cmd = "belowright 100vsplit new"

dap.adapters.node2 = {
  type = "executable",
  command = "node",
  args = {os.getenv("HOME") .. "/debuggers/vscode-node-debug2/out/src/nodeDebug.js"},
  port = 30922
}

dap.adapters.cppdbg = {
  type = "executable",
  command = "/home/sanket/debuggers/cpptools/extension/debugAdapters/bin/OpenDebugAD7"
}

dap.configurations.javascript = {
  {
    name = "Uptycs Api server",
    type = "node2",
    request = "launch",
    program = "${workspaceFolder}/api/apiserver.js",
    runtimeArgs = {"--inspect-brk"},
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal",
    restart = true
  },
  {
    name = "Node debugger",
    type = "node2",
    request = "launch",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal"
  }
}

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true
  }
}

dap.adapters.go = function(callback, config)
  local stdout = vim.loop.new_pipe(false)
  local handle
  local pid_or_err
  local port = 38697
  local opts = {
    stdio = {nil, stdout},
    args = {"dap", "-l", "127.0.0.1:" .. port},
    detached = true
  }
  handle, pid_or_err =
    vim.loop.spawn(
    "dlv",
    opts,
    function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        print("dlv exited with code", code)
      end
    end
  )
  assert(handle, "Error running dlv: " .. tostring(pid_or_err))
  stdout:read_start(
    function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(
          function()
            require("dap.repl").append(chunk)
          end
        )
      end
    end
  )
  -- Wait for delve to start
  vim.defer_fn(
    function()
      callback({type = "server", host = "127.0.0.1", port = port})
    end,
    100
  )
end
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "go",
    name = "Debug uptycsapp",
    request = "launch",
    program = "./${relativeFileDirname}/",
    cwd = "/home/sanket/gitlocal/uptycs/cloud",
    mode = "debug",
  },
  {
    type = "go",
    name = "Debug file",
    request = "launch",
    program = "${file}"
  },
  {
    type = "go",
    name = "Debug uptycs cloudquery",
    request = "launch",
    program = "/home/sanket/gitlocal/uptycs-cloudquery/cmd/cloudquery/",
    cwd = "/home/sanket/gitlocal/uptycs-cloudquery/",
    mode = "debug",
    args = {'--socket','/home/sanket/.osquery/shell.em','--verbose','true'},
    env = "{'CLOUDQUERY_EXT_HOME':/home/sanket/gitlocal/uptycs-cloudquery,'DEBUG':true}"
  },
  {
    type = "go",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "go",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}
