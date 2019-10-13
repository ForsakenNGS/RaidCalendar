local AceGUI = LibStub("AceGUI-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

local Raids = {}
Raids["MC"] = L["RAID_MC"];
Raids["Ony"] = L["RAID_Ony"];
Raids["Other"] = L["RAID_Other"];

RaidCreateFrame = AceGUI:Create("Frame");
RaidCreateFrame:SetTitle(L["FRAME_CREATE_TITLE"]);
RaidCreateFrame:SetLayout("List");
RaidCreateFrame:SetWidth(480);
RaidCreateFrame:SetHeight(340);
RaidCreateFrame.raidData = {};

local labelInvite = AceGUI:Create("Label");
labelInvite:SetText(L["FRAME_GENERIC_INVITE"]);
labelInvite:SetWidth(140);
labelInvite:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelStart = AceGUI:Create("Label");
labelStart:SetText(L["FRAME_GENERIC_START"]);
labelStart:SetWidth(140);
labelStart:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelEnd = AceGUI:Create("Label");
labelEnd:SetText(L["FRAME_GENERIC_END"]);
labelEnd:SetWidth(140);
labelEnd:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelGroupTime = AceGUI:Create("SimpleGroup");
labelGroupTime:SetLayout("Flow");
labelGroupTime:SetFullWidth(true);
labelGroupTime:SetHeight(32);
labelGroupTime:AddChild(labelInvite);
labelGroupTime:AddChild(labelStart);
labelGroupTime:AddChild(labelEnd);
RaidCreateFrame:AddChild(labelGroupTime);

local editInvite = AceGUI:Create("EditBox");
editInvite:SetText("18:30");
editInvite:SetWidth(140);
editInvite:SetHeight(24);
editInvite:SetCallback("OnEnterPressed", function(widget, event, text) RaidCreateFrame:OnInviteChanged(widget, text) end);
local editStart = AceGUI:Create("EditBox");
editStart:SetText("19:00");
editStart:SetWidth(140);
editStart:SetHeight(24);
editStart:SetCallback("OnEnterPressed", function(widget, event, text) RaidCreateFrame:OnStartChanged(widget, text) end);
local editEnd = AceGUI:Create("EditBox");
editEnd:SetText("22:00");
editEnd:SetWidth(140);
editEnd:SetHeight(24);
editEnd:SetCallback("OnEnterPressed", function(widget, event, text) RaidCreateFrame:OnEndChanged(widget, text) end);
local editGroupTime = AceGUI:Create("SimpleGroup");
editGroupTime:SetLayout("Flow");
editGroupTime:SetFullWidth(true);
editGroupTime:SetHeight(32);
editGroupTime:AddChild(editInvite);
editGroupTime:AddChild(editStart);
editGroupTime:AddChild(editEnd);
RaidCreateFrame.editInvite = editInvite;
RaidCreateFrame.editStart = editStart;
RaidCreateFrame.editEnd = editEnd;
RaidCreateFrame:AddChild(editGroupTime);

local labelRaid = AceGUI:Create("Label");
labelRaid:SetText(L["FRAME_GENERIC_INSTANCE"]);
labelRaid:SetWidth(140);
labelRaid:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelComment = AceGUI:Create("Label");
labelComment:SetText(L["FRAME_GENERIC_COMMENT"]);
labelComment:SetWidth(140);
labelComment:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelGroupRaid = AceGUI:Create("SimpleGroup");
labelGroupRaid:SetLayout("Flow");
labelGroupRaid:SetFullWidth(true);
labelGroupRaid:SetHeight(32);
labelGroupRaid:AddChild(labelRaid);
labelGroupRaid:AddChild(labelComment);
RaidCreateFrame:AddChild(labelGroupRaid);

local editRaid = AceGUI:Create("Dropdown");
editRaid:SetList(Raids);
editRaid:SetWidth(140);
editRaid:SetHeight(24);
editRaid:SetValue("Other");
editRaid:SetCallback("OnValueChanged", function(widget, event, key) RaidCreateFrame:OnRaidChanged(widget, key) end);
local editComment = AceGUI:Create("EditBox");
editComment:SetWidth(280);
editComment:SetHeight(24);
editComment:SetCallback("OnEnterPressed", function(widget, event, text) RaidCreateFrame:OnCommentChanged(widget, text) end);
editComment:DisableButton(true);
local editGroupRaid = AceGUI:Create("SimpleGroup");
editGroupRaid:SetLayout("Flow");
editGroupRaid:SetFullWidth(true);
editGroupRaid:SetHeight(32);
editGroupRaid:AddChild(editRaid);
editGroupRaid:AddChild(editComment);
RaidCreateFrame.editRaid = editRaid;
RaidCreateFrame.editComment = editComment;
RaidCreateFrame:AddChild(editGroupRaid);

local editDetails = AceGUI:Create("MultiLineEditBox");
editDetails:SetFullWidth(true);
editDetails:SetNumLines(8);
editDetails:SetCallback("OnEnterPressed", function(widget, event, text) RaidCreateFrame:OnDetailsChanged(widget, text) end);
editDetails.button:Hide();
RaidCreateFrame.editDetails = editDetails;
RaidCreateFrame:AddChild(editDetails);

local btnSave = AceGUI:Create("Button");
btnSave:SetText(L["FRAME_GENERIC_SAVE"]);
btnSave:SetCallback("OnClick", function(widget) RaidCreateFrame:OnSave(widget) end);
local btnDelete = AceGUI:Create("Button");
btnDelete:SetText(L["FRAME_GENERIC_DELETE"]);
btnDelete:SetCallback("OnClick", function(widget) RaidCreateFrame:OnDelete(widget) end);
local editGroupButton = AceGUI:Create("SimpleGroup");
editGroupButton:SetLayout("Flow");
editGroupButton:SetFullWidth(true);
editGroupButton:AddChild(btnSave);
editGroupButton:AddChild(btnDelete);
RaidCreateFrame.btnSave = btnSave;
RaidCreateFrame.btnDelete = btnDelete;
RaidCreateFrame:AddChild(editGroupButton);

function RaidCreateFrame:SetData(data)
  self.raidData = {};
  for k,v in pairs(data) do
    self.raidData[k] = v;
  end
  if (self.raidData.id == nil) then
    self.btnDelete:SetDisabled(true);
  else
    self.btnDelete:SetDisabled(false);
  end
  if (self.raidData.timeInvite == nil) then
    self.raidData.timeInvite = "18:30";
  end
  if (self.raidData.timeStart == nil) then
    self.raidData.timeStart = "19:00";
  end
  if (self.raidData.timeEnd == nil) then
    self.raidData.timeEnd = "22:00";
  end
  if (self.raidData.instance == nil) then
    self.raidData.instance = "MC";
  end
  if (self.raidData.comment == nil) then
    self.raidData.comment = "";
  end
  if (self.raidData.details == nil) then
    self.raidData.details = "";
  end
  self.editInvite:SetText(self.raidData.timeInvite);
  self.editStart:SetText(self.raidData.timeStart);
  self.editEnd:SetText(self.raidData.timeEnd);
  self.editRaid:SetValue(self.raidData.instance);
  self.editComment:SetText(self.raidData.comment);
  self.editDetails:SetText(self.raidData.details);
end

function RaidCreateFrame:OpenNew(dateStr)
  self:SetData(RaidCalendar.db.factionrealm.raidDefaults);
  self:SetDateStr(dateStr);
  self:Show();
end

function RaidCreateFrame:OpenEdit(raidId)
  local raidData = RaidCalendar:GetRaidDetails(raidId)
  self:SetData(raidData);
  self:SetDateStr(raidData.dateStr);
  self:Show();
end

function RaidCreateFrame:SetDateStr(dateStr)
  self.raidData.dateStr = dateStr;
  if (self.raidData.id == nil) then
    self:SetTitle(dateStr.." - "..L["FRAME_CREATE_TITLE_NEW"]);
  else
    self:SetTitle(dateStr.." - "..L["FRAME_CREATE_TITLE_EDIT"]);
  end
end

function RaidCreateFrame:OnInviteChanged(widget, value)
  self.raidData.timeInvite = value;
end

function RaidCreateFrame:OnStartChanged(widget, value)
  self.raidData.timeStart = value;
end

function RaidCreateFrame:OnEndChanged(widget, value)
  self.raidData.timeEnd = value;
end

function RaidCreateFrame:OnRaidChanged(widget, key)
  self.raidData.instance = key;
end

function RaidCreateFrame:OnCommentChanged(widget, value)
  self.raidData.comment = value;
end

function RaidCreateFrame:OnDetailsChanged(widget, value)
  self.raidData.details = value;
end

function RaidCreateFrame:OnSave(widget)
  self.raidData.comment = self.editComment:GetText();
  self.raidData.details = self.editDetails:GetText();
  if (self.raidData.id == nil) then
    -- Create raid
    self.raidData.id = RaidCalendar:AddRaid(
      self.raidData.dateStr, UnitName("player"),
      self.raidData.timeInvite, self.raidData.timeStart, self.raidData.timeEnd,
      self.raidData.instance, self.raidData.comment, self.raidData.details
    );
  else
    -- Create raid
    RaidCalendar:UpdateRaid(
      self.raidData.id, self.raidData.dateStr, self.raidData.createdBy,
      self.raidData.timeInvite, self.raidData.timeStart, self.raidData.timeEnd,
      self.raidData.instance, self.raidData.comment, self.raidData.details
    );
  end
  self:Hide();
end

function RaidCreateFrame:OnDelete(widget)
  -- Delete raid
  RaidCalendar:DeleteRaid(self.raidData.id);
  RaidCalendarFrame:UpdateMonth();
  self:Hide();
end
