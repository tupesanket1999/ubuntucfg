-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local jdtls = require('jdtls')
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = '/home/sanket/eclipse-workspace/' .. project_name
--print(workspace_dir)
--                                               string concattenation in Lu
local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {

        -- 💀
        '/usr/lib/jvm/openlogic-openjdk-17-hotspot-amd64/bin/java', -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

        -- 💀
        '-jar', '/home/sanket/java_lsp/plugins/org.eclipse.equinox.launcher_1.6.800.v20240426-1701.jar',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
        -- Must point to the                                                     Change this to
        -- eclipse.jdt.ls installation                                           the actual version


        -- 💀
        '-configuration', '/home/sanket/java_lsp/config_linux',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
        -- Must point to the                      Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls installation            Depending on your system.


        -- 💀
        -- See `data directory configuration` section in the README
        '-data', workspace_dir
    },

    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
    --root_dir = "/home/sanket/gitlocal/uptycs/cloud/",

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
        java = {

            eclipse = {
                downloadSources = true,
            },
            --maven = {
            --downloadSources = true,
            --},
            gradle = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = false,
            },
            signatureHelp = { enabled = true };
            contentProvider = { preferred = 'fernflower' };
            completion = {
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*"
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            };
            sources = {
                organizeImports = {
                    starThreshold = 9999;
                    staticStarThreshold = 9999;
                };
            };
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                },
                hashCodeEquals = {
                    useJava7Objects = true,
                },
                useBlocks = true,
            };
            configuration = {
                updateBuildConfiguration = "interactive",
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- And search for `interface RuntimeOption`
                -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
                runtimes = {
                    {
                        name = "JavaSE-17",
                        path = "/usr/lib/jvm/openlogic-openjdk-17-hotspot-amd64",
                    },
                }
            }
        }
    },

    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    init_options = {
        bundles = {
            "/home/sanket/java_lsp/vscode-java-test/server/com.microsoft.java.test.plugin-0.41.1.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/com.microsoft.java.test.runner-jar-with-dependencies.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/jacocoagent.jar ",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-api_5.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-engine_5.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-migrationsupport_5.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-params_5.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-commons_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-engine_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-launcher_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-runner_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-suite-api_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-suite-commons_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-suite-engine_1.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/junit-vintage-engine_5.9.3.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/org.apiguardian.api_1.1.2.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/org.eclipse.jdt.junit4.runtime_1.3.0.v20220609-1843.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/org.eclipse.jdt.junit5.runtime_1.1.100.v20220907-0450.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/org.jacoco.core_0.8.12.202403310830.jar",
            "/home/sanket/java_lsp/vscode-java-test/server/org.opentest4j_1.2.0.jar",
            "/home/sanket/java_lsp/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.52.0.jar"
        }
    },

    vim.api.nvim_exec(
        [[
    augroup FormatAutogroup
      autocmd!
      autocmd BufWritePost *.js,*.tsx,*.ts FormatWrite
    augroup END
  ]]     ,
        true
    )
}

--config.on_attach = function(client, bufnr)
--local function buf_set_keymap(...)
--vim.api.nvim_buf_set_keymap(bufnr, ...)
--end

--local function buf_set_option(...)
--vim.api.nvim_buf_set_option(bufnr, ...)
--end

---- Mappings.
--local opts = { noremap = true, silent = true }
--vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
--keymaps(buf_set_keymap, opts)
--buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
--end

config.capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
--config['init_options'] = {
--bundles = {
--vim.fn.glob("/home/sanket/java_lsp/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"),
--vim.fn.glob("/home/sanket/java_lsp/vscode-java-test/server/*.jar")
--};
--}
---- This bundles definition is the same as in the previous section (java-debug installation)
--local bundles = {

--};
---- This is the new part
--vim.list_extend(bundles, vim.split())
-- This bundles definition is the same as in the previous section (java-debug installation)
local bundles = {
    "/home/sanket/java_lsp/vscode-java-test/server/com.microsoft.java.test.plugin-0.41.1.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/com.microsoft.java.test.runner-jar-with-dependencies.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/jacocoagent.jar ",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-api_5.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-engine_5.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-migrationsupport_5.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-jupiter-params_5.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-commons_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-engine_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-launcher_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-runner_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-suite-api_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-suite-commons_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-platform-suite-engine_1.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/junit-vintage-engine_5.9.3.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/org.apiguardian.api_1.1.2.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/org.eclipse.jdt.junit4.runtime_1.3.0.v20220609-1843.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/org.eclipse.jdt.junit5.runtime_1.1.100.v20220907-0450.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/org.jacoco.core_0.8.12.202403310830.jar",
    "/home/sanket/java_lsp/vscode-java-test/server/org.opentest4j_1.2.0.jar",
    "/home/sanket/java_lsp/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.52.0.jar"
};
config['init_options'] = {
    bundles = bundles;
}

local function keymaps(buf_set_keymap, opts)
    buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    --buf_set_keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
    --buf_set_keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    --buf_set_keymap("n", "<space>gh", '<Cmd>Lspsaga signature_help<CR>', { silent = true, noremap = true })
    --buf_set_keymap("n", "<space>gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    --buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    buf_set_keymap("n", "<space>wd", "<cmd>Telescope diagnostics<CR>", opts)

    buf_set_keymap("n", "<space>df", "<cmd>lua require'jdtls'.test_class()<CR>", opts)
    buf_set_keymap("n", "<space>dn", "<cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
end

local on_attach = function(client, bufnr)
    jdtls.setup_dap({ hotcodereplace = 'auto',
        config_overrides = { vmArgs = "-Duptycs.home=/home/sanket/gitlocal/uptycs" } })
    jdtls.setup.add_commands()
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Mappings.
    local opts = { noremap = true, silent = true }
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")

    vim.api.nvim_exec(
        [[
    augroup FormatAutogroup
      autocmd!
      autocmd BufWritePost *.java,*.pom, FormatWrite
    augroup END
  ]]     ,
        true
    )

    keymaps(buf_set_keymap, opts)
    buf_set_keymap("n", "<space>f", "<cmd>Format<CR>", opts)
end
config.on_attach = on_attach
jdtls.start_or_attach(config)
require("jdtls.setup").add_commands()
