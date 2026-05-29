local venv = require("util.venv")

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local root = config.root_dir or venv.project_root(config.bufnr)
    local cmd = venv.bin("pyright-langserver", root) or "pyright-langserver"
    if vim.fn.executable(cmd) ~= 1 then
      vim.notify(
        "pyright-langserver not found (install pyright in the project .venv or globally)",
        vim.log.levels.WARN
      )
    end
    return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        -- Breaking / correctness only; style and hygiene rules stay off.
        reportMissingImports = "error",
        reportUndefinedVariable = "error",
        reportGeneralTypeIssues = "error",
        reportOptionalMemberAccess = "error",
        reportOptionalSubscript = "error",
        reportOptionalIterable = "error",
        reportOptionalContextManager = "error",
        reportOptionalOperand = "error",
        reportArgumentType = "error",
        reportReturnType = "error",
        reportAttributeAccessIssue = "error",
        reportCallIssue = "error",
        reportIndexIssue = "error",
        reportOperatorIssue = "error",
        reportAssignmentType = "error",
        reportAbstractUsage = "error",
        reportInvalidTypeForm = "error",
        reportMissingTypeStubs = "none",
        reportUnusedImport = "none",
        reportUnusedVariable = "none",
        reportUnusedClass = "none",
        reportUnusedFunction = "none",
        reportUnusedCallResult = "none",
        reportUnusedExpression = "none",
        reportUnusedCoroutine = "none",
        reportDuplicateImport = "none",
        reportPrivateUsage = "none",
        reportConstantRedefinition = "none",
        reportImplicitStringConcatenation = "none",
        reportUnnecessaryComparison = "none",
        reportUnnecessaryIsInstance = "none",
        reportUnnecessaryCast = "none",
        reportUnnecessaryContains = "none",
        reportAssertAlwaysTrue = "none",
        reportSelfClsParameterName = "none",
        reportUnknownMemberType = "none",
        reportUnknownArgumentType = "none",
        reportUnknownVariableType = "none",
        reportUnknownParameterType = "none",
        reportMissingParameterType = "none",
        reportMissingTypeArgument = "none",
        reportUntypedFunctionDecorator = "none",
        reportUntypedClassDecorator = "none",
        reportUntypedBaseClass = "none",
        reportImplicitOverride = "none",
      },
    },
  },
}
