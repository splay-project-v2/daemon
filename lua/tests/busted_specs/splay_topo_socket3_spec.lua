describe("Test Splay Topology socket - 2", function()
    it("Topology socket wrapping - 2", function()
        local json = require("json")

        local del_2_to_1 = 0.250
        local del_1_to_2 = 0.100

        local settings = {}
        local nodes = {{ip="127.0.0.1",port=11001}, {ip="127.0.0.1",port=11002}}
        local topo = json.decode('{"2":{"1":[250,5000,["2","1"],[5000]]},"1":{"2":[100,5000,["1","2"],[5000]]}}')
        local my_pos = 1

        local rs=require"splay.restricted_socket"
        assert(rs.init({max_sockets=1024}))
        socket = rs.wrap(socket) --to gather stats on network IO and simulate in-controller deploy

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

        function receive_c(s)
            print("Receive Stand by ")

            data, err = s:receive()
            if data then
                print("RECEIVED : "..data)
            else 
                print("ERROR REC : "..err)
            end
            events.sleep(5)

        end
        
        function send_c(s)
            print("Send Stand by")
            l, err = s:send("I AM "..my_pos.."\n")
            if l then
                print("SEND : "..l)
            else 
                print("ERROR SEND : "..err)
            end
            events.sleep(5)

        end

        function receive_s(s)
            print("S Receive Stand by ")

            data, err = s:receive()
            if data then
                print("S RECEIVED : "..data)
            else 
                print("S ERROR REC : "..err)
            end
            events.sleep(5)
        end
        
        function send_s(s)
            print("S Send Stand by")
            l, err = s:send("I AM S "..my_pos.."\n")
            if l then
                print("S SEND : "..l)
            else 
                print("S ERROR SEND : "..err)
            end
            events.sleep(5)

        end
        
        function init(s, connect)
            local ip, port = s:getpeername()
            if connect then
                s:send(my_pos.."\n")
                local d = s:receive()
    
                s:set_node_peer(tonumber(d))
    
                print("connection to: "..ip..":"..port.." - peer node index = "..s:node_peer())
            else
                local d,err  = s:receive()
                s:send(my_pos.."\n")
                
                s:set_node_peer(tonumber(d))
    
                print("connection from: "..ip..":"..port.." - peer node index = "..s:node_peer())
            end
            -- s:update_node_peer(connect)
        end
        
        function final(s)
            local ip, port = s:getpeername()
            print("Closing: "..ip..":"..port)
        end

        events.run(function()
            -- Accept connection from other nodes
            t_ser = net.server(11001, {initialize = init, send = send_s, receive = receive_s, finalize = final})
            
            -- Launch connection to each orther node
            events.thread(function ()
                print("Try to begin connection to")
                net.client({ip= '127.0.0.1', port= 11001}, {initialize = init, send = send_c, receive = receive_c, finalize = final})
            end)

            events.sleep(1)
            events.kill(t_ser)
        end)
    end)
end)