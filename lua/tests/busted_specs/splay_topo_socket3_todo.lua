describe("Test Splay Topology socket - 3 - speed bandwidth", function()
    it("Topology socket wrapping - 3", function()
        local json = require("json")

        -- 8 kbits sec = 1KBytes sec
        local bandwidth = 800

        local settings = {}
        local nodes = {{ip="127.0.0.1",port=11001}, {ip="127.0.0.1",port=11002}}
        local topo = json.decode('{"2":{"1":[0,'..bandwidth..',["2","1"],['..bandwidth..']]},"1":{"2":[0,'..bandwidth..',["1","2"],['..bandwidth..']]}}')
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

        function big_str(size)
            t = {}
            for i=1,size do t[#t+1]="o" end
            return table.concat(t,"")
        end

        -- 10 KB to launch
        local size_pack = 10000
        local b_rec = 0
        local rtt = 0
        local t_end = 0

        function print_server(data, ip, port)
            -- print(">>>", data, ip, port)
            if data == "hello" then
                print(">>> hello : send big str in smaller packets "..size_pack/1000)
                start = misc.time()
                for i=1,size_pack/1000 do
                    print("send") 
                    ris,err=u.s:sendto(big_str(1000), "127.0.0.1", 11002)
                end
            else
                local size = string.len(data)
                b_rec = b_rec + size
                print("Size str : "..size..", tot: "..b_rec)
                if b_rec >= size_pack then
                    print("All rec")
                    t_end = misc.time()
                end
            end
        end
        u = net.udp_helper(11002, print_server)

        events.run(function()
            start = misc.time()
            u.s:sendto("hello", "127.0.0.1", 11002)

            events.sleep(10)

            rtt = t_end - start
            print(rtt)

            events.kill(u.server)
        end)

        assert.True(rtt >= 1)
    end)
end)