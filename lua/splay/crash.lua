local log = require("splay.log")

local _M = {}
_M._NAME = "splay.lbinenc"
local l_o = log.new(1, "[".._M._NAME.."]")

-- Crash by id
local crash_table = {}

-- PARSING PART
--
local function line_by_line(str) 
    str = str.."\n"
    return str:gmatch("(.-)\n")
end

-- CRASH POINT id_splayd [id_splayd, [...]] : <Type> : <When> 
-- <Type> => STOP | RECOVERY x_sleep
-- <When> => IMMEDIATELY | AFTER x_pass | RANDOM chance
local p_crash_point = "%s*--%s*CRASH%s+POINT%s+(.+)"
local p_id_splayd = "^(.-):(.+)"
local p_type = "^%s*(%u+)%s+(.+)"

local p_recovery_wait = "%s*--%s*CRASH%s+POINT%s+%d+%s+:%s+RECOVERY%s+(%d+)"

--
local function concerned(job, nb_splayd) 
    return false
end

-- 
local function parse_line(line, job, i_line)
    if string.match(line, p_crash_point) then
        line = string.match(line, p_crash_point)
        l_o:debug("crash point : line_1 => "..line)
        local id_splayds_str, line = string.match(line, p_id_splayd)
        l_o:debug("Break point line_2 => "..line)
        id_splayd = {}
        for id_splayd_str in string.gmatch(id_splayds_str, "%d+") do
            print(id_splayd_str)
            id_splayd[tonumber(id_splayd_str)] = true
        end

        if not concerned(job, nb_splayd) then
            l_o:info("I am not concerned by crash line "..i_line.." => ignored")
            return line
        end

        local type, line = string.match(line, p_type)
        l_o:debug("Break point line_3 => "..line)
        
        if type == "STOP" then

        elseif type == "RECOVERY" then
            local time_to_wait = tonumber(string.match(line, p_recovery_wait))

        else 
            l_o:warning("Type "..type.." of crash not known : line "..i_line.." ignored")
        end
    end

    return line
end 

-- Parse the code of the job and add the true code for the Crash point 
function _M.parse_code(job_code, job)
    local tab = {}
    for line in line_by_line(job_code) do 
        tab[#tab + 1] = parse_line(line, job, #tab + 1)
    end
    return table.concat(tab,"\n")
end

-- CRASH PART

-- Crash the code (no rerun)
function _M.crash_stop(id)

end

-- Crash the code (rerun)
function _M.crash_recovery(id)

end

return _M