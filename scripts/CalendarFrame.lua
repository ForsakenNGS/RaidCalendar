local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

RaidCalendarFrame = AceGUI:Create("Frame");
RaidCalendarFrame:SetTitle(L["TITLE"]);
RaidCalendarFrame:SetLayout("Flow");
RaidCalendarFrame:SetWidth(600);
RaidCalendarFrame:SetHeight(540);
RaidCalendarFrame.sizer_se:Hide();
RaidCalendarFrame.sizer_s:Hide();
RaidCalendarFrame.sizer_e:Hide();
RaidCalendarFrame:Hide();

-- Prev Month
local btnPrev = AceGUI:Create("Button");
btnPrev:SetHeight(32);
btnPrev:SetWidth(48);
btnPrev:SetText("<<");
btnPrev:SetCallback("OnClick", function() RaidCalendarFrame:PrevMonth() end);
-- Current Month
local currentMonth = AceGUI:Create("Heading");
currentMonth:SetText( date("%B %Y") );
currentMonth:SetWidth(460);
-- Next Month
local btnNext = AceGUI:Create("Button");
btnNext:SetHeight(32);
btnNext:SetWidth(48);
btnNext:SetText(">>");
btnNext:SetCallback("OnClick", function() RaidCalendarFrame:NextMonth() end);

-- Add to frame
RaidCalendarFrame:AddChild(btnPrev);
RaidCalendarFrame:AddChild(currentMonth);
RaidCalendarFrame:AddChild(btnNext);

-- Weekday labels
local labelsWeekdays = {};
for day = 1, 7 do
  local frameWeekdayLabel = AceGUI:Create("InteractiveLabel");
  frameWeekdayLabel:SetWidth(80);
  frameWeekdayLabel:SetText("???");
  labelsWeekdays[day] = frameWeekdayLabel;
  RaidCalendarFrame:AddChild(frameWeekdayLabel);
end
-- Days
local framesDays = {};
for week = 1, 6 do
  framesDays[week] = {};
  local frameWeek = AceGUI:Create("SimpleGroup");
  frameWeek:SetLayout("Flow");
  frameWeek:SetFullWidth(true);
  for day = 1, 7 do
    local frameDay = AceGUI:Create("CalendarDay");
    frameDay:SetWidth(80);
    frameDay:SetHeight(64);
    frameDay:SetDay("?");
    frameDay:SetText("...");
    frameDay:SetCallback("OnClick", function(widget, event, button) RaidCalendarFrame:OnClickDay(widget, button) end);
    frameDay:SetCallback("OnEnter", function(widget) RaidCalendarFrame:OnEnterDay(widget) end);
    frameDay:SetCallback("OnLeave", function(widget) RaidCalendarFrame:OnLeaveDay(widget) end);
    frameWeek:AddChild(frameDay);
    framesDays[week][day] = { week = frameWeek, frame = frameDay };
  end
  RaidCalendarFrame:AddChild(frameWeek);
end

RaidCalendarFrame.curMonth = tonumber(date("%m"));
RaidCalendarFrame.curYear = tonumber(date("%Y"));
RaidCalendarFrame.frames = {
  btnPrev = btnPrev,
  btnNext = btnNext,
  currentMonth = currentMonth,
  weekdays = labelsWeekdays,
  days = framesDays
};

function RaidCalendarFrame:PrevMonth()
  self.curMonth = self.curMonth - 1;
  if (self.curMonth < 1) then
    self.curMonth = 12;
    self.curYear = self.curYear - 1;
  end
  self:UpdateMonth();
end

function RaidCalendarFrame:NextMonth()
  self.curMonth = self.curMonth + 1;
  if (self.curMonth > 12) then
    self.curMonth = 1;
    self.curYear = self.curYear + 1;
  end
  self:UpdateMonth();
end

function RaidCalendarFrame:OnClickDay(widget, button)
  local week = widget:GetUserData("weekIndex");
  local day = widget:GetUserData("dayIndex");
  local dateStr = widget:GetUserData("dateStr");
  local dateLabel = widget:GetUserData("dateLabel");
  if (button == "LeftButton") then
    RaidSignupFrame:OpenDay(dateStr, dateLabel);
  elseif (button == "RightButton") and RaidCalendar:CanEditRaids() then
    RaidCreateFrame:OpenNew(dateStr);
  end
end

function RaidCalendarFrame:OnEnterDay(widget)
  local dateStr = widget:GetUserData("dateStr");
  local dateLabel = widget:GetUserData("dateLabel");
  GameTooltip_SetDefaultAnchor( GameTooltip, UIParent );
  GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
  GameTooltip:ClearLines();
  GameTooltip:AddLine(dateLabel);
  GameTooltip:AddLine(L["FRAME_CAL_HINT_LCLICK"]);
  if RaidCalendar:CanEditRaids() then
    GameTooltip:AddLine(L["FRAME_CAL_HINT_RCLICK"]);
  end
  GameTooltip:Show();
end

function RaidCalendarFrame:OnLeaveDay(widget)
  GameTooltip_SetDefaultAnchor( GameTooltip, UIParent );
  GameTooltip:Hide();
end

function RaidCalendarFrame:UpdateMonth()
  if not self:IsShown() then
    -- Prevent update if not visible
    return;
  end
  local week = 1;
  local day = 1;
  local dayTimeStart = time({
    year = self.curYear, month = self.curMonth, day = 1,
    hour = 0, min = 0, sec = 1, isdst = false
  });
  local dayWeekday = tonumber(date("%u", dayTimeStart));
  if (RaidCalendar:GetStartWithMonday()) then
    dayWeekday = mod(dayWeekday - 1, 7);
  end
  -- Set month header
  self.frames.currentMonth:SetText( date("%B %Y", dayTimeStart) );
  -- Go back to first day of week
  local dayTime = dayTimeStart - (dayWeekday * 86400);
  for week = 1, 6 do
    for day = 1, 7 do
      -- Weekday labels
      if (week == 1) then
        if (date("%a") == date("%a", dayTime)) then
          self.frames.weekdays[day]:SetText( "  |cffffffff"..date("%a", dayTime) );
        else
          self.frames.weekdays[day]:SetText( "  |cffffff80"..date("%a", dayTime) );
        end
      end
      -- Day box
      local dateStr = date("%Y-%m-%d", dayTime);
      local dayFrame = self.frames.days[week][day].frame;
      dayFrame:SetDay( date("%d", dayTime) );
      if (date("%Y-%m-%d") == dateStr) then
        dayFrame:SetActive(true);
      else
        dayFrame:SetActive(false);
        dayFrame:SetMuted(tonumber(date("%m", dayTime)) ~= self.curMonth);
      end
      local raids = RaidCalendar:GetRaids(dateStr);
      local raidText = "";
      for raidId, raidData in pairs(raids) do
        local raidInstance = raidData.instance;
        if (raidInstance == "Other") then
          raidInstance = raidData.comment;
        end
        if (raidText ~= "") then
          raidText = raidText.."\n";
        end
        if (raidData.signedUp) then
          if (raidData.signedUp.ack) then
            raidText = raidText.."|cff80ff80";
          else
            raidText = raidText.."|cffffb040";
          end
        else
          raidText = raidText.."|cffffffff";
        end
        raidText = raidText..raidData.timeInvite.." "..raidInstance.." ("..raidData.signupCount..")";
      end
      dayFrame:SetText(raidText);
      dayFrame:SetUserData("weekIndex", week);
      dayFrame:SetUserData("dayIndex", day);
      dayFrame:SetUserData("dateStr", dateStr);
      dayFrame:SetUserData("dateLabel", date("%a, %e. %b", dayTime));
      dayTime = dayTime + 86400;
    end
  end
end
