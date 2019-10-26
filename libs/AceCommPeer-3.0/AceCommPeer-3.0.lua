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

TODO: Add some todo's (that definitly exist ;-) )

]]

local AceComm = LibStub("AceComm-3.0");
local CTL = assert(AceComm, "AceCommPeer-3.0 requires AceComm")

local MAJOR, MINOR = "AceCommPeer-3.0", 1
local AceCommPeer, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceCommPeer then return end

AceCommPeer.embeds = AceCommPeer.embeds or {};

function AceCommPeer:RegisterChannel(channel)
	if (not tContains(AceCommPeer.syncChannels, channel)) then
		tinsert(self.syncChannels, channel);
		self.syncPeers[channel] = {};
		if (channel == "GUILD") then
	  	self:RegisterEvent("GUILD_ROSTER_UPDATE", "OnEventCommPeer");
		end
	end
end

function AceCommPeer:AddSyncPacket(type, data, timestamp, expires, source, packetId, sender)
	local charName = UnitName("player");
	if (not source) then
		source = charName;
		verified = true;
		timestamp = self:GetSyncTime();
	else
	  for charName, charDetails in pairs(self.syncDb.factionrealm.characters) do
	    if (source == charName) then
	      -- Do not allow receiving own packets from remote sources
	      return;
	    end
	  end
	end
	if (not packetId) then
		-- Generate local packet id
		packetId = charName..self.syncDb.char.messageId;
		self.syncDb.char.messageId = self.syncDb.char.messageId + 1;
	end
	if (not timestamp) then
		timestamp = self:GetSyncTime();
	end
	if (not expires) then
		expires = timestamp + 86400 * 7; -- 1 week by default
	end
	if (not sender) then
		sender = charName;
	end
	local verified = false;
	if (source == sender) then
		verified = true;
	end
	-- Store in db
	local packet = {
		id = packetId, type = type, timestamp = timestamp, expires = expires,
		data = data, source = source, sender = sender, verified = verified,
		extra = {}
	};
	self.syncDb.factionrealm.packets[packetId] = packet;
	self:Print("Added packet: "..packetId);
	self:Print("Next id: "..self.syncDb.char.messageId);
	return packetId;
end

function AceCommPeer:GetSyncDbDefaults()
	return {
    char = {
			messageId = 0
    },
    factionrealm = {
			characters = {},
			packets = {},
			config = {}
    }
  };
end

function AceCommPeer:GetSyncTime()
  return self.syncTimeStart + GetTime();
end

function AceCommPeer:GetSyncPacketsSorted()
	-- Sort packets by timestamp
	local packetsSorted = {};
	for id, packet in pairs(self.syncDb.factionrealm.packets) do
		tinsert(packetsSorted, packet);
	end
  sort(packetsSorted, function(a, b)
    return a.timestamp < b.timestamp;
  end);
	return packetsSorted;
end

function AceCommPeer:SyncPeers()
	for index, channel in ipairs(self.syncChannels) do
		if (channel == "WHISPER") then
			-- Whisper peers (friends?)
			--TODO self:SyncPeer(channel, charName);
		else
			-- Group peers (guild, raid, etc.)
			self:SyncPeer(channel);
		end
	end
end

function AceCommPeer:SyncPeer(distribution, target)
  local messageData = { type = "SyncReport", known = {} };
  for id, packet in orderedpairs(self.syncDb.factionrealm.packets) do
    tinsert(messageData.known, id);
  end
  self:SyncSend(messageData, distribution, target);
end

function AceCommPeer:SyncSend(messageData, distribution, target)
  -- Serialize and send
  local message = self:Serialize(messageData);
  self:SendCommMessage(self.syncCommName, message, distribution, target);
  -- Debugging
  if (target == nil) then
    target = "nil";
  end
  self:Debug(messageData.type.." @ "..distribution.." / "..target..": "..message);
end

function AceCommPeer:SyncRequestPackets(ids, distribution, target)
  local messageData = { type = "SyncRequest", packetIds = ids };
  self:SyncSend(messageData, "WHISPER", target);
end

function AceCommPeer:SyncSendPackets(ids, distribution, target)
  local messageData = { type = "SyncData", packets = {} };
  for index, id in ipairs(ids) do
    messageData.packets[id] = self.syncDb.factionrealm.packets[id];
  end
  self:SyncSend(messageData, "WHISPER", target);
end

function AceCommPeer:SyncConfirm(id, packet)
  local messageData = { type = "SyncConfirm", id = id, data = packet.data };
  self:SyncSend(messageData, "WHISPER", packet.source);
end

function AceCommPeer:SyncUpdateVerification(id)
  local packet = self.db.factionrealm.packets[id];
  if (not packet) then
    return;
  end
  if (packet.verified) then
    return;
  end
  if (self:SyncPeerAvailable(packet.source)) then
    self:SyncConfirm(id, packet);
  end
end

function AceCommPeer:SyncPeerAdd(charName, distribution)
	if not self.syncPeers[charName] then
		self.syncPeers[charName] = {
			friend = false, guild = false, online = true, updated = self:GetSyncTime()
		};
	else
		self.syncPeers[charName].updated = self:GetSyncTime();
	end
	if (distribution == "GUILD") then
		self.syncPeers[charName].guild = true;
	end
end

function AceCommPeer:SyncPeerAvailable(charName)
	if not self.syncPeers[charName] then
		self.syncPeers[charName] = {
			friend = false, guild = false, online = false, updated = false
		};
	end
	-- TODO Update online status?
	return self.syncPeers[charName].online;
end

--------------------------------------------------------------------------------
-- Handle comm events                                                         --
--------------------------------------------------------------------------------
function AceCommPeer:OnCommReceivedPeer(prefix, message, distribution, sender)
  if (prefix == self.syncCommName) then
    local valid, messageData = self:Deserialize(message);
    if (not valid) then
      self:Debug("OnCommReceived @ "..prefix.." / "..message);
      return;
    end
    self:SyncPeerAdd(sender, distribution);
    if (messageData.type == "SyncReport") then
      local packetsKnownLocal = {};
      local packetsMissingLocal = {};
      local packetsMissingRemote = {};
      for id, packet in orderedpairs(self.syncDb.factionrealm.packets) do
        tinsert(packetsKnownLocal, id);
        if not tContains(messageData.known, id) then
          tinsert(packetsMissingRemote, id);
        end
      end
      for index, id in ipairs(messageData.known) do
        if not tContains(packetsKnownLocal, id) then
          tinsert(packetsMissingLocal, id);
        end
      end
      if #(packetsMissingLocal) > 0 then
        -- Request missing actions from peer
        self:SyncRequestPackets(packetsMissingLocal, distribution, sender);
      end
      if #(packetsMissingRemote) > 0 then
        -- Send missing actions to peer
        self:SyncSendPackets(packetsMissingRemote, distribution, sender);
      end
    elseif (messageData.type == "SyncRequest") then
      self:SyncSendPackets(messageData.packetIds, sender);
    elseif (messageData.type == "SyncData") then
			local newPackets = false;
      for id, packet in orderedpairs(messageData.packets) do
        if (self.syncDb.factionrealm.packets[id] == nil) then
          self:AddSyncPacket(packet.type, packet.data, packet.timestamp, packet.expires, packet.source, id, sender);
					newPackets = true;
        end
      end
			if (newPackets) then
				self:OnSyncPacketsChanged();
			end
      self.queueReparse = true;
    elseif (messageData.type == "SyncConfirm") then
		  local packet = self.db.factionrealm.packets[messageData.id];
		  if (self:Serialize(packet.data) == self:Serialize(messageData.data)) then
		    local messageData = { type = "SyncAck", id = messageData.id };
		    self:SyncSend(messageData, "WHISPER", sender);
		  end
    elseif (messageData.type == "SyncAck") then
      local packet = self.syncDb.factionrealm.packets[messageData.id];
			if (packet and packet.source == sender) then
				packet.verified = true;
			end
    elseif (messageData.type == "SyncPing") then
      self:SyncSend({ type = "SyncPong", time = self:GetSyncTime() }, "WHISPER", sender);
    elseif (messageData.type == "SyncPong") then
      self:SyncPeerAdd(sender, distribution);
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
    local charName = UnitName("player");
    if (self.syncDb.factionrealm.characters[charName] == nil) then
      self.syncDb.factionrealm.characters[charName] = {
        name = charName, level = 0, class = ""
      };
    end
    local charLevel = UnitLevel("player");
    local className, classFilename, classID = UnitClass("player");
    self.syncDb.factionrealm.characters[charName].level = charLevel;
    self.syncDb.factionrealm.characters[charName].class = classFilename;
		self:SyncPeers();
  end
  if (eventName == "GUILD_ROSTER_UPDATE") then
		-- Update guild members online
		for guildIndex = 1, GetNumGuildMembers() do
			local name, rankName, rankIndex, level, classDisplayName,
				zone, publicNote, officerNote, isOnline, status, class = GetGuildRosterInfo(guildIndex);
			if (self.syncPeers[charName]) then
				self.syncPeers[charName].online = isOnline;
			end
		end
  end
end

----------------------------------------
-- Base library stuff
----------------------------------------

local mixins = {
	"RegisterChannel",
	"AddSyncPacket",
	"GetSyncDbDefaults",
	"GetSyncTime",
	"GetSyncPacketsSorted",
	"SyncPeers",
	"SyncPeer",
	"SyncSend",
	"SyncConfirm",
	"SyncPeerAdd",
	"SyncPeerAvailable",
	"OnSyncPacketsChanged",
	"OnEventCommPeer",
	"OnCommReceivedPeer"
}

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
	target.syncPeers = {};
  target.syncTimeStart = GetServerTime() - GetTime();
  -- EVENTS
  target:RegisterComm(target.syncCommName, "OnCommReceivedPeer")
  target:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEventCommPeer");
  target:RegisterEvent("GUILD_ROSTER_UPDATE", "OnEventCommPeer");
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
