describe("Test Splay RPC", function()
    _G.pong = function()
        return "pong"
    end
    setup(function()
        require"splay.base"
        rpc = require"splay.rpc"
        
    end)
    it("- RPC no server", function()
        local finish = false
        events.run(function()
            -- rpc.server(30001)
            local pong_rep, err = rpc.call({ip="127.0.0.1",port=30001}, {"pong"})	
            assert(pong_rep==nil)
            assert(err=="connection refused")
            finish = true
        end)

        assert.True(finish)
    end)

    it("- With server rpc", function()
        require"splay.base"
        local rpc = require"splay.rpc"
        
        local finish = false
        local pong_rep = ""
        local err = nil

        events.run(function()
            local port=30001
            local rpc_server_thread = rpc.server(port)
            pong_rep, err= rpc.call("127.0.0.1", port, "pong" )	
            finish = true
            rpc.stop_server(port)
            events.kill(rpc_server_thread)
        end)

        assert(pong_rep=="pong")
        assert(err==nil)
        assert(finish == true)
    end)
end)