describe("Test socket features", function()
    it("Test the installation of socket + wrapper of it", function()
        local se = require("splay.socket_events")
        assert.truthy(se.wrap)
        assert.truthy(se._NAME == "splay.socket_events")

        -- Check if function of socket is available
        local socket = require("socket")
        assert.truthy(socket._VERSION)
        assert.truthy(socket.dns) --	table: 0x7fc8b1c0fc60
        assert.truthy(socket._SETSIZE)
        assert.truthy(socket.protect) --	function: 0x105c0bff0
        assert.truthy(socket.choose) --	function: 0x7fc8b1c06310
        assert.truthy(socket.try) --	function: 0x7fc8b1c062e0
        assert.truthy(socket.connect4) --	function: 0x7fc8b1c0fa50
        assert.truthy(socket.udp6) --	function: 0x105c0d620
        assert.truthy(socket.tcp6) --	function: 0x105c0cd30
        assert.truthy(socket.source) --	function: 0x7fc8b1c0ac40
        assert.truthy(socket.skip) --	function: 0x105c08520
        assert.truthy(socket.bind) --	function: 0x7fc8b1c06280
        assert.truthy(socket.newtry) --	function: 0x105c0c010
        assert.truthy(socket.BLOCKSIZE)
        assert.truthy(socket.sleep) --	function: 0x105c08680
        assert.truthy(socket.sinkt) --	table: 0x7fc8b1c0dd60
        assert.truthy(socket.udp) --	function: 0x105c0d630
        assert.truthy(socket.sourcet) --	table: 0x7fc8b1c0dd20
        assert.truthy(socket.connect6) --	function: 0x7fc8b1c0fab0
        assert.truthy(socket.connect) --	function: 0x105c0c990
        assert.truthy(socket.tcp) --	function: 0x105c0cd40
        assert.truthy(socket.__unload) --	function: 0x105c08510
        assert.truthy(socket.select) --	function: 0x105c0c580
        assert.truthy(socket.gettime) --	function: 0x105c087a0
        assert.truthy(socket.sink) --	function: 0x7fc8b1c0ddd0
        assert.truthy(socket.udp)
        assert.truthy(socket.tcp)
        assert.truthy(socket.newtry)
        assert.truthy(socket.protect)

        local socket_wrapped_by_socket_events = se.wrap(socket)
        assert.truthy(socket_wrapped_by_socket_events.bind)
        local lsh = require("splay.luasocket")
        local wrapped_socket = lsh.wrap(socket_wrapped_by_socket_events)
        assert.truthy(wrapped_socket.bind)
    end)

    it("DNS testing - With restricted socket wrap", function ()
        local socket = require("socket.core")
        local rs = require("splay.restricted_socket")
        rs.init(
	        {max_sockets=1024,
	        local_ip="127.0.0.1",
	        start_port=11000,end_port=11500})
        local socket = rs.wrap(socket)

        local ip,_ = socket.dns.toip("google-public-dns-a.google.com")
	    assert.True(ip=="8.8.8.8")
	
	    local name,_ = socket.dns.tohostname("8.8.8.8")
	    --the '.' at the end of the domain is intended by the DNS RFC
	    assert.True(name=="google-public-dns-a.google.com")	
    end)
end)