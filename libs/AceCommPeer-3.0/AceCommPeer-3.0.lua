--- **AceCommPeer-3.0** allows peer to peer messaging to spread data between many clients. \\
--
-- **AceCommPeer-3.0** can be embeded into your addon, either explicitly by calling AceCommPeer:Embed(MyAddon) or by
-- specifying it as an embeded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call AceCommPeer itself.\\
-- It is recommended to embed AceCommPeer, otherwise you'll have to specify a custom `self` on all calls you
-- make into AceCommPeer.
-- @class file
-- @name AceCommPeer-3.0
-- @release $Id: AceCommPeer-3.0.lua 1202 2019-10-26 17:35:00Z nevcairiel $

--[[ AceCommPeer-3.0

TODO: Add some todo (that there surely still is ;-) )

]]

local AceComm = LibStub("AceComm-3.0");
local CTL = assert(AceComm, "AceCommPeer-3.0 requires AceComm")

local MAJOR, MINOR = "AceCommPeer-3.0", 1
local AceCommPeer, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceCommPeer then return end

AceCommPeer.embeds = AceCommPeer.embeds or {};

local function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0
    local tmp = string.rep(" ", depth)
    if name then tmp = tmp .. name .. " = " end
    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
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

function AceCommPeer:RegisterSyncChannel(channel)
	if (not tContains(self.syncChannels, channel)) then
		tinsert(self.syncChannels, channel);
		if (channel == "WHISPER") then
	  	self:RegisterEvent("FRIENDLIST_UPDATE", "OnEventCommPeer");
		end
		if (channel == "GUILD") then
	  	self:RegisterEvent("GUILD_ROSTER_UPDATE", "OnEventCommPeer");
		end
	end
end

function AceCommPeer:AddSyncPacket(groupId, type, data, timestamp, expires, source, packetId, sender, suppressUpdate)
  if (self.syncDb.factionrealm.groups[groupId] == nil) then
    -- Group unknown
    return;
  end
  local group = self.syncDb.factionrealm.groups[groupId];

	if (not source) then
    -- Source not supplied, player character by default
		source = self.charName;
		verified = true;
	else
    -- Ensure not accepting packets for own characters
	  for charName, charDetails in pairs(self.syncDb.factionrealm.characters) do
	    if (source == charName) then
	      -- Do not allow receiving own packets from remote sources
	      return;
	    end
	  end
	end
	if (not packetId) then
		-- Generate local packet id
		packetId = self.charName..self.syncDb.char.messageId;
		self.syncDb.char.messageId = self.syncDb.char.messageId + 1;
	end
	if (not timestamp) then
    -- Set current timestamp
		timestamp = self:GetSyncTime();
	end
	if (not expires) then
    -- Expire date not supplied, 1 week by default
		expires = timestamp + 86400 * 7;
	end
	if (not sender) then
    -- Sender not supplied, player character by default
		sender = self.charName;
	end
	local verified = false;
	if (source == sender) then
    -- Automatically set verified if the source is also the sender
		verified = true;
	end
	-- Store in db
	local packet = {
		id = packetId, type = type, timestamp = timestamp, expires = expires,
		data = data, group = groupId, source = source, sender = sender, verified = verified,
		extra = {}
	};
	self.syncDb.factionrealm.groups[groupId].packets[packetId] = packet;
	-- Debug
	self:Debug("Added packet: "..packetId);
	-- Broadcast if own
	if (sender == self.charName) then
	  self:Debug("Broadcasting packet: "..packetId);
		self:SyncBroadcastPackets(groupId, { packetId });
	end
  -- Send update event
  if (not suppressUpdate) then
    self:OnSyncPacketsChanged(groupId);
  end
	-- Return packet id
	return packetId;
end

function AceCommPeer:AddSyncPeer(groupId, peerName)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    -- Group unknown
    return;
  end
  if not tContains(group.peers, peerName) then
    tinsert(group.peers, peerName);
    self:SyncSendGroup(groupId);
  end
end

function AceCommPeer:CreateSyncGroup(title, guild, peers, owner, id, confirmed, enabled, operators)
  -- Owner
  if (owner == nil) then
    -- Create group for the player if not supplied
    owner = self.charName;
    confirmed = true;
  end
  -- Ident
  if (id == nil) then
    -- Automatically generate a new group id
    local idBase = owner..date("%y%d%m");
    local idCounter = 1;
    id = idBase.."-"..idCounter;
    while (self.syncDb.factionrealm.groups[id] ~= nil) do
      idCounter = idCounter + 1;
      id = idBase.."-"..idCounter;
    end
  end
  -- Title
  if (title == nil) then
    title = id;
  end
  -- Peers
  if (peers == nil) then
    peers = {};
    tinsert(peers, owner);
  end
  -- Enabled
  if (enabled == nil) then
    enabled = true;
  end
  -- Operators
  if (operators == nil) then
    operators = {};
    tinsert(operators, owner);
  end
  -- Do not overwrite existing groups
  if (self.syncDb.factionrealm.groups[id] ~= nil) then
    -- Update if from owner
    local group = self.syncDb.factionrealm.groups[id];
    if confirmed and (group.owner == owner) then
      group.confirmed = confirmed;
      group.title = title;
      group.guild = guild;
      group.peers = peers;
      group.operators = operators;
      group.updated = self:GetSyncTime();
    end
    return;
  end
	-- Store in db
  local group = {
    id = id, title = title, owner = owner, guild = guild, enabled = enabled,
    confirmed = confirmed, updated = self:GetSyncTime(),
    packets = {}, peers = peers, operators = operators
  };
  self.syncDb.factionrealm.groups[id] = group;
end

function AceCommPeer:DeleteSyncPeer(groupId, peerName)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    -- Group unknown
    return;
  end
  for index, charName in ipairs(group.peers) do
    if (charName == peerName) then
      tremove(group.peers, index);
      self:SyncSendGroup(groupId);
      return;
    end
  end
end

function AceCommPeer:DeleteSyncGroup(groupId)
  if (self.syncDb.factionrealm.groups[groupId] == nil) then
    return false;
  end
  self.syncDb.factionrealm.groups[groupId] = nil;
  self:OnSyncPacketsChanged();
  return true;
end

function AceCommPeer:GetSyncGroupTitles()
  local groupTitles = {};
  for groupId, group in pairs(self.syncDb.factionrealm.groups) do
    groupTitles[groupId] = group.title;
  end
  return groupTitles;
end

function AceCommPeer:GetSyncGroupList()
  return self.syncDb.factionrealm.groups;
end

function AceCommPeer:GetSyncDbDefaults()
	return {
    char = {
			messageId = 0
    },
    factionrealm = {
			characters = {},
			packets = {},
			config = {},
			peers = {},
      groups = {}
    }
  };
end

function AceCommPeer:GetSyncTime()
  return self.syncTimeStart + GetTime();
end

function AceCommPeer:GetSyncPacketsSorted(groupId)
  local packetsSorted = {};
  if (groupId == nil) then
    -- List all known packets regardless of group
  	for groupId, group in pairs(self.syncDb.factionrealm.groups) do
      if (group.enabled) then
      	for id, packet in pairs(group.packets) do
      		tinsert(packetsSorted, packet);
      	end
      end
    end
  else
    -- List all known packets for a specific group
    if (self.syncDb.factionrealm.groups[groupId] ~= nil) then
    	for id, packet in pairs(self.syncDb.factionrealm.groups[groupId].packets) do
    		tinsert(packetsSorted, packet);
    	end
    end
  end
	-- Sort packets by timestamp
  sort(packetsSorted, function(a, b)
    return a.timestamp < b.timestamp;
  end);
	return packetsSorted;
end

function AceCommPeer:SetSyncGroupEnabled(groupId, enabled)
  if (self.syncDb.factionrealm.groups[groupId] ~= nil) then
    local group = self.syncDb.factionrealm.groups[groupId];
    if (group.enabled ~= enabled) then
      self:Debug(enabled);
      group.enabled = enabled;
      if (enabled) then
        self:SyncGroup(groupId);
        self:OnSyncPacketsChanged(groupId);
      else
        self:OnSyncPacketsChanged();
      end
    end
  end
end

function AceCommPeer:SyncDebug(message)
	self:SendMessage("SYNC_DEBUG", message);
end

function AceCommPeer:SyncCleanup()
  local timeNow = self:GetSyncTime();
  local expiredPackets = {};
  for id, packet in pairs(self.syncDb.factionrealm.packets) do
    if (packet.expires <= timeNow) then
      tinsert(expiredPackets, id);
    end
  end
  if #(expiredPackets) > 0 then
    self:SyncDebug("Deleting "..#(expiredPackets).." expired messages...");
    for index, id in ipairs(expiredPackets) do
      self.syncDb.factionrealm.packets[id] = nil;
    end
  end
end

function AceCommPeer:SyncClearData()
  self.syncDb.factionrealm.packets = {};
end

function AceCommPeer:SyncPeers()
	for index, channel in ipairs(self.syncChannels) do
		if (channel == "WHISPER") then
			-- Whisper peers (friends?)
			for charName, syncPeer in pairs(self.syncDb.factionrealm.peers) do
				if (syncPeer.guild == nil) or (syncPeer.guild ~= self.charDetails.guild) then
          if (self:SyncPeerAvailable(charName)) then
  					self:SyncPeer("WHISPER", charName);
          end
				end
			end
		else
			-- Group peers (guild, raid, etc.)
			self:SyncPeer(channel);
		end
	end
end

function AceCommPeer:SyncGroup(groupId)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    return false;
  end
  -- Prepare message data
  local timeNow = self:GetSyncTime();
  local messageData = { type = "SyncReport", group = groupId, known = {} };
  for id, packet in pairs(group.packets) do
    if (packet.expires > timeNow) then
      tinsert(messageData.known, id);
    end
  end
  self:SyncSendGroup(groupId, messageData);
end

function AceCommPeer:SyncPeer(distribution, target)
  local timeNow = self:GetSyncTime();
  for groupId, group in pairs(self.syncDb.factionrealm.groups) do
    if (self:SyncPeerCheck(group, distribution, target)) then
      local messageData = { type = "SyncReport", group = groupId, known = {} };
      for id, packet in pairs(group.packets) do
        if (packet.expires > timeNow) then
          tinsert(messageData.known, id);
        end
      end
      self:SyncSend(messageData, distribution, target);
    end
  end
end

-- Check if a sync report for the given group should be sent on the given channel
function AceCommPeer:SyncPeerCheck(group, distribution, target)
  if (distribution == "WHISPER") then
    -- Should send sync report to the given peer?
    if tContains(group.peers, target) then
      -- Peer explicitly added
      return true;
    end
    local peer = self.syncDb.factionrealm.peers[target];
    if (peer == nil) then
      -- Peer not known
      return false;
    end
    if not IsInGuild() then
      return false;
    end
    if (group.guild ~= nil) and (peer.guild ~= nil) then
      -- Peer is in the groups guild
      return (peer.guild == group.guild);
    end
    -- Not qualified!
    return false;
  elseif (distribution == "GUILD") then
    -- Should send sync report to guild?
    if not IsInGuild() or (group.guild == nil) then
      -- Not in a guild or no guild group
      return false;
    end
    return (group.guild == self.charDetails.guild);
  end
end

function AceCommPeer:SyncPeerAdd(charName, distribution, online)
  if (online == nil) then
    online = false;
  end
	if self.syncDb.factionrealm.peers[charName] then
		self.syncDb.factionrealm.peers[charName].online = online;
		self.syncDb.factionrealm.peers[charName].updated = self:GetSyncTime();
	else
    self.syncDb.factionrealm.peers[charName] = {
      friend = false, guild = false, online = online, updated = self:GetSyncTime()
    };
	end
	if (distribution == "GUILD") then
		self.syncDb.factionrealm.peers[charName].guild = GetGuildInfo("player");
	end
end

function AceCommPeer:SyncPeerAvailable(charName)
	if self.syncDb.factionrealm.peers[charName] then
    local syncPeer = self.syncDb.factionrealm.peers[charName];
    local peerUpdate = self:GetSyncTime() - 300; -- Allow update once every 5min
    -- Do not update guild/friend peers via whisper
    if ((syncPeer.guild == nil) or (syncPeer.guild ~= self.charDetails.guild))
      and not syncPeer.friend then
      -- Update every 5min max!
      if (syncPeer.updated == false) or (syncPeer.updated < peerUpdate) then
        self:Debug("Peer "..charName.." updated", (peerUpdate - syncPeer.updated));
        local messageData = { type = "SyncPing", time = self:GetSyncTime() };
        self:SyncSend(messageData, "WHISPER", charName);
      end
    end
  else
		self.syncDb.factionrealm.peers[charName] = {
			friend = false, guild = false, online = false, updated = false
		};
    -- Send ping to check if player is online
    local messageData = { type = "SyncPing", time = self:GetSyncTime() };
    self:SyncSend(messageData, "WHISPER", charName);
	end
	return self.syncDb.factionrealm.peers[charName].online;
end

function AceCommPeer:SyncSend(messageData, distribution, target)
  -- Serialize and send
  local message = self:Serialize(messageData);
  self:SendCommMessage(self.syncCommName, message, distribution, target);
  -- Debugging
  if (target == nil) then
    target = "nil";
  end
	self:SyncDebug(messageData.type.." @ "..distribution.." / "..target..": "..serializeTable(messageData, "data", true));
end

function AceCommPeer:SyncSendGroup(groupId, messageData, distribution, target)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    -- Group not known!
    return;
  end
  if (messageData == nil) then
    -- Send group data by default if no message data was given
    messageData = { type = "SyncData", group = groupId, groupData = {
      title = group.title, guild = group.guild, peers = group.peers,
      owner = group.owner, operators = group.operators
    } };
  end
  if (distribution == nil) then
    -- Target not supplied, send to all peers within the given group
    self:SyncSendGroup(groupId, messageData, "GUILD");
    for index, charName in ipairs(group.peers) do
      local syncPeer = self.syncDb.factionrealm.peers[charName];
      if (syncPeer ~= nil) and (syncPeer.guild ~= self.charDetails.guild) then
        if (self:SyncPeerAvailable(charName)) then
          self:SyncSendGroup(groupId, messageData, "WHISPER", charName);
        end
      end
    end
    return;
  end
  -- Permission check
  if not self:SyncPeerCheck(group, distribution, target) then
    -- Target not qualified to receive packets from this group
    self:Debug("Not qualified to receive information about group '"..groupId.."': "..distribution, target);
    return;
  end
  -- Send message
  self:SyncSend(messageData, distribution, target);
end

function AceCommPeer:SyncRequestPackets(groupId, ids, distribution, target)
  local messageData = { type = "SyncRequest", group = groupId, packetIds = ids };
  self:SyncSend(messageData, distribution, target);
end

function AceCommPeer:SyncRequestGroup(groupId, distribution, target)
  local messageData = { type = "SyncRequest", group = groupId };
  self:SyncSend(messageData, distribution, target);
end

function AceCommPeer:SyncBroadcastPackets(groupId, ids)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    -- Group not known!
    return;
  end
	for index, channel in ipairs(self.syncChannels) do
		if (channel == "WHISPER") then
			-- Whisper peers (friends?)
			for index, charName in ipairs(group.peers) do
        local syncPeer = self.syncDb.factionrealm.peers[charName];
				if (syncPeer.guild == nil) or (syncPeer.guild ~= self.charDetails.guild) then
          if (self:SyncPeerAvailable(charName)) then
            self:SyncSendPackets(groupId, ids, "WHISPER", charName);
          end
				end
			end
		else
			-- Group peers (guild, raid, etc.)
			self:SyncSendPackets(groupId, ids, "GUILD");
		end
	end
end

function AceCommPeer:SyncSendPackets(groupId, ids, distribution, target)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    -- Group not known!
    return;
  end
  -- Send packets to peer
  local messageData = { type = "SyncData", group = groupId, packets = {} };
  for index, id in ipairs(ids) do
    messageData.packets[id] = group.packets[id];
  end
  self:SyncSendGroup(groupId, messageData, distribution, target);
end

function AceCommPeer:SyncConfirm(groupId, id, packet)
  local messageData = { type = "SyncConfirm", group = groupId, id = id, data = packet.data };
  self:SyncSendGroup(groupId, messageData, "WHISPER", packet.source);
end

function AceCommPeer:SyncUpdateVerification(groupId, id)
  local group = self.syncDb.factionrealm.groups[groupId];
  if (group == nil) then
    -- Group not known!
    return;
  end
  local packet = group.packets[id];
  if (not packet) then
    -- Packet not known!
    return;
  end
  if (packet.verified) then
    return;
  end
  if (self:SyncPeerAvailable(packet.source)) then
    self:SyncConfirm(groupId, id, packet);
  end
end

--------------------------------------------------------------------------------
-- Handle comm events                                                         --
--------------------------------------------------------------------------------
function AceCommPeer:OnCommReceivedPeer(prefix, message, distribution, sender)
  if (prefix == self.syncCommName) then
    local valid, messageData = self:Deserialize(message);
    if (not valid) then
	  	self:SyncDebug("OnCommReceived invalid @ "..distribution.." / "..sender..": "..serializeTable(messageData, "data", true));
      return;
    end
  	self:SyncDebug(messageData.type.." @ "..distribution.." / "..sender..": "..serializeTable(messageData, "data", true));
    self:SyncPeerAdd(sender, distribution, true);
    if (messageData.type == "SyncReport") then
      local groupId = messageData.group;
      local group = self.syncDb.factionrealm.groups[groupId];
      if (group ~= nil) then
        if (group.owner == sender) then
          local groupUpdate = self:GetSyncTime() - 3600; -- Allow update once an hour
          if not group.confirmed or (group.updated < groupUpdate) then
            -- Group not confirmed (or update is due) - request from owner
            self:SyncRequestGroup(groupId, "WHISPER", sender);
          end
        end
        -- Sync packets
        local timeNow = self:GetSyncTime();
        local packetsKnownLocal = {};
        local packetsMissingLocal = {};
        local packetsMissingRemote = {};
        for id, packet in pairs(group.packets) do
          if (packet.expires > timeNow) then
            tinsert(packetsKnownLocal, id);
            if not tContains(messageData.known, id) then
              tinsert(packetsMissingRemote, id);
              if (#(packetsMissingRemote) >= self.syncMaxPacketsPerRequest) then
                -- Limit max packet per reply to a reasonable number
                break;
              end
            end
          end
        end
        for index, id in ipairs(messageData.known) do
          if not tContains(packetsKnownLocal, id) then
            tinsert(packetsMissingLocal, id);
          end
        end
        if #(packetsMissingLocal) > 0 then
          self:SyncDebug("Sending "..#(packetsMissingLocal).." Sync-Packets to "..sender.." (Group: "..groupId..")");
          -- Request missing actions from peer
          self:SyncRequestPackets(groupId, packetsMissingLocal, "WHISPER", sender);
        end
        if #(packetsMissingRemote) > 0 then
          self:SyncDebug("Requesting "..#(packetsMissingLocal).." Sync-Packets from "..sender.." (Group: "..groupId..")");
          -- Send missing actions to peer
          self:SyncSendPackets(groupId, packetsMissingRemote, "WHISPER", sender);
        end
      else
        -- Group unknown, request from sender
        self:SyncRequestGroup(groupId, "WHISPER", sender);
      end
    elseif (messageData.type == "SyncRequest") then
      local group = self.syncDb.factionrealm.groups[messageData.group];
      if (group ~= nil) and (group.owner == self.charName) then
          if self:SyncPeerCheck(group, "WHISPER", sender) then
            self:AddSyncPeer(messageData.group, sender);
          end
      end
      if (messageData.packetIds ~= nil) then
        -- Send requested messages
        self:SyncSendPackets(messageData.group, messageData.packetIds, sender);
      else
        if (group ~= nil) and (group.owner == sender) then
          -- Group is not known to owner, delete it!
          self:DeleteSyncGroup(messageData.group);
        else
          -- Group is not known to player, send the group details!
          self:SyncSendGroup(messageData.group, nil, "WHISPER", sender);
        end
      end
    elseif (messageData.type == "SyncData") then
      local group = self.syncDb.factionrealm.groups[messageData.group];
      if (group ~= nil) and (messageData.packets ~= nil) then
  			local newPackets = false;
        for id, packet in pairs(messageData.packets) do
          if (group.packets[id] == nil) then
            self:AddSyncPacket(messageData.group, packet.type, packet.data, packet.timestamp, packet.expires, packet.source, id, sender, true);
  					newPackets = true;
          end
        end
  			if (newPackets) then
  				self:OnSyncPacketsChanged(messageData.group);
  			end
      end
      if (messageData.groupData ~= nil) then
        if (messageData.groupData.owner == self.charName) then
          -- Do not allow faking groups
          return;
        end
        local groupConfirmed = (sender == messageData.groupData.owner);
        self:CreateSyncGroup(
          messageData.groupData.title, messageData.groupData.guild,
          messageData.groupData.peers, messageData.groupData.owner,
          messageData.group, groupConfirmed, false, messageData.groupData.operators
        );
      end
    elseif (messageData.type == "SyncConfirm") then
      local group = self.syncDb.factionrealm.groups[messageData.group];
      if (group ~= nil) then
  		  local packet = group.packets[messageData.id];
  		  if (self:Serialize(packet.data) == self:Serialize(messageData.data)) then
  		    local messageData = { type = "SyncAck", group = messageData.group, id = messageData.id };
  		    self:SyncSend(messageData, "WHISPER", sender);
  		  end
      end
    elseif (messageData.type == "SyncAck") then
      local group = self.syncDb.factionrealm.groups[messageData.group];
      if (group ~= nil) then
  		  local packet = group.packets[messageData.id];
  			if (packet and packet.source == sender) then
  				packet.verified = true;
  			end
      end
    elseif (messageData.type == "SyncPing") then
      self:SyncSend({ type = "SyncPong", time = self:GetSyncTime() }, "WHISPER", sender);
    elseif (messageData.type == "SyncPong") then
      self:SyncPeerAdd(sender, distribution, true);
    end
  end
end

function AceCommPeer:OnSyncPacketsChanged()
	self:SendMessage("SYNC_PACKETS_CHANGED", self:GetSyncPacketsSorted());
end

--------------------------------------------------------------------------------
-- Handle game events                                                         --
--------------------------------------------------------------------------------
function AceCommPeer:OnEventCommPeer(eventName, ...)
  if (eventName == "PLAYER_ENTERING_WORLD") then
    self.charName = UnitName("player");
    -- Cleanup expired packages
    self:SyncCleanup();
    -- Update local character list
    if (self.syncDb.factionrealm.characters[self.charName] == nil) then
      self.charDetails = {
        name = charName, level = 0, class = ""
      };
      self.syncDb.factionrealm.characters[self.charName] = self.charDetails;
    else
      self.charDetails = self.syncDb.factionrealm.characters[self.charName];
    end
    local charLevel = UnitLevel("player");
    local className, classFilename, classID = UnitClass("player");
    local guildName, guildRankName, guildRankIndex, realm = GetGuildInfo("player");
    self.charDetails.level = charLevel;
    self.charDetails.class = classFilename;
    self.charDetails.guild = guildName;
  end
  if (eventName == "PLAYER_ENTERING_WORLD") or (eventName == "GUILD_ROSTER_UPDATE") then
		-- Update guild members online
    local guildName = GetGuildInfo("player");
    if (guildName ~= nil) then
  		for guildIndex = 1, GetNumGuildMembers() do
  			local charNameFull, rankName, rankIndex, level, classDisplayName,
  				zone, publicNote, officerNote, isOnline, status, class = GetGuildRosterInfo(guildIndex);
        local charName = strsub(charNameFull, 1, strfind(charNameFull, "-") - 1); -- Remove realm from name
  			if (self.syncDb.factionrealm.peers[charName]) then
          --self:Debug("Guild peer update: "..charName);
  				self.syncDb.factionrealm.peers[charName].online = isOnline;
  				self.syncDb.factionrealm.peers[charName].guild = guildName;
          self.syncDb.factionrealm.peers[charName].updated = self:GetSyncTime();
  			end
  		end
    end
  end
  if (eventName == "PLAYER_ENTERING_WORLD") or (eventName == "FRIENDLIST_UPDATE") then
		-- Update friends online
		for friendIndex = 1, C_FriendList.GetNumFriends() do
			local friend = C_FriendList.GetFriendInfoByIndex(friendIndex);
			if (self.syncDb.factionrealm.peers[friend.name]) then
        --self:Debug("Friend peer update: "..friend.name);
				self.syncDb.factionrealm.peers[friend.name].online = friend.connected;
				self.syncDb.factionrealm.peers[friend.name].friend = true;
        self.syncDb.factionrealm.peers[friend.name].updated = self:GetSyncTime();
			end
		end
  end
  if (eventName == "PLAYER_ENTERING_WORLD") then
    -- Update sync peers (that are not covered by guild / friends list)
    self:SyncPeers();
  end
end

----------------------------------------
-- Base library stuff
----------------------------------------

local mixins = {
	"AddSyncPacket",
  "AddSyncPeer",
  "CreateSyncGroup",
  "DeleteSyncPeer",
  "DeleteSyncGroup",
	"GetSyncDbDefaults",
	"GetSyncTime",
	"GetSyncPacketsSorted",
  "GetSyncGroupTitles",
  "GetSyncGroupList",
  "SetSyncGroupEnabled",
	"SyncDebug",
  "SyncCleanup",
  "SyncClearData",
	"SyncSend",
	"SyncConfirm",
  "SyncGroup",
	"SyncPeer",
	"SyncPeers",
	"SyncPeerAdd",
	"SyncPeerAvailable",
  "SyncPeerCheck",
	"SyncBroadcastPackets",
	"SyncSendPackets",
  "SyncSendGroup",
  "SyncRequestPackets",
  "SyncRequestGroup",
	"OnSyncPacketsChanged",
	"OnEventCommPeer",
	"OnCommReceivedPeer",
	"RegisterSyncChannel"
};

-- Embeds AceComm-3.0 into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceComm-3.0 in
function AceCommPeer:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	if (not target.syncCommName) then
		target.syncCommName = target.name.."Peer";
	end
	target.syncDb = LibStub("AceDB-3.0"):New(target.name.."PeerSync", target:GetSyncDbDefaults());
	target.syncChannels = {};
  target.syncTimeStart = GetServerTime() - GetTime();
  target.syncMaxPacketsPerRequest = 50;
  -- EVENTS
  target:RegisterComm(target.syncCommName, "OnCommReceivedPeer")
  target:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEventCommPeer");
	self.embeds[target] = true;
	return target;
end

function AceCommPeer:OnEmbedDisable(target)
	target:UnregisterAllCommPeer();
end

-- Update embeds
for target, v in pairs(AceCommPeer.embeds) do
	AceCommPeer:Embed(target)
end
