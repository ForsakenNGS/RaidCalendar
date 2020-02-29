--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("RaidCalendar", "deDE");
if not L then
  return;
end

L["TITLE"] = "Raid Kalender";
L["ICON_TOOLTIP"] = "Raid Kalender\nLinks-Klick: Kalender\nRechts-Klick: Gruppen";

L["DATE_FORMAT"] = "%d.%m.%Y %H:%M:%S";

L["OPTION_DEBUG_NAME"] = "Debug-Ausgaben";
L["OPTION_DEBUG_DESC"] = "Gibt Debug-Ausgaben im Chat aus";
L["OPTION_START_ON_MONDAY_NAME"] = "Montag als ersten Wochentag";
L["OPTION_START_ON_MONDAY_DESC"] = "Beim Kalender Montag (anstatt Sonntag) als ersten Wochentag anzeigen";
L["OPTION_SHOW_CALENDAR"] = "Kalender öffnen";
L["OPTION_SHOW_CALENDAR_DESC"] = "Das Kalender-Fenster öffnen";
L["OPTION_SHOW_GROUPS"] = "Raid gruppen anzeigen";
L["OPTION_SHOW_GROUPS_DESC"] = "Übersicht der Raid-Gruppen öffnen";
L["OPTION_RESET_DATA"] = "Daten zurücksetzen";
L["OPTION_RESET_DATA_DESC"] = "Alle lokalen Sync-Daten löschen";
L["OPTION_ADD_CHARACTER"] = "Char. hinzufügen";
L["OPTION_ADD_CHARACTER_DESC"] = "Charakter zu den raids einladen";
L["OPTION_ADD_CHARACTER_HELP"] = "Geben Sie ein: /rc add <spielername> (z.B. \"/rc add Muradin\")";

L["STATUS_SIGNED_UP"] = "Angemeldet";
L["STATUS_UNSURE"] = "Unsicher";
L["STATUS_NOT_AVAILABLE"] = "Nicht verfügbar";
L["STATUS_LATE"] = "Verspätet";
L["STATUS_SHORT_CONFIRMED"] = "Bestät.";
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

L["CLASS_HUNTER"] = "Jäger";
L["CLASS_WARLOCK"] = "Hexenmeister";
L["CLASS_PRIEST"] = "Priester";
L["CLASS_PALADIN"] = "Palading";
L["CLASS_MAGE"] = "Magier";
L["CLASS_ROGUE"] = "Schurke";
L["CLASS_DRUID"] = "Druide";
L["CLASS_SHAMAN"] = "Schamane";
L["CLASS_WARRIOR"] = "Krieger";

L["RAID_MC"] = "Geschmolzener Kern";
L["RAID_Ony"] = "Onyxia";
L["RAID_BWL"] = "Pechschwingenhort";
L["RAID_Other"] = "Other";

L["CHAT_REPORT_NOT_SIGNED_UP"] = "Du bist für :count raid(s) noch nicht angemeldet!";
L["CHAT_REPORT_HELP"] = "Gib :cmd ein um den Raid-Kalender zu öffnen.";

L["FRAME_CAL_HINT_LCLICK"] = "Linke Maustaste: Details / Anmeldung";
L["FRAME_CAL_HINT_RCLICK"] = "Right click: Neuen Raid erstellen";

L["FRAME_GENERIC_INVITE"] = "Invite";
L["FRAME_GENERIC_START"] = "Anfang";
L["FRAME_GENERIC_END"] = "Ende";
L["FRAME_GENERIC_RAID_GROUP"] = "Raid-Gruppe";
L["FRAME_GENERIC_INSTANCE"] = "Instanz";
L["FRAME_GENERIC_COMMENT"] = "Kommentar";
L["FRAME_GENERIC_DESCRIPTION"] = "Beschreibung";
L["FRAME_GENERIC_SAVE"] = "Speichern";
L["FRAME_GENERIC_DELETE"] = "Löschen";
L["FRAME_GENERIC_UPDATE"] = "Ändern";
L["FRAME_GENERIC_CREATED_BY"] = "Erstellt von";

L["FRAME_GROUPS_TITLE"] = "Raid-Gruppen";
L["FRAME_GROUPS_PEERS"] = "Peers";
L["FRAME_GROUPS_DELETE"] = "Löschen";

L["FRAME_GROUP_CREATE_HEADER"] = "Raid-Gruppe erstellen";
L["FRAME_GROUP_CREATE_TYPE"] = "Art der Gruppe";
L["FRAME_GROUP_CREATE_TYPE_PERSONAL"] = "Persönlich";
L["FRAME_GROUP_CREATE_TYPE_GUILD"] = "Gilden-Gruppe";
L["FRAME_GROUP_CREATE_TITLE"] = "Name der Raidgruppe";

L["FRAME_CREATE_TITLE"] = "Raid bearbeiten/erstellen";
L["FRAME_CREATE_TITLE_NEW"] = "Neuen Raid erstellen";
L["FRAME_CREATE_TITLE_EDIT"] = "Raid bearbeiten";

L["FRAME_SIGNUP_TITLE"] = "Zum Raid anmelden";
L["FRAME_SIGNUP_STATUS"] = "Status";
L["FRAME_SIGNUP_CHAR"] = "Charakter";
L["FRAME_SIGNUP_ROLE"] = "Rolle";
L["FRAME_SIGNUP_CLASS"] = "Klasse";
L["FRAME_SIGNUP_NOTES"] = "Notizen";
L["FRAME_SIGNUP_EDIT"] = "Bearbeiten";
L["FRAME_SIGNUP_CREATE"] = "Neuer Raid";
L["FRAME_SIGNUP_ACCEPT"] = "Bestätigen";
L["FRAME_SIGNUP_DECLINE"] = "Ablehnen";
L["FRAME_SIGNUP_TAB_OVERVIEW"] = "Übersicht";
L["FRAME_SIGNUP_TAB_PLAYERS_SIGNED_UP"] = "Angemeldet";
L["FRAME_SIGNUP_TAB_PLAYERS_CONFIRMED"] = "Bestätigt";
L["FRAME_SIGNUP_TAB_SIGNUP"] = "Anmelden";
L["FRAME_SIGNUP_STATUS_CONFIRMED"] = "Anmeldung durch Raidleitung bestätigt";
L["FRAME_SIGNUP_STATUS_ACK"] = "Anmeldung erfolgreich verschickt";
L["FRAME_SIGNUP_STATUS_PENDING"] = "Anmeldung steht noch aus...";
L["FRAME_SIGNUP_STATUS_OPEN"] = "Noch nicht angemeldet!";
L["FRAME_SIGNUP_TIME"] = "Zeitpunkt";
L["FRAME_SIGNUP_NONE_PLANNED"] = "Noch kein Raid geplant.";
L["FRAME_SIGNUP_PLAYERS_SELECTED"] = "Spieler ausgewählt";
