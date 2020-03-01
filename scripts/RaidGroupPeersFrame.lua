local AceGUI = LibStub("AceGUI-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

-- FRAME
RaidGroupPeerFrame = AceGUI:Create("Frame");
RaidGroupPeerFrame:SetTitle(L["FRAME_GROUP_PEERS_HEADER"]);
RaidGroupPeerFrame:SetLayout("List");
RaidGroupPeerFrame:SetWidth(520);
RaidGroupPeerFrame:SetHeight(400);
RaidGroupPeerFrame.sizer_se:Hide();
RaidGroupPeerFrame.sizer_s:Hide();
RaidGroupPeerFrame.sizer_e:Hide();
RaidGroupPeerFrame.groupData = {};
RaidGroupPeerFrame:Hide();

-- LIST
local listPlayers = AceGUI:Create("ScrollFrame");
listPlayers:SetLayout("List");
listPlayers:SetFullWidth(true);
listPlayers:SetHeight(300);
-- PLAYER
local editPlayer = AceGUI:Create("EditBox");
editPlayer:DisableButton(true);
editPlayer:SetText("");
editPlayer:SetWidth(300);
editPlayer:SetHeight(24);
editPlayer:SetCallback("OnEnterPressed", function(widget, event, text) RaidGroupPeerFrame:OnPlayerChanged(widget, text) end);
-- ADD
local btnAdd = AceGUI:Create("Button");
btnAdd:SetText(L["FRAME_GENERIC_ADD"]);
btnAdd:SetWidth(180);
btnAdd:SetCallback("OnClick", function(widget) RaidGroupPeerFrame:OnAdd(widget) end);
-- GROUP TYPE/TITLE/CREATE
local editGroupPlayerAdd = AceGUI:Create("SimpleGroup");
editGroupPlayerAdd:SetLayout("Flow");
editGroupPlayerAdd:SetFullWidth(true);
editGroupPlayerAdd:SetHeight(32);
editGroupPlayerAdd:AddChild(editPlayer);
editGroupPlayerAdd:AddChild(btnAdd);
RaidGroupPeerFrame.listPlayers = listPlayers;
RaidGroupPeerFrame.editPlayer = editPlayer;
RaidGroupPeerFrame.btnAdd = btnAdd;
RaidGroupPeerFrame:AddChild(listPlayers);
RaidGroupPeerFrame:AddChild(editGroupPlayerAdd);

function RaidGroupPeerFrame:LoadPlayers(players)
  self.listPlayers:ReleaseChildren();
  for index, charName in ipairs(self.groupData.peers) do
    local labelName = AceGUI:Create("Label");
    labelName:SetText(charName);
    labelName:SetWidth(300);
    labelName:SetHeight(16);
    labelName:SetFont("Fonts\\FRIZQT__.TTF", 14)
    local btnDelete = AceGUI:Create("Button");
    btnDelete:SetText(L["FRAME_GENERIC_DELETE"]);
    btnDelete:SetWidth(180);
    btnDelete:SetHeight(16);
    btnDelete:SetCallback("OnClick", function(widget) RaidGroupPeerFrame:OnDelete(widget, charName) end);
    local groupPlayer = AceGUI:Create("SimpleGroup");
    groupPlayer:SetLayout("Flow");
    groupPlayer:SetFullWidth(true);
    groupPlayer:SetHeight(24);
    groupPlayer:AddChild(labelName);
    groupPlayer:AddChild(btnDelete);
    self.listPlayers:AddChild(groupPlayer);
  end
end

function RaidGroupPeerFrame:OpenGroup(groupData)
  self.groupData = groupData;
  RaidGroupPeerFrame:SetTitle(L["FRAME_GROUP_PEERS_HEADER"].." / "..groupData.title);
  self:LoadPlayers(groupData.peers);
  self.editPlayer:SetText("");
  self:Show();
end

function RaidGroupPeerFrame:OnDelete(widget, playerName)
  RaidCalendar:DeleteSyncPeer(self.groupData.id, playerName);
  self:LoadPlayers();
end

function RaidGroupPeerFrame:OnAdd(widget)
  local playerName = self.editPlayer:GetText();
  RaidCalendar:AddSyncPeer(self.groupData.id, playerName);
  self:LoadPlayers();
  self.editPlayer:SetText("");
  self.btnAdd:SetDisabled(true);
end
