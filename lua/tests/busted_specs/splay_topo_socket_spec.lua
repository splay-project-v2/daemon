describe("Test Splay Topology socket", function()
    it("Topology socket wrapping", function()
        --setup double wrapping, topo and rs
        local log=require"splay.log"
        local l_o=log.new(5,"[test_topo_socket]")

        local socket = require"socket.core"
        l_o:info("Socket type:",socket)

        local in_del =  0.2

        local ts = require"splay.topo_socket"
        assert(ts.init({in_delay=in_del})) --seconds
        socket=ts.wrap(socket)
        l_o:info("Socket type:",socket)

        local rs=require"splay.restricted_socket"
        assert(rs.init({max_sockets=1024}))
        socket = rs.wrap(socket) --to gather stats on network IO and simulate in-controller deploy
        l_o:info("Socket type:",socket)
        
        package.loaded['socket.core'] = socket

        require("splay.base")

        local events=require("splay.events")
        local rpc=require("splay.rpc")

        local final_time = 0

        events.run(function()

            local t_rpc = rpc.server({ip="127.0.0.1",port=10002})
            local rtt, err=rpc.ping({ip="127.0.0.1",port=10002},in_del*4) 
            l_o:info(rtt, err)
            final_time = rtt
            
            events.sleep(in_del * 4)
            rpc.stop_server(10002)
            events.kill(t_rpc)
        end)

        assert.True(final_time >= 2 * in_del)
    end)
end)