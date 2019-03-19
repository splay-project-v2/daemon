--[[

Raft leader election implemantation

--]]
require("splay.base")
local math = require("math")
local net = require("splay.net")
local misc = require("splay.misc")
local table = require("table")

-- JOB definition, normally already define
job = {}
job.me = {ip = '127.0.0.1', port= 15001}
job.nodes = {{ip= '127.0.0.1', port= 15001 }, {ip= '127.0.0.1', port= 15002 }}

-- Minimal timeout for each purpose in second
election_timeout = 2.0
rpc_timeout = 0.3
heartbeat_timeout = 0.5

-- Constant msg send and receive between nodes
vote_msg = {req = "VOTEREQ", rep = "VOTEREP"}
heartbeat_msg = "HEARTBEAT"

-- State of this node
state = {
    term = 0,
    voteFor = nil, -- {ip = ip, port = port} as id
    state = "follower", -- follower, candidat, or leader
    leader = nil, --  {ip = ip, port = port} of the leader
    votes = {}
}

-- sockets table of each connected node (nil == cot connected to)
sockets = {}

-- Init sockets table
for i,n in ipairs(job.nodes) do
    if n.ip ~= job.me.ip or n.port ~= job.me.port then
        sockets[n.ip..n.port] = nil
    end
end

-- Timeout variable (if x_time < misc.time() then trigger the corresponded timeout)
rpc_time = {}
election_time = ((math.random() + 1.0) * election_timeout) + misc.time()
heart_time = misc.time()

-- helper functions
function isLeader(node)
    if (node and state.leader and node.ip == state.leader.ip and node.port == state.leader.port) then
        return true
    else
        return false
    end
end

function setContains(set, key)
    return set[key] ~= nil
end

function stepdown(term)
    state.term = tonumber(term)
    state.state = "follower"
    state.voteFor = nil
    election_time = ((math.random() + 1.0) * election_timeout) + misc.time()
end

-- Trigger functions
function trigger_rpc_timeout(socket)
    if (state == "candidate") then
        local ip, port = s:getpeername()
        rpc_time[ip..port] = misc.time() + (math.random() * 0.2) + rpc_timeout
        socket:send(vote_msg.req.." "..state.term)
    end
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

function trigger_hearbeat_timeout(s)
    state.term = state.term + 1
    s:send(heartbeat_msg.." "..state.term)
    heart_time = misc.time() + heartbeat_timeout
end

-- Socket fonction
function send(s)
    local ip, port = s:getpeername()
    rpc_time[ip..port] =  misc.time() + (math.random() * 0.2) + rpc_timeout
    while events.yield() do
        -- RPC Timeout
        if (not isLeader(job.me) and  rpc_time[ip..port] ~= nil and rpc_time[ip..port] < misc.time()) then
            print("Trigger rpc timeout for "..ip..":"..port)
            trigger_rpc_timeout(s)
        end
        -- HEARTBEAT Timeout
        if (isLeader(job.me) and heart_time < misc.time()) then
            print("Trigger heartbeat timeout for "..ip..":"..port)
            trigger_hearbeat_timeout(s)
        end
    end
end

function receive(s)
    local ip, port = s:getpeername()
    while events.yield() do
        local data = s:receive("*l")
        print("I receive "..data.." From "..ip..":"..port)
        local table_d = misc.split(data, " ")
        if table_d[1] == vote_msg.rep then
            -- VOTE RES
            local term, vote = tonumber(table_d[2]), table_d[3]
            if term > state.term then
                stepdown(term)
            end
            if term == state.term and state.state == "candidat" then
                if vote == job.me.ip..job.me.port then
                    state.votes[ip..port] = true
                end
                rpc_time[ip..port] = nil
                if table.getn(state.votes) > table.getn(job.nodes) /2 then
                    print("I am the leader")
                    state.state = "leader"
                    state.leader = job.me
                    heart_time = misc.time()
                end
            end
        elseif table_d[1] == vote_msg.req then
            -- VOTE REQ
            local term = tonumber(table_d[2])
            if term > state.term then
                stepdown(term)
            end
            if term == state.term and (state.voteFor == nil or state.voteFor == ip..port) then
                state.voteFor = ip..port
                election_time = ((math.random() + 1.0) * election_timeout) + misc.time()
            end
            s:send(vote_msg.rep.." "..state.term..state.voteFor)
        elseif table_d[1] == heartbeat_msg then
            -- HEARBEAT
            state.term = tonumber(table_d[2])
        end
    end
end

function init(s, connect)
    -- If this function returns false,
    -- The connection will be closed immediatly
    local ip, port = s:getpeername()
    if connect then
        print("connection to: "..ip..":"..port)
    else
        print("connection from: "..ip..":"..port)
    end
    if  sockets[ip..port] ~= nil then
        print("I am already connect => close this one")
        return false
    else
        print("New Connection")
        sockets[ip..port] = s
    end
end

function final(s)
    local ip, port = s:getpeername()
    print("closing: "..ip..":"..port)
    sockets[ip..port] = nil
end

events.run(function()
    -- Accept connection from other nodes
    net.server(job.me.port, {initialize = init, send = send, receive = receive, finalize = final})
    
    -- Launch connection to each orther node (use the same function than server) (retry every 5 second)
    events.thread(function ()
        while events.yield() do
            for i,n in ipairs(job.nodes) do
                if sockets[n.ip..n.port] == nil and not (n.ip == job.me.ip and n.port == job.me.port) then
                    print("Try to instanciate connection to "..n.ip..":"..n.port)
                    net.client(n, {initialize = init, send = send, receive = receive, finalize = final})
                end
            end
            events.sleep(5)
        end
    end)

    -- Election manage 
    events.thread(function ()
        while events.yield() do
            if (state.state ~= "leader" and election_time < misc.time()) then
                -- Election Timeout
                print("Trigger election timeout "..election_time)
                trigger_election_timeout()
            end
        end
    end)
    
    -- Stop after 20 seconds
    events.sleep(20)
    events.exit() -- rpc.server() is still running...
end)

