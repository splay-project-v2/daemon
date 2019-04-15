describe("Test Splay llenc", function()
    it("...", function()
        local llenc = require("splay.llenc")
        assert.truthy(llenc)

        toTest = {1000, "A String", {a="a", b="b"}}
        for i,gen in pairs(toTest) do 
            assert.truthy(llenc.encode(gen))
        end
    end)
end)