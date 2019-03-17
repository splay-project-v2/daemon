describe("Test Splay RPC", function()
    setup(function()
        function pong()
            return "pong"
        end
        require("splay.base")
    end)
    it("- RPC no server", function()
        -- async()

        local rpc = require"splay.rpc"

        local finish = false
        events.run(function()
            --rpc.server(30001)
            local pong_rep, err = rpc.call({ip="127.0.0.1",port=30001}, {"pong"})	
            assert(pong_rep==nil)
            assert(err=="connection refused")
            finish = true
        end)

        local clock = os.clock
        function sleep(n)  -- seconds
            local t0 = clock()
            while clock() - t0 <= n and finish == false do end
        end

        sleep(2)

        assert.True(finish)
    end)

    it("- With server rpc", function()
      --[[   require("splay.base")
        local rpc = require"splay.rpc"
        local log = require"splay.log"
        function pong()
            return "pong"
        end
        local finish = false
        events.run(function()
            local port=30001
            local rpc_server_thread = rpc.server(port)
            local pong_rep, err = rpc.call({ip="127.0.0.1",port=port}, {"pong"})
            print(pong_rep)
            assert.True(pong_rep == "pong")
            assert.True(err == nil)
            finish = true
        end)
        local clock = os.clock
        function sleep(n)  -- seconds
            local t0 = clock()
            while clock() - t0 <= n and finish == false do end
        end

        sleep(2)

        assert.True(finish) ]]
    end)
end)