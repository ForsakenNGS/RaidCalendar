local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

RaidGroupsFrame = AceGUI:Create("Frame");
RaidGroupsFrame:SetTitle(L["FRAME_GROUPS_TITLE"]);
RaidGroupsFrame:SetLayout("Flow");
RaidGroupsFrame:SetWidth(600);
RaidGroupsFrame:SetHeight(520);
RaidGroupsFrame.sizer_se:Hide();
RaidGroupsFrame.sizer_s:Hide();
RaidGroupsFrame.sizer_e:Hide();

-- Create Group
local btnCreateGrp = AceGUI:Create("Button");
btnCreateGrp:SetHeight(32);
btnCreateGrp:SetWidth(120);
btnCreateGrp:SetText("Create Group");
btnCreateGrp:SetCallback("OnClick", function() RaidGroupCreateFrame:OpenCreateGroup() end);

-- List of joined groups
local list = AceGUI:Create("ScrollFrame");
list:SetLayout("List");
list:SetFullWidth(true);
list:SetFullHeight(true);

-- Store frames
RaidGroupsFrame.frameCollection = {
  btnCreateGrp = btnCreateGrp,
  list = list
};

-- Add to frame
RaidGroupsFrame:AddChild(btnCreateGrp);
RaidGroupsFrame:AddChild(list);

function RaidGroupsFrame:CreateGroupFrame(groupData)
  -- CHECKBOX
  local checkbox = AceGUI:Create("CheckBox");
  checkbox:SetValue(groupData.enabled);
  checkbox:SetCallback("OnValueChanged", function(cb, event, enabled)
    RaidCalendar:SetSyncGroupEnabled(groupData.id, enabled);
  end);
  -- NAME
  checkbox:SetLabel(groupData.title);
  checkbox:SetWidth(240);
  -- PEERS
  local labelPeers = AceGUI:Create("Label");
  labelPeers:SetText("|cffffff80"..#(groupData.peers).." "..L["FRAME_GROUPS_PEERS"]);
  labelPeers:SetWidth(64);
  labelPeers:SetFont("Fonts\\FRIZQT__.TTF", 14)
  -- GROUP TYPE/TITLE
  local labelRow = AceGUI:Create("SimpleGroup");
  labelRow:SetLayout("Flow");
  labelRow:SetFullWidth(true);
  labelRow:SetHeight(32);
  labelRow:AddChild(checkbox);
  labelRow:AddChild(labelPeers);
  -- DELETE BUTTON
  if (groupData.owner == UnitName("player")) then
    local buttonPlayers = AceGUI:Create("Button");
    buttonPlayers:SetText(L["FRAME_GROUP_PEERS_HEADER"]);
    buttonPlayers:SetWidth(120);
    buttonPlayers:SetCallback("OnClick", function()
      RaidGroupPeerFrame:OpenGroup(groupData);
    end);
    local buttonDelete = AceGUI:Create("Button");
    buttonDelete:SetText(L["FRAME_GROUPS_DELETE"]);
    buttonDelete:SetWidth(120);
    buttonDelete:SetCallback("OnClick", function()
      RaidCalendar:DeleteSyncGroup(groupData.id);
      RaidGroupsFrame:UpdateGroups();
    end);
    labelRow:AddChild(buttonPlayers);
    labelRow:AddChild(buttonDelete);
  end
  return labelRow;
end

function RaidGroupsFrame:UpdateGroups()
  self.frameCollection.list:ReleaseChildren();
  local groups = RaidCalendar:GetSyncGroupList();
  for groupId, group in pairs(groups) do
    local groupFrame = RaidGroupsFrame:CreateGroupFrame(group);
    self.frameCollection.list:AddChild(groupFrame);
  end
end
