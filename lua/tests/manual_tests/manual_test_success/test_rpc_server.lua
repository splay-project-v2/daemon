require"splay.base"
local rpc = require"splay.rpc"
function pong()
	return "pong"
end
local finish = false
local pong_rep = ""
local err = nil

events.run(function()
	local port=30001
	local rpc_server_thread = rpc.server(port)
	pong_rep, err= rpc.call("127.0.0.1", port, "pong" )	
	print(err)
	print(pong_rep)
	finish = true
	rpc.stop_server(port)
	events.kill(rpc_server_thread)
end)

assert(pong_rep=="pong")
assert(err==nil)
assert(finish == true)