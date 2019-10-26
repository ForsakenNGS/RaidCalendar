--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("RaidCalendar", "deDE");
if not L then
  return;
end

L["TITLE"] = "Raid Kalender";

L["OPTION_DEBUG_NAME"] = "Debug-Ausgaben";
L["OPTION_DEBUG_DESC"] = "Gibt Debug-Ausgaben im Chat aus";
L["OPTION_SHOW_CALENDAR"] = "Kalender öffnen";
L["OPTION_SHOW_CALENDAR_DESC"] = "Das Kalender-Fenster öffnen";

L["STATUS_SIGNED_UP"] = "Angemeldet";
L["STATUS_UNSURE"] = "Unsicher";
L["STATUS_NOT_AVAILABLE"] = "Nicht verfügbar";
L["STATUS_LATE"] = "Verspätet";
L["STATUS_SHORT_SIGNED_UP"] = "Verfüg.";
L["STATUS_SHORT_UNSURE"] = "Unsicher";
L["STATUS_SHORT_NOT_AVAILABLE"] = "Abwes.";
L["STATUS_SHORT_LATE"] = "Spät";
L["ROLE_TANK"] = "Tank";
L["ROLE_HEALER"] = "Heiler";
L["ROLE_CASTER"] = "Caster (DD)";
L["ROLE_AUTOATTACKER"] = "Physisch (DD)";
L["ROLE_FLEX_TANK"] = "Tank/DD";
L["ROLE_FLEX_HEAL"] = "Heal/DD";

L["RAID_MC"] = "Geschmolzener Kern";
L["RAID_Ony"] = "Onyxia";
L["RAID_Other"] = "Other";

L["CHAT_REPORT_NOT_SIGNED_UP"] = "Du bist für :count raid(s) noch nicht angemeldet!";
L["CHAT_REPORT_HELP"] = "Gib :cmd ein um den Raid-Kalender zu öffnen.";

L["FRAME_CAL_HINT_LCLICK"] = "Linke Maustaste: Details / Anmeldung";
L["FRAME_CAL_HINT_RCLICK"] = "Right click: Neuen Raid erstellen";

L["FRAME_GENERIC_INVITE"] = "Invite";
L["FRAME_GENERIC_START"] = "Anfang";
L["FRAME_GENERIC_END"] = "Ende";
L["FRAME_GENERIC_INSTANCE"] = "Instanz";
L["FRAME_GENERIC_COMMENT"] = "Kommentar";
L["FRAME_GENERIC_DESCRIPTION"] = "Beschreibung";
L["FRAME_GENERIC_SAVE"] = "Speichern";
L["FRAME_GENERIC_DELETE"] = "Löschen";
L["FRAME_GENERIC_UPDATE"] = "Ändern";

L["FRAME_CREATE_TITLE"] = "Raid bearbeiten/erstellen";
L["FRAME_CREATE_TITLE_NEW"] = "Neuen Raid erstellen";
L["FRAME_CREATE_TITLE_EDIT"] = "Raid bearbeiten";

L["FRAME_SIGNUP_TITLE"] = "Zum Raid anmelden";
L["FRAME_SIGNUP_CHAR"] = "Charakter";
L["FRAME_SIGNUP_ROLE"] = "Rolle";
L["FRAME_SIGNUP_NOTES"] = "Notizen";
L["FRAME_SIGNUP_EDIT"] = "Bearbeiten";
L["FRAME_SIGNUP_CREATE"] = "Neuer Raid";
L["FRAME_SIGNUP_TAB_OVERVIEW"] = "Übersicht";
L["FRAME_SIGNUP_TAB_PLAYERS"] = "Spieler";
L["FRAME_SIGNUP_TAB_SIGNUP"] = "Anmelden";
