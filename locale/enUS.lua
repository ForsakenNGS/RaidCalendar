--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("RaidCalendar", "enUS", true);

L["TITLE"] = "Raid Calendar";

L["DATE_FORMAT"] = "%m.%d.%Y %H:%M:%S";

L["OPTION_DEBUG_NAME"] = "Debugging output";
L["OPTION_DEBUG_DESC"] = "Prints debug messages in the chat";
L["OPTION_START_ON_MONDAY_NAME"] = "Start calendar on monday";
L["OPTION_START_ON_MONDAY_DESC"] = "Start calendar with monday as the first day (instead of sunday)";
L["OPTION_SHOW_CALENDAR"] = "Open Calendar";
L["OPTION_SHOW_CALENDAR_DESC"] = "Open the calendar window";
L["OPTION_RESET_DATA"] = "Reset data";
L["OPTION_RESET_DATA_DESC"] = "Reset all local sync data";
L["OPTION_ADD_CHARACTER"] = "Add character";
L["OPTION_ADD_CHARACTER_DESC"] = "Invite character to the raids";
L["OPTION_ADD_CHARACTER_HELP"] = "Please input like: /rc add <spielername> (e.g. \"/rc add Muradin\")";

L["STATUS_SIGNED_UP"] = "Signed up";
L["STATUS_UNSURE"] = "Unsure";
L["STATUS_NOT_AVAILABLE"] = "Not available";
L["STATUS_LATE"] = "Will be late";
L["STATUS_SHORT_SIGNED_UP"] = "Avail";
L["STATUS_SHORT_UNSURE"] = "Unsure";
L["STATUS_SHORT_NOT_AVAILABLE"] = "N/A";
L["STATUS_SHORT_LATE"] = "Late";

L["ROLE_TANK"] = "Tank";
L["ROLE_HEALER"] = "Healer";
L["ROLE_CASTER"] = "Caster (DD)";
L["ROLE_AUTOATTACKER"] = "Physical (DD)";
L["ROLE_FLEX_TANK"] = "Tank/DD";
L["ROLE_FLEX_HEAL"] = "Heal/DD";

L["CLASS_HUNTER"] = "Hunter";
L["CLASS_WARLOCK"] = "Warlock";
L["CLASS_PRIEST"] = "Priest";
L["CLASS_PALADIN"] = "Paladin";
L["CLASS_MAGE"] = "Mage";
L["CLASS_ROGUE"] = "Rogue";
L["CLASS_DRUID"] = "Druid";
L["CLASS_SHAMAN"] = "Shaman";
L["CLASS_WARRIOR"] = "Warrior";

L["RAID_MC"] = "Moten Core";
L["RAID_Ony"] = "Onyxia";
L["RAID_Other"] = "Other";

L["CHAT_REPORT_NOT_SIGNED_UP"] = "You are not signed up for :count raid(s)!";
L["CHAT_REPORT_HELP"] = "Type :cmd to open the raid calendar.";

L["FRAME_CAL_HINT_LCLICK"] = "Left click: Details / Sign-up";
L["FRAME_CAL_HINT_RCLICK"] = "Right click: Create new raid";

L["FRAME_GENERIC_INVITE"] = "Invite";
L["FRAME_GENERIC_START"] = "Start";
L["FRAME_GENERIC_END"] = "End";
L["FRAME_GENERIC_INSTANCE"] = "Instance";
L["FRAME_GENERIC_COMMENT"] = "Comment";
L["FRAME_GENERIC_DESCRIPTION"] = "Description";
L["FRAME_GENERIC_SAVE"] = "Save";
L["FRAME_GENERIC_DELETE"] = "Delete";
L["FRAME_GENERIC_CREATED_BY"] = "Created by";

L["FRAME_CREATE_TITLE"] = "Create/Edit Raid";
L["FRAME_CREATE_TITLE_NEW"] = "Create new Raid";
L["FRAME_CREATE_TITLE_EDIT"] = "Edit existing Raid";

L["FRAME_SIGNUP_TITLE"] = "Signup for Raid";
L["FRAME_SIGNUP_STATUS"] = "Status";
L["FRAME_SIGNUP_CHAR"] = "Character";
L["FRAME_SIGNUP_ROLE"] = "Role";
L["FRAME_SIGNUP_CLASS"] = "Class";
L["FRAME_SIGNUP_NOTES"] = "Notes";
L["FRAME_SIGNUP_EDIT"] = "Edit";
L["FRAME_SIGNUP_CREATE"] = "New raid";
L["FRAME_SIGNUP_ACCEPT"] = "Accept";
L["FRAME_SIGNUP_DECLINE"] = "Decline";
L["FRAME_SIGNUP_TAB_OVERVIEW"] = "Overview";
L["FRAME_SIGNUP_TAB_PLAYERS_SIGNED_UP"] = "Signed up";
L["FRAME_SIGNUP_TAB_PLAYERS_CONFIRMED"] = "Confirmed";
L["FRAME_SIGNUP_TAB_SIGNUP"] = "Signup";
L["FRAME_SIGNUP_STATUS_ACK"] = "Signup successfully sent";
L["FRAME_SIGNUP_STATUS_PENDING"] = "Signup pending...";
L["FRAME_SIGNUP_STATUS_OPEN"] = "Not signed up yet!";
L["FRAME_SIGNUP_TIME"] = "Signup time";
L["FRAME_SIGNUP_NONE_PLANNED"] = "No raid planned yet.";
L["FRAME_SIGNUP_PLAYERS_SELECTED"] = "players selected";
