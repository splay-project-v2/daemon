describe("Test splay benc", function()
    it("MD5 check", function()
        local openssl = require("openssl.digest")
        
        local d = openssl.new("md5")

        local function tohex(b)
            local x = ""
            for i = 1, #b do
                x = x .. string.format("%.2x", string.byte(b, i))
            end
            return x
        end

        s = tohex(d:final("password"))
        print(s)

        assert.truthy(s)
        assert.truthy(s..".txt")
        assert.True(s == "5f4dcc3b5aa765d61d8327deb882cf99")
    end)

    it("SHA1 check", function()
        local openssl = require("openssl.digest")
        
        local d = openssl.new("sha1")

        local function tohex(b)
            local x = ""
            for i = 1, #b do
                x = x .. string.format("%.2x", string.byte(b, i))
            end
            return x
        end

        s = tohex(d:final("password"))
        print(s)

        assert.truthy(s)
        assert.truthy(s..".txt")
        assert.True(s == "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8")
    end)
end)


