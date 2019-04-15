describe("Splay Utils Testing", function ()
    it("Job generation", function()
        utils=require"splay.utils"
        job=utils.generate_job(1, 10, 100, 10, "random")
        assert.truthy(job.nodes)
        assert.truthy(job.get_live_nodes)
        local the_nodes = job.get_live_nodes()
        assert.truthy(the_nodes)
        for i=1, #job.nodes do
            assert.True(job.nodes[i]==the_nodes[i])
        end
    end)
end)
