describe("Test Crash point interpretation", function()
    it("Simple stop", function()
        -- CRASH POINT nb_splayd : STOP : after_x_pass 
        line = "-- CRASH POINT 1 : STOP : 3"
    end)
    it("Simple Recovery", function()
        -- CRASH POINT nb_splayd : RECOVERY x_spleep : after_x_pass 
        line = "-- CRASH POINT 1 : RECOVERY 1 : 3"
    end)
end)