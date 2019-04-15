describe("Test splay benc", function()
    it("MD5 check", function()
        local misc = require("splay.misc")
        local openssl = require("openssl.digest")
        
        local d = openssl.new("md5")

        s = misc.binary_string_to_hex(d:final("password"))
        print(s)

        assert.truthy(s)
        assert.truthy(s..".txt")
        assert.True(s == "5f4dcc3b5aa765d61d8327deb882cf99")
    end)

    it("SHA1 check", function()
        local misc = require("splay.misc")
        local openssl = require("openssl.digest")        
        local d = openssl.new("sha1")


        s = misc.binary_string_to_hex(d:final("password"))
        print(s)

        assert.truthy(s)
        assert.truthy(s..".txt")
        assert.True(s == "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8")
    end)
end)


