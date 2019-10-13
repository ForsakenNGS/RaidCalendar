local AceGUI = LibStub("AceGUI-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("RaidCalendar");

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
    -- Base information
    local raidInstance = "|cffffffff"..self.raidData.instance.."|cffffff80: "..self.raidData.comment;
    if (self.raidData.instance == "Other") then
      raidInstance = "|cffffffff"..self.raidData.comment;
    end
    local raidTimes = "|cffffffff"..self.raidData.timeInvite.."|cffffff80 - "..L["FRAME_GENERIC_INVITE"].."\n"
      .."|cffffffff"..self.raidData.timeStart.."|cffffff80 - "..L["FRAME_GENERIC_START"].."\n"
      .."|cffffffff"..self.raidData.timeEnd.."|cffffff80 - "..L["FRAME_GENERIC_END"].."";
    local labelInstance = AceGUI:Create("Label");
    labelInstance:SetText(raidInstance);
    labelInstance:SetHeight(24);
    labelInstance:SetFont("Fonts\\FRIZQT__.TTF", 14)
    local labelTimes = AceGUI:Create("Label");
    labelTimes:SetText(raidTimes);
    labelTimes:SetHeight(24);
    labelTimes:SetFont("Fonts\\FRIZQT__.TTF", 12)
    local infoBase = AceGUI:Create("SimpleGroup");
    infoBase:SetWidth(160);
    infoBase:SetLayout("List");
    infoBase:AddChild(labelInstance);
    infoBase:AddChild(labelTimes);
    -- Statistics
    local infoStatsRoles = AceGUI:Create("SimpleGroup");
    infoStatsRoles:SetFullWidth(true);
    infoStatsRoles:SetLayout("Flow");
    for roleName, roleCount in pairs(self.raidData.roleStats) do
      local iconRole = AceGUI:Create("Icon");
      iconRole:SetImage(RaidCalendar.roleIcons[roleName]);
      iconRole:SetImageSize(16, 16);
      iconRole:SetLabel(roleCount);
      iconRole:SetWidth(32);
      infoStatsRoles:AddChild(iconRole);
    end
    local infoStatsClasses = AceGUI:Create("SimpleGroup");
    infoStatsClasses:SetFullWidth(true);
    infoStatsClasses:SetLayout("Flow");
    for className, classCount in pairs(self.raidData.classStats) do
      local iconClass = AceGUI:Create("Icon");
      iconClass:SetImage(RaidCalendar.classIcons[className]);
      iconClass:SetImageSize(16, 16);
      iconClass:SetLabel(classCount);
      iconClass:SetWidth(32);
      infoStatsClasses:AddChild(iconClass);
    end
    local infoStats = AceGUI:Create("SimpleGroup");
    infoStats:SetWidth(300);
    infoStats:SetLayout("List");
    infoStats:AddChild(infoStatsRoles);
    infoStats:AddChild(infoStatsClasses);
    -- Detail text
    local infoDetails = AceGUI:Create("Label");
    infoDetails:SetText("|cffC0C0C0\n"..self.raidData.details);
    infoDetails:SetFullWidth(true);
    infoDetails:SetHeight(24);
    infoDetails:SetFont("Fonts\\FRIZQT__.TTF", 12)
    tabOverview:SetFullWidth(true);
    tabOverview:SetLayout("Flow");
    tabOverview:AddChild(infoBase);
    tabOverview:AddChild(infoStats);
    tabOverview:AddChild(infoDetails);
  end
  self.tabs:AddChild(tabOverview);
end

function RaidSignupFrame:ShowTabPlayers()
  -- Header
  local labelNumber = AceGUI:Create("Label");
  labelNumber:SetText("#");
  labelNumber:SetWidth(32);
  labelNumber:SetHeight(24);
  labelNumber:SetFont("Fonts\\FRIZQT__.TTF", 14)
  local labelStatus = AceGUI:Create("Label");
  labelStatus:SetText("Status");
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
  tableHeader:AddChild(labelNumber);
  tableHeader:AddChild(labelStatus);
  tableHeader:AddChild(labelCharacter);
  tableHeader:AddChild(labelRole);
  tableHeader:AddChild(labelNotes);
  -- Player list
  local tableBody = AceGUI:Create("ScrollFrame");
  tableBody:SetLayout("List");
  tableBody:SetFullWidth(true);
  tableBody:SetFullHeight(true);
  if (self.raidData) then
    local players = RaidCalendar:GetRaidSignups(self.raidData.id);
    for signupIndex, signupPlayer in pairs(players) do
      local valueNumber = AceGUI:Create("Label");
      valueNumber:SetText(signupIndex);
      valueNumber:SetWidth(32);
      valueNumber:SetFullHeight(true);
      valueNumber:SetFont("Fonts\\FRIZQT__.TTF", 14)
      local valueStatus = AceGUI:Create("Label");
      local valueStatusColor = RaidCalendar:GetColorHex(RaidCalendar.statusColors[signupPlayer.status]);
      valueStatus:SetText(valueStatusColor..L["STATUS_SHORT_"..signupPlayer.status]);
      valueStatus:SetWidth(48);
      valueStatus:SetFullHeight(true);
      valueStatus:SetFont("Fonts\\FRIZQT__.TTF", 10)
      local iconCharacter = AceGUI:Create("Icon");
      if (signupPlayer.class) then
        iconCharacter:SetImage(RaidCalendar.classIcons[signupPlayer.class]);
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
      valueCharacter:SetFont("Fonts\\FRIZQT__.TTF", 14)
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
      local valueNotes = AceGUI:Create("InteractiveLabel");
      valueNotes:SetText(signupPlayer.notes);
      valueNotes:SetWidth(116);
      valueNotes:SetFullHeight(true);
      valueNotes:SetFont("Fonts\\FRIZQT__.TTF", 14)
      local tableRow = AceGUI:Create("SimpleGroup");
      tableRow:SetLayout("Flow");
      tableRow:SetWidth(476 + 16);
      tableRow:SetHeight(16);
      tableRow:AddChild(valueNumber);
      tableRow:AddChild(valueStatus);
      tableRow:AddChild(iconCharacter);
      tableRow:AddChild(valueCharacter);
      tableRow:AddChild(iconRole);
      tableRow:AddChild(valueRole);
      tableRow:AddChild(valueNotes);
      tableBody:AddChild(tableRow);
    end
  end
  self.tabs:AddChild(tableHeader);
  self.tabs:AddChild(tableBody);
end

function RaidSignupFrame:ShowTabSignup()
  -- Status
  local statusDefault = "SIGNED_UP";
  -- Character
  local characterDefault = RaidCalendar.db.factionrealm.characterDefault;
  local characterOptions = {};
  for charName, charDetails in pairs(RaidCalendar.db.factionrealm.characters) do
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
  if self.tabs.tabActive == "overview" then
    self:ShowTabOverview();
  elseif self.tabs.tabActive == "players" then
    self:ShowTabPlayers();
  elseif self.tabs.tabActive == "signup" then
    self:ShowTabSignup();
  end
end

function RaidSignupFrame:OnSave(button, status, character, role, notes)
  local charDetails = RaidCalendar.db.factionrealm.characters[character];
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
tabs:SetTabs({
  { value = "overview", text = L["FRAME_SIGNUP_TAB_OVERVIEW"] },
  { value = "players", text = L["FRAME_SIGNUP_TAB_PLAYERS"] },
  { value = "signup", text = L["FRAME_SIGNUP_TAB_SIGNUP"] }
});
tabs:SetFullWidth(true);
tabs:SetFullHeight(true);
tabs:SelectTab("overview");
tabs:SetCallback("OnGroupSelected", function(tabs, event, group) RaidSignupFrame:OnSelectSignupTab(tabs, event, group) end);
tabs.tabActive = "overview";
RaidSignupFrame:AddChild(tabs);
RaidSignupFrame.tabs = tabs;
