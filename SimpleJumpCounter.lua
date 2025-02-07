if not JumpCounterDB then
    JumpCounterDB = {};
end

-- print("=========== Jump counter loaded! >>>>>>>>>>>")
SLASH_JUMPCOUNTER1 = "/jumps";
local last_jump = 0.0;
local delay = 0.80;
local jump_msg_requested = false;
local initial_requested = false;

local addon = CreateFrame("FRAME", "JumpCounterFrame");
addon:RegisterEvent("TIME_PLAYED_MSG");
addon:SetScript("OnEvent", function(self, event, ...)
    if initial_requested then
        JumpCounterDB.started = ...;
        initial_requested = false;
        return
    end
    if jump_msg_requested then
        local duration = ... - JumpCounterDB.started;
        print_stats(duration);
    end
end)


local o = ChatFrame_DisplayTimePlayed
ChatFrame_DisplayTimePlayed = function(...)
    if jump_msg_requested or initial_requested then
        jump_msg_requested = false;
        return;
    end
    return o(...);
end

function addon:RequestTimePlayed()
    jump_msg_requested = true;
    RequestTimePlayed();
end


function print_stats(duration)
    -- print("Duration: "..duration)
    local avgday = 0.0;
    local avghour = 0.0;
    if JumpCounterDB.jumps > 0 then
        avgday = perdayavg(duration);
        avghour = perhoursavg(duration);
    end

    print(string.format("Avg. per day: |cffFF9900%.1f", avgday));
    print(string.format("Avg. per hour: |cff0099FF%.1f", avghour));
end



function perhoursavg(t)
    local hours = t / 3600;
    return JumpCounterDB.jumps / hours;
end

function perdayavg(t)
    local days = t / 86400;
    return JumpCounterDB.jumps / days;
end

hooksecurefunc( "JumpOrAscendStart", function()
    if not JumpCounterDB.started then
        initial_requested = true;
        addon:RequestTimePlayed();
    end

    if GetTime() >= last_jump + delay and not IsSwimming() then
        last_jump = GetTime();
        if not JumpCounterDB.jumps then
            JumpCounterDB.jumps = 1;
        else
            JumpCounterDB.jumps = JumpCounterDB.jumps + 1;
        end
        
        if JumpCounterDB.jumps % 10000 == 0 then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffD3FF23JumpCounter:|r You have jumped |cffFF0000%d|r times!!!", JumpCounterDB.jumps));
        end
    end
  end );

SlashCmdList["JUMPCOUNTER"] = function()
    if not JumpCounterDB.started then
        JumpCounterDB.started = GetTime();
    end
    if not JumpCounterDB.jumps then
        JumpCounterDB.jumps = 0;
    end
    print(string.format("Total jumps: |cff99FF00%d", JumpCounterDB.jumps));
    addon:RequestTimePlayed();

end