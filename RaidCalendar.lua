local ADDON_NAME = "RaidCalendar";
local ADDON_DB_NAME = "RaidCalendarDB";

RaidCalendar = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceCommPeer-3.0", "AceSerializer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

local RaidCalendarIcon = LibStub("LibDataBroker-1.1"):NewDataObject("RaidCalendarIcon", {
    type = "data source",
    text = L["TITLE"],
    icon = "Interface\\Icons\\inv_scroll_04",
    OnClick = function()
      if RaidCalendarFrame:IsVisible() then
        RaidCalendarFrame:Hide();
      else
        RaidCalendarFrame:Show();
        RaidCalendarFrame:UpdateMonth();
      end
    end,
})
local icon = LibStub("LibDBIcon-1.0");

local function clonetable(t, deep)
  local tNew = {};
  for k in pairs(t) do
    if (type(t[k]) == "table") then
      if (deep) then
        tNew[k] = clonetable(t[k], true);
      else
        tNew[k] = t[k];
      end
    else
      tNew[k] = t[k];
    end
  end
  return tNew;
end

function RaidCalendar:OnInitialize()
  -- DATABASE / STORAGE
  self.db = LibStub("AceDB-3.0"):New(ADDON_DB_NAME, self:GetDefaultOptions());
	self.syncDb = self.db:RegisterNamespace("PeerSync", self:GetSyncDbDefaults());
  self.frames = {};
  self.actionLog = self:GetSyncPacketsSorted();
  self:Debug("ADDON INIT");
  -- MINIMAP ICON
  icon:Register(L["TITLE"], RaidCalendarIcon, self.db.profile.minimap);
  -- OPTIONS
  self.options = LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME, self:InitOptions(), {"rc", "raidcal", "raidcalendar"});
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, ADDON_NAME);
  -- FRAMES
  self.frames.calendar = RaidCalendarFrame;
  self.frames.signup = RaidSignupFrame;
  self.frames.create = RaidCreateFrame;
  RaidCalendarFrame:Hide();
  RaidSignupFrame:Hide();
  RaidCreateFrame:Hide();
  -- DATA
  self.statusOptions = {};
  self.statusOptions["SIGNED_UP"] = L["STATUS_SIGNED_UP"];
  self.statusOptions["UNSURE"] = L["STATUS_UNSURE"];
  self.statusOptions["NOT_AVAILABLE"] = L["STATUS_NOT_AVAILABLE"];
  self.statusOptions["LATE"] = L["STATUS_LATE"];
  self.statusColors = {
    	SIGNED_UP = { r = 0.45, g = 0.83, b = 0.45 },
    	LATE = { r = 0.83, g = 0.83, b = 0.45 },
    	UNSURE = { r = 1.0, g = 0.96, b = 0.41 },
    	NOT_AVAILABLE = { r = 0.96, g = 0.20, b = 0.20 }
  };
  self.roles = {};
  self.roles["TANK"] = L["ROLE_TANK"];
  self.roles["HEALER"] = L["ROLE_HEALER"];
  self.roles["CASTER"] = L["ROLE_CASTER"];
  self.roles["AUTOATTACKER"] = L["ROLE_AUTOATTACKER"];
  self.roles["FLEX_TANK"] = L["ROLE_FLEX_TANK"];
  self.roles["FLEX_HEAL"] = L["ROLE_FLEX_HEAL"];
  self.classColors = {
    	HUNTER = { r = 0.67, g = 0.83, b = 0.45 },
    	WARLOCK = { r = 0.58, g = 0.51, b = 0.79 },
    	PRIEST = { r = 1.0, g = 1.0, b = 1.0 },
    	PALADIN = { r = 0.96, g = 0.55, b = 0.73 },
    	MAGE = { r = 0.41, g = 0.8, b = 0.94 },
    	ROGUE = { r = 1.0, g = 0.96, b = 0.41 },
    	DRUID = { r = 1.0, g = 0.49, b = 0.04 },
    	SHAMAN = { r = 0.96, g = 0.55, b = 0.73 },
    	WARRIOR = { r = 0.78, g = 0.61, b = 0.43 }
  };
  self.classIcons = {
    HUNTER = "interface\\icons\\inv_weapon_bow_07",
    WARLOCK = "interface\\icons\\spell_nature_faeriefire",
    PRIEST = "interface\\icons\\inv_staff_30",
    PALADIN = "interface\\icons\\spell_holy_holysmite",
    MAGE = "interface\\icons\\inv_staff_13",
    ROGUE = "interface\\icons\\inv_throwingknife_04",
    DRUID = "interface\\icons\\ability_druid_maul",
    SHAMAN = "interface\\icons\\spell_nature_bloodlust",
    WARRIOR = "interface\\icons\\inv_sword_27"
  };
  self.roleIcons = {
    TANK = "interface\\icons\\inv_shield_01",
    CASTER = "interface\\icons\\inv_staff_06",
    AUTOATTACKER = "interface\\icons\\inv_sword_25",
    HEALER = "interface\\icons\\spell_nature_healingtouch",
    FLEX_TANK = "interface\\icons\\ability_racial_bearform.png",
    FLEX_HEAL = "interface\\icons\\spell_nature_healingwavelesser"
  };
  -- EVENTS
  self:RegisterMessage("SYNC_DEBUG", "OnSyncDebug")
  self:RegisterMessage("SYNC_PACKETS_CHANGED", "OnActionLogChanged")
  self:RegisterSyncChannel("GUILD");
  self:RegisterSyncChannel("WHISPER");
  -- QUEUED Actions
  self.queueReparse = self:GetSyncTime() + 0.1;
  self.queueChatReport = true;
  self.queueStartup = true;
  self.queueFrame = CreateFrame("Frame");
  self.queueFrame:SetScript("OnUpdate", function()
    RaidCalendar:QueueUpdate();
  end);
end

function RaidCalendar:QueueUpdate()
  if not (self.queueReparse == false) and (self.queueReparse < self:GetSyncTime()) then
    -- Re-Parse log
    self.queueReparse = false;
    self:ParseActionLog();
    return;
  elseif (self.queueChatReport) then
    self.queueChatReport = false;
    local raidsNotSignedUp = 0;
    for raidId, raidData in pairs(self.db.factionrealm.raids) do
      if (not raidData.signedUp) then
        raidsNotSignedUp = raidsNotSignedUp + 1;
      end
    end
    if (raidsNotSignedUp > 0) then
      self:Print("|cffffff80"..gsub(L["CHAT_REPORT_NOT_SIGNED_UP"], ":count", "|cffffffff"..raidsNotSignedUp.."|cffffff80"));
      self:Print("|cffffff80"..gsub(L["CHAT_REPORT_HELP"], ":cmd", "|cffffffff/rc show|cffffff80"));
      if (self.queueStartup) then
        RaidCalendarFrame:Show();
        RaidCalendarFrame:UpdateMonth();
      end
    end
    return;
  end
  self.queueStartup = false;
end

function RaidCalendar:GetColorHex(rgb)
	local code = '|c';
  if (rgb.a ~= nil) then
    code = code..string.format("%02x", math.floor(rgb.a * 255));
  else
    code = code.."ff";
  end
  code = code..string.format("%02x", math.floor(rgb.r * 255));
  code = code..string.format("%02x", math.floor(rgb.g * 255));
  code = code..string.format("%02x", math.floor(rgb.b * 255));
  return code;
end

--------------------------------------------------------------------------------
-- Raid management                                                            --
--------------------------------------------------------------------------------

function RaidCalendar:AddRaid(dateStr, expires, createdBy, timeInvite, timeStart, timeEnd, instance, comment, details)
  -- (type, data, timestamp, expires, source, packetId, verified)
  local id = self:AddSyncPacket("raidCreate", {
    dateStr = dateStr, createdBy = createdBy,
    timeInvite = timeInvite, timeStart = timeStart, timeEnd = timeEnd,
    instance = instance, comment = comment, details = details
  }, nil, expires );
  return id;
end

function RaidCalendar:UpdateRaid(id, dateStr, expires, createdBy, timeInvite, timeStart, timeEnd, instance, comment, details)
  self:AddSyncPacket("raidUpdate", {
    id = id, dateStr = dateStr, createdBy = createdBy,
    timeInvite = timeInvite, timeStart = timeStart, timeEnd = timeEnd,
    instance = instance, comment = comment, details = details
  });
  return true;
end

function RaidCalendar:DeleteRaid(id)
  self:AddSyncPacket("raidDelete", { id = id });
  return true;
end

function RaidCalendar:Signup(raidId, status, character, level, class, role, notes)
  self:AddSyncPacket("raidSignup", {
    raidId = raidId, status = status, notes = notes,
    character = character, level = level, class = class, role = role
  });
  return true;
end

function RaidCalendar:GetRaids(dateStr)
  local raidList = {};
  for raidId, raidData in pairs(self.db.factionrealm.raids) do
    if (raidData ~= nil) and (raidData.dateStr == dateStr) then
      raidData.id = raidId;
      tinsert(raidList, raidData);
    end
  end
  return raidList;
end

function RaidCalendar:GetRaidDetails(raidId)
  return self.db.factionrealm.raids[raidId];
end

function RaidCalendar:GetRaidSignups(raidId)
  local signupsSorted = {};
  for charName, charSignup in pairs(self.db.factionrealm.raids[raidId].signups) do
    tinsert(signupsSorted, charSignup);
  end
  sort(signupsSorted, function(a, b)
    if (not a.ack) then
      return true;
    end
    if (not b.ack) then
      return false;
    end
    return a.ackTime < b.ackTime;
  end);
  return signupsSorted;
end

function RaidCalendar:CanEditRaids()
  return true;
  --return CanEditMOTD();
end

function RaidCalendar:IsOwnRaid(raidData)
  for charName, charDetails in pairs(self.syncDb.factionrealm.characters) do
    if (raidData.createdBy == charName) then
      return true;
    end
  end
  return false;
end

--------------------------------------------------------------------------------
-- Options                                                                    --
--------------------------------------------------------------------------------

function RaidCalendar:GetStartWithMonday()
  return self.db.profile.calendarStartOnMonday;
end

function RaidCalendar:GetDefaultOptions()
  return {
    char = {
      debug = true
    },
    profile = {
      minimap = { hide = false },
      calendarStartOnMonday = true
    },
    factionrealm = {
      characters = {},
      raids = {},
      raidDefaults = {
        dateStr = "---", timeInvite = "18:30", timeStart = "19:00", timeEnd = "22:00",
        instance = "MC", comment = "", details = ""
      }
    }
  };
end

function RaidCalendar:InitOptions()
  local options = {
    name = ADDON_NAME,
    handler = RaidCalendar,
    type = "group",
    args = {
      show = {
        name = L["OPTION_SHOW_CALENDAR"],
        name = L["OPTION_SHOW_CALENDAR_DESC"],
        type = "execute",
        order = 10,
        func = function(info,val)
          RaidCalendarFrame:Show();
          RaidCalendarFrame:UpdateMonth();
        end
      },
      add = {
        name = L["OPTION_ADD_CHARACTER"],
        name = L["OPTION_ADD_CHARACTER_DESC"],
        type = "execute",
        order = 11,
        func = function(info,val)
          if info.input and (strlen(info.input) > 5) then
            local charName = strsub(info.input, 5);
            self:SyncPeerAvailable(charName);
            self:Debug("Synchronizing raids with '"..charName.."'...");
          else
            self:Print(L["OPTION_ADD_CHARACTER_HELP"]);
          end
        end
      },
      debug = {
        name = L["OPTION_DEBUG_NAME"],
        desc = L["OPTION_DEBUG_DESC"],
        type = "toggle",
        order = 100,
        set = function(info,val)
          RaidCalendar.db.char.debug = val;
        end,
        get = function(info) return RaidCalendar.db.char.debug; end
      },
      calendarStartOnMonday = {
        name = L["OPTION_START_ON_MONDAY_NAME"],
        desc = L["OPTION_START_ON_MONDAY_DESC"],
        type = "toggle",
        order = 110,
        set = function(info,val)
          RaidCalendar.db.profile.calendarStartOnMonday = val;
        end,
        get = function(info) return RaidCalendar.db.profile.calendarStartOnMonday; end
      }
    }
  }
  return options;
end

--------------------------------------------------------------------------------
-- Handle synchronisation                                                     --
--------------------------------------------------------------------------------

function RaidCalendar:OnActionLogChanged(event, actions)
  self.actionLog = actions;
  self.queueReparse = self:GetSyncTime() + 0.1;
end

function RaidCalendar:ParseActionLog()
  self:Debug("Parsing peer action log... (len: "..#(self.actionLog)..")");
  -- Parse log
  self.db.factionrealm.raids = {};
  for index, action in ipairs(self.actionLog) do
    self:ParseActionEntry(index, action);
  end
  -- Check unverified raid signups
  local acksSent = false;
  for raidId, raidData in pairs(self.db.factionrealm.raids) do
    if (self:IsOwnRaid(raidData)) then
      local signupAcks = {};
      for charName, signupData in pairs(raidData.signups) do
        if (not signupData.ack) then
          tinsert(signupAcks, charName);
        end
      end
      if #(signupAcks) > 0 then
        self:AddSyncPacket("raidSignupAck", { raidId = raidId, characters = signupAcks });
        return;
      end
    end
  end
  -- Process raid data
  for raidId, raidData in pairs(self.db.factionrealm.raids) do
    raidData.classStats = {};
    for className, classColor in pairs(self.classColors) do
      raidData.classStats[className] = 0;
    end
    raidData.roleStats = {};
    for roleName, roleLabel in pairs(self.roles) do
      raidData.roleStats[roleName] = 0;
    end
    for charName, signupData in pairs(raidData.signups) do
      if (signupData.status == "SIGNED_UP") or (signupData.status == "LATE") then
        if (signupData.class) then
          raidData.classStats[signupData.class] = raidData.classStats[signupData.class] + 1;
        end
        if (signupData.role) then
          raidData.roleStats[signupData.role] = raidData.roleStats[signupData.role] + 1;
        end
      end
    end
  end
  -- Update calendar frame
  RaidCalendarFrame:UpdateMonth();
  self:Debug("Parsing peer action log done!");
end

function RaidCalendar:ParseActionEntry(index, action)
  --self:Debug(timestamp, action.type);
  if (action.type == "raidCreate") then
    -- Insert the raid
    action.data.id = action.id;
    self.db.factionrealm.raids[action.id] = clonetable(action.data);
    self.db.factionrealm.raids[action.id].signedUp = false;
    self.db.factionrealm.raids[action.id].signups = {};
  elseif (action.type == "raidUpdate") then
    local raidId = action.data.id;
    -- Keep signups
    local signedUp = self.db.factionrealm.raids[raidId].signedUp;
    local signups = self.db.factionrealm.raids[raidId].signups;
    -- Update the rest
    self.db.factionrealm.raids[raidId] = clonetable(action.data);
    self.db.factionrealm.raids[raidId].signedUp = signedUp;
    self.db.factionrealm.raids[raidId].signups = signups;
  elseif (action.type == "raidDelete") then
    -- Update the rest
    self.db.factionrealm.raids[action.data.id] = nil;
  elseif (action.type == "raidSignup") then
    local playerName = UnitName("player");
    if (self.db.factionrealm.raids[action.data.raidId] ~= nil) then
      -- Raid exists, add/update signup
      local timeFirst = action.timestamp;
      if (self.db.factionrealm.raids[action.data.raidId].signups[action.data.character]) then
        timeFirst = self.db.factionrealm.raids[action.data.raidId].signups[action.data.character].timeFirst;
      end
      self.db.factionrealm.raids[action.data.raidId].signups[action.data.character] = clonetable(action.data);
      self.db.factionrealm.raids[action.data.raidId].signups[action.data.character].timeFirst = timeFirst;
      self.db.factionrealm.raids[action.data.raidId].signups[action.data.character].timeLast = action.timestamp;
      self.db.factionrealm.raids[action.data.raidId].signups[action.data.character].ack = false;
      self.db.factionrealm.raids[action.data.raidId].signups[action.data.character].ackTime = false;
      if (action.data.character == playerName) then
        self.db.factionrealm.raids[action.data.raidId].signedUp = self.db.factionrealm.raids[action.data.raidId].signups[playerName];
      end
    end
  elseif (action.type == "raidSignupAck") then
    local raid = self.db.factionrealm.raids[action.data.raidId];
    if raid then
      for charIndex, charName in ipairs(action.data.characters) do
        if raid.signups[charName] then
          raid.signups[charName].ack = true;
          raid.signups[charName].ackTime = action.timestamp;
        end
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Handle game events                                                         --
--------------------------------------------------------------------------------

function RaidCalendar:OnEnable()
  self:Debug("ADDON ENABLE");
  -- TODO
end

function RaidCalendar:OnDisable()
  self:Debug("ADDON DISABLE");
  -- TODO
end

--------------------------------------------------------------------------------
-- Debug output                                                               --
--------------------------------------------------------------------------------

function RaidCalendar:OnSyncDebug(event, message)
  self:Debug(message);
end

function RaidCalendar:Debug(...)
  if (self.db.char.debug) then
    local message = "Debug: ";
    local arg = {...};
    for i,v in ipairs(arg) do
      if (type(v) == "table") then
        message = message..self:DebugTable(v, nil, true, 3).." ";
      else
        message = message..tostring(v).." ";
      end
    end
    self:Print(message);
  end
end

function RaidCalendar:DebugTable(val, name, skipnewlines, maxDepth, depth)
    skipnewlines = skipnewlines or false
    maxDepth = maxDepth or 3
    depth = depth or 0
    local tmp = string.rep(" ", depth)
    if name then tmp = tmp .. name .. " = " end
    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
        if (maxDepth > depth) then
          for k, v in pairs(val) do
              tmp =  tmp .. self:DebugTable(v, k, skipnewlines, maxDepth, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
          end
        else
          tmp = tmp .. "max. depth reached: " .. maxDepth .. (not skipnewlines and "\n" or "");
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end
    return tmp
end
