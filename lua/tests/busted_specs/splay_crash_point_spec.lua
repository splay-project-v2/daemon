describe("Test Crash point interpretation", function()

    setup(function()
        splay_crash = require("splay.crash")
    end)

    -- CRASH POINT id_splayd [id_splayd, [...]] : <Type> : <When> 
    -- <Type> => STOP | RECOVERY x_sleep
    -- <When> => AFTER x_pass | RANDOM chance
    -- STOP status code = 66, RECOVERY status code = 65
   
    it("Simple parsing", function()
        splay_crash = require("splay.crash")
        job = {position = 2}
       
        code = [[
            -- CRASH POINT 1 2 : STOP : AFTER 3
            -- CRASH POINT 2 : STOP : AFTER 3
            -- The next line is not in account because i am the job 2 and only 1 is select
            -- CRASH POINT 1 : RECOVERY 2 : AFTER 3
        ]]
        newCode = splay_crash.parse_code(code, job)
        assert.are.truthy(string.match( newCode, "splay_crash.crash_point%(2%)"))
        assert.are.equal(string.match( newCode, "splay_crash.crash_point%(3%)"), nil)
        assert.are.truthy(string.match( newCode, "-- CRASH POINT 1 : RECOVERY 2 : AFTER 3"))

        code = [[
            --CRASH POINT 1 2:STOP:AFTER   3   
            -- CRASH POINT 2    :RECOVERY  965 :   AFTER 3   
            --  CRASH   POINT   2     :RECOVERY VERY  965 :   AFTER 3   

        ]]
        newCode = splay_crash.parse_code(code, job)
        assert.are.truthy(string.match( newCode, "splay_crash.crash_point%(2%)"))

    end)

    it("Extended parsing", function()
        splay_crash = require("splay.crash")
        job = {position = 1}
       
        code_ok = [[
            -- Crash forever the node 1 and 2 at the 4th passage
            -- in the code
            -- CRASH POINT 1 2 : STOP : AFTER    3

            -- At each time that the code (node 1) pass by this comment,
            -- there is 0.0002 chance to crash the node 1
            --CRASH POINT 1: STOP : RANDOM 0.0002
            
            -- Crash immediately when the comment is encouter in 
            -- the node 1, but this node will recover after 2 sec
            -- CRASH POINT 1: RECOVERY 2 : AFTER 0

            -- Have one chance on two to crash at each pass for 
            -- the node 1, 2, 3, 4, 5. But recover immediately
            -- CRASH POINT 1 2 3 4 5 :RECOVERY 0:RANDOM 0.5
        ]]
        newCode = splay_crash.parse_code(code_ok, job)
        assert.are.truthy(string.match( newCode, "splay_crash.crash_point%(1%)"))
        assert.are.truthy(string.match( newCode, "splay_crash.crash_point%(2%)"))
        assert.are.truthy(string.match( newCode, "splay_crash.crash_point%(3%)"))
        assert.are.truthy(string.match( newCode, "splay_crash.crash_point%(4%)"))

        code_ko = [[
            -- Won't work because Crash point not in uppercase
            --Crash Point 1 2 : STOP : AFTER 3   

            -- Won't work because no node is specified.
            -- CRASH POINT :RECOVERY  965 :   AFTER 3 

            -- Won't work because RECOVER is not a valid
            -- type (but warning expected).
            -- CRASH POINT 1 2 :RECOVER 1 : AFTER 3  
            
            -- Won't work because TIME is not a valid type 
            -- for now (but error expected).
            -- CRASH POINT 1 2 :RECOVERY 1 : TIME 3
        ]]
        newCode = splay_crash.parse_code(code_ko, job)

        assert.are.equal(string.match( newCode, "splay_crash.crash_point%(1%)"), nil)
        assert.are.equal(string.match( newCode, "splay_crash.crash_point%(2%)"), nil)
        assert.are.equal(string.match( newCode, "splay_crash.crash_point%(3%)"), nil)
        assert.are.equal(string.match( newCode, "splay_crash.crash_point%(4%)"), nil)

    end)
    
    it("Test the STOP - AFTER 3  crash point with fork", function()
        splay = require("splay")
        misc = require("splay.misc")

        job = {position = 1, code = code}
        local code = [[
            require("splay.base")
            splay_crash = require"splay.crash"
            events.run(function()
                for i=1, 10 do
                    -- CRASH POINT 1 : STOP : AFTER 3
                    events.sleep(0.10)
                end
                
                print("Not Here")
                events.sleep(1)
            end)
        ]]
        code = splay_crash.parse_code(code, job)
        splay_code_function, err = load(code, "job code")

        time = misc.time()
        pid = splay.fork()

        if (pid < 0) then 
            error("Error Fork (JOBD)")
        elseif (pid  == 0) then
            splay_code_function()
        else
            status = splay.waitpid(pid)
            time_end = misc.time()
            assert.are.equal(status, 66)
            assert.are.True(time_end-time >= 0.3)
            assert.are.True(time_end-time < 0.5)
        end
    end)

    it("Test the STOP - RANDOM 0.5 crash point with fork", function()
        splay = require("splay")
        misc = require("splay.misc")

        job = {position = 1, code = code}
        local code = [[
            require("splay.base")
            splay_crash = require"splay.crash"
            events.run(function()
                for i=1, 10 do
                    events.sleep(0.10)
                    -- CRASH POINT 1 : STOP : RANDOM 0.5   
                end
                
                print("Not Here")
                events.sleep(1)
            end)
        ]]
        code = splay_crash.parse_code(code, job)
        splay_code_function, err = load(code, "job code")

        time = misc.time()
        pid = splay.fork()

        if (pid < 0) then 
            error("Error Fork (JOBD)")
        elseif (pid  == 0) then
            splay_code_function()
        else
            status = splay.waitpid(pid)
            time_end = misc.time()
            assert.are.equal(status, 66)
            -- Very little chance to be bigger
            assert.are.True(time_end-time < 1)
        end
    end)

    it("Test the STOP - AFTER 0 crash point with fork", function()
        splay = require("splay")
        misc = require("splay.misc")

        job = {position = 1, code = code}
        local code = [[
            require("splay.base")
            splay_crash = require("splay.crash")
            events.run(function()
                -- CRASH POINT 1 : STOP : AFTER 0
                print("Not Here")
                events.sleep(1)
            end)
        ]]
        code = splay_crash.parse_code(code, job)
        splay_code_function, err = load(code, "job code")

        time = misc.time()
        pid = splay.fork()

        if (pid < 0) then 
            error("Error Fork (JOBD)")
        elseif (pid  == 0) then
            splay_code_function()
        else
            status = splay.waitpid(pid)
            time_end = misc.time()
            assert.are.equal(status, 66)
            assert.are.True(time_end-time < 0.5)
        end
    end)

    it("Test the RECOVERY - AFTER 3 crash point with fork", function()
        splay = require("splay")
        misc = require("splay.misc")

        job = {position = 1, code = code}
        local code = [[
            require("splay.base")
            splay_crash = require("splay.crash")
            events.run(function()
                events.thread(function()
                    for i=1, 10 do
                        -- CRASH POINT 1 : RECOVERY 0.2 : AFTER 3  
                        events.sleep(0.05)
                    end
                end)
                events.thread(function()
                    events.sleep(0.2)
                    print("Not HERE")
                end)
            end)
        ]]
        code = splay_crash.parse_code(code, job)
        splay_code_function, err = load(code, "job code")

        time = misc.time()
        pid = splay.fork()

        if (pid < 0) then 
            error("Error Fork (JOBD)")
        elseif (pid  == 0) then
            splay_code_function()
        else
            status = splay.waitpid(pid)
            time_end = misc.time()
            assert.are.equal(status, 65)
            -- Recovery 0.2 + 3 * 0.05 sleep
            assert.are.True(time_end-time >= 0.35)
            assert.are.True(time_end-time <= 0.5)
        end
    end)


    it("Parse code, don't modify the code", function()
       
        code = "print('ee')\nprint('ee')\nprint('ee')\n\n"
        newCode = splay_crash.parse_code(code)
        assert.are.equal(code, newCode)

        code = "print('e\ne')\nprint('e\\ne')\nprint('e\ne')"
        newCode = splay_crash.parse_code(code)
        assert.are.equal(code, newCode)

        code = 'require("splay.base")\nprint("Ok")\n\n\nprint("Multpi")'
        newCode = splay_crash.parse_code(code)
        assert.are.equal(code, newCode)

        code = [[        
            print("RAFT.LUA START on "..job.me.ip..":"..job.me.port.." ("..job.position..")")
            
            require("splay.base")
            local math = require("math")
            local net = require("splay.net")
            local misc = require("splay.misc")
            
            -- Index in the list of nodes -> Send to other of nodes.
            job_index = job.position
            
            -- Minimal timeout for each purpose in second
            election_timeout = 1.5
            rpc_timeout = 0.2
            heartbeat_timeout = 0.6
            
            -- Constant msg send and receive between nodes
            vote_msg = {req = "VOTEREQ", rep = "VOTEREP"}
            heartbeat_msg = "HEARTBEAT"
            
            -- State of this node
            state = {
                term = 0,
                voteFor = nil, -- index in the node list
                state = "follower", -- follower, candidat, or leader
                leader = nil, --  {ip = ip, port = port} of the leader
                votes = {}
            }
            
            -- sockets table of each connected node (nil == cot connected to)
            sockets = {}
            
            -- Timeout variable (to check if timeout has been canceled)
            rpc_time = {}
            election_time = nil
            heart_time = nil
            
            -- helper functions
            function set_contains(set, key)
                return set[key] ~= nil
            end
            
            function stepdown(term)
                print("STEPDOWN : "..term.." > "..state.term)
                state.term = tonumber(term)
                state.state = "follower"
                state.voteFor = nil
                set_election_timeout()
            end
            
            -- Timeout functions
            function set_election_timeout()
                election_time = misc.time()
                local time = election_time
                events.thread(function ()
                    events.sleep(((math.random() + 1.0) * election_timeout))
                    -- if the timeout is not cancelled
                    if (time == election_time) then
                        trigger_election_timeout()
                    end
                end)
            end
            
            function set_rpc_timeout(node_index)
                rpc_time[node_index] = misc.time()
                local time = rpc_time[node_index]
                events.thread(function ()
                    events.sleep((math.random() * 0.2) + rpc_timeout)
                    -- if the timeout is not cancelled
                    if (time == rpc_time[node_index] and sockets[node_index] ~= nil) then
                        trigger_rpc_timeout(sockets[node_index])
                    end
                end)
            end
            
            function set_heart_timeout()
                heart_time = misc.time()
                local time = heart_time
                events.thread(function ()
                    events.sleep(heartbeat_timeout)
                    -- if the timeout is not cancelled
                    if (time == heart_time and state.leader == job_index) then
                        trigger_heart_timeout()
                    end
                end)
            end
            
            -- Trigger functions
            function trigger_rpc_timeout(s)
                local ip, port = s:getpeername()
                if (state.state == "candidate") then
                    print("Send new rpc timeout for "..ip..":"..port.." - index "..s.job_index)
                    set_rpc_timeout(s.job_index)
                    s:send(vote_msg.req.." "..state.term.."\n")
                end
            end
            
            function trigger_election_timeout()
                if (state.state == "follower" or state.state == "candidate") then 
                    set_election_timeout()
                    state.term = state.term + 1
                    state.state = "candidate"
                    state.voteFor = job_index
                    state.votes = {}
                    state.votes[job_index] = true
                    for k, s in pairs(sockets) do
                        rpc_time[s.job_index] = nil
                        trigger_rpc_timeout(s)
                    end
                end
            end
            
            function trigger_heart_timeout()
                state.term = state.term + 1
                for k, s in pairs(sockets) do
                    if s ~= nil then
                        s:send(heartbeat_msg.." "..state.term.."\n")
                    end
                end
                set_heart_timeout()
            end
            
            -- Socket fonctions
            function send(s)
                set_rpc_timeout(s)
                while events.yield() do
                    events.sleep(3)
                end
            end
            
            function receive(s)
                local ip, port = s:getpeername()
                while events.yield() do
                    local data, err = s:receive("*l")
                    if data == nil then
                        print("ERROR : "..err)
                        return false
                    else
                        print("I receive "..data.." From "..ip..":"..port)
                        local table_d = misc.split(data, " ")
                        if table_d[1] == vote_msg.rep then
                            -- VOTE REP
                            local term, vote = tonumber(table_d[2]), tonumber(table_d[3])
                            if term > state.term then
                                stepdown(term)
                            end
                            if term == state.term and state.state == "candidate" then
                                if vote == job_index then
                                    state.votes[s.job_index] = true
                                    print("I have received one vote from "..s.job_index.." | cnt = "..misc.size(state.votes))
                                end
                                rpc_time[s.job_index] = nil
                                if misc.size(state.votes) > misc.size(job.nodes) /2 then
                                    print("I become the LEADER")
                                    state.state = "leader"
                                    state.leader = job_index
                                    trigger_heart_timeout()
                                end
                            end
                        elseif table_d[1] == vote_msg.req then
                            -- VOTE REQ
                            local term = tonumber(table_d[2])
                            if term > state.term then
                                stepdown(term)
                            end
                            if term == state.term and (state.voteFor == nil or state.voteFor == s.job_index) then
                                state.voteFor = s.job_index
                                set_election_timeout()
                            end
                            s:send(vote_msg.rep.." "..state.term.." "..state.voteFor.."\n")
                        elseif table_d[1] == heartbeat_msg then
                            -- HEARBEAT
                            set_election_timeout()
                            state.term = tonumber(table_d[2])
                            state.voteFor = nil
                        else
                            print("Warning : unkown message -> "..table_d[1])
                        end
                    end
                end
            end
            
            function init(s, connect)
                -- if connect == true => client 
                -- If this function returns false, The connection will be closed immediatly
                local ip, port = s:getpeername()
                if connect then
                    s:send(job_index.."\n")
                    local d = s:receive()
            
                    s.job_index = tonumber(d)
            
                    print("connection to: "..ip..":"..port.." - job_index = "..s.job_index)
                else
                    local d = s:receive()
                    s:send(job_index.."\n")
            
                    s.job_index = tonumber(d)
            
                    print("connection from: "..ip..":"..port.." - job_index = "..s.job_index)
                end
                if  sockets[s.job_index] ~= nil then
                    print("I am already connect to "..s.job_index )
                    error("Already connect in a other socket")
                else
                    print("Save socket "..s.job_index.." in the table")
                    sockets[s.job_index] = s
                end
            end
            
            function final(s)
                local ip, port = s:getpeername()
                print("Closing: "..ip..":"..port.." - index "..s.job_index)
                sockets[s.job_index] = nil
            end
            
            events.run(function()
                -- Accept connection from other nodes
                net.server(job.me.port, {initialize = init, send = send, receive = receive, finalize = final})
                
                -- Launch connection to each orther node (use the same function than server) (retry every 5 second)
                events.thread(function ()
                    while events.yield() do
                        for i, n in pairs(job.nodes) do
                            if sockets[i] == nil and i ~= job_index then
                                print("Try to begin connection to "..n.ip..":"..n.port.." - index "..i)
                                net.client(n, {initialize = init, send = send, receive = receive, finalize = final})
                            end
                        end
                        events.sleep(5)
                    end
                end)
            
                -- Election manage 
                set_election_timeout()
                
                -- Stop after 10 seconds
                events.sleep(10)
                print("RAFT.LUA EXIT on"..job.me.ip..":"..job.me.port)
                events.exit()
            end)
        ]]
        newCode = splay_crash.parse_code(code)
        assert.are.equal(code, newCode)
    end)
end)