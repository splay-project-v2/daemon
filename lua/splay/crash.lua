local log = require("splay.log")
local misc = require("splay.misc")

local _M = {}
_M._NAME = "splay.lbinenc"
local l_o = log.new(1, "[".._M._NAME.."]")

-- Crash by id
local crash_table = {}

--[[ CRASH STRUCTURE
    'id' = {
        type = "<TYPE>",
        data_type = <...>
        when = {
            type = "<WHEN>"
            data = <...>
        }
    }
]]

-- PARSING PART
--
local function line_by_line(str) 
    str = str.."\n"
    return str:gmatch("(.-)\n")
end

-- CRASH POINT id_splayd [id_splayd, [...]] : <Type> : <When> 
-- <TYPE> => STOP | RECOVERY x_sleep
-- <WHEN> => IMMEDIATELY | AFTER x_pass | RANDOM chance
local p_crash_point = "%s*--%s*CRASH%s+POINT%s+(.+)"
local p_id_splayd = "^(.-):(.+)"

-- Type patterns
local p_type = "^%s*(%u+)%s*(.+)"
local p_type_recovery = "^%s*(%d+)%s*(.+)"

-- When patterns
local p_when_type = "^%s*:%s*(%u+)%s*(.*)"

local p_when_after = "^%s*(%d+)"
local p_when_random = "^%s*(.-)%s*"

--
local function concerned(job, id_splayd) 
    return id_splayd[job.position] == true
end

--
local function parse_when(line, job)
    local data_when = nil
    local type_when, line = string.match(line, p_when_type)
    if type_when == "AFTER" then
        data_when = tonumber(string.match(line, p_when_after))
    elseif type_when == "RANDOM" then 
        data_when = tonumber(string.match(line, p_when_random))
    elseif type_when == "IMMEDIATELY" then
        -- NOTHING
    else 
        l_o:warning("Type of when crash - "..type_when.." is unknown : line "..i_line.." ignored")
    end
    return {type = type_when, data = data_when}
end

--
local function add_crash(type, data_type, when)
    local id = #crash_table + 1
    crash_table[id] = {
        type = type,
        ["when"] = when,
        data_type = data_type,
    }
    return id
end

-- 
local function parse_line(line, job, i_line)
    full_line = line
    if string.match(line, p_crash_point) then

        line = string.match(line, p_crash_point)
        local id_splayds_str, line = string.match(line, p_id_splayd)

        -- Get conserned daemons
        id_splayds = {}
        for id_splayd_str in string.gmatch(id_splayds_str, "%d+") do
            id_splayds[tonumber(id_splayd_str)] = true
        end
        -- Check if this job is conserned
        if not concerned(job, id_splayds) then
            l_o:info("I am not concerned by crash line "..i_line.." => ignored")
            return full_line
        end

        local type, line = string.match(line, p_type)
        
        if type == "STOP" then
            local when = parse_when(line, job)

            local id = add_crash("STOP", nil, when)
            -- Change the line
            l_o:info("Crash point add - id = "..id.." : "..misc.dump(crash_table[id]))
            return "crash.crash_point("..id..")"
        elseif type == "RECOVERY" then
            local time_to_wait, line = string.match(line, p_type_recovery)
            time_to_wait = tonumber(time_to_wait) 

            local when = parse_when(line, job)

            local id = add_crash("RECOVERY", time_to_wait, when)
            -- Change the line
            l_o:info("Crash point add - id = "..id.." : "..misc.dump(crash_table[id]))
            return "crash.crash_point("..id..")"
        else 
            l_o:warning("Type "..type.." of crash is unknown : line "..i_line.." ignored")
        end
       
    end

    return full_line
end 

-- Parse the code of the job and add the true code for the Crash point 
function _M.parse_code(job_code, job, no_reset_table)
    if not no_reset_table then
        crash_table = {}
    end
    local tab = {}

    for line in line_by_line(job_code) do 
        local status, new_line = pcall(parse_line, line, job, #tab + 1)
        if status then
            tab[#tab + 1] = new_line
        else
            l_o:error("Fail to parsing the line "..(#tab + 1).." for a Crash point : "..line.." => Ingored this line")
            tab[#tab + 1] = line
        end
    end
    return table.concat(tab,"\n")
end

-- CRASH PART

-- Crash the code (no rerun)
function _M.crash_point(id)

end

return _M