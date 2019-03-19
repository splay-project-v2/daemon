--[[

Small script to test splay, just log the different neighbours during 1 minutes

--]]
require("splay.base")
local math = require("math")
local net = require("splay.net")
local misc = require("splay.misc")



job = {}
job.me = {ip = '127.0.0.1', port= 15001}
job.nodes = {{ip= '127.0.0.1', port= 15001 }, {ip= '127.0.0.1', port= 15002 }}


election_timeout = 1.0
rpc_timeout = 0.3

vote_msg = {req = "VOTEREQ", rep = "VOTEREP"}
heartbeat_msg = "HEARTBEAT"

state = {
    term = 0,
    voteFor = nil, -- {ip = ip, port = port} as id
    state = "follower", -- follower, candidat, or leader
    leader = nil, --  {ip = ip, port = port} of the leader
    votes = {}
}

sockets = {}

for i,n in ipairs(job.nodes) do
    if not n.ip ~= job.me.ip then
        sockets[n.ip..n.port] = nil
    end
end

rpc_time = {}
election_time = ((math.random() + 1.0) * election_timeout) + misc.time()

function isLeader(node)
    if (node and state.leader and node.ip == state.leader.ip and node.port == state.leader.port) then
        return true
    else
        return false
    end
end

function trigger_rpc_timeout(socket)
    if (state == "candidate") then
        local ip, port = s:getpeername()
        rpc_time[ip..port] = misc.time() + (math.random() * 0.2) + rpc_timeout
        socket:send(vote_msg.req.." "..state.term)
    end
end

function setContains(set, key)
    return set[key] ~= nil
end

function trigger_election_timeout()
    if (state.state == "follower" or state.state == "candidate") then 
        election_time = ((math.random() + 1.0) * election_timeout) + misc.time()
        state.term = state.term + 1
        state.state = "candidate"
        state.voteFor = job.me.ip..job.me.port
        state.votes[job.me.ip..job.me.port] = true
        for i, s in ipairs(sockets) do
            local ip, port = s:getpeername()
            rpc_time[ip..port] =  misc.time()
        end
    end
end

function send(s)
    local ip, port = s:getpeername()
    rpc_time[ip..port] =  misc.time() + (math.random() * 0.2) + rpc_timeout
    while events.yield() do
        if (not isLeader(job.me) and rpc_time[ip..port] < misc.time()) then
            -- RPC Timeout
            print("Trigger rpc timeout for "..ip..":"..port)
            trigger_rpc_timeout(s)
        end
    end
end

function receive(s)
    local ip, port = s:getpeername()

end

function init(s, connect)
    -- if this function returns false,
    -- the connection will be closed immediatly
    local ip, port = s:getpeername()
    if connect then
        print("connection to: "..ip..":"..port)
    else
        print("connection from: "..ip..":"..port)
    end
end

function final(s)
    local ip, port = s:getpeername()
    print("closing: "..ip..":"..port)
end

events.run(function()
    -- Accept connection from other nodes
    net.server(job.me.port, {initialize = init, send = send, receive = receive, finalize = final})
    
    -- Launch connection to each orther node (use the same function than server)
    events.thread(function ()
        for i,n in ipairs(job.nodes) do
            if not n.ip ~= job.me.ip then
                print("Try to instanciate connectio to "..n.ip..":"..n.port)
                net.client(n, {initialize = init, send = send, receive = receive, finalize = final})
            end
        end
    end)

    events.thread(function ()
        while events.yield() do
            if (state.state ~= "leader" and election_time < misc.time()) then
                -- Election Timeout
                print("Trigger election timeout "..election_time)
                trigger_election_timeout()
            end
        end
    end)
    
    events.sleep(10)
    events.exit() -- rpc.server() is still running...
end)

