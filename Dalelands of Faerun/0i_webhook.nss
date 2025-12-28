/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 ScriptName: 0i_dbcalls
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Adapted from Dark Sun. https://github.com/tinygiant98/darksun-sot/tree/webhook
// Brought to my attention by Frozen North PW.

Must have the following environment variables set.
NWNX_ACTIVITY_DISCORD_PATH = to the discord activity channel - Integrations - Webhooks (Copy Webhook URL).
NWNX_BUG_DISCORD_PATH to the discord bug channel - Integrations - Webhooks (Copy Webhook URL).
*/////////////////////////////////////////////////////////////////////////////////////////////////////
const int TEXT_PLAYER_LOG_IN = 1;
const int TEXT_PLAYER_LOG_OUT = 2;
const int TEXT_CHAR_CREATE = 3;
const int TEXT_CHAR_DELETE = 4;
const int TEXT_LEVEL_UP = 5;
const string LOG_PLAYER_COLOR = "#0000ff"; // Blue
const string NEW_PLAYER_COLOR = "#00aaff"; // Light blue
const string LEVEL_UP_COLOR = "#00cccc"; //
const string DEATH_COLOR = "#dd0000"; // Red
const string VILLAIN_DEFEATED_COLOR = "#9900dd"; // Purple
const string SERVER_COLOR = "#b0b0b0"; // Gray
const string VALUABLE_ITEM_COLOR = "#cccc00"; // Gold
const string QUEST_DONE_COLOR = "#008800"; // Green
const string BUG_REPORT_COLOR = "#000000"; // Black
const string SERVER_NAME = "Dalelands of Faerun";
#include "nwnx_player"
#include "nwnx_webhook_rch"
#include "0i_database"
// Gets the number of players on the server.
int GetPlayerCount ()
{
    object oPC = GetFirstPC ();
    int nPCCnt = 0;
    while (GetIsObjectValid (oPC))
    {
        if (GetIsCharacter (oPC)) nPCCnt++;
        oPC = GetNextPC ();
    }
    return nPCCnt;
}
// Gets the number of dungeon masters on the server.
int GetDMCount ()
{
    object oPC = GetFirstPC ();
    int nDMCnt = 0;
    while (GetIsObjectValid (oPC))
    {
        if (GetIsDungeonMaster (oPC)) nDMCnt++;
        oPC = GetNextPC ();
    }
    return nDMCnt;
}
// Returns a string of a creatures class and level in nPosition.
string GetClassAndLevel (int nPosition, object oCreature)
{
    int nClass = GetClassByPosition (nPosition, oCreature);
    if (nClass == CLASS_TYPE_INVALID) return "";
    string sClass = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Name", nClass)));
    if (sClass != "") return sClass + " " + IntToString (GetLevelByPosition (nPosition, oCreature));
    else return "";
}
// Returns a string of a creatures class and levels.
string GetClassesAndLevels (object oCreature)
{
    string sClass = GetClassAndLevel (1, oCreature);
    string sClassLabel = "CLASS";
    if (GetLevelByPosition (2, oCreature) > 0)
        sClass = sClass + "/" + GetClassAndLevel (2, oCreature);
    if (GetLevelByPosition (3, oCreature) > 0)
        sClass = sClass + "/" + GetClassAndLevel (3, oCreature);
    if (GetLevelByPosition (4, oCreature) > 0)
        sClass = sClass + "/" + GetClassAndLevel (4, oCreature);
    if (GetLevelByPosition (5, oCreature) > 0)
        sClass = sClass + "/" + GetClassAndLevel (5, oCreature);
    return sClass;
}
// Adds additional values to the Webhook structure.
// nCustomFieldIndex can be from 1 to 10.
// nName is the name to be use for that index field.
// nValue is the value to be used for that index field.
struct NWNX_WebHook_Message SetWebhookCustomField (struct NWNX_WebHook_Message stMessage, int nCustomFieldIndex, string sName, string sValue, int bInline = TRUE)
{
    if (nCustomFieldIndex == 1)
        { stMessage.sField1Name = sName; stMessage.sField1Value = sValue; stMessage.nField1Inline = bInline; }
    if (nCustomFieldIndex == 2)
        { stMessage.sField2Name = sName; stMessage.sField2Value = sValue; stMessage.nField2Inline = bInline; }
    if (nCustomFieldIndex == 3)
        { stMessage.sField3Name = sName; stMessage.sField3Value = sValue; stMessage.nField3Inline = bInline; }
    if (nCustomFieldIndex == 4)
        { stMessage.sField4Name = sName; stMessage.sField4Value = sValue; stMessage.nField4Inline = bInline; }
    if (nCustomFieldIndex == 5)
        { stMessage.sField5Name = sName; stMessage.sField5Value = sValue; stMessage.nField5Inline = bInline; }
    if (nCustomFieldIndex == 6)
        { stMessage.sField6Name = sName; stMessage.sField6Value = sValue; stMessage.nField6Inline = bInline; }
    if (nCustomFieldIndex == 7)
        { stMessage.sField6Name = sName; stMessage.sField7Value = sValue; stMessage.nField7Inline = bInline; }
    if (nCustomFieldIndex == 8)
        { stMessage.sField6Name = sName; stMessage.sField8Value = sValue; stMessage.nField8Inline = bInline; }
    if (nCustomFieldIndex == 9)
        { stMessage.sField6Name = sName; stMessage.sField9Value = sValue; stMessage.nField9Inline = bInline; }
    if (nCustomFieldIndex == 10)
        { stMessage.sField6Name = sName; stMessage.sField10Value = sValue; stMessage.nField10Inline = bInline; }
    return stMessage;
}
void SendServerMessageToDiscord (string sTitle, string sDescription, string sUsername = SERVER_NAME,
                                 string sColor = SERVER_COLOR, string sAvatar = "", string sThumbnail = "")
{
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = sUsername;
  if (sAvatar != "") stMessage.sAvatarURL = sAvatar;
  if (sThumbnail != "") stMessage.sThumbnailURL = sThumbnail;
  stMessage.sColor = sColor;
  stMessage.sTitle = sTitle;
  stMessage.sDescription = sDescription;
  stMessage.sDescription = StripColorCodes (stMessage.sDescription);
  string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook (stMessage);
  NWNX_WebHook_SendWebHookHTTPS (sConstructedMsg, "NWNX_ACTIVITY_DISCORD_PATH");
}
// nTextOption = TEXT_*
// nData allows us to pass special data to specific TEXT_* options.
void SendPlayerLogToDiscord (object oPC, int nTextOption = TEXT_PLAYER_LOG_IN, int nData = 0)
{
    if (GetIsDungeonMaster (oPC))
    {
        string sOptions = GetServerDatabaseString (oPC, DM_TABLE, "options");
        if (GetStringArray (sOptions, 1) == "0") return;
    }
    struct NWNX_WebHook_Message stMessage;
    string sActionText, sDMs, sChar = "", sPlayers = "", sUserAction;
    // Set the description to show if they aregloging in or out.
    int nPlayers = GetPlayerCount ();
    int nDMs = GetDMCount ();
    if (nTextOption == TEXT_PLAYER_LOG_IN)
    {
        sUserAction = " has logged in.";
        sActionText += " has logged in";
        stMessage.sColor = LOG_PLAYER_COLOR;
        if (nDMs > 0) sDMs = "   Dungeon Masters: " + IntToString (nDMs);
        sPlayers = "Players: " + IntToString (nPlayers) + sDMs;
    }
    else if (nTextOption == TEXT_PLAYER_LOG_OUT)
    {
        sUserAction = " has logged out.";
        sActionText += " has logged out";
        if (GetIsCharacter (oPC)) nPlayers--;
        else nDMs--;
        stMessage.sColor = LOG_PLAYER_COLOR;
        if (nDMs > 0) sDMs = "   Dungeon Masters: " + IntToString (nDMs);
        sPlayers = "Players: " + IntToString (nPlayers) + sDMs;
    }
    else if (nTextOption == TEXT_CHAR_CREATE)
    {
        sUserAction = " has created a new character.";
        sActionText = " has been created";
        stMessage.sColor = NEW_PLAYER_COLOR;
        int nCharacters = GetServerDatabaseInt (oPC, PLAYER_TABLE, "characters");
        sChar = "Number of characters: " + IntToString (nCharacters);
        if (nDMs > 0) sDMs = "   Dungeon Masters: " + IntToString (nDMs);
        sPlayers = "Players: " + IntToString (nPlayers) + sDMs;
    }
    else if (nTextOption == TEXT_CHAR_DELETE)
    {
        sUserAction = " has deleted a character.";
        sActionText = " has been deleted";
        nPlayers = nPlayers - 1;
        stMessage.sColor = DEATH_COLOR;
        // Set field 3 for number of characters.
        int nCharacters = GetServerDatabaseInt (oPC, PLAYER_TABLE, "characters");
        sChar = "Number of characters: " + IntToString (nCharacters);
        SetLocalInt (oPC, "0_DELETED", TRUE);
        if (nDMs > 0) sDMs = "   Dungeon Masters: " + IntToString (nDMs);
        sPlayers = "Players: " + IntToString (nPlayers) + sDMs;
    }
    else if (nTextOption == TEXT_LEVEL_UP)
    {
        sUserAction = " leveled up a character.";
        sActionText = "has leveled up";
        stMessage.sColor = LEVEL_UP_COLOR;
    }
    stMessage.sUsername = GetPCPlayerName (oPC) + sUserAction;
    stMessage.sAvatarURL = "https://battledale-nwsync.com/pictures/character.jpg";
    stMessage.sThumbnailURL = "https://battledale-nwsync.com/portraits/" + GetStringLowerCase (GetPortraitResRef (oPC)) + "m.png";
    if (GetIsDungeonMaster (oPC))
    {
        stMessage.sDescription += "**" + GetName (oPC) + "** " + sActionText + " as a Dungeon Master.";
    }
    else
    {
        // Set line 1 for character name and description of the action.
        stMessage.sDescription = "**" + GetName (oPC) + "** " + sActionText + ".\\n";
        // Set line 2 for gender and race description.
        string sGender;
        if (GetGender (oPC)) sGender = "female";
        else sGender = "male";
        string sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oPC))));
        stMessage.sDescription += sGender + " " +  sRace + "\\n";
        // Set line 3 for class description.
        stMessage.sDescription += GetClassesAndLevels (oPC);
        // Set line 4/5 for Characters and/or Players.
        if (sChar != "") stMessage.sDescription += "\\n" + sChar;
    }
    if (sPlayers != "") stMessage.sDescription += "\\n" + sPlayers;
    stMessage.sDescription = StripColorCodes (stMessage.sDescription);
    string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook (stMessage);
    NWNX_WebHook_SendWebHookHTTPS (sConstructedMsg, "NWNX_ACTIVITY_DISCORD_PATH");
}
void SendPlayerRespawnToDiscord (object oPC, object oKiller)
{
    struct NWNX_WebHook_Message stMessage;
    stMessage.sAvatarURL = "https://battledale-nwsync.com/pictures/death.jpg";
    // Embeded data.
    stMessage.sColor = DEATH_COLOR;
    // Lets find out what killed us!
    string sDeathText, sName = GetName (oKiller);
    if (sName == "")
    {
        stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_piratex_m.png";
        sDeathText = " has been killed by an unknown force";
        stMessage.sUsername = "Death";
    }
    else
    {
        object oMaster = GetMaster(oKiller);
        if (GetIsObjectValid (oMaster))
        {
            int nAssociateType = GetAssociateType (oKiller);
            if (nAssociateType == ASSOCIATE_TYPE_FAMILIAR || nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION || nAssociateType == ASSOCIATE_TYPE_SUMMONED)
            {
                sDeathText = " has been killed by " + GetName (oMaster) + "'s " + GetName (oKiller);
                oKiller = oMaster;
            }
        }
        else sDeathText = " has been killed by a " + sName;
        stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase (GetPortraitResRef (oKiller)) + "m.png";
        stMessage.sUsername = StripColorCodes (GetName (oKiller)) + " has killed!";
    }
    string sArea = GetName (GetArea (oPC));
    // Set line 1 for character name and description of the action.
    stMessage.sDescription = "**" + GetName (oPC) + "** " + sDeathText + " in " + sArea + "!\\n";
    // Set line 2 for gender and race description.
    string sGender;
    if (GetGender (oPC)) sGender = "female";
    else sGender = "male";
    string sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oPC))));
    stMessage.sDescription += sGender + " " +  sRace + "\\n";
    // Set line 3 for class description.
    stMessage.sDescription += GetClassesAndLevels (oPC) + "\\n";
    // Set line 4 for number of deaths.
    string sDeaths;
    int nRespawns = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "respawns");
    if(nRespawns == 1) stMessage.sDescription += "**" + GetName (oPC) + "** has lost hardcore status!";
    stMessage.sDescription += "Number of Respawns: " + IntToString (nRespawns);
    stMessage.sDescription += sDeaths;
    if(sName != "")
    {
        // Set line 5 for oKiller stat block.
        if(GetGender(oKiller)) sGender = "female";
        else sGender = "male";
        sRace = GetStringByStrRef(StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType(oKiller))));
        stMessage.sDescription += "\\n**" + sName + "**\\n" + sGender + " " + sRace + "\\n";
        stMessage.sDescription += "CR: " + FloatToString (GetChallengeRating(oKiller), 0, 0) + " (" + GetClassesAndLevels(oKiller) + ")\\n";
    }
    stMessage.sDescription = StripColorCodes(stMessage.sDescription);
    string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook(stMessage);
    NWNX_WebHook_SendWebHookHTTPS (sConstructedMsg, "NWNX_ACTIVITY_DISCORD_PATH");
}
void SendPlayerQuestDoneToDiscord (object oPC, object oNPC, string sQuestName)
{
    struct NWNX_WebHook_Message stMessage;
    stMessage.sUsername = GetPCPlayerName (oPC) + " has finished a quest.";
    stMessage.sAvatarURL = "https://battledale-nwsync.com/pictures/quest.jpg";
    // Embeded data.
    stMessage.sColor = QUEST_DONE_COLOR;
    stMessage.sThumbnailURL = "https://battledale-nwsync.com/portraits/" + GetStringLowerCase (GetPortraitResRef (oNPC)) + "m.png";
    // Set line 1 for character name and description of the action.
    stMessage.sDescription = "**" + GetName (oPC) + "** has finished the " + sQuestName + "!\\n";
    // Set line 2 for gender and race description.
    string sGender;
    if (GetGender (oPC)) sGender = "female";
    else sGender = "male";
    string sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oPC))));
    stMessage.sDescription += sGender + " " +  sRace + "\\n";
    // Set line 3 for class description.
    stMessage.sDescription += GetClassesAndLevels (oPC) + "\\n";
    // Set line 4 for number of quests completed.
    string sDeaths;
    int nMainQuests = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "mainquests");
    int nSideQuests = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "sidequests");
    stMessage.sDescription += "Completed: Main quests (" + IntToString (nMainQuests) +
                              ") Side quests (" + IntToString (nSideQuests) + ")";
    stMessage.sDescription = StripColorCodes (stMessage.sDescription);
    string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook (stMessage);
    NWNX_WebHook_SendWebHookHTTPS (sConstructedMsg, "NWNX_ACTIVITY_DISCORD_PATH");
}
void SendPlayerVillainKilledToDiscord (object oPC, object oVillain)
{
    struct NWNX_WebHook_Message stMessage;
    stMessage.sUsername = GetPCPlayerName (oPC) + " has killed a villain.";
    stMessage.sAvatarURL = "https://battledale-nwsync.com/pictures/death.jpg";
    // Embeded data.
    stMessage.sColor = VILLAIN_DEFEATED_COLOR;
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase (GetPortraitResRef (oVillain)) + "m.png";
    // Set line 1 for character name and description of the action.
    string sVillainName = GetName (oVillain);
    stMessage.sDescription = "**" + GetName (oPC) + "**\\n";
    // Set line 2 for gender and race description.
    string sGender;
    if (GetGender (oPC)) sGender = "female";
    else sGender = "male";
    string sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oPC))));
    stMessage.sDescription += sGender + " " +  sRace + "\\n";
    // Set line 3 for class description.
    stMessage.sDescription += GetClassesAndLevels (oPC) + "\\n";
    // Set line 4 for Villain stat block.
    if (GetGender (oVillain)) sGender = "female";
    else sGender = "male";
    sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oVillain))));
    stMessage.sDescription += "**" + sVillainName + "**\\n" + sGender + " " + sRace + "\\n";
    stMessage.sDescription += "CR: " + FloatToString (GetChallengeRating (oVillain), 0, 0) + " (" + GetClassesAndLevels (oVillain) + ")\\n";
    stMessage.sDescription = StripColorCodes (stMessage.sDescription);
    string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook (stMessage);
    NWNX_WebHook_SendWebHookHTTPS (sConstructedMsg, "NWNX_ACTIVITY_DISCORD_PATH");
}
void SendServerDebugToDiscord (object oPC, string sLocation, string sReport)
{
    struct NWNX_WebHook_Message stMessage;
    stMessage.sUsername = GetPCPlayerName (oPC) + " has sent a bug report.";
    stMessage.sAvatarURL = "https://battledale-nwsync.com/pictures/bug_report.jpg";
    stMessage.sThumbnailURL = "https://battledale-nwsync.com/portraits/" + GetStringLowerCase (GetPortraitResRef (oPC)) + "m.png";
    stMessage.sColor = BUG_REPORT_COLOR;
    stMessage.sDescription = sLocation + "\\n\\n" + GetName (oPC) + ": " + sReport;
    stMessage.sDescription = StripColorCodes (stMessage.sDescription);
    string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook (stMessage);
    NWNX_WebHook_SendWebHookHTTPS (sConstructedMsg, "NWNX_BUG_DISCORD_PATH");
}
/*void ValuableItemWebhook(object oPC, object oItem, int nIsPurchased=FALSE);
void ValuableItemWebhook(object oPC, object oItem, int nIsPurchased=FALSE)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

    if (GetGoldPieceValue(oItem) < 14000)
    {
        return;
    }
    // Hopefully all cases of double reporting are fixed, but for safety's sake
    // This specifically stops the webhook firing twice for the player who identified an item for any reason
    // The lore event is by far the most dodgy detection...
    if (GetLocalObject(oItem, "webhook_valuable_identifier") == oPC)
    {
        return;
    }
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    // Messages work out to be like this:
    // PC has purchased an Amulet of Protection!
    // PC has identified an Amulet of Protection!

    string sAcquisitionMethod = nIsPurchased ? "purchased" : "identified";

    string sTitle;
    string sDescription = "**" + sName + "** has " + sAcquisitionMethod;
    string sNonDiscordDescription = sName + " has " + sAcquisitionMethod;
    int nPlayers = GetPlayerCount();

    stMessage = SetWebhookCustomField(stMessage, 1, "ITEM TYPE", GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", GetBaseItemType(oItem)))));
    stMessage = SetWebhookCustomField(stMessage, 2, "VALUE", IntToString(GetGoldPieceValue(oItem)));

    string sItemName = GetName(oItem);
    string sFirstLetter = GetStringLowerCase(GetStringLeft(sItemName, 1));
    if (sFirstLetter == "a" || sFirstLetter == "e" || sFirstLetter == "i" ||
        sFirstLetter == "o" || sFirstLetter == "u")
    {
        sDescription += " an **" + sItemName + "**!";
        sNonDiscordDescription += " an " + sItemName + "!";
    }
    else
    {
        sDescription += " a **" + sItemName + "**!";
        sNonDiscordDescription += " a " + sItemName + "!";
    }

    sTitle = "VALUABLE ITEM";

    stMessage.sTitle = sTitle;
    stMessage.sColor = VALUABLE_ITEM_COLOR;
    stMessage.sDescription = sDescription;

    // strongbox stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_a09_m.png";
    // chest transparent https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_a08_m.png
    // gold pile transparent https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_c08_m.png
    // gold chest transparent https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_c09_m.png
    // pirate gold chest black https://nwn.sfo2.digitaloceanspaces.com/portrait/po_pwc_ches01_m.png

    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_pwc_ches01_m.png";


    //SendDebugMessage("ValuableItemWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    //SendMessageToAllPCs(sNonDiscordDescription);
}


void HouseBuyWebhook(object oPC, int nGoldCost, object oArea);
void HouseBuyWebhook(object oPC, int nGoldCost, object oArea)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    // PC has purchased a house in Area for Gold!
    string sTitle = "HOUSE PURCHASED";
    string sDescription = "**" + sName + "** has purchased a house in " + GetName(oArea) + " for " + IntToString(nGoldCost) + " gold!";

    stMessage.sTitle = sTitle;
    stMessage.sColor = HOUSE_BUY_COLOR;
    stMessage.sAuthorName = sName;

    stMessage.sDescription = sDescription;

    // bed black https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_x0_bdb_m.png
    // balcony, not really a house but closest to uploaded https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_balce02_m.png
    // actual house, this is preferred but not uploaded https://nwn.sfo2.digitaloceanspaces.com/portrait/po_tm_tnohsa01_m.png

    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_balce02_m.png";

    //SendDebugMessage("HouseBuyWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    //SendMessageToAllPCs(sName + " has purchased a house in " + GetName(oArea) + " for " + IntToString(nGoldCost) + " gold!");
}
void BugReportWebhook(object oPC, string sMessage);
void BugReportWebhook(object oPC, string sMessage)
{
    string sDiscordKey = Get2DAString("env", "Value", ENV_DISCORD_BUG_REPORT_KEY_ROW);
    // SendDebugMessage("key " + sDiscordKey);
    if (sDiscordKey == "") return;
    // string sDiscordKey = GetDiscordKey();

    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    string sTitle = "BUG REPORT";

    stMessage.sTitle = sTitle;
    stMessage.sColor = BUG_REPORT_COLOR;
    stMessage.sUsername = "nwnx-webhook-bugs";

    stMessage.sDescription = sMessage;

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", sDiscordKey, stMessage);
    SendDiscordMessage(sConstructedMsg, sDiscordKey);
}         */
