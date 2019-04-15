describe("Test Base64 lib", function()
    it(" - Raw test", function()
        local json = require("json")
        assert.truthy(json)

        input_file="./tests/busted_specs/raw.json"
        f, err = io.open(input_file,"r")
        local l_json=f:read("*a")
        f:close()
        
        local x = os.clock()
        local list = json.decode(l_json)
        assert.truthy(list)
        local jlist = json.encode(list)
        assert.truthy(jlist)
        print(string.format("json decode + encode, elapsed time: %.5f\n", os.clock() - x))
    end)

    it("Result test", function()
        local json = require("json")
        assert.truthy(json)
        simple_json = '{"TEST1": "Simple","TEST2":{"TEST3": "Double"}}'
        local object = json.decode(simple_json)
        assert.are.equals(object.TEST1, "Simple")
        assert.are.equals(object.TEST2.TEST3, "Double")
    end)
end)