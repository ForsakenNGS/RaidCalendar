local AceGUI = LibStub("AceGUI-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

local Raids = {}
Raids["PERSONAL"] = L["FRAME_GROUP_CREATE_TYPE_PERSONAL"];
Raids["GUILD"] = L["FRAME_GROUP_CREATE_TYPE_GUILD"];

-- FRAME
RaidGroupCreateFrame = AceGUI:Create("Frame");
RaidGroupCreateFrame:SetTitle(L["FRAME_GROUP_CREATE_HEADER"]);
RaidGroupCreateFrame:SetLayout("List");
RaidGroupCreateFrame:SetWidth(520);
RaidGroupCreateFrame:SetHeight(120);
RaidGroupCreateFrame.groupData = {};

-- TYPE
local labelType = AceGUI:Create("Label");
labelType:SetText(L["FRAME_GROUP_CREATE_TYPE"]);
labelType:SetWidth(140);
labelType:SetFont("Fonts\\FRIZQT__.TTF", 14)
-- TITLE
local labelTitle = AceGUI:Create("Label");
labelTitle:SetText(L["FRAME_GROUP_CREATE_TITLE"]);
labelTitle:SetWidth(200);
labelTitle:SetFont("Fonts\\FRIZQT__.TTF", 14)
-- GROUP TYPE/TITLE
local labelGroupTypeTitle = AceGUI:Create("SimpleGroup");
labelGroupTypeTitle:SetLayout("Flow");
labelGroupTypeTitle:SetFullWidth(true);
labelGroupTypeTitle:SetHeight(32);
labelGroupTypeTitle:AddChild(labelType);
labelGroupTypeTitle:AddChild(labelTitle);
RaidGroupCreateFrame:AddChild(labelGroupTypeTitle);

-- TYPE
local editType = AceGUI:Create("Dropdown");
editType:SetList(Raids);
editType:SetWidth(140);
editType:SetHeight(24);
editType:SetValue("Other");
editType:SetCallback("OnValueChanged", function(widget, event, key) RaidGroupCreateFrame:OnTypeChanged(widget, key) end);
-- TITLE
local editTitle = AceGUI:Create("EditBox");
editTitle:SetText("My raid group");
editTitle:SetWidth(230);
editTitle:SetHeight(24);
editTitle:SetCallback("OnEnterPressed", function(widget, event, text) RaidGroupCreateFrame:OnTitleChanged(widget, text) end);
-- CREATE
local btnCreate = AceGUI:Create("Button");
btnCreate:SetText(L["FRAME_GENERIC_SAVE"]);
btnCreate:SetWidth(100);
btnCreate:SetCallback("OnClick", function(widget) RaidGroupCreateFrame:OnSave(widget) end);
-- GROUP TYPE/TITLE/CREATE
local editGroupTypeTitle = AceGUI:Create("SimpleGroup");
editGroupTypeTitle:SetLayout("Flow");
editGroupTypeTitle:SetFullWidth(true);
editGroupTypeTitle:SetHeight(32);
editGroupTypeTitle:AddChild(editType);
editGroupTypeTitle:AddChild(editTitle);
editGroupTypeTitle:AddChild(btnCreate);
RaidGroupCreateFrame.editType = editType;
RaidGroupCreateFrame.editTitle = editTitle;
RaidGroupCreateFrame.btnCreate = btnCreate;
RaidGroupCreateFrame:AddChild(editGroupTypeTitle);


function RaidGroupCreateFrame:SetData(data)
  self.groupData = {};
  for k,v in pairs(data) do
    self.groupData[k] = v;
  end
  if (self.groupData.title == nil) then
    self.groupData.title = "";
  end
  self.editTitle:SetText(self.groupData.title);
  self.editType:SetValue(self.groupData.type);
end

function RaidGroupCreateFrame:OpenCreateGroup()
  self:SetData(RaidCalendar.db.factionrealm.groupDefaults);
  self:Show();
end

function RaidGroupCreateFrame:OnTypeChanged(widget, value)
  self.groupData.type = value;
end

function RaidGroupCreateFrame:OnTitleChanged(widget, value)
  self.groupData.title = value;
end

function RaidGroupCreateFrame:OnSave(widget)
  self.groupData.type = self.editType:GetValue();
  self.groupData.title = self.editTitle:GetText();
  local groupGuild = nil;
  if (self.groupData.type == "GUILD") then
    groupGuild = GetGuildInfo("player");
  end
  if (self.groupData.id == nil) then
    -- Create group
    self.groupData.id = RaidCalendar:CreateSyncGroup(self.groupData.title, groupGuild);
  else
    -- Update group
    -- TODO
  end
  self:Hide();
  RaidGroupsFrame:UpdateGroups();
end
