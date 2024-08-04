local dap = require("dap")
require("dapui").setup({
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    -- Expand lines larger than the window
    -- Requires >= 0.7
    expand_lines = vim.fn.has("nvim-0.7"),
    -- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                { id = "scopes", size = 0.25 },
                "breakpoints",
                "stacks",
                --"watches",
            },
            size = 40, -- 40 columns
            position = "left",
        },
        {
            elements = {
                "repl",
                --"console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
        },
    },
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
    }
})
require("nvim-dap-virtual-text").setup()
require("dap-go").setup()

dap.defaults.fallback.terminal_win_cmd = "belowright 100vsplit new"

dap.adapters.node2 = {
    type = "executable",
    command = "node",
    args = { os.getenv("HOME") .. "/debuggers/vscode-node-debug2/out/src/nodeDebug.js" },
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
        runtimeArgs = { "--inspect-brk" },
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
        stopOnEntry = true,
        console = "integratedTerminal"
    }
}

dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
        stdio = { nil, stdout },
        args = { "dap", "-l", "127.0.0.1:" .. port },
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
            callback({ type = "server", host = "127.0.0.1", port = port })
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
        args = { '--socket', '/home/sanket/.osquery/shell.em', '--verbose', 'true' },
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

dap.adapters.python = {
    type = 'executable';
    command = 'python3';
    args = { '-m', 'debugpy.adapter' };
}

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch';
        name = "Launch file";

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

        program = "${file}"; -- This configuration will launch the current file if used.
        pythonPath = function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd .. '/.venv/bin/python'
            else
                return '/usr/bin/python3'
            end
        end;
    },
    {
        -- The first three options are required by nvim-dap
        type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch';
        name = "Launch ciem cli";

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

        program = "/home/sanket/gitlocal/effective-permissions-poc/ciem/cli.py"; -- This configuration will launch the current file if used.
        args = { "identity-based", "-R", "uptycs-test-role-103", "-i", "-b", "-s", "-p", "effective-permissions", "-m",
            "effective-permissions", "-j" },
        cwd = vim.fn.getcwd(),
        pythonPath = function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd .. '/.venv/bin/python'
            else
                return '/usr/bin/python3'
            end
        end;
    },
}
dap.configurations.java = {
    {
        -- You need to extend the classPath to list your dependencies.
        -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
        -- If using multi-module projects, remove otherwise.
        projectName = "effective-permissions",
        mode = "debug",
        console = "internalTerminator",
        javaExec = "/usr/lib/jvm/openlogic-openjdk-17-hotspot-amd64/bin/java",
        mainClass = "com.uptycs.EffectivePermissions",
        cwd = "/home/sanket/gitlocal/uptycs/cloud",
        vmArgs = "-Dconfig.home=/home/sanket/gitlocal/config/generated_files/localhost -Duptycs.home=/home/sanket/gitlocal/uptycs -Dlog.name=effectivePermissions --add-opens java.base/java.nio=ALL-UNNAMED --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/sun.security.action=ALL-UNNAMED",
        --env = "CONFIG_HOME=/home/sanket/gitlocal/config/generated_files/localhost",
        --env = '{CONFIG_HOME:"/home/sanket/gitlocal/config/generated_files/localhost",DEBUG:true}',

        classPaths = {
            "/home/sanket/gitlocal/uptycs/cloud/effective-permissions/bin/main/",
            "/home/sanket/gitlocal/uptycs/cloud/coalesce/bin/main",
            "/home/sanket/gitlocal/uptycs/cloud/spring-common/bin/main",
            "/home/sanket/gitlocal/uptycs/cloud/java-utils/bin/main",
            "/home/sanket/gitlocal/uptycs/cloud/java-stats/bin/main",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-streaming_2.12/3.4.2/3bb7920aeac738c73be095b3dda855c46a39dad1/spark-streaming_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-hive_2.12/3.4.2/bfbe57fec91b9dda25582df93bbf144479c31d24/spark-hive_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-core_2.12/3.4.2/3719ed1b08db45575e24ff4d5e42469cf6a426fb/spark-core_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-client/3.3.6/a954e810173ed34d29b95eb2e4885dbf1afeb7fa/hadoop-client-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-text/1.10.0/3363381aef8cef2dbc1023b3e3a9433b08b64e01/commons-text-1.10.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-autoconfigure/3.2.5/6385a2c00a03edb896b2833e4bdee2ae53cd69b8/spring-boot-autoconfigure-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot/3.2.5/eec72431f6f56a50c9919129665ba3359ca02104/spring-boot-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/software.amazon.awssdk/arns/2.17.267/924c69b977734663c4a236bf23f1d8826d8dee1b/arns-2.17.267.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/software.amazon.awssdk/utils/2.17.267/67130ec34fcd8c58cab8f72cc3b120724ac5c925/utils-2.17.267.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-sql-kafka-0-10_2.12/3.4.2/ac18876a5cf0d4914176b9ac89cd7f7c280a95be/spark-sql-kafka-0-10_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.codehaus.janino/janino/3.1.9/536fb0c44627faae32ca7a8a24734f4aab38c878/janino-3.1.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.codehaus.janino/commons-compiler/3.1.9/f0d70bb319e9339aea90a8665693e69848acc598/commons-compiler-3.1.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.jayway.jsonpath/json-path/2.4.0/765a4401ceb2dc8d40553c2075eb80a8fa35c2ae/json-path-2.4.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.zaxxer/HikariCP/5.1.0/8c96e36c14461fc436bb02b264b96ef3ca5dca8c/HikariCP-5.1.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.guava/guava/29.0-jre/801142b4c3d0f0770dd29abea50906cacfddd447/guava-29.0-jre.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jdbi/jdbi3-core/3.44.0/6554f5b9bdaeaecaad0cbbad5494f411e3025bda/jdbi3-core-3.44.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-streaming-kafka-0-10_2.12/3.4.2/f057c69ea1deadce317181da5c90718bb2fff534/spark-streaming-kafka-0-10_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hudi/hudi-spark3-bundle_2.12/0.14.1/53d50e282c11f58b9baeb43ffd874a5e2b517cdd/hudi-spark3-bundle_2.12-0.14.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-web/3.2.5/664d75553c6af42122d4db645f4924a95084e382/spring-boot-starter-web-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-data-jpa/3.2.5/99c1272c135f1c44b0c94ed0b65dca9b201323b7/spring-boot-starter-data-jpa-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-jdbc/3.2.5/2fc156645b02bef43dcd4e697ae6f4ba9388a978/spring-boot-starter-jdbc-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-actuator/3.2.5/14ac0ed95f3913fb90d3a49884e561c88ad2d844/spring-boot-starter-actuator-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-data-redis/3.2.5/5c28002231949d324d5c5a06e0a1768103b3075f/spring-boot-starter-data-redis-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-integration/3.2.5/337d8fafda2671c3e48bcad1008e835a5a5a4fc9/spring-boot-starter-integration-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter/3.2.5/a9837a876129cc6fe5f3abf1de5ec0a16faaf003/spring-boot-starter-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-log4j2/3.2.5/abf9f6c325745c002ba1b1c001d63719f0ed799f/spring-boot-starter-log4j2-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.integration/spring-integration-redis/6.2.4/31d6d40e88f90714ea54b96b2caa4f49673a4810/spring-integration-redis-6.2.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.postgresql/postgresql/42.7.2/86ed42574cd68662b05d3b00432a34e9a34cb12c/postgresql-42.7.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.googlecode.json-simple/json-simple/1.1.1/c9ad4a0850ab676c5c64461a05ca524cdfff59f1/json-simple-1.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.code.gson/gson/2.10.1/b3add478d4382b78ea20b1671390a858002feb6c/gson-2.10.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.javatuples/javatuples/1.2/507312ac4b601204a72a83380badbca82683dd36/javatuples-1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-tags_2.12/3.4.2/e3b0250c3fa4a0761f61e47b36ba571de1138dd3/spark-tags_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.scala-lang/scala-library/2.12.17/4a4dee1ebb59ed1dbce014223c7c42612e4cddde/scala-library-2.12.17.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-sql_2.12/3.4.2/ce1239c54681dac0ff7c676c84152ebfc4f02295/spark-sql_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-metastore/2.3.7u1/881831ac3da15190a1eb931d4d1e090fd8ed44c7/hive-metastore-2.3.7u1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-common/2.3.9/f33a3bce9955c959afe9f441ad1eb7f2885c2ddb/hive-common-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-llap-common/2.3.9/9ac072bd790d719fa09258e6f922bdde4dc042f/hive-llap-common-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-llap-client/2.3.9/a9d33e5ee15083874b13643f7d734e77478e96ee/hive-llap-client-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-exec/2.3.7u1/cf8ffaee14827ad401456c8052b9dba417837f7d/hive-exec-2.3.7u1-core.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.avro/avro-mapred/1.11.1/5683d99c94f0ae35e2a3d5b2bcd974570b0ff388/avro-mapred-1.11.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.avro/avro/1.11.1/81af5d4b9bdaaf4ba41bcb0df5241355ec34c630/avro-1.11.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.code.findbugs/jsr305/3.0.2/25ea2e8b0c338a877313bd4672d3fe056ea78f0d/jsr305-3.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-serde/2.3.9/b76292b52f9127039b6a4ec4c81ed426a0e8e901/hive-serde-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-shims/2.3.9/758b531c2e0e925b8d00f0761e091a38a762bcdd/hive-shims-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.thrift/libfb303/0.9.3/5d1abb695642e88558f4e7e0d32aa1925a1fd0b7/libfb303-0.9.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.thrift/libthrift/0.12.0/300bfbee03c7afa77301fb0946115e400e28ae04/libthrift-0.12.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.httpcomponents/httpclient/4.5.14/1194890e6f56ec29177673f2f12d0b8e627dec98/httpclient-4.5.14.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.codehaus.jackson/jackson-mapper-asl/1.9.13/1ee2f2bed0e5dd29d1cb155a166e6f8d50bbddb7/jackson-mapper-asl-1.9.13.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-codec/commons-codec/1.15/49d94806b6e3dc933dacbd8acb0fdbab8ebd1e5d/commons-codec-1.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/joda-time/joda-time/2.12.2/78e18a7b4180e911dafba0a412adfa82c1e3d14b/joda-time-2.12.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jodd/jodd-core/3.5.2/a9ac8028eeeb5fa430e17017628629c94123c401/jodd-core-3.5.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.datanucleus/datanucleus-core/4.1.17/c03898d49b506b60849fe1db39d04ab27fa15422/datanucleus-core-4.1.17.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-client-runtime/3.3.4/21f7a9a2da446f1e5b3e5af16ebf956d3ee43ee0/hadoop-client-runtime-3.3.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.curator/curator-recipes/5.2.0/477c28fdc25eb5d59759d8e931be191f11068f4a/curator-recipes-5.2.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-network-shuffle_2.12/3.4.2/cc1d4faf34bd1c2a265ad2b94dd5cc746eb331c1/spark-network-shuffle_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-network-common_2.12/3.4.2/1c2796adc36f00e0a7f957fce9a686dc0bac6ffe/spark-network-common_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-lang3/3.12.0/c6842c86792ff03b9f1d1fe2aab8dc23aa6c6f0e/commons-lang3-3.12.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.slf4j/jul-to-slf4j/2.0.6/c4d348977a83a0bfcf42fd6fd1fee6e7904f1a0c/jul-to-slf4j-2.0.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.slf4j/jcl-over-slf4j/2.0.6/839ff57e112f2e28ef372e96d135696a6896b9ad/jcl-over-slf4j-2.0.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-slf4j2-impl/2.19.0/5c04bfdd63ce9dceb2e284b81e96b6a70010ee10/log4j-slf4j2-impl-2.19.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.clearspring.analytics/stream/2.9.6/f9c235bdf6681756b8d4b5429f6e7217597c37ef/stream-2.9.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.dropwizard.metrics/metrics-jvm/4.2.15/f3f51669eaae87cc8d95ec806f818b7a6f8dc390/metrics-jvm-4.2.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.dropwizard.metrics/metrics-json/4.2.15/e27a423a660c13b8a71370c78c80326d3a1acc9/metrics-json-4.2.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.dropwizard.metrics/metrics-graphite/4.2.15/5b4ed80b3cf371bd83fec91372942306c040777/metrics-graphite-4.2.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.dropwizard.metrics/metrics-jmx/4.2.15/ddbdf83a5510dbdf67a14bfdb8a92fd742078841/metrics-jmx-4.2.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.dropwizard.metrics/metrics-core/4.2.15/a3ee63ed254f9a6977e2751ffcc0f158c2c1f5e3/metrics-core-4.2.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.slf4j/slf4j-api/2.0.11/ad96c3f8cf895e696dd35c2bc8e8ebe710be9e6d/slf4j-api-2.0.11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-unsafe_2.12/3.4.2/9528460774edced67ac1a886e94c11bf0239a901/spark-unsafe_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-launcher_2.12/3.4.2/87c9b243c52bb3234b0359ece52e8ed3d966c697/spark-launcher_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-kvstore_2.12/3.4.2/387a4d67429f6fb563d9281d26560ed2dcc936ad/spark-kvstore_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.twitter/chill_2.12/0.10.0/b208321208c0b3232a305fccd59df3d6a1f1eecd/chill_2.12-0.10.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.scala-lang.modules/scala-xml_2.12/2.1.0/16b228fa6f9d5afece0f2d2d6d5b03d5372dbea4/scala-xml_2.12-2.1.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.scala-lang/scala-reflect/2.12.17/c0fcfc7932ee0c92e6d00d1c7c47d5042391a987/scala-reflect-2.12.17.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.json4s/json4s-jackson_2.12/3.7.0-M11/54089dd27d932de33c329199474ad429ee076510/json4s-jackson_2.12-3.7.0-M11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.core/jackson-databind/2.15.4/560309fc381f77d4d15c4a4cdaa0db5025c4fd13/jackson-databind-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.module/jackson-module-scala_2.12/2.15.4/bc557d1dfc72190abf646b486f44c1e6b5c8ad9c/jackson-module-scala_2.12-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.twitter/chill-java/0.10.0/fd2eb52afd9ab4337c9e51823f41ad8916e6976/chill-java-0.10.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.xbean/xbean-asm9-shaded/4.22/58a5eae5fced0ee652754045f740bbca4f0d922a/xbean-asm9-shaded-4.22.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-client-api/3.3.4/6339a8f7279310c8b1f7ef314b592d8c71ca72ef/hadoop-client-api-3.3.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.activation/activation/1.1.1/485de3a253e23f645037828c07f1d7f1af40763a/activation-1.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.zookeeper/zookeeper/3.6.3/a6e74f826db85ff8c51c15ef0fa2ea0b462aef25/zookeeper-3.6.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.servlet/jakarta.servlet-api/4.0.3/7c810f7bca93d109bac3323286b8e5ec6c394e12/jakarta.servlet-api-4.0.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-compress/1.22/691a8b4e6cf4248c3bc72c8b719337d5cb7359fa/commons-compress-1.22.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-math3/3.6.1/e4ba98f1d4b3c80ec46392f25e094a6a2e58fcbf/commons-math3-3.6.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-io/commons-io/2.11.0/a2503f302b11ebde7ebc3df41daebe0e4eea3689/commons-io-2.11.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-collections/commons-collections/3.2.2/8ad72fe39fa8c91eaaf12aadb21e0c3661fe26d5/commons-collections-3.2.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-collections4/4.4/62ebe7544cb7164d87e0637a2a6a2bdc981395e8/commons-collections4-4.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.21.1/eba8eac8d464791c84e4bafa0fea7cdf7113168/log4j-core-2.21.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-1.2-api/2.21.1/e01395d68fb94faa1fbf8188072549e75d309b9e/log4j-1.2-api-2.21.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.21.1/74c65e87b9ce1694a01524e192d7be989ba70486/log4j-api-2.21.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.ning/compress-lzf/1.1.2/d09d33ffa7bc1d987db92e5ebec926ff92b7cbdf/compress-lzf-1.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.xerial.snappy/snappy-java/1.1.10.3/4548ee2aac847998146e8d4a3176f7bcc766a00/snappy-java-1.1.10.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.lz4/lz4-java/1.8.0/4b986a99445e49ea5fbf5d149c4b63f6ed6c6780/lz4-java-1.8.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.github.luben/zstd-jni/1.5.2-5/ef34c3a855e144c03de5c0b0a8e80469915ebae6/zstd-jni-1.5.2-5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.roaringbitmap/RoaringBitmap/0.9.38/db0ebf650c71469890e894100b008d091dfc178e/RoaringBitmap-0.9.38.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jersey.containers/jersey-container-servlet/2.36/fa6b0f7d47d5c3e054c71eea613a6bbe62b1b733/jersey-container-servlet-2.36.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jersey.containers/jersey-container-servlet-core/2.36/d3bd5067597fa7252e603502ee4ae34563852eb5/jersey-container-servlet-core-2.36.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jersey.core/jersey-server/2.36/73cf67d0d761b60860b7721529503a121cfa9df4/jersey-server-2.36.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jersey.core/jersey-client/2.36/755709fb31407d36c114afbe345b47cebf0fe60/jersey-client-2.36.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jersey.inject/jersey-hk2/2.36/69a57963b35428a261ac4313cfa89f6b3dc255c6/jersey-hk2-2.36.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jersey.core/jersey-common/2.36/5d259ea71ca3c1f4566ec5bfee7320e63d79673b/jersey-common-2.36.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-all/4.1.101.Final/2761d380bc97e6ce64745dd9ca04538cedd40a5b/netty-all-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-epoll/4.1.101.Final/1406f92112cdc4644d21c7b52c8c48e1cc5fb911/netty-transport-native-epoll-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-epoll/4.1.101.Final/316a70d8a9c48bb1f1ff44c7c1d5e4c0c604a71c/netty-transport-native-epoll-4.1.101.Final-linux-aarch_64.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-epoll/4.1.101.Final/760f4aa3b9576f446d39b3886f4862d67428a1be/netty-transport-native-epoll-4.1.101.Final-linux-x86_64.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-kqueue/4.1.87.Final/fd571f6f7b8e70d0d9051bf1ff6b38a7d44c891a/netty-transport-native-kqueue-4.1.87.Final-osx-aarch_64.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-kqueue/4.1.87.Final/28db44b32b4c68f14858e9d691646a7262b57863/netty-transport-native-kqueue-4.1.87.Final-osx-x86_64.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.ivy/ivy/2.5.1/7fac35f24f89776e7b78ec98658d8bc8f22f7e89/ivy-2.5.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/oro/oro/2.0.8/5592374f834645c4ae250f4c9fbb314c9369d698/oro-2.0.8.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.razorvine/pickle/1.3/43eab5f4a8d0a06a38a6c349dec32bd08454c176/pickle-1.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.sf.py4j/py4j/0.10.9.7/e444374109f6f3ffdfdbd4e7dc5a89122b0c9134/py4j-0.10.9.7.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-crypto/1.1.0/4a8b4caa84032a0f1f1dad16875820a4f37524b7/commons-crypto-1.1.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-common/3.3.6/9ca864bec94779e74b99e84ea02dba85a641233/hadoop-common-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-mapreduce-client-jobclient/3.3.6/1a64cee1e0e53d638f5b8bc4899f4c75c00598b8/hadoop-mapreduce-client-jobclient-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-mapreduce-client-core/3.3.6/b75e5e9feb70f599a6f6232e71bd5b0030608179/hadoop-mapreduce-client-core-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-yarn-client/3.3.6/c535b0ebc03721e4eea8ed80b161f06a1ecca873/hadoop-yarn-client-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-hdfs-client/3.3.6/d635e3eed4beb74213489ff003ca39dbe47ea44e/hadoop-hdfs-client-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-yarn-api/3.3.6/e3dc7c2359c888146510c853274e1f309b2fc982/hadoop-yarn-api-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-annotations/3.3.6/451bc97f7519017cfa96c8f11d79e1e8027968b2/hadoop-annotations-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-context/6.1.6/2be30298638975efaf7fff22f1570d79b2679814/spring-context-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-core/6.1.6/dea4b8e110b7b54a02a4907e32dbb0adee8a7168/spring-core-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/software.amazon.awssdk/annotations/2.17.267/903ef2d49505b78e9c0a3bc1316c0260bd99e8f4/annotations-2.17.267.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.reactivestreams/reactive-streams/1.0.4/3864a1320d97d7b045f729a326e1e077661f31b7/reactive-streams-1.0.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-token-provider-kafka-0-10_2.12/3.4.2/3ec62786ec12937117d89227f8d1c1d011502b10/spark-token-provider-kafka-0-10_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka-clients/3.6.2/2bbee78783a8403c012693cfac7fdfc52422a94d/kafka-clients-3.6.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-pool2/2.11.1/8970fd110c965f285ed4c6e40be7630c62db6f68/commons-pool2-2.11.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.minidev/json-smart/2.3/7396407491352ce4fa30de92efb158adb76b5b/json-smart-2.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.guava/failureaccess/1.0.1/1dcf1de382a0bf95a3d8b0849546c88bac1292c9/failureaccess-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.guava/listenablefuture/9999.0-empty-to-avoid-conflict-with-guava/b421526c5f297295adef1c886e5246c39d4ac629/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.checkerframework/checker-qual/2.11.1/8c43bf8f99b841d23aadda6044329dad9b63c185/checker-qual-2.11.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.errorprone/error_prone_annotations/2.3.4/dac170e4594de319655ffb62f41cbd6dbb5e601e/error_prone_annotations-2.3.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.j2objc/j2objc-annotations/1.3/ba035118bc8bac37d7eff77700720999acd9986d/j2objc-annotations-1.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.leangen.geantyref/geantyref/1.3.15/1c9a807a35a02c57dae5e6fa13197e6c735bd721/geantyref-1.3.15.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.cloud/spring-cloud-starter-vault-config/4.1.1/a745f7140e1139ed5c2794aa763f903e82af3e76/spring-cloud-starter-vault-config-4.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jdbi/jdbi3-jackson2/3.44.0/f6ca007e0217735406b1826157a142e6d4aa3665/jdbi3-jackson2-3.44.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.kafka/spring-kafka/3.1.4/34002e4f8c3481682e0302badc5a98f91c5ed7e4/spring-kafka-3.1.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.redisson/redisson/3.13.4/daf19978c93fa4d0d6cb293e7927988777a1f49d/redisson-3.13.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.ecwid.consul/consul-api/1.4.2/32d034933beaee24b539d082fb37d3c456e75cc7/consul-api-1.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-configuration-processor/3.2.5/748cf1d49e04e20db1784e88f676657cd030d937/spring-boot-configuration-processor-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.json/json/20231013/e22e0c040fe16f04ffdb85d851d77b07fc05ea52/json-20231013.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/redis.clients/jedis/5.0.2/47d917ce322cef3fc1fbe7534f351e25d977e52b/jedis-5.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.lettuce/lettuce-core/6.3.2.RELEASE/29b2aac09256c5fc2e9e9ad1df41c65dad5e557a/lettuce-core-6.3.2.RELEASE.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka_2.12/3.1.2/6b58a51de95e924231c90d3e387148a053567c9d/kafka_2.12-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.mikesamuel/json-sanitizer/1.1/7368e73cfade6cb1ca5739239802907d17733e06/json-sanitizer-1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.amazonaws/aws-java-sdk-s3/1.12.332/6b4d356df13956a1afbaa5e2233c2af10f4298b4/aws-java-sdk-s3-1.12.332.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.annotation/javax.annotation-api/1.3.2/934c04d3cfef185a8008e7bf34331b79730a9d43/javax.annotation-api-1.3.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.hibernate.orm/hibernate-core/6.4.4.Final/5c9decb3c5a70bf7801d41fc32633416c26be069/hibernate-core-6.4.4.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.hibernate.orm/hibernate-hikaricp/6.4.3.Final/a7bd1fdd8ead898533d625a8c385f53c82aabbd6/hibernate-hikaricp-6.4.3.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.trino/trino-jdbc/438/da797c348d402e39c0729590704ee60488bbf397/trino-jdbc-438.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.alluxio/alluxio-shaded-client/2.9.3/b00f260fbfbdb8990211fa7fdd894da40a9ae11/alluxio-shaded-client-2.9.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.persistence/jakarta.persistence-api/3.1.0/66901fa1c373c6aff65c13791cc11da72060a8d6/jakarta.persistence-api-3.1.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_hotspot/0.15.0/7f1f8f281756a89f743d87eab45c5665eaabf59d/simpleclient_hotspot-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_httpserver/0.15.0/2d75a63bc5924b4bea682b8e11cdafb78e5d9935/simpleclient_httpserver-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_pushgateway/0.15.0/120537d6ac5d977f14a467c0506dcc6a8c8adb0d/simpleclient_pushgateway-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient/0.15.0/144aaf1ac9361a497d98079e0db8757a95e22fc4/simpleclient-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-json/3.2.5/6df311af4c242eb95c3526f48ab4f31c384a247e/spring-boot-starter-json-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-webmvc/6.1.6/ef1f76db6d94bac428839cb91fa59235c8356e56/spring-webmvc-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-web/6.1.6/49a32e3497fe39550da3b280bda5d9933ae2d51d/spring-web-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-tomcat/3.2.5/a40ebfa6becb35b419b37e49e33b2822e22cf42a/spring-boot-starter-tomcat-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-starter-aop/3.2.5/1c6c5d81e6c7f8b3e255c9e384153e9f52a93d1b/spring-boot-starter-aop-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.data/spring-data-jpa/3.2.5/f5c674caedc0132c7865b9a2edaa04b8f5351262/spring-data-jpa-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-aspects/6.1.6/409aba797564c23c08e2307f2df728aed117e914/spring-aspects-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-jdbc/6.1.6/3f8a440a49c15264ff438598b715bd00c5a88109/spring-jdbc-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-actuator-autoconfigure/3.2.5/aa58ac33da22febe8ea6d179eb0bf3f76ed2850d/spring-boot-actuator-autoconfigure-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.micrometer/micrometer-jakarta9/1.12.5/8fe03be9a51974cdb700b04c8df5378f8566c179/micrometer-jakarta9-1.12.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.micrometer/micrometer-observation/1.12.5/ee23704259a1aad5c8f503db4d37cdfe5352e766/micrometer-observation-1.12.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.data/spring-data-redis/3.2.5/686c8fb1ec322e5aed5dfdb2f49a3ada6eb9f961/spring-data-redis-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.integration/spring-integration-core/6.2.4/6068b2589047bde910c8e9ef6b71691ecbf49594/spring-integration-core-6.2.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.annotation/jakarta.annotation-api/2.1.1/48b9bda22b091b1f48b13af03fe36db3be6e1ae3/jakarta.annotation-api-2.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.yaml/snakeyaml/2.2/3af797a25458550a16bf89acc8e4ab2b7f2bfce0/snakeyaml-2.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-catalyst_2.12/3.4.2/36928f79e1f9f10c3418778107f1e3b1e913e4da/spark-catalyst_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.orc/orc-core/1.8.6/e255a4e0918c99adc7c4c843e8cb1fa795258ca0/orc-core-1.8.6-shaded-protobuf.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.orc/orc-mapreduce/1.8.6/e2dbe4cbd91559c7ed854dd0fd6e5a41c7b49c37/orc-mapreduce-1.8.6-shaded-protobuf.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive/hive-storage-api/2.8.1/4b151bcdfe290542f27a442ed09be99f815f88e8/hive-storage-api-2.8.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.parquet/parquet-hadoop/1.12.3/57001fa0b6622767e63c1b9cd2e6db666d180caa/parquet-hadoop-1.12.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.parquet/parquet-column/1.12.3/5506a7066998a2be47b86e28d061863a475a7ca8/parquet-column-1.12.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.spark/spark-sketch_2.12/3.4.2/d6889ad249c1e7cc72d3774fddb400fb447ea5d5/spark-sketch_2.12-3.4.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.rocksdb/rocksdbjni/7.9.2/6409b667493149191b09fe1fce94bada6096a3e9/rocksdbjni-7.9.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.univocity/univocity-parsers/2.9.1/81827d186e42129f23c3f1e002b757ad4b4e769/univocity-parsers-2.9.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.protobuf/protobuf-java/3.21.12/5589e79a33cb6509f7e681d7cf4fc59d47c51c71/protobuf-java-3.21.12.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-cli/commons-cli/1.2/2bf96b7aa8b611c177d329452af1dc933e14501c/commons-cli-1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-lang/commons-lang/2.6/ce1edb914c94ebc388f086c6827e8bdeec71ac2/commons-lang-2.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.antlr/antlr-runtime/3.5.2/cd9cd41361c155f3af0f653009dcecb08d8b4afd/antlr-runtime-3.5.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javolution/javolution/5.5.1/3fcba819cdb7861728405963ddc4b2755ab182e5/javolution-5.5.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.jolbox/bonecp/0.8.0.RELEASE/cec24ee9345b3678472bb1b8fdd6aa6b9428beb8/bonecp-0.8.0.RELEASE.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.datanucleus/datanucleus-api-jdo/4.2.4/7e2c71f7eb9b40b660d009c3ea1b55fb71694bca/datanucleus-api-jdo-4.2.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.datanucleus/datanucleus-rdbms/4.1.19/923fa411f49cca5dbb6221140b1ae89c90b3a3fd/datanucleus-rdbms-4.1.19.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-dbcp/commons-dbcp/1.4/30be73c965cc990b153a100aaaaafcf239f82d39/commons-dbcp-1.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-pool/commons-pool/1.5.4/75b6e20c596ed2945a259cea26d7fadd298398e6/commons-pool-1.5.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.jdo/jdo-api/3.0.1/58e7a538e020b73871e232eeb064835fd98a492/jdo-api-3.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.datanucleus/javax.jdo/3.2.0-m3/c911b22710a8f77541a966615033b4ab943fd6f3/javax.jdo-3.2.0-m3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.github.joshelser/dropwizard-metrics-hadoop-metrics2-reporter/0.1.2/ff3520ab6e48718e2d79e47f6cf2bd7b50180b84/dropwizard-metrics-hadoop-metrics2-reporter-0.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jline/jline/2.12/ce9062c6a125e0f9ad766032573c041ae8ecc986/jline-2.12.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.tdunning/json/1.8/fa57d5adf557b226738cd42e6c093dd0a76c5fd4/json-1.8.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-httpclient/commons-httpclient/3.0.1/d6364bcc1b2b2aa69d008602d36a700453648560/commons-httpclient-3.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.antlr/ST4/4.0.4/467a2aa12be6d0f0f68c70eecf6714ab733027ac/ST4-4.0.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/stax/stax-api/1.0.1/49c100caf72d658aca8e58bd74a4ba90fa2b0d70/stax-api-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.avro/avro-ipc/1.11.1/40d653933f829e5193b24864d82b306b5a31e7c0/avro-ipc-1.11.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.core/jackson-core/2.15.3/60d600567c1862840397bf9ff5a92398edc5797b/jackson-core-2.15.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.sf.opencsv/opencsv/2.3/c23708cdb9e80a144db433e23344a788a1fd6599/opencsv-2.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive.shims/hive-shims-common/2.3.9/74624533c53d1163d9d6954ba5c97c845b99dd11/hive-shims-common-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.httpcomponents/httpcore/4.4.16/51cf043c87253c9f58b539c9f7e44c8894223850/httpcore-4.4.16.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-logging/commons-logging/1.2/4bfc12adfe4842bf07b657f0369c4cb522955686/commons-logging-1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.codehaus.jackson/jackson-core-asl/1.9.13/3c304d70f42f832e0a86d45bd437f692129299a4/jackson-core-asl-1.9.13.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.curator/curator-framework/5.2.0/dffcfb521d99b9b7515f7b6041badac62910075e/curator-framework-5.2.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.crypto.tink/tink/1.7.0/668b57f109d32349b2870448f06ae6f202713edc/tink-1.7.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.core/jackson-annotations/2.15.4/5223ea5a9bf52cdc9c5e537a0e52f2432eaf208b/jackson-annotations-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.fusesource.leveldbjni/leveldbjni-all/1.8/707350a2eeb1fa2ed77a32ddb3893ed308e941db/leveldbjni-all-1.8.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.esotericsoftware/kryo-shaded/4.0.2/e8c89779f93091aa9cb895093402b5d15065bf88/kryo-shaded-4.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.json4s/json4s-core_2.12/3.7.0-M11/4126de102c272d727ea0e1875ee3db9f6ac7060f/json4s-core_2.12-3.7.0-M11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.thoughtworks.paranamer/paranamer/2.8/619eba74c19ccf1da8ebec97a2d7f8ba05773dd6/paranamer-2.8.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.zookeeper/zookeeper-jute/3.6.3/8990d19ec3db01f45f82d4011a11b085db66de05/zookeeper-jute-3.6.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.yetus/audience-annotations/0.13.0/8ad1147dcd02196e3924013679c6bf4c25d8c351/audience-annotations-0.13.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-handler/4.1.107.Final/d4c6b05f4d9aca117981297fb7f02953102ebb5e/netty-handler-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.ws.rs/jakarta.ws.rs-api/2.1.6/1dcb770bce80a490dff49729b99c7a60e9ecb122/jakarta.ws.rs-api-2.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.hk2.external/jakarta.inject/2.6.1/8096ebf722902e75fbd4f532a751e514f02e1eb7/jakarta.inject-2.6.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.validation/jakarta.validation-api/2.0.2/5eacc6522521f7eacb081f95cee1e231648461e7/jakarta.validation-api-2.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.hk2/hk2-locator/2.6.1/9dedf9d2022e38ec0743ed44c1ac94ad6149acdd/hk2-locator-2.6.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.javassist/javassist/3.25.0-GA/442dc1f9fd520130bd18da938622f4f9b2e5fba3/javassist-3.25.0-GA.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.hk2/osgi-resource-locator/1.0.3/de3b21279df7e755e38275137539be5e2c80dd58/osgi-resource-locator-1.0.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-classes-epoll/4.1.101.Final/f86303830ab65680e45cabb531e37078ecc6791e/netty-transport-classes-epoll-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-classes-kqueue/4.1.101.Final/a151e9831013efc0fd1375d21bd4075117cfb31/netty-transport-classes-kqueue-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-unix-common/4.1.107.Final/4d61d4959741109b3eccd7337f11fc89fa90a74a/netty-transport-native-unix-common-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-codec/4.1.107.Final/a1d32debf2ed07c5852ab5b2904c43adb76c39e/netty-codec-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport/4.1.107.Final/d6a105c621b47d1410e0e09419d7209d2d46e914/netty-transport-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-buffer/4.1.107.Final/8509a72b8a5a2d33d611e99254aed39765c3ad82/netty-buffer-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-codec-http/4.1.101.Final/c648f863b301e3fc62d0de098ec61be7628b8ea2/netty-codec-http-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-codec-http2/4.1.101.Final/40590da6c615b852384542051330e9fd51d4c4b1/netty-codec-http2-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-codec-socks/4.1.101.Final/cbaac9e2c2d7b86e4c1bda220cde49949c9bcaee/netty-codec-socks-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-resolver/4.1.107.Final/dfee84308341a42131dd0f8ac0e1e02d627c19f3/netty-resolver-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-common/4.1.107.Final/4f17a547530d64becd7179507b25f4154bcfba57/netty-common-4.1.107.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-handler-proxy/4.1.101.Final/c198ee61abba7ae6b3cb6b1033f04fb0ae79d512/netty-handler-proxy-4.1.101.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.commons/commons-configuration2/2.8.0/6a76acbe14d2c01d4758a57171f3f6a150dbd462/commons-configuration2-2.8.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-auth/3.3.6/66aaf67a580910de62f92f21f76e3df170483cf/hadoop-auth-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.curator/curator-client/5.2.0/221dde476d45c328da9a08e0671edc4ee654ccb4/curator-client-5.2.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-core/1.0.1/82357e97a5c1b505beb0f6c227d9f39b2d7fdde0/kerb-core-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-beanutils/commons-beanutils/1.9.4/d52b9abcd97f38c81342bb7e7ae1eee9b73cba51/commons-beanutils-1.9.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop.thirdparty/hadoop-shaded-protobuf_3_7/1.1.1/57b7ba0ca94313c342b03bd31830fe4a8f34bc1a/hadoop-shaded-protobuf_3_7-1.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop.thirdparty/hadoop-shaded-guava/1.1.1/2419d851c01139edf9e19b81056382163d9bfab/hadoop-shaded-guava-1.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-net/commons-net/3.9.0/5a4e26802e0a5a42938f987976b55dae4a6cc636/commons-net-3.9.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-webapp/9.4.51.v20230217/d1ac2cfce10cb5ca9a65dee26511cedfa3859614/jetty-webapp-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-servlet/9.4.51.v20230217/3ec1be0b1ca49b633dd7de0733d0054bb4763965/jetty-servlet-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.jersey/jersey-servlet/1.19.4/fbdcb39db6a6976944a621fe11bf1d2ff048d7c2/jersey-servlet-1.19.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/ch.qos.reload4j/reload4j/1.2.22/f9d9e55d1072d7a697d2bf06e1847e93635a7cf9/reload4j-1.2.22.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.re2j/re2j/1.1/d716952ab58aa4369ea15126505a36544d50a333/re2j-1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.woodstox/woodstox-core/6.4.0/c47579857bbf12c85499f431d4ecf27d77976b7c/woodstox-core-6.4.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.codehaus.woodstox/stax2-api/4.2.1/a3f7325c52240418c2ba257b103c3c550e140c83/stax2-api-4.2.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/dnsjava/dnsjava/2.1.7/a1ed0a251d22bf528cebfafb94c55e6f3f339cf/dnsjava-2.1.7.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-mapreduce-client-common/3.3.6/f329b54cc270f976714b50c8a6ca76941269fbb9/hadoop-mapreduce-client-common-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hadoop/hadoop-yarn-common/3.3.6/3aeb5017bcb0f98b2f4556a07bbcac11935fdca0/hadoop-yarn-common-3.3.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty.websocket/websocket-client/9.4.51.v20230217/76058b58d0cde721a41a09a39c121db1c4f61ce0/websocket-client-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jline/jline/3.9.0/da6eb8ebdd131ec41f7e42e7e77b257868279698/jline-3.9.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.squareup.okhttp3/okhttp/4.9.3/b0b14b3d12980912723fb8b66afb48dcda742fcb/okhttp-4.9.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib/1.4.10/ea29e063d2bbe695be13e9d044dcfb0c7add398e/kotlin-stdlib-1.4.10.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-common/1.4.10/6229be3465805c99db1142ad75e6c6ddeac0b04c/kotlin-stdlib-common-1.4.10.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.xml.bind/jaxb-api/2.2.11/32274d4244967ff43e7a5d967743d94ed3d2aea7/jaxb-api-2.2.11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-aop/6.1.6/4958f52cb9fcb3adf7e836304550de5431a9347e/spring-aop-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-beans/6.1.6/332d80ff134420db4ebf7614758e6a02a9bd3c41/spring-beans-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-expression/6.1.6/9c3d7f0e17a919a4ea9f087e4e2140ad39776bc8/spring-expression-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-jcl/6.1.6/84cb19b30b22feca73c2ac005ca849c5890935a3/spring-jcl-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.minidev/accessors-smart/1.2/c592b500269bfde36096641b01238a8350f8aa31/accessors-smart-1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.cloud/spring-cloud-vault-config/4.1.1/8979adc16baeab791af3771bbec40e18711394fd/spring-cloud-vault-config-4.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.cloud/spring-cloud-starter/4.1.2/757a6f0ecdb191fb04c0aed2055e91f50f89231d/spring-cloud-starter-4.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.vault/spring-vault-core/3.1.1/242e31d8b38595de0ba3c9ee38f8280913a8d110/spring-vault-core-3.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.httpcomponents.client5/httpclient5/5.2.3/5d753a99d299756998a08c488f2efdf9cf26198e/httpclient5-5.2.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.httpcomponents.core5/httpcore5/5.2.4/34d8332b975f9e9a8298efe4c883ec43d45b7059/httpcore5-5.2.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jdbi/jdbi3-json/3.44.0/f48080d9021519bd823d517b39c13fd9961e4996/jdbi3-json-3.44.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-messaging/6.1.6/4d45af04b25818f9f91804c9e4845a0380a271d5/spring-messaging-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-tx/6.1.6/4e18554fb6669f266108cc838a4619bbc8f7db8d/spring-tx-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.retry/spring-retry/2.0.5/6aa0cd18f611ee83dc1d8e5052485e9669088253/spring-retry-2.0.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.reactivex.rxjava2/rxjava/2.2.19/1a79a902bbfcde95ad6f34eb6d1860e6b37f0da9/rxjava-2.2.19.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.projectreactor/reactor-core/3.6.5/2004aaddac35e8b52daca6a8b4d0db7c6f8fca10/reactor-core-3.6.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.dataformat/jackson-dataformat-yaml/2.15.4/4a5dcae45b67fe5edbec821711555d30347f69a0/jackson-dataformat-yaml-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-resolver-dns/4.1.51.Final/7b5273d72a198d4ce6718dd84ae67ef50943fc09/netty-resolver-dns-4.1.51.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.cache/cache-api/1.0.0/2b57384801243f387f1a2e7ab8066ac79c2a91d3/cache-api-1.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jboss.marshalling/jboss-marshalling-river/2.0.9.Final/40029f32d0bbc5dab5e8fe832120e785f01f6b99/jboss-marshalling-river-2.0.9.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.bytebuddy/byte-buddy/1.10.14/5288bd154aa7bc8ea81a658f60a790f646025832/byte-buddy-1.10.14.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.amazonaws/aws-java-sdk-kms/1.12.332/54a90f04e514f0aba52626bbfa625ad2e69606cf/aws-java-sdk-kms-1.12.332.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.amazonaws/aws-java-sdk-core/1.12.332/bf3778829d12202e97607a4eef2dda99597af904/aws-java-sdk-core-1.12.332.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.amazonaws/jmespath-java/1.12.332/e8c3b940b87fb2685bfa3e7657e99fa5f3f0273f/jmespath-java-1.12.332.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.transaction/jakarta.transaction-api/2.0.1/51a520e3fae406abb84e2e1148e6746ce3f80a1a/jakarta.transaction-api-2.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_common/0.15.0/57bd1d8be9f4d965a38c6b1b35ee60358cc679fc/simpleclient_common-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_tracer_otel/0.15.0/53770a575d13d5aeebc7e2ebd7cc714496d7ab28/simpleclient_tracer_otel-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_tracer_otel_agent/0.15.0/9c2f1a317960110581857911ca5fd7379ba77e28/simpleclient_tracer_otel_agent-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.datatype/jackson-datatype-jdk8/2.15.4/694777f182334a21bf1aeab1b04cc4398c801f3f/jackson-datatype-jdk8-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.datatype/jackson-datatype-jsr310/2.15.4/7de629770a4559db57128d35ccae7d2fddd35db3/jackson-datatype-jsr310-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.module/jackson-module-parameter-names/2.15.4/e654497a08359db2521b69b5f710e00836915d8c/jackson-module-parameter-names-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.tomcat.embed/tomcat-embed-websocket/10.1.20/21502adffaf9e6e4bc2b63a557e348d7f6c0faf7/tomcat-embed-websocket-10.1.20.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.tomcat.embed/tomcat-embed-core/10.1.20/ba0dc784e12086f83d8e1d5a10443b166abf5780/tomcat-embed-core-10.1.20.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.tomcat.embed/tomcat-embed-el/10.1.20/cc1a42b8228699e92c8eba0187eccf54bf892802/tomcat-embed-el-10.1.20.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.aspectj/aspectjweaver/1.9.22/10736ab74a53af5e2e1b07e76335a5391526b6f8/aspectjweaver-1.9.22.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-orm/6.1.6/c8687b15d3ae95769cef73626e62ffc7fff7e0bf/spring-orm-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.data/spring-data-commons/3.2.5/d4bb5a08fad512b345ae4077bdf0f50c95eed07/spring-data-commons-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.antlr/antlr4-runtime/4.9.3/81befc16ebedb8b8aea3e4c0835dd5ca7e8523a8/antlr4-runtime-4.9.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.boot/spring-boot-actuator/3.2.5/f0623b4ce7c614a452cddc9b369d69ff6e7f9173/spring-boot-actuator-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.micrometer/micrometer-core/1.12.5/ee49ea9ec34c3d4aa1417a46ce8017f15513b5af/micrometer-core-1.12.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.micrometer/micrometer-commons/1.12.5/da45afd81a6a05267df5ddfe10438ea857e0f7d9/micrometer-commons-1.12.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.data/spring-data-keyvalue/3.2.5/dd9edad22714829bf5d027cacc377d51942e489a/spring-data-keyvalue-3.2.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-context-support/6.1.6/7cc404d7f0c6e1b1ecfa30080fe194b52867d6b2/spring-context-support-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework/spring-oxm/6.1.6/1af328c07b70c5360e73fb206fd0ae81401e00a5/spring-oxm-6.1.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.arrow/arrow-vector/11.0.0/86cfffdf0e7185058cb1302aa0db4565300caa46/arrow-vector-11.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.arrow/arrow-memory-netty/11.0.0/4e427a070f21efaffe6009faf6d97b260dbec36b/arrow-memory-netty-11.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.scala-lang.modules/scala-parser-combinators_2.12/2.1.1/c35c234a906ac014cc4889e7377418752a6f5b49/scala-parser-combinators_2.12-2.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.orc/orc-shims/1.8.6/ab5a009c952973f98e581d042c74e13cfe9293e8/orc-shims-1.8.6.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.airlift/aircompressor/0.21/d1efd839d539481952a9757834054239774f057/aircompressor-0.21.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jetbrains/annotations/17.0.0/8ceead41f4e71821919dbdb7a9847608f1a938cb/annotations-17.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.threeten/threeten-extra/1.7.1/caddbd1f234f87b0d65e421b5d5032b6a473f67b/threeten-extra-1.7.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.parquet/parquet-common/1.12.3/da50b1b4177cbadb977d52aa70011713f37a2156/parquet-common-1.12.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.parquet/parquet-format-structures/1.12.3/9074f509fbc3df3ad104eca5427d03eece453246/parquet-format-structures-1.12.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.parquet/parquet-encoding/1.12.3/ce981aa4a840f84b670bbb3dfd77cd3be87ca84/parquet-encoding-1.12.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.transaction/jta/1.1/2ca09f0b36ca7d71b762e14ea2ff09d5eac57558/jta-1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.transaction/transaction-api/1.1/2ca09f0b36ca7d71b762e14ea2ff09d5eac57558/transaction-api-1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/junit/junit/3.8.1/99129f16442844f6a4a11ae22fbbee40b14d774f/junit-3.8.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.tukaani/xz/1.9/1ea4bec1a921180164852c65006d928617bd2caf/xz-1.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.esotericsoftware/minlog/1.3.0/ff07b5f1b01d2f92bb00a337f9a94873712f0827/minlog-1.3.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.objenesis/objenesis/2.5.1/272bab9a4e5994757044d1fc43ce480c8cb907a4/objenesis-2.5.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.json4s/json4s-ast_2.12/3.7.0-M11/f8c92b6b7cb37f3e2fdf649ad1ba3d65248bb45d/json4s-ast_2.12-3.7.0-M11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.json4s/json4s-scalap_2.12/3.7.0-M11/5a5aafd028f7ac4a8565e1cebe1307c146c87f70/json4s-scalap_2.12-3.7.0-M11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.hk2/hk2-api/2.6.1/114bd7afb4a1bd9993527f52a08a252b5d2acac5/hk2-api-2.6.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.hk2/hk2-utils/2.6.1/396513aa96c1d5a10aa4f75c4dcbf259a698d62d/hk2-utils-2.6.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.hk2.external/aopalliance-repackaged/2.6.1/b2eb0a83bcbb44cc5d25f8b18f23be116313a638/aopalliance-repackaged-2.6.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-simplekdc/1.0.1/1e39adf7c3f5e87695789994b694d24c1dda5752/kerb-simplekdc-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.nimbusds/nimbus-jose-jwt/9.16/fb81111c2d7a8cc6c85cd26dee2f1aa140ed28fe/nimbus-jose-jwt-9.16.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerby-pkix/1.0.1/4c1fd1f78ba7c16cf6fcd663ddad7eed34b4d911/kerby-pkix-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-xml/9.4.51.v20230217/54572d542f3a9e943ebf50f34df5ef1420b0b045/jetty-xml-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-security/9.4.51.v20230217/a3342214ce480cc5bb8e74fe7589dd0436a5d903/jetty-security-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-util-ajax/9.4.51.v20230217/3b2a998a5ed1f93bc1878fa89d65e307d8b8ebaf/jetty-util-ajax-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.inject/guice/4.0/f990a43d3725781b6db7cd0acf0a8b62dfd1649/guice-4.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.jaxrs/jackson-jaxrs-json-provider/2.15.4/403b453d73187e35cff91126c60b4decb0743857/jackson-jaxrs-json-provider-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.module/jackson-module-jaxb-annotations/2.15.4/5f7a34ad7d48d222320b0037c18d700323bcfa8/jackson-module-jaxb-annotations-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.jersey.contribs/jersey-guice/1.19.4/fc5cdccdeeedb067b8b2a3c7df2907dfb7e8a1b9/jersey-guice-1.19.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.github.pjfanning/jersey-json/1.20/3ced16e1d195baf892041e66f9f4e41595b7a3b4/jersey-json-1.20.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-util/9.4.51.v20230217/a11df06530a3a28c9af7ff336730a2f8e18e7205/jetty-util-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.servlet/javax.servlet-api/3.1.0/3cd63d075497751784b2fa84be59432f4905bf7c/javax.servlet-api-3.1.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.jersey/jersey-client/1.19.4/9b1f3cf3fdd02d313018f1a67c42106e6ce9f60d/jersey-client-1.19.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.jersey/jersey-server/1.19.4/44df9a1310c1278b62658509aca3ca53978e8822/jersey-server-1.19.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.jersey/jersey-core/1.19.4/21c5319c82ca29705715b315553a16f11b16655e/jersey-core-1.19.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-client/9.4.51.v20230217/992630431704cf3144fb83fdac8e3c365c811c0a/jetty-client-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty.websocket/websocket-common/9.4.51.v20230217/7808553f0197ed107229cbcf75dd0d940c485db9/websocket-common-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-io/9.4.51.v20230217/a11a0713b17334a5b6e694602fbd1a9457cb5fdd/jetty-io-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.squareup.okio/okio/2.8.0/49b64e09d81c0cc84b267edd0c2fd7df5a64c78c/okio-jvm-2.8.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.ow2.asm/asm/5.0.4/da08b8cce7bbf903602a25a3a163ae252435795/asm-5.0.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.cloud/spring-cloud-context/4.1.2/69d9edfe8c4b4037653d28b29f3184afc573603/spring-cloud-context-4.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.cloud/spring-cloud-commons/4.1.2/84377482af72a3ef008b6c981e77897a04ae20aa/spring-cloud-commons-4.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.security/spring-security-rsa/1.1.2/ca388d615a60199186ec248ac2a9806a76db4014/spring-security-rsa-1.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.httpcomponents.core5/httpcore5-h2/5.2.4/2872764df7b4857549e2880dd32a6f9009166289/httpcore5-h2-5.2.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-codec-dns/4.1.51.Final/127fba3117deced1cb20f8f58b0028f354b9fc25/netty-codec-dns-4.1.51.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jboss.marshalling/jboss-marshalling/2.0.9.Final/54e8ae4d8ab3cdf08c46b01331bffe6ec4d3e880/jboss-marshalling-2.0.9.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.dataformat/jackson-dataformat-cbor/2.15.4/4416d9cc61bde0c0b11d38e66d219090be4a2b70/jackson-dataformat-cbor-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/software.amazon.ion/ion-java/1.0.2/ee9dacea7726e495f8352b81c12c23834ffbc564/ion-java-1.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.prometheus/simpleclient_tracer_common/0.15.0/f1bac57eaf6c04e6b72a08b44a0e6569e87974a4/simpleclient_tracer_common-0.15.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.arrow/arrow-memory-core/11.0.0/e8a11b92d5d79af8bfa8a81a00c97b1c46ce915d/arrow-memory-core-11.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.arrow/arrow-format/11.0.0/370e76ffad508246e98a09a09fcabe96f42014ab/arrow-format-11.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.google.flatbuffers/flatbuffers-java/1.12.0/8201cc7b511177a37071249e891f2f2fea4b32e9/flatbuffers-java-1.12.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-client/1.0.1/a82d2503e718d17628fc9b4db411b001573f61b7/kerb-client-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-admin/1.0.1/7868b29620b92aa1040fe20d21ba09f2506207aa/kerb-admin-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.github.stephenc.jcip/jcip-annotations/1.0-1/ef31541dd28ae2cefdd17c7ebf352d93e9058c63/jcip-annotations-1.0-1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerby-asn1/1.0.1/d54a9712c29c4e6d9d9ba483fad3d450be135fff/kerby-asn1-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerby-util/1.0.1/389b730dc4e454f70d72ec19ddac2528047f157e/kerby-util-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.inject/javax.inject/1/6975da39a7040257bd51d21a231b76c915872d38/javax.inject-1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/aopalliance/aopalliance/1.0/235ba8b489512805ac13a8f9ea77a1ca5ebe3e8/aopalliance-1.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.jaxrs/jackson-jaxrs-base/2.15.4/f8a34d71417baddad799e0a68ffa1901e24febf7/jackson-jaxrs-base-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.xml.bind/jakarta.xml.bind-api/2.3.3/48e3b9cfc10752fba3521d6511f4165bea951801/jakarta.xml.bind-api-2.3.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.activation/jakarta.activation-api/1.2.2/99f53adba383cb1bf7c3862844488574b559621f/jakarta.activation-api-1.2.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.xml.bind/jaxb-impl/2.2.3-1/56baae106392040a45a06d4a41099173425da1e6/jaxb-impl-2.2.3-1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.codehaus.jettison/jettison/1.5.4/174ca56c411b05aec323d8f53e66709c0d28b337/jettison-1.5.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.ws.rs/jsr311-api/1.1.1/59033da2a1afd56af1ac576750a8d0b1830d59e6/jsr311-api-1.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty/jetty-http/9.4.51.v20230217/fe37568aded59dd8e437e0f670fe5f809071fe8f/jetty-http-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.jetty.websocket/websocket-api/9.4.51.v20230217/e2dfd856ee17165d4eef573babaf45a977076b8/websocket-api-9.4.51.v20230217.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.springframework.security/spring-security-crypto/6.2.3/dbe4e299636951e00f18223a1794806d75000e7d/spring-security-crypto-6.2.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.bouncycastle/bcprov-jdk18on/1.77/2cc971b6c20949c1ff98d1a4bc741ee848a09523/bcprov-jdk18on-1.77.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-util/1.0.1/93d37f677addd2450b199e8da8fcac243ceb8a88/kerb-util-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/token-provider/1.0.1/e6feb6b7c06600924e8b6bda3263c870cfb0a447/token-provider-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-common/1.0.1/e358016010b6355630e398db20d83925462fa4cd/kerb-common-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerby-config/1.0.1/a4c3885fa656a92508315aca9b4632197a454b18/kerby-config-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-server/1.0.1/c56ffb4a6541864daf9868895b79c0c33427fd8c/kerb-server-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerby-xdr/1.0.1/7d1b5b69a5ea87fb2f62498710d9d788d17beb2b/kerby-xdr-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-crypto/1.0.1/66eab4bbf91fa01ed4f72ce771db28c59d35a843/kerb-crypto-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kerby/kerb-identity/1.0.1/eb91bc9b9ff26bfcca077cf1a888fb09e8ce72be/kerb-identity-1.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.xerial.snappy/snappy-java/1.1.10.5/ac605269f3598506196e469f1fb0d7ed5c55059e/snappy-java-1.1.10.5.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.github.luben/zstd-jni/1.5.5-1/fda1d6278299af27484e1cc3c79a060e41b7ef7e/zstd-jni-1.5.5-1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-kqueue/4.1.101.Final/b31756f28d3271da99d31c79a5b44a7da69a9b9b/netty-transport-native-kqueue-4.1.101.Final-osx-aarch_64.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.netty/netty-transport-native-kqueue/4.1.101.Final/9e94ca952f422e9330e30cc406ae31a6c547d51b/netty-transport-native-kqueue-4.1.101.Final-osx-x86_64.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.checkerframework/checker-qual/3.42.0/638ec33f363a94d41a4f03c3e7d3dcfba64e402d/checker-qual-3.42.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/commons-cli/commons-cli/1.4/c51c00206bb913cd8612b24abd9fa98ae89719b1/commons-cli-1.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive.shims/hive-shims-0.23/2.3.9/8dbc9520ce98cf661a90c652f817c7b4c168dc17/hive-shims-0.23-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.hive.shims/hive-shims-scheduler/2.3.9/8c7b61a1d3b54bf865d3b525dc51d9c27a3dbd21/hive-shims-scheduler-2.3.9.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.roaringbitmap/shims/0.9.38/45572e816d3a2fdab3435eecb1deb69e35a76778/shims-0.9.38.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.activation/jakarta.activation-api/2.1.1/88c774ab863a21fb2fc4219af95379fafe499a31/jakarta.activation-api-2.1.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/javax.servlet.jsp/jsp-api/2.1/63f943103f250ef1f3a4d5e94d145a0f961f5316/jsp-api-2.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.bytebuddy/byte-buddy/1.14.11/725602eb7c8c56b51b9c21f273f9df5c909d9e7d/byte-buddy-1.14.11.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.jboss.logging/jboss-logging/3.5.0.Final/c19307cc11f28f5e2679347e633a3294d865334d/jboss-logging-3.5.0.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka-metadata/3.1.2/8b39bfc4028147045b2ebe591af957a2a91d683f/kafka-metadata-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka-raft/3.1.2/f3f4412c14522040ca98149ac19c3bca3a69f620/kafka-raft-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka-storage/3.1.2/4288869c80495c2cede53e1049f5957e4c883307/kafka-storage-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka-server-common/3.1.2/17a50f0cdd93ddbd17d9d99fbbe60140993132ed/kafka-server-common-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.bitbucket.b_c/jose4j/0.7.8/34b47db4364d1916c78c3e26e419e8acbff57d80/jose4j-0.7.8.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.yammer.metrics/metrics-core/2.2.0/f82c035cfa786d3cbec362c38c22a5f5b1bc8724/metrics-core-2.2.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.typesafe.scala-logging/scala-logging_2.12/3.9.3/15be85904b6137d9d13b10d1e53cb783ba0a7a66/scala-logging_2.12-3.9.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.scala-lang.modules/scala-collection-compat_2.12/2.4.4/dd5c55c708e3ea17ff553b3933eedc66ff6f8b8/scala-collection-compat_2.12-2.4.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.scala-lang.modules/scala-java8-compat_2.12/1.0.0/79fb184e4ec47a32c5904da23c80a6818b8c43d1/scala-java8-compat_2.12-1.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml.jackson.dataformat/jackson-dataformat-csv/2.15.4/9e063dc60de5dbcd8cea2c523bb22387ff0725ae/jackson-dataformat-csv-2.15.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.sourceforge.argparse4j/argparse4j/0.7.0/6f0621d0c3888de39e0f06d01f37ba53a798e657/argparse4j-0.7.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/net.sf.jopt-simple/jopt-simple/5.0.4/4fdac2fbe92dfad86aa6e9301736f6b4342a3f5c/jopt-simple-5.0.4.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jaxb/jaxb-runtime/4.0.2/e4e4e0c5b0d42054d00dc4023901572a60d368c7/jaxb-runtime-4.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.xml.bind/jakarta.xml.bind-api/4.0.0/bbb399208d288b15ec101fa4fcfc4bd77cedc97a/jakarta.xml.bind-api-4.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.hibernate.common/hibernate-commons-annotations/6.0.6.Final/77a5f94b56d49508e0ee334751db5b78e5ccd50c/hibernate-commons-annotations-6.0.6.Final.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/io.smallrye/jandex/3.1.2/a6c1c89925c7df06242b03dddb353116ceb9584c/jandex-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.fasterxml/classmate/1.5.1/3fe0bed568c62df5e89f4f174c101eab25345b6c/classmate-1.5.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/jakarta.inject/jakarta.inject-api/2.0.1/4c28afe1991a941d7702fe1362c365f0a8641d1e/jakarta.inject-api-2.0.1.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.parquet/parquet-jackson/1.12.3/2c3fe5d2e5941e50947ff59c50d201d3968fac02/parquet-jackson-1.12.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.apache.kafka/kafka-storage-api/3.1.2/c23bc615bfd36be99a7e2edb35fa7e0503e8be9f/kafka-storage-api-3.1.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jaxb/jaxb-core/4.0.2/8c29249f6c10f4ee08967783831580b0f5c5360/jaxb-core-4.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.hdrhistogram/HdrHistogram/2.1.12/6eb7552156e0d517ae80cc2247be1427c8d90452/HdrHistogram-2.1.12.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.latencyutils/LatencyUtils/2.0.3/769c0b82cb2421c8256300e907298a9410a2a3d3/LatencyUtils-2.0.3.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.eclipse.angus/angus-activation/2.0.0/72369f4e2314d38de2dcbb277141ef0226f73151/angus-activation-2.0.0.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/org.glassfish.jaxb/txw2/4.0.2/24e167be69c29ebb7ee0a3b1f9b546f1dfd111fc/txw2-4.0.2.jar",
            "/home/sanket/.gradle/caches/modules-2/files-2.1/com.sun.istack/istack-commons-runtime/4.1.1/9b3769c76235bc283b060da4fae2318c6d53f07e/istack-commons-runtime-4.1.1.jar"

        },
        args = "--spring.config.location=/home/sanket/gitlocal/uptycs/cloud/effective-permissions/config/application.properties",
        --env = "{'CONFIG_HOME':'/home/sanket/gitlocal/config/generated_files/localhost'}",
        -- If using the JDK9+ module system, this needs to be extended
        -- `nvim-jdtls` would automatically populate this property
        --modulePaths = {},
        name = "Launch effective-permissions",
        request = "launch",
        type = "java",
    },
}
