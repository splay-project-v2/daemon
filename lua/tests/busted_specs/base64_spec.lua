describe("Test Base64 lib", function()
    it(" - Random test", function()
        local base64 = require("base64")
        assert.truthy(base64)
        assert.truthy(base64.version)

        function test(s)
            local a = base64.encode(s)
            local b = base64.decode(a)
            assert.are.equal(b, s)
        end

        for i=1,9 do
            locals=string.sub("Lua-scripting-language",1,i)
            test(locals)
        end

        function test(p)
            for i=1,255 do
                local s=p..string.char(i)
                local a=base64.encode(s)
                local b=base64.decode(a)
                assert.are.equal(b, s)
            end
        end

        test("")
        test("x")
        test("xy")
        test("xyz")
    end)

    it("Testing result", function()
        local base64 = require("base64")
        assert.truthy(base64)
        assert.truthy(base64.version)
        
        res_enc = base64.encode("splay")

        assert.are.equals(res_enc, "c3BsYXk=")

        res_dec= base64.decode("U3BsYXlWMg==")

        assert.are.equals(res_dec, "SplayV2")
    end)
end)