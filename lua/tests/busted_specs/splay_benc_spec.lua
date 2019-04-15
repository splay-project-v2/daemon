describe("Test splay benc", function()
    it("Random String benc encode-decode", function()
        local misc = require("splay.misc")
        local benc = require("splay.benc")

        assert.truthy(benc)
        assert.truthy(benc.decode(benc.encode("some input"))=="some input")

        -- Doesn't work with decimal
        toTest = {1000, "A String", {a="a", b="b"}}
        for i,gen in pairs(toTest) do 
            enc_data = benc.encode(gen)
            dec_data = benc.decode(enc_data)
            assert.are.same(gen, dec_data)
        end
    end)
end)


