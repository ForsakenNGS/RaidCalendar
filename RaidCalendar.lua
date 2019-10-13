local ADDON_NAME = "RaidCalendar";
local ADDON_DB_NAME = "RaidCalendarDB";

RaidCalendar = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

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

local function orderednext(t, n)
   local key = t[t.__next]
   if not key then return end
   t.__next = t.__next + 1
   return key, t.__source[key]
end

local function orderedpairs(t, f)
   local keys, kn = {__source = t, __next = 1}, 1
   for k in pairs(t) do
     keys[kn], kn = k, kn + 1;
   end
   sort(keys, f)
   return orderednext, keys
end

local function orderedtable(t, f)
  local tNew = {};
  for k, v in orderedpairs(t, f) do
    tNew[k] = v;
  end
  return tNew;
end

function RaidCalendar:OnInitialize()
  -- DATABASE / STORAGE
  self.db = LibStub("AceDB-3.0"):New(ADDON_DB_NAME, self:GetDefaultOptions());
  self.frames = {};
  self.syncPeers = {
    guild = {}, players = {}
  };
  self.timeStart = GetServerTime() - GetTime();
  self:Debug("ADDON INIT");
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
  self:RegisterComm(ADDON_NAME, "OnCommReceived")
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent");
  self:RegisterEvent("GUILD_ROSTER_UPDATE", "OnEvent");
  -- QUEUED Actions
  self.queueSyncPeerUpdate = false;
  self.queueReparse = true;
  self.queueChatReport = true;
  self.queueStartup = true;
  self.queueFrame = CreateFrame("Frame");
  self.queueFrame:SetScript("OnUpdate", function()
    RaidCalendar:QueueUpdate();
  end);
end

function RaidCalendar:QueueUpdate()
  if (self.queueSyncPeerUpdate) then
    -- Update sync peers
    self.queueSyncPeerUpdate = false;
    self:UpdateSyncPeers(true);
    return;
  elseif (self.queueReparse) then
    -- Re-Parse log
    self.queueReparse = false;
    self:ParseActionLog();
    return;
  elseif (self.queueChatReport) then
    self.queueChatReport = false;
    local raidsNotSignedUp = 0;
    for raidId, raidData in orderedpairs(self.db.factionrealm.raids) do
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

function RaidCalendar:CanEditRaids()
  return true;
  --return CanEditMOTD();
end

function RaidCalendar:GetTime()
  return self.timeStart + GetTime();
end

--------------------------------------------------------------------------------
-- Handle addon events                                                         --
--------------------------------------------------------------------------------
function RaidCalendar:OnCommReceived(prefix, message, distribution, sender)
  if (prefix == ADDON_NAME) then
    local valid, package = self:Deserialize(message);
    if (not valid) then
      self:Debug("OnCommReceived @ "..prefix.." / "..message);
      return;
    end
    if (package.type == "SyncReport") then
      local actionsKnownLocal = {};
      local actionsMissingLocal = {};
      local actionsMissingRemote = {};
      for timestamp, action in orderedpairs(self.db.factionrealm.actionLog) do
        tinsert(actionsKnownLocal, timestamp);
        if not tContains(package.known, timestamp) then
          tinsert(actionsMissingRemote, timestamp);
        end
      end
      for index, timestamp in ipairs(package.known) do
        if not tContains(actionsKnownLocal, timestamp) then
          tinsert(actionsMissingLocal, timestamp);
        end
      end
      if #(actionsMissingLocal) > 0 then
        -- Request missing actions from peer
        self:SyncRequestActions(actionsMissingLocal, sender);
      end
      if #(actionsMissingRemote) > 0 then
        -- Send missing actions to peer
        self:SyncSendActions(actionsMissingRemote, sender);
      end
    elseif (package.type == "SyncRequest") then
      self:SyncSendActions(package.actions, sender);
    elseif (package.type == "SyncData") then
      for timestamp, action in orderedpairs(package.actions) do
        if (self.db.factionrealm.actionLog[timestamp] == nil) then
          self:AddActionRemote(timestamp, action, sender);
        end
      end
      self.queueReparse = true;
    elseif (package.type == "SyncConfirm") then
      self:SyncSend({ type = "SyncAck", timetamp = package.timestamp }, "WHISPER", sender);
    elseif (package.type == "SyncPing") then
      self:SyncSend({ type = "SyncPong", time = self:GetTime() }, "WHISPER", sender);
    elseif (package.type == "SyncPong") then
      self:AddSyncPeer(sender, distribution);
    end
  end
end

function RaidCalendar:SyncSend(package, distribution, target)
  -- Validate
  if not package.type then
    self:Debug("Invalid package! (no type specified)");
    return;
  end
  -- Serialize and send
  local message = self:Serialize(package);
  self:SendCommMessage(ADDON_NAME, message, distribution, target);
  -- Debugging
  if (target == nil) then
    target = "nil";
  end
  self:Debug(package.type.." @ "..distribution.." / "..target..": "..message);
end

function RaidCalendar:SyncReport(distribution, target)
  local package = { type = "SyncReport", known = {} };
  for timestamp, action in orderedpairs(self.db.factionrealm.actionLog) do
    tinsert(package.known, timestamp);
  end
  self:SyncSend(package, distribution, target);
end

function RaidCalendar:SyncBroadcast(timestamp, distribution, target)
  local package = { type = "SyncData", actions = {} };
  package.actions[timestamp] = self.db.factionrealm.actionLog[timestamp];
  self:SyncSend(package, distribution, target);
end

function RaidCalendar:SyncRequestActions(missingActions, user)
  local package = { type = "SyncRequest", actions = missingActions };
  self:SyncSend(package, "WHISPER", user);
end

function RaidCalendar:SyncSendActions(missingActions, user)
  local package = { type = "SyncData", actions = {} };
  for index, timestamp in ipairs(missingActions) do
    package.actions[timestamp] = self.db.factionrealm.actionLog[timestamp];
  end
  self:SyncSend(package, "WHISPER", user);
end

function RaidCalendar:SyncConfirm(timestamp, action)
  local knownAction = self.db.factionrealm.actionLog[timestamp];
  if (self:Serialize(action.data) == self:Serialize(knownAction.data)) then
    local package = { type = "SyncConfirm", action = action, timestamp = timestamp };
    self:SyncSend(package, "WHISPER", action.character);
  end
end

function RaidCalendar:AddSyncPeer(charName, distribution)
  if self.syncPeers.guild[charName] then
    self.syncPeers.guild[charName].online = true;
    return;
  end
  if self.syncPeers.players[charName] then
    self.syncPeers.players[charName].online = true;
    return;
  end
  if (distribution == "GUILD") then
    -- Unknown guild player - force update now!
    self.queueSyncPeerUpdate = true;
    return;
  end
  -- New non-guild player
  self.syncPeers.players[charName] = {
    online = true
  };
end

function RaidCalendar:IsSyncPeerAvailable(charName)
  if self.syncPeers.guild[charName] then
    return self.syncPeers.guild[charName].online;
  end
  if self.syncPeers.players[charName] then
    return self.syncPeers.players[charName].online;
  end
  -- Check if online
  self.syncPeers.players[charName] = {
    online = false
  };
  self:SyncSend({ type = "SyncPing", time = self:GetTime() }, "WHISPER", charName);
  return false;
end

function RaidCalendar:UpdateSyncPeers(force)
  local timeNow = self:GetTime();
  local updateInterval = 300;
  local lastUpdate = self.syncPeers.lastUpdate;
  if force or not lastUpdate or (timeNow - lastUpdate) >= updateInterval then
    self.syncPeers.lastUpdate = timeNow;
    self.syncPeers.guild = {};
    -- Update guild members online
    for guildIndex = 1, GetNumGuildMembers() do
      local name, rankName, rankIndex, level, classDisplayName,
        zone, publicNote, officerNote, isOnline, status, class = GetGuildRosterInfo(guildIndex);
      if (isOnline) then
        -- Player is online
        local charName, realm = strsplit("-", name);
        self.syncPeers.guild[charName] = {
          online = true, rankIndex = rankIndex, level = level, class = class
        };
      elseif self.syncPeers.guild[charName] then
        -- Player no longer online
        self.syncPeers.guild[charName].online = false;
      end
    end
    -- Update players
    self:Debug("Updated Sync-Peers");
  end
end

--------------------------------------------------------------------------------
-- Handle game events                                                         --
--------------------------------------------------------------------------------
function RaidCalendar:OnEvent(eventName, ...)
  if (eventName == "PLAYER_ENTERING_WORLD") then
    local charName = UnitName("player");
    if (self.db.factionrealm.characters[charName] == nil) then
      self.db.factionrealm.characters[charName] = {
        name = charName, level = 0, class = ""
      };
    end
    local charLevel = UnitLevel("player");
    local className, classFilename, classID = UnitClass("player");
    self.db.factionrealm.characters[charName].level = charLevel;
    self.db.factionrealm.characters[charName].class = classFilename;
    self:SyncReport("GUILD");
  end
  if (eventName == "GUILD_ROSTER_UPDATE") then
    self.queueSyncPeerUpdate = true;
  end
end

function RaidCalendar:OnEnable()
  self:Debug("ADDON ENABLE");
  -- TODO
end

function RaidCalendar:OnDisable()
  self:Debug("ADDON DISABLE");
  -- TODO
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

function RaidCalendar:Debug(...)
  if (self.db.char.debug) then
    local message = "Debug: ";
    local arg = {...};
    for i,v in ipairs(arg) do
      message = message..tostring(v).." ";
    end
    self:Print(message);
  end
end

function RaidCalendar:AddAction(timestamp, action, character)
  if (not character) then
    character = UnitName("player");
  end
  self.db.factionrealm.actionLog[timestamp] = action;
  self.db.factionrealm.actionLog[timestamp].character = character;
  self.db.factionrealm.actionLog[timestamp].source = character;
  self.db.factionrealm.actionLog[timestamp].confirmed = false;
  -- Update confirmation
  self:UpdateActionConfirmation(timestamp);
end

function RaidCalendar:AddActionRemote(timestamp, action, source)
  for charName, charDetails in pairs(RaidCalendar.db.factionrealm.characters) do
    if (action.character == charName) then
      -- Ignore own actions
      return;
    end
  end
  self.db.factionrealm.actionLog[timestamp] = action;
  self.db.factionrealm.actionLog[timestamp].source = source;
  self.db.factionrealm.actionLog[timestamp].confirmed = false;
  -- Update confirmation
  self:UpdateActionConfirmation(timestamp);
end

function RaidCalendar:AddRaid(dateStr, createdBy, timeInvite, timeStart, timeEnd, instance, comment, details)
  local id = floor(self:GetTime() * 1000);
  local timestamp = self:GetTime();
  self:AddAction(timestamp, { type = "raidCreate", id = id, data = {
    dateStr = dateStr, createdBy = createdBy,
    timeInvite = timeInvite, timeStart = timeStart, timeEnd = timeEnd,
    instance = instance, comment = comment, details = details
  } });
  self:SyncBroadcast(timestamp, "GUILD");
  self.queueReparse = true;
  return id;
end

function RaidCalendar:UpdateActionConfirmation(timestamp)
  local action = self.db.factionrealm.actionLog[timestamp];
  if (not action) then
    return;
  end
  if (action.confirmed) then
    return;
  end
  if (action.character == action.source) then
    action.confirmed = true;
    return;
  end
  if (self:IsSyncPeerAvailable(action.character)) then
    self:SyncConfirm(timestamp, action);
  end
end

function RaidCalendar:UpdateRaid(id, dateStr, createdBy, timeInvite, timeStart, timeEnd, instance, comment, details)
  local timestamp = self:GetTime();
  self:AddAction(timestamp, { type = "raidUpdate", id = id, data = {
    dateStr = dateStr, createdBy = createdBy,
    timeInvite = timeInvite, timeStart = timeStart, timeEnd = timeEnd,
    instance = instance, comment = comment, details = details
  } });
  self:SyncBroadcast(timestamp, "GUILD");
  self.queueReparse = true;
  return true;
end

function RaidCalendar:DeleteRaid(id)
  local timestamp = self:GetTime();
  self:AddAction(timestamp, { type = "raidDelete", id = id });
  self:SyncBroadcast(timestamp, "GUILD");
  self.queueReparse = true;
  return true;
end

function RaidCalendar:Signup(raidId, status, character, level, class, role, notes)
  local timestamp = self:GetTime();
  self:AddAction(timestamp, { type = "raidSignup", id = raidId, data = {
    status = status, notes = notes,
    character = character, level = level, class = class, role = role
  } });
  self:SyncBroadcast(timestamp, "GUILD");
  self.queueReparse = true;
  return true;
end

function RaidCalendar:GetRaids(dateStr)
  local raidList = {};
  for raidId, raidData in orderedpairs(self.db.factionrealm.raids) do
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
    return a.ackTime < b.ackTime;
  end);
  return signupsSorted;
end

function RaidCalendar:ParseActionLog()
  -- Order log
  self.db.factionrealm.actionLog = orderedtable(self.db.factionrealm.actionLog)
  -- Parse log
  self.db.factionrealm.raids = {};
  for timestamp, action in orderedpairs(self.db.factionrealm.actionLog) do
    self:ParseActionEntry(timestamp, action);
  end
  -- Check unverified raid signups
  local acksSent = false;
  for raidId, raidData in orderedpairs(self.db.factionrealm.raids) do
    if (self:IsOwnRaid(raidData)) then
      local signupAcks = {};
      for charName, signupData in orderedpairs(raidData.signups) do
        if (not signupData.ack) then
          tinsert(signupAcks, charName);
        end
      end
      if #(signupAcks) > 0 then
        local timestamp = self:GetTime();
        if (not self.db.factionrealm.actionLog[timestamp]) then
          self:AddAction(timestamp, { type = "raidSignupAck", id = raidId, characters = signupAcks });
          self:SyncBroadcast(timestamp, "GUILD");
        end
        self.queueReparse = true;
        return;
      end
    end
  end
  -- Process raid data
  for raidId, raidData in orderedpairs(self.db.factionrealm.raids) do
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
end

function RaidCalendar:IsOwnRaid(raidData)
  for charName, charDetails in pairs(RaidCalendar.db.factionrealm.characters) do
    if (raidData.createdBy == charName) then
      return true;
    end
  end
  return false;
end

function RaidCalendar:ParseActionEntry(timestamp, action)
  --self:Debug(timestamp, action.type);
  if (action.type == "raidCreate") then
    -- Insert the raid
    action.data.id = action.id;
    self.db.factionrealm.raids[action.id] = clonetable(action.data);
    self.db.factionrealm.raids[action.id].signedUp = false;
    self.db.factionrealm.raids[action.id].signups = {};
  elseif (action.type == "raidUpdate") then
    action.data.id = action.id;
    -- Keep signups
    local signedUp = self.db.factionrealm.raids[action.id].signedUp;
    local signups = self.db.factionrealm.raids[action.id].signups;
    -- Update the rest
    self.db.factionrealm.raids[action.id] = clonetable(action.data);
    self.db.factionrealm.raids[action.id].signedUp = signedUp;
    self.db.factionrealm.raids[action.id].signups = signups;
  elseif (action.type == "raidDelete") then
    -- Update the rest
    self.db.factionrealm.raids[action.id] = nil;
  elseif (action.type == "raidSignup") then
    local playerName = UnitName("player");
    if (self.db.factionrealm.raids[action.id] ~= nil) then
      -- Raid exists, add/update signup
      self.db.factionrealm.raids[action.id].signups[action.data.character] = clonetable(action.data);
      self.db.factionrealm.raids[action.id].signups[action.data.character].ack = false;
      if (action.data.character == playerName) then
        self.db.factionrealm.raids[action.id].signedUp = self.db.factionrealm.raids[action.id].signups[action.data.character];
      end
    end
  elseif (action.type == "raidSignupAck") then
    local raid = self.db.factionrealm.raids[action.id];
    if raid then
      for charIndex, charName in ipairs(action.characters) do
        if raid.signups[charName] then
          raid.signups[charName].ack = true;
          raid.signups[charName].ackTime = timestamp;
        end
      end
    end
  end
end

function RaidCalendar:GetDefaultOptions()
  return {
    char = {
      debug = true
    },
    factionrealm = {
      characters = {},
      actionLog = {},
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
      debug = {
        name = L["OPTION_DEBUG_NAME"],
        desc = L["OPTION_DEBUG_DESC"],
        type = "toggle",
        order = 100,
        set = function(info,val)
          RaidCalendar.db.char.debug = val;
        end,
        get = function(info) return RaidCalendar.db.char.debug; end
      }
    }
  }
  return options;
end
