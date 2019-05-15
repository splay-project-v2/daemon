describe("Test Splay fork and status code of the child process", function()
    it("...", function()
        local splay = require"splay"

        exit_code = 25
        pid = splay.fork()

        if (pid < 0) then 
            error("Error Fork (JOBD)")
        elseif (pid  == 0) then
            os.exit(exit_code)
        else
            status = splay.waitpid(pid)
            assert.are.equal(status,exit_code)
        end
    end)
end)