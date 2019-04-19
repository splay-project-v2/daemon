describe("Test Splay Topology socket - 2", function()
    it("Topology socket wrapping - 2", function()
        local json = require("json")

        local del_2_to_1 = 0.250
        local del_1_to_2 = 0.100

        local settings = {}
        local nodes = {{ip="127.0.0.1",port=11001}, {ip="127.0.0.1",port=11002}}
        local topo = json.decode('{"2":{"1":[250,5000,["2","1"],[5000]]},"1":{"2":[100,5000,["1","2"],[5000]]}}')
        local my_pos = 1

        local socket = require"socket.core"
        local ts = require"splay.topo_socket"
        assert(ts.init(settings, nodes, topo, my_pos))
        socket=ts.wrap(socket)

        package.loaded['socket.core'] = socket

        require("splay.base")

        local events=require("splay.events")
        local rpc=require("splay.rpc")
        local net = require("splay.net")
        local misc = require("splay.misc")

        local rtt = 0
        local t_end = 0

        function print_server(data, ip, port)
            print(">>>", data, ip, port)
            if data == "hello" then
                u.s:sendto("world", "127.0.0.1", 11002)
            else
                t_end = misc.time()
            end
        end
        u = net.udp_helper(11002, print_server)

        events.run(function()
            local start = misc.time()
            u.s:sendto("hello", "127.0.0.1", 11002)

            events.sleep(del_1_to_2 * 4)

            final_time = t_end - start
            print(final_time)

            events.kill(u.server)
        end)

        assert.True(final_time >= 2 * del_1_to_2)
    end)
end)