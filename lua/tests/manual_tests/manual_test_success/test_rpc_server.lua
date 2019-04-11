require"splay.base"
local splay = require("socket")
local rpc = require"splay.rpc"
function pong()
	return "pong1"
end
success = false

events.run(function()
	local port=30001
	local rpc_server_thread = rpc.server(port)
	local pong_rep, err= rpc.call({ip="127.0.0.1",port=port}, {"pong"})	
	assert(pong_rep=="pong1")
	assert(err==nil)
	success = true
	events.kill(rpc_server_thread)
end)

assert(success == true)
