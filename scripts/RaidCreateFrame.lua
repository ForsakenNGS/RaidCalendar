local AceGUI = LibStub("AceGUI-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

local Raids = {}
Raids["MC"] = L["RAID_MC"];
Raids["Ony"] = L["RAID_Ony"];
Raids["BWL"] = L["RAID_BWL"];
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
editInvite:DisableButton(true);
editInvite:SetText("18:30");
editInvite:SetWidth(140);
editInvite:SetHeight(24);
local editStart = AceGUI:Create("EditBox");
editStart:DisableButton(true);
editStart:SetText("19:00");
editStart:SetWidth(140);
editStart:SetHeight(24);
local editEnd = AceGUI:Create("EditBox");
editEnd:DisableButton(true);
editEnd:SetText("22:00");
editEnd:SetWidth(140);
editEnd:SetHeight(24);
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
local labelRaidGroup = AceGUI:Create("Label");
labelRaidGroup:SetText(L["FRAME_GENERIC_RAID_GROUP"]);
labelRaidGroup:SetWidth(140);
labelRaidGroup:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelComment = AceGUI:Create("Label");
labelComment:SetText(L["FRAME_GENERIC_COMMENT"]);
labelComment:SetWidth(140);
labelComment:SetFont("Fonts\\FRIZQT__.TTF", 14)
local labelGroupRaid = AceGUI:Create("SimpleGroup");
labelGroupRaid:SetLayout("Flow");
labelGroupRaid:SetFullWidth(true);
labelGroupRaid:SetHeight(32);
labelGroupRaid:AddChild(labelRaid);
labelGroupRaid:AddChild(labelRaidGroup);
labelGroupRaid:AddChild(labelComment);
RaidCreateFrame:AddChild(labelGroupRaid);

local editRaid = AceGUI:Create("Dropdown");
editRaid:SetList(Raids);
editRaid:SetWidth(140);
editRaid:SetHeight(24);
editRaid:SetValue("Other");
editRaid:SetCallback("OnValueChanged", function(widget, event, key) RaidCreateFrame:OnRaidChanged(widget, key) end);
local editRaidGroup = AceGUI:Create("Dropdown");
editRaidGroup:SetWidth(140);
editRaidGroup:SetHeight(24);
editRaidGroup:SetCallback("OnValueChanged", function(widget, event, key) RaidCreateFrame:OnRaidGroupChanged(widget, key) end);
local editComment = AceGUI:Create("EditBox");
editComment:DisableButton(true);
editComment:SetWidth(140);
editComment:SetHeight(24);
editComment:DisableButton(true);
local editGroupRaid = AceGUI:Create("SimpleGroup");
editGroupRaid:SetLayout("Flow");
editGroupRaid:SetFullWidth(true);
editGroupRaid:SetHeight(32);
editGroupRaid:AddChild(editRaid);
editGroupRaid:AddChild(editRaidGroup);
editGroupRaid:AddChild(editComment);
RaidCreateFrame.editRaid = editRaid;
RaidCreateFrame.editRaidGroup = editRaidGroup;
RaidCreateFrame.editComment = editComment;
RaidCreateFrame:AddChild(editGroupRaid);

local editDetails = AceGUI:Create("MultiLineEditBox");
editComment:DisableButton(true);
editDetails:SetLabel(L["FRAME_GENERIC_DESCRIPTION"]);
editDetails:SetFullWidth(true);
editDetails:SetNumLines(8);
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
  if (self.raidData.group == nil) then
    self.raidData.group = "";
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
  self.editRaidGroup:SetValue(self.raidData.group);
  self.editComment:SetText(self.raidData.comment);
  self.editDetails:SetText(self.raidData.details);
  self:Validate();
end

function RaidCreateFrame:OpenNew(dateStr)
  self.editRaidGroup:SetList( RaidCalendar:GetSyncGroupTitles() );
  self.editRaidGroup:SetDisabled(false);
  self:SetData(RaidCalendar.db.factionrealm.raidDefaults);
  self:SetDateStr(dateStr);
  self:Show();
end

function RaidCreateFrame:OpenEdit(raidId)
  local raidData = RaidCalendar:GetRaidDetails(raidId)
  self.editRaidGroup:SetList( RaidCalendar:GetSyncGroupTitles() );
  self.editRaidGroup:SetDisabled(true);
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
  self.raidData.expires = nil;
  local expires = nil;
  local raidYear, raidMonth, raidDay = strmatch(dateStr, "^(%d)+\\-(%d)+\\-(%d)+$");
  if (raidDay) then
    self.raidData.expires = time({
      year = raidYear, month = raidMonth, day = raidDay,
      hour = 0, min = 0, sec = 0, isdst = true
    }) + 86400 * 7; -- Expires 7 days after the raid
  end
end

function RaidCreateFrame:OnRaidChanged(widget, key)
  self.raidData.instance = key;
end

function RaidCreateFrame:OnRaidGroupChanged(widget, key)
  self.raidData.group = key;
  self:Validate();
end

function RaidCreateFrame:OnSave(widget)
  self.raidData.timeInvite = self.editInvite:GetText();
  self.raidData.timeStart = self.editStart:GetText();
  self.raidData.timeEnd = self.editEnd:GetText();
  self.raidData.comment = self.editComment:GetText();
  self.raidData.details = self.editDetails:GetText();
  if (self.raidData.id == nil) then
    -- Create raid
    self.raidData.id = RaidCalendar:AddRaid(
      self.raidData.group, self.raidData.dateStr, self.raidData.expires, UnitName("player"),
      self.raidData.timeInvite, self.raidData.timeStart, self.raidData.timeEnd,
      self.raidData.instance, self.raidData.comment, self.raidData.details
    );
  else
    -- Create raid
    RaidCalendar:UpdateRaid(
      self.raidData.id, self.raidData.dateStr, self.raidData.expires, self.raidData.createdBy,
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

function RaidCreateFrame:Validate()
  -- Validate
  if (self.raidData.group == "") then
    self.btnSave:SetDisabled(true);
  else
    self.btnSave:SetDisabled(false);
  end
end
