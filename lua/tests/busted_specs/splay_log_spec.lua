describe("Test Splay Log", function()
    it("...", function()
        
        log = require("splay.log")
        assert.truthy(log.global_filter) --	function: 0x7faec94060b0
        assert.truthy(log.global_out) --	function: 0x7faec940eb20
        assert.truthy(log.global_write) --	function: 0x7faec940e910
        assert.truthy(log.global_level) --	3
        assert.truthy(log.new) --	function: 0x7faec940e620

        local l_o = log.new(5, "[inf-logger]")

        assert.truthy(l_o.i) --	function: 0x7faec940be20
        assert.truthy(l_o.debug) --	function: 0x7faec940e330
        assert.truthy(l_o.n) --	function: 0x7faec940be20
        assert.truthy(l_o.p) --	function: 0x7faec940b5e0
        assert.truthy(l_o.error) --	function: 0x7faec940c750
        assert.truthy(l_o.warn) --	function: 0x7faec940c6e0
        assert.truthy(l_o.w) --	function: 0x7faec940c6e0
        assert.truthy(l_o.info) --	function: 0x7faec940be20
        assert.truthy(l_o.d) --	function: 0x7faec940e330
        assert.truthy(l_o.print) --	function: 0x7faec940b5e0
        assert.truthy(l_o.e) --	function: 0x7faec940c750
        assert.truthy(l_o.warning) --	function: 0x7faec940c6e0
        assert.truthy(l_o.notice) --	function: 0x7faec940be20
        assert.truthy(l_o:print("print-level","test"))

        local l_o = log.new(1, "[deb-logger]")
        assert.truthy(l_o:debug("test"))

        a_module = {
            l_o = log.new(1, "[a_module]")
        }
        assert.truthy(a_module.l_o:print("test"))
    end)
end)