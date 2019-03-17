describe("The installation Test", function()
    it("Should Works - check busted", function()
        assert.True(1 == 1)
    end)

    it("Installation check", function()
        -- Standard libs
        assert.truthy(require("table"))
        assert.truthy(require("math"))
        assert.truthy(require("os"))
        assert.truthy(require("io"))
        assert.truthy(require("string"))

        -- Splay libs
        assert.truthy(require("splay"))
        assert.truthy(require("splay.base"))
        assert.truthy(require("splay.data_bits"))
        assert.truthy(require("splay.misc"))
        assert.truthy(require("splay.net"))
        assert.truthy(require("splay.rpc"))
        assert.truthy(require("splay.urpc"))

        -- JSON libs
        assert.truthy(require("json"))

        -- Socket Libraries
        assert.truthy(require("socket.ftp"))
        assert.truthy(require("socket.http"))
        assert.truthy(require("socket.smtp"))
        assert.truthy(require("socket.tp"))
        assert.truthy(require("socket.url"))
        assert.truthy(require("mime"))
        assert.truthy(require("ltn12"))
        -- SSL libraries
        assert.truthy(require("ssl"))
        assert.truthy(require("openssl"))
        assert.truthy(require("openssl.digest"))

    end)

    it("Splay base check", function()
        require("splay.base")
        assert.truthy(misc)
        assert.truthy(log)
        assert.truthy(events)
        assert.truthy(socket)
    end)

end)