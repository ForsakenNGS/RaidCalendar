local AceGUI = LibStub("AceGUI-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

local tabsConfig = {
  { value = "overview", text = L["FRAME_SIGNUP_TAB_OVERVIEW"], disabled = false },
  { value = "signup", text = L["FRAME_SIGNUP_TAB_SIGNUP"], disabled = false },
  { value = "playersSignedUp", text = L["FRAME_SIGNUP_TAB_PLAYERS_SIGNED_UP"], disabled = false },
  { value = "playersConfirmed", text = L["FRAME_SIGNUP_TAB_PLAYERS_CONFIRMED"], disabled = false }
};

RaidSignupFrame = AceGUI:Create("Frame");
RaidSignupFrame:SetTitle(L["FRAME_SIGNUP_TITLE"]);
RaidSignupFrame:SetLayout("Flow");
RaidSignupFrame:SetWidth(520);
RaidSignupFrame:SetHeight(380);

function RaidSignupFrame:OnRaidChanged(widget, key)
  self.raidData = self.raids[key];
end

function RaidSignupFrame:OpenDay(dateStr, dateLabel)
  self:SetTitle(dateLabel.." - "..L["FRAME_SIGNUP_TITLE"]);
  self:Show();
  self.dateStr = dateStr;
  self.raids = RaidCalendar:GetRaids(dateStr);
  self.raidOptions = {};
  for index, raidData in pairs(self.raids) do
    local raidInstance = raidData.instance;
    if (raidInstance == "Other") then
      raidInstance = raidData.comment;
    end
    self.raidOptions[index] = raidData.timeInvite.." "..raidInstance;
  end
  self.dropdownRaids:SetList(self.raidOptions);
  if #(self.raids) > 0 then
    self.raidData = self.raids[1];
    self.dropdownRaids:SetValue(1);
    self.dropdownRaids:SetText(self.raidOptions[1]);
    if RaidCalendar:CanEditRaids() then
      self.btnEdit:SetDisabled(false);
    else
      self.btnEdit:SetDisabled(true);
    end
  else
    self.btnEdit:SetDisabled(true);
  end
  self.btnCreate:SetDisabled(not RaidCalendar:CanEditRaids());
  self:RefreshTab();
end

function RaidSignupFrame:ShowTabOverview()
  local tabOverview = AceGUI:Create("SimpleGroup");
  if (self.raidData) then
    -- Tooltip
    local tooltipShow = function(widget)
      GameTooltip_SetDefaultAnchor( GameTooltip, UIParent );
      GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
      GameTooltip:SetText(widget:GetUserData("tooltip"));
      GameTooltip:Show();
    end;
    local tooltipHide = function(widget)
      GameTooltip:Hide();
    end;
    -- Base information
    local raidInstance = "|cffffffff"..self.raidData.instance.."|cffffff80: "..self.raidData.comment;
    if (self.raidData.instance == "Other") then
      raidInstance = "|cffffffff"..self.raidData.comment;
    end
    local raidTimes = "|cffffffff"..self.raidData.timeInvite.."|cffffff80 - "..L["FRAME_GENERIC_INVITE"].."\n"
      .."|cffffffff"..self.raidData.timeStart.."|cffffff80 - "..L["FRAME_GENERIC_START"].."\n"
      .."|cffffffff"..self.raidData.timeEnd.."|cffffff80 - "..L["FRAME_GENERIC_END"].."";
    local raidCreatedBy = "|cffffffff"..L["FRAME_GENERIC_CREATED_BY"]..": |cffffff80"..self.raidData.createdBy;
    local labelInstance = AceGUI:Create("Label");
    labelInstance:SetText(raidInstance);
    labelInstance:SetHeight(24);
    labelInstance:SetFullWidth(true);
    labelInstance:SetFont("Fonts\\FRIZQT__.TTF", 14)
    local labelTimes = AceGUI:Create("Label");
    labelTimes:SetText(raidTimes);
    labelTimes:SetHeight(24);
    labelTimes:SetFullWidth(true);
    labelTimes:SetFont("Fonts\\FRIZQT__.TTF", 12)
    local infoDetails = AceGUI:Create("Label");
    infoDetails:SetText(raidCreatedBy.."\n|cffC0C0C0"..self.raidData.details);
    infoDetails:SetFullWidth(true);
    infoDetails:SetFont("Fonts\\FRIZQT__.TTF", 12);
    local infoBase = AceGUI:Create("SimpleGroup");
    --infoBase:SetRelativeWidth(0.4);
    --infoBase:SetFullHeight(true);
    infoBase:SetWidth(128);
    infoBase:SetLayout("List");
    infoBase:AddChild(labelInstance);
    infoBase:AddChild(labelTimes);
    infoBase:AddChild(infoDetails);
    -- Statistics
    local headStatsRoles = AceGUI:Create("Heading");
    headStatsRoles:SetFullWidth(true);
    headStatsRoles:SetText(L["FRAME_SIGNUP_ROLE"]);
    local infoStatsRoles = AceGUI:Create("SimpleGroup");
    infoStatsRoles:SetFullWidth(true);
    infoStatsRoles:SetLayout("Flow");
    for roleName, roleCount in pairs(self.raidData.roleStats) do
      local iconRole = AceGUI:Create("Icon");
      iconRole:SetImage(RaidCalendar.roleIcons[roleName]);
      iconRole:SetImageSize(24, 24);
      iconRole:SetLabel("|cff00ff00"..roleCount.confirmed.."|cffffffff/|cffffff00"..roleCount.overall);
      iconRole:SetHeight(40);
      iconRole:SetWidth(52);
      iconRole:SetUserData("tooltip", "|cffffffff"..L["ROLE_"..roleName].."\n"
        .."|cffffff00"..roleCount.overall.." "..L["FRAME_SIGNUP_TAB_PLAYERS_SIGNED_UP"].."\n"
        .."|cff00ff00"..roleCount.confirmed.." "..L["FRAME_SIGNUP_TAB_PLAYERS_CONFIRMED"]);
      iconRole:SetCallback("OnEnter", tooltipShow);
      iconRole:SetCallback("OnLeave", tooltipHide);
      iconRole.label:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE");
      infoStatsRoles:AddChild(iconRole);
    end
    local headStatsClasses = AceGUI:Create("Heading");
    headStatsClasses:SetFullWidth(true);
    headStatsClasses:SetText(L["FRAME_SIGNUP_CLASS"]);
    local infoStatsClasses = AceGUI:Create("SimpleGroup");
    infoStatsClasses:SetFullWidth(true);
    infoStatsClasses:SetLayout("Flow");
    for className, classCount in pairs(self.raidData.classStats) do
      local iconClass = AceGUI:Create("Icon");
      iconClass:SetImage(RaidCalendar.classIcons[className]);
      iconClass:SetImageSize(24, 24);
      iconClass:SetLabel("|cff00ff00"..classCount.confirmed.."|cffffffff/|cffffff00"..classCount.overall);
      iconClass:SetHeight(40);
      iconClass:SetWidth(52);
      iconClass:SetUserData("tooltip", "|cffffffff"..L["CLASS_"..className].."\n"
        .."|cffffff00"..classCount.overall.." "..L["FRAME_SIGNUP_TAB_PLAYERS_SIGNED_UP"].."\n"
        .."|cff00ff00"..classCount.confirmed.." "..L["FRAME_SIGNUP_TAB_PLAYERS_CONFIRMED"]);
      iconClass:SetCallback("OnEnter", tooltipShow);
      iconClass:SetCallback("OnLeave", tooltipHide);
      iconClass.label:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE");
      infoStatsClasses:AddChild(iconClass);
    end
    local infoStats = AceGUI:Create("SimpleGroup");
    infoStats:SetLayout("Flow");
    infoStats:AddChild(headStatsRoles);
    infoStats:AddChild(infoStatsRoles);
    infoStats:AddChild(headStatsClasses);
    infoStats:AddChild(infoStatsClasses);
    -- Tab content
    tabOverview:SetFullWidth(true);
    tabOverview:SetLayout(nil);
    tabOverview:AddChild(infoBase);
    tabOverview:AddChild(infoStats);
    -- Main positioning
    infoBase.frame:ClearAllPoints();
  	infoBase.frame:SetPoint("TOPLEFT", 0, 0);
  	infoBase.frame:SetPoint("BOTTOMRIGHT", infoBase.frame:GetParent(), "BOTTOMLEFT", 140, 0);
    infoStats.frame:ClearAllPoints();
  	infoStats.frame:SetPoint("TOPLEFT", 148, 0);
  	infoStats.frame:SetPoint("BOTTOMRIGHT", 0, 0);
  else
    local labelNone = AceGUI:Create("Label");
    labelNone:SetText(L["FRAME_SIGNUP_NONE_PLANNED"]);
    labelNone:SetHeight(24);
    labelNone:SetFullWidth(true);
    labelNone:SetFont("Fonts\\FRIZQT__.TTF", 14)
    tabOverview:AddChild(labelNone);
  end
  self.tabs:AddChild(tabOverview);
end

function RaidSignupFrame:ShowTabPlayers(players)
  -- Header
  local numberOrCheckboxHeader = nil;
  if (RaidCalendar:IsOwnRaid(self.raidData)) then
    local checkboxAllPlayers = AceGUI:Create("CheckBox");
    checkboxAllPlayers:SetWidth(32);
    checkboxAllPlayers:SetCallback("OnValueChanged", function(widget)
      local countChecked = 0;
      for index, player in ipairs(RaidSignupFrame.playerCheckboxes) do
        player.checkbox:SetValue( widget:GetValue() );
        countChecked = countChecked + 1;
      end
      RaidSignupFrame:SetStatusText(countChecked.." "..L["FRAME_SIGNUP_PLAYERS_SELECTED"]);
    end);
    numberOrCheckboxHeader = checkboxAllPlayers;
  else
    local labelNumber = AceGUI:Create("Label");
    labelNumber:SetText("#");
    labelNumber:SetWidth(32);
    labelNumber:SetHeight(24);
    labelNumber:SetFont("Fonts\\FRIZQT__.TTF", 14)
    numberOrCheckboxHeader = labelNumber;
  end
  local labelStatus = AceGUI:Create("Label");
  labelStatus:SetText(L["FRAME_SIGNUP_STATUS"]);
  labelStatus:SetWidth(48);
  labelStatus:SetHeight(24);
  labelStatus:SetFont("Fonts\\FRIZQT__.TTF", 14)
  local labelCharacter = AceGUI:Create("Label");
  labelCharacter:SetText(L["FRAME_SIGNUP_CHAR"]);
  labelCharacter:SetWidth(140);
  labelCharacter:SetHeight(24);
  labelCharacter:SetFont("Fonts\\FRIZQT__.TTF", 14)
  local labelRole = AceGUI:Create("Label");
  labelRole:SetText(L["FRAME_SIGNUP_ROLE"]);
  labelRole:SetWidth(128);
  labelRole:SetHeight(24);
  labelRole:SetFont("Fonts\\FRIZQT__.TTF", 14)
  local labelNotes = AceGUI:Create("Label");
  labelNotes:SetText(L["FRAME_SIGNUP_NOTES"]);
  labelNotes:SetWidth(128);
  labelNotes:SetHeight(24);
  labelNotes:SetFont("Fonts\\FRIZQT__.TTF", 14)
  local tableHeader = AceGUI:Create("SimpleGroup");
  tableHeader:SetLayout("Flow");
  tableHeader:SetWidth(476 + 16);
  tableHeader:SetHeight(32);
  tableHeader:AddChild(numberOrCheckboxHeader);
  tableHeader:AddChild(labelStatus);
  tableHeader:AddChild(labelCharacter);
  tableHeader:AddChild(labelRole);
  tableHeader:AddChild(labelNotes);
  -- Player list
  local tableBody = AceGUI:Create("ScrollFrame");
  tableBody:SetLayout("List");
  tableBody:SetFullWidth(true);
  tableBody:SetFullHeight(true);
  self.playerCheckboxes = {};
  if (self.raidData) then
    local checkboxChanged = function(widget)
      local countChecked = 0;
      for index, player in ipairs(RaidSignupFrame.playerCheckboxes) do
        if (player.checkbox:GetValue()) then
          countChecked = countChecked + 1;
        end
      end
      RaidSignupFrame:SetStatusText(countChecked.." "..L["FRAME_SIGNUP_PLAYERS_SELECTED"]);
    end
    for signupIndex, signupPlayer in pairs(players) do
      local tooltip = "";
      local numberOrCheckbox = nil;
      if (RaidCalendar:IsOwnRaid(self.raidData)) then
        local checkboxPlayer = AceGUI:Create("CheckBox");
        checkboxPlayer:SetWidth(32);
        checkboxPlayer:SetCallback("OnValueChanged", checkboxChanged);
        tinsert(self.playerCheckboxes, {
          data = signupPlayer, index = signupIndex, checkbox = checkboxPlayer
        });
        numberOrCheckbox = checkboxPlayer;
      else
        local valueNumber = AceGUI:Create("Label");
        valueNumber:SetText(signupIndex);
        valueNumber:SetWidth(32);
        valueNumber:SetFullHeight(true);
        valueNumber:SetFont("Fonts\\FRIZQT__.TTF", 14);
        numberOrCheckbox = valueNumber;
      end
      local valueStatus = AceGUI:Create("Label");
      local valueStatusColor = RaidCalendar:GetColorHex(RaidCalendar.statusColors[signupPlayer.status]);
      valueStatus:SetText(valueStatusColor..L["STATUS_SHORT_"..signupPlayer.status]);
      valueStatus:SetWidth(48);
      valueStatus:SetFullHeight(true);
      valueStatus:SetFont("Fonts\\FRIZQT__.TTF", 10)
      tooltip = tooltip.."|cffffffff"..L["FRAME_SIGNUP_STATUS"]..": "..valueStatusColor..L["STATUS_"..signupPlayer.status].."\n";
      local iconCharacter = AceGUI:Create("Icon");
      local classText = "";
      if (signupPlayer.class) then
        iconCharacter:SetImage(RaidCalendar.classIcons[signupPlayer.class]);
        classText = L["CLASS_"..signupPlayer.class];
      end
      iconCharacter:SetImageSize(16, 16);
      iconCharacter:SetHeight(24);
      iconCharacter:SetWidth(24);
      local valueCharacter = AceGUI:Create("InteractiveLabel");
      local charColor = RaidCalendar.classColors["WARRIOR"];
      if (signupPlayer.class) then
        charColor = RaidCalendar.classColors[signupPlayer.class];
      end
      valueCharacter:SetColor(charColor.r, charColor.g, charColor.b);
      valueCharacter:SetText(signupPlayer.character);
      valueCharacter:SetWidth(116);
      valueCharacter:SetFullHeight(true);
      valueCharacter:SetFont("Fonts\\FRIZQT__.TTF", 14);
      tooltip = tooltip.."|cffffffff"..L["FRAME_SIGNUP_CHAR"]..": "..RaidCalendar:GetColorHex(charColor)
        ..signupPlayer.character.." / "..signupPlayer.level.." "..classText.."\n";
      local iconRole = AceGUI:Create("Icon");
      iconRole:SetImage(RaidCalendar.roleIcons[signupPlayer.role]);
      iconRole:SetImageSize(16, 16);
      iconRole:SetHeight(24);
      iconRole:SetWidth(24);
      local valueRole = AceGUI:Create("InteractiveLabel");
      valueRole:SetText(L["ROLE_"..signupPlayer.role]);
      valueRole:SetWidth(116);
      valueRole:SetFullHeight(true);
      valueRole:SetFont("Fonts\\FRIZQT__.TTF", 14)
      tooltip = tooltip.."|cffffffff"..L["FRAME_SIGNUP_ROLE"]..": |cffffff80"..L["ROLE_"..signupPlayer.role].."\n";
      local valueNotes = AceGUI:Create("InteractiveLabel");
      valueNotes:SetText( strsub(signupPlayer.notes, 0, 8).."..." );
      valueNotes:SetWidth(116);
      valueNotes:SetFont("Fonts\\FRIZQT__.TTF", 14)
      local tableRow = AceGUI:Create("SimpleGroup");
      tableRow:SetLayout("Flow");
      tableRow:SetWidth(476 + 16);
      tableRow:SetHeight(24);
      tableRow:SetAutoAdjustHeight(false);
      tableRow:AddChild(numberOrCheckbox);
      tableRow:AddChild(valueStatus);
      tableRow:AddChild(iconCharacter);
      tableRow:AddChild(valueCharacter);
      tableRow:AddChild(iconRole);
      tableRow:AddChild(valueRole);
      tableRow:AddChild(valueNotes);
      tooltip = tooltip.."|cffffffff"..L["FRAME_SIGNUP_TIME"]..": |cffffff80"
        ..date(L["DATE_FORMAT"], signupPlayer.timeFirst).." - "..date(L["DATE_FORMAT"], signupPlayer.timeLast).."\n"
        .."|cffffffff"..L["FRAME_SIGNUP_NOTES"]..":\n".."|cffffff80"..signupPlayer.notes;
      local tooltipShow = function(widget)
        --RaidCalendar:Debug(widget:GetUserData("tooltip"));
        GameTooltip_SetDefaultAnchor( GameTooltip, UIParent );
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
        GameTooltip:SetText(widget:GetUserData("tooltip"));
        GameTooltip:Show();
      end;
      local tooltipHide = function(widget)
        GameTooltip:Hide();
      end;
      iconCharacter:SetUserData("tooltip", tooltip);
      iconCharacter:SetCallback("OnEnter", tooltipShow);
      iconCharacter:SetCallback("OnLeave", tooltipHide);
      iconRole:SetUserData("tooltip", tooltip);
      iconRole:SetCallback("OnEnter", tooltipShow);
      iconRole:SetCallback("OnLeave", tooltipHide);
      valueNotes:SetUserData("tooltip", tooltip);
      valueNotes:SetCallback("OnEnter", tooltipShow);
      valueNotes:SetCallback("OnLeave", tooltipHide);
      tableBody:AddChild(tableRow);
    end
  end
  local tableActions = AceGUI:Create("SimpleGroup");
  tableActions:SetLayout("Flow");
  tableActions:SetFullWidth(true);
  if (RaidCalendar:IsOwnRaid(self.raidData)) then
    -- Action buttons
    local btnPlayersAccept = AceGUI:Create("Button");
    btnPlayersAccept:SetText(L["FRAME_SIGNUP_ACCEPT"]);
    btnPlayersAccept:SetCallback("OnClick", function(widget)
      RaidSignupFrame:OnPlayersAccept();
    end);
    local btnPlayersDecline = AceGUI:Create("Button");
    btnPlayersDecline:SetText(L["FRAME_SIGNUP_DECLINE"]);
    btnPlayersDecline:SetCallback("OnClick", function(widget)
      RaidSignupFrame:OnPlayersDecline();
    end);
    tableActions:AddChild(btnPlayersAccept);
    tableActions:AddChild(btnPlayersDecline);
  end
  self.tabs:AddChild(tableHeader);
  self.tabs:AddChild(tableBody);
  self.tabs:AddChild(tableActions);
end

function RaidSignupFrame:GetSelectedPlayers()
  local players = {};
  for index, player in ipairs(self.playerCheckboxes) do
    if (player.checkbox:GetValue()) then
      tinsert(players, player.data.character);
    end
  end
  return players;
end

function RaidSignupFrame:OnPlayersAccept()
  RaidCalendar:SignupAccept(self.raidData.id, self:GetSelectedPlayers());
end

function RaidSignupFrame:OnPlayersDecline()
  RaidCalendar:SignupDecline(self.raidData.id, self:GetSelectedPlayers());
end

function RaidSignupFrame:ShowTabSignup()
  -- Status
  local statusDefault = "SIGNED_UP";
  -- Character
  local characterDefault = RaidCalendar.db.factionrealm.characterDefault;
  local characterOptions = {};
  for charName, charDetails in pairs(RaidCalendar.syncDb.factionrealm.characters) do
    if (characterDefault == nil) then
      characterDefault = charName;
    end
    characterOptions[charName] = RaidCalendar:GetColorHex(RaidCalendar.classColors[charDetails.class])..charDetails.level.." "..charName;
  end
  -- Role
  local roleDefault = RaidCalendar.db.factionrealm.roleDefault;
  if (roleDefault == nil) then
    roleDefault = "CASTER";
  end
  -- Note
  local noteDefault = "";
  -- Active signup data
  if (self.raidData) then
    if (self.raidData.signedUp) then
      statusDefault = self.raidData.signedUp.status;
      characterDefault = self.raidData.signedUp.character;
      roleDefault = self.raidData.signedUp.role;
      noteDefault = self.raidData.signedUp.notes;
    end
  end
  -- Create GUI
  local signupStatus = AceGUI:Create("Dropdown");
  signupStatus:SetList(RaidCalendar.statusOptions);
  signupStatus:SetValue(statusDefault);
  signupStatus:SetWidth(128);
  local signupChar = AceGUI:Create("Dropdown");
  signupChar:SetList(characterOptions);
  if (characterDefault ~= nil) then
    signupChar:SetValue(characterDefault);
  end
  signupChar:SetWidth(140);
  local signupRole = AceGUI:Create("Dropdown");
  signupRole:SetList(RaidCalendar.roles);
  signupRole:SetValue(roleDefault);
  signupRole:SetWidth(140);
  local signupNote = AceGUI:Create("MultiLineEditBox");
  signupNote:SetLabel(L["FRAME_SIGNUP_NOTES"]);
  signupNote:SetText(noteDefault);
  signupNote:SetFullWidth(true);
  signupNote:SetNumLines(8);
  signupNote.button:Hide();
  local btnSave = AceGUI:Create("Button");
  btnSave:SetText(L["FRAME_GENERIC_SAVE"]);
  btnSave:SetCallback("OnClick", function(widget)
    local status = signupStatus:GetValue();
    local character = signupChar:GetValue();
    local role = signupRole:GetValue();
    local notes = signupNote:GetText();
    RaidSignupFrame:OnSave(widget, status, character, role, notes);
  end);
  if (self.raidData) then
    btnSave:SetDisabled(false);
  else
    btnSave:SetDisabled(true);
  end
  local tabSignup = AceGUI:Create("SimpleGroup");
  tabSignup:SetFullWidth(true);
  tabSignup:SetLayout("Flow");
  tabSignup:AddChild(signupStatus);
  tabSignup:AddChild(signupChar);
  tabSignup:AddChild(signupRole);
  tabSignup:AddChild(signupNote);
  tabSignup:AddChild(btnSave);
  self.tabs:AddChild(tabSignup);
end

function RaidSignupFrame:RefreshTab()
  self.tabs:ReleaseChildren();
  if (self.tabs.tabActive == "overview") or not self.raidData then
    self:ShowTabOverview();
  elseif self.tabs.tabActive == "playersSignedUp" then
    local players = RaidCalendar:GetRaidSignups(self.raidData.id);
    self:ShowTabPlayers(players);
  elseif self.tabs.tabActive == "playersConfirmed" then
    local players = RaidCalendar:GetRaidSignups(self.raidData.id, true);
    self:ShowTabPlayers(players);
  elseif self.tabs.tabActive == "signup" then
    self:ShowTabSignup();
  end
  if (self.raidData) then
    if (self.raidData.signedUp) then
      if (self.raidData.signedUp.ack) then
        -- Signed up and confirmed
        self:SetStatusText("|cff00ff00"..L["FRAME_SIGNUP_STATUS_ACK"]);
      else
        -- Signed up and pending
        self:SetStatusText("|cffffff00"..L["FRAME_SIGNUP_STATUS_PENDING"]);
      end
    else
      -- Not signed up
      self:SetStatusText("|cffff0000"..L["FRAME_SIGNUP_STATUS_OPEN"]);
    end
    -- Enable all tabs
    tabsConfig[2].disabled = false;
    tabsConfig[3].disabled = false;
    tabsConfig[4].disabled = false;
  else
    self:SetStatusText(L["FRAME_SIGNUP_NONE_PLANNED"]);
    -- Disable all but overview
    tabsConfig[2].disabled = true;
    tabsConfig[3].disabled = true;
    tabsConfig[4].disabled = true;
  end
  self.tabs:SetTabs(tabsConfig);
end

function RaidSignupFrame:OnSave(button, status, character, role, notes)
  local charDetails = RaidCalendar.syncDb.factionrealm.characters[character];
  RaidCalendar.db.factionrealm.characterDefault = character;
  RaidCalendar.db.factionrealm.roleDefault = role;
  RaidCalendar:Signup(self.raidData.id, status, character, charDetails.level, charDetails.class, role, notes);
  self:Hide();
  RaidCalendarFrame:UpdateMonth();
end

function RaidSignupFrame:OnEdit(button)
  if RaidCalendar:CanEditRaids() then
    self:Hide();
    RaidCreateFrame:OpenEdit(self.raidData.id);
  end
end

function RaidSignupFrame:OnCreate(button)
  if RaidCalendar:CanEditRaids() then
    self:Hide();
    RaidCreateFrame:OpenNew(self.dateStr);
  end
end

function RaidSignupFrame:OnSelectSignupTab(tabs, event, group)
  tabs.tabActive = group;
  self:RefreshTab();
end

local raids = AceGUI:Create("Dropdown");
raids:SetWidth(240);
raids:SetCallback("OnValueChanged", function(widget, event, key) RaidSignupFrame:OnRaidChanged(widget, key) end);
RaidSignupFrame.dropdownRaids = raids;

local btnEdit = AceGUI:Create("Button");
btnEdit:SetWidth(80);
btnEdit:SetText(L["FRAME_SIGNUP_EDIT"]);
btnEdit:SetCallback("OnClick", function(widget) RaidSignupFrame:OnEdit(widget) end);
RaidSignupFrame.btnEdit = btnEdit;

local btnCreate = AceGUI:Create("Button");
btnCreate:SetWidth(120);
btnCreate:SetText(L["FRAME_SIGNUP_CREATE"]);
btnCreate:SetCallback("OnClick", function(widget) RaidSignupFrame:OnCreate(widget) end);
RaidSignupFrame.btnCreate = btnCreate;

local raidRow = AceGUI:Create("SimpleGroup");
raidRow:SetFullWidth(true);
raidRow:SetLayout("Flow");
raidRow:AddChild(raids);
raidRow:AddChild(btnEdit);
raidRow:AddChild(btnCreate);
RaidSignupFrame:AddChild(raidRow);

local tabs = AceGUI:Create("TabGroup");
tabs:SetTabs(tabsConfig);
tabs:SetFullWidth(true);
tabs:SetFullHeight(true);
tabs:SelectTab("overview");
tabs:SetCallback("OnGroupSelected", function(tabs, event, group) RaidSignupFrame:OnSelectSignupTab(tabs, event, group) end);
tabs.tabActive = "overview";
RaidSignupFrame:AddChild(tabs);
RaidSignupFrame.tabs = tabs;
