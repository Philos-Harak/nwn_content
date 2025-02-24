/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_main
////////////////////////////////////////////////////////////////////////////////
 Include script for handling main/basic functions not defined by other includes.

 Database structure: Json with indexes.
 name (string)       - The associatetype to link the data. "pc", "familiar", etc.
 modes (jsonarray)   - 0-aimodes (int), 1-magicmodes (int)
 buttons (jsonarray) - 0-widgetbuttons (int), 1-aibuttons (int)
 aidata (jsonarray)  - 0-difficulty (int), 1-healoutcombat (int), 2-healincombat (int),
                       3-lootrange (float), 4-lockrange (float), 5-traprange (float),
                       6-Follow range (float).
 lootfilters (jsonarray) - 0-maxweight (int), 1-lootfilters (int),
      Item filters in min gold json array; 2-plot, 3-armor, 4-belts, 5-boots,
          6-cloaks, 7-gems, 8-gloves, 9-headgear, 10-jewelry, 11-misc, 12-potions,
          13-scrolls, 14-shields, 15-wands, 16-weapons, 17-arrow, 18-bolt, 19-bullet.
 plugins (jsonarray) - 0+ (string). * Only used in the "pc" data.
 location (jsonobject) - geometry (json), used in widgets for pc and associates.
*///////////////////////////////////////////////////////////////////////////////
const string AI_TABLE = "PEPS_TABLE";
const string AI_CAMPAIGN_DATABASE = "peps_database";
const string AI_DM_TABLE = "DM_TABLE";
#include "0i_constants"
#include "0i_messages"
// Sets PEPS RULES from the database to the module.
// Creates default rules if they do not exist.
void ai_CheckAIRules();
// Returns TRUE if oCreature is controlled by a player.
int ai_GetIsCharacter(object oCreature);
// Returns TRUE if oCreature is controlled by a dungeon master.
int ai_GetIsDungeonMaster(object oCreature);
// Returns the Player of oAssociate even if oAssociate is the player.
// If there is no player associated with oAssociate then it returns OBJECT_INVALID.
object ai_GetPlayerMaster(object oAssociate);
// Returns the percentage of hit points oCreature has left.
int ai_GetPercHPLoss(object oCreature);
// Returns a rolled result from sDice string.
// Example: "1d6" will be 1-6 or "3d6" will be 3-18 or 1d6+5 will be 6-11.
int ai_RollDiceString(string sDice);
// Returns the int number of a encoded 0x00000000 hex number from a string.
int ai_HexStringToInt(string sString);
// Returns cosine of the angle between oObject1 and oObject2
float ai_GetCosAngleBetween(object oObject1, object oObject2);
// Returns a string from sString with only characters in sLegal.
// Used to remove illegal characters for databases.
string ai_RemoveIllegalCharacters(string sString, string sLegal = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
// Returns the total levels of oCreature.
int ai_GetCharacterLevels(object oCreature);
// Returns a string where sFind is replaced in any occurrence of sSource with sReplace.
string ai_StringReplaceText(string sSource, string sFind, string sReplace);
// Returns a string of characters between the nIndex of predefined markers of
// sSeperator in sText.
// nIndex is the number of the data we are searching for in the array.
// A 0 nIndex is the first item in the text array.
// sSeperator is the character that seperates the array(Usefull for Multiple arrays).
string ai_GetStringArray(string sText, int nIndex, string sSeperator = ":");
// Returns a string of characters between the nIndex of predefined markers of
// sSeperator in sText where sField has been set.
// sText is the text holding the array.
// nIndex is the array number in the data we are searching for.
// A 0 nIndex is the first item in the text array.
// sField is the field of characters to replace that index.
// sSeperator is the character that seperates the array(Usefull for Multiple arrays).
string ai_SetStringArray(string sText, int nIndex, string sField, string sSeperator = ":");
// Returns the number of magical properties oItem has.
int ai_GetNumberOfProperties(object oItem);
// Checks if the campaign database table has been created and initialized.
void ai_CheckCampaignDataAndInitialize();
// Checks if the dm database table and data has been created and initialized of oDM.
void ai_CheckDMDataAndInitialize(object oDM);
// Sets json to a campaign database.
void ai_SetCampaignDbJson(string sDataField, json jData, string sName = "PEPS_DATA", string sTable = AI_TABLE);
// Gets json from a campaign database.
json ai_GetCampaignDbJson(string sDataField, string sName = "PEPS_DATA", string sTable = AI_TABLE);
// Checks if oMaster has the Table created for Associate data.
// If no table found then the table is created and then initialized.
void ai_CheckDataAndInitialize(object oPlayer, string sAssociateType);
// Returns the associate defined by sAssociateType string
// Text must be one of the following: pc, familiar, companion, summons, henchman#
object ai_GetAssociateByStringType(object oPlayer, string sAssociateType);
// Returns the associatetype int string format for oAssociate.
// They are pc, familar, companion, summons, henchman is the henchmans tag
string ai_GetAssociateType(object oPlayer, object oAssociate);
// Sets nData to sDataField for sAssociateType that is on oPlayer.
// sDataField can be modes, magicmodes, lootmodes, widgetbuttons, aibuttons, magic,
//                   healoutcombat, healincombat, mingold*.
void ai_SetAssociateDbInt(object oPlayer, string sAssociateType, string sDataField, int nData, string sTable = AI_TABLE);
// Returns nData from sDataField for sAssociateType that is on oPlayer.
// sDataField can be modes, magicmodes, lootmodes, widgetbuttons, aibuttons, magic,
//                   healoutcombat, healincombat, mingold*.
int ai_GetAssociateDbInt(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_TABLE);
// Sets fData to sDataField for sAssociateType that is on oPlayer.
// sDataField can be lootrange, lockrange, traprange.
void ai_SetAssociateDbFloat(object oPlayer, string sAssociatetype, string sDataField, float fData, string sTable = AI_TABLE);
// Returns fData from sDataField for sAssociateType that is on oPlayer.
// sDataField can be lootrange, lockrange, traprange.
float ai_GetAssociateDbFloat(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_TABLE);
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void ai_SetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, json jData, string sTable = AI_TABLE);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json ai_GetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_TABLE);
// Saves Associate AIModes and MagicModes to the database.
void aiSaveAssociateModesToDb(object oPlayer, object oAssociate);
// Checks Associate local data and if none is found will initialize or load the
// correct data for oAssociate.
void ai_CheckAssociateData(object oPlayer, object oAssociate, string sAssociateType, int bLoad = FALSE);
// Checks DM's local data and if none is found will initizlize or load the
// correct data for oPlayer.
void ai_CheckDMData(object oPlayer);
// Adds to jPlugins via "inplace" functions after checking if the plugin can be installed.
json ai_Plugin_Add(object oPC, json jPlugins, string sPluginScript);
// Updates the players Plugin list and saves to the database.
json ai_UpdatePluginsForPC(object oPC, string sAssociateType);
// Updates the DM's Plugin list and saves to the database.
json ai_UpdatePluginsForDM (object oPC);
// Runs all plugins that are loaded into the database.
void ai_StartupPlugins(object oPC);
void ai_CheckAIRules()
{
    object oModule = GetModule();
    ai_CheckCampaignDataAndInitialize();
    json jRules = ai_GetCampaignDbJson("rules");
    if(JsonGetType(JsonObjectGet(jRules, AI_RULE_MORAL_CHECKS)) == JSON_TYPE_NULL)
    {
        jRules = JsonObject();
        // Variable name set to a creatures full name to set debugging on.
        JsonObjectSetInplace(jRules, AI_RULE_DEBUG_CREATURE, JsonString(""));
        // Moral checks on or off.
        SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, AI_MORAL_CHECKS);
        JsonObjectSetInplace(jRules, AI_RULE_MORAL_CHECKS, JsonInt(AI_MORAL_CHECKS));
        // Allows monsters to prebuff before combat starts.
        SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, AI_PREBUFF);
        JsonObjectSetInplace(jRules, AI_RULE_BUFF_MONSTERS, JsonInt(AI_PREBUFF));
        // Allows monsters cast summons spells when prebuffing.
        SetLocalInt(oModule, AI_RULE_PRESUMMON, AI_PRESUMMONS);
        JsonObjectSetInplace(jRules, AI_RULE_PRESUMMON, JsonInt(AI_PRESUMMONS));
        // Allows monsters to use tactical AI scripts.
        SetLocalInt(oModule, AI_RULE_AMBUSH, AI_TACTICAL);
        JsonObjectSetInplace(jRules, AI_RULE_AMBUSH, JsonInt(AI_TACTICAL));
        // Enemies may summon familiars and Animal companions and will be randomized.
        SetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS, AI_SUMMON_COMPANIONS);
        JsonObjectSetInplace(jRules, AI_RULE_SUMMON_COMPANIONS, JsonInt(AI_SUMMON_COMPANIONS));
        // Allow the AI to move during combat base on the situation and action taking.
        SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, AI_ADVANCED_MOVEMENT);
        JsonObjectSetInplace(jRules, AI_RULE_ADVANCED_MOVEMENT, JsonInt(AI_ADVANCED_MOVEMENT));
        // Follow Item Level Restrictions for monsters/associates.
        SetLocalInt(oModule, AI_RULE_ILR, AI_ITEM_LEVEL_RESTRICTIONS);
        JsonObjectSetInplace(jRules, AI_RULE_ILR, JsonInt(AI_ITEM_LEVEL_RESTRICTIONS));
        // Allow the AI to use Use Magic Device.
        SetLocalInt(oModule, AI_RULE_ALLOW_UMD, AI_USE_MAGIC_DEVICE);
        JsonObjectSetInplace(jRules, AI_RULE_ALLOW_UMD, JsonInt(AI_USE_MAGIC_DEVICE));
        // Allow the AI to use healing kits.
        SetLocalInt(oModule, AI_RULE_HEALERSKITS, AI_HEALING_KITS);
        JsonObjectSetInplace(jRules, AI_RULE_HEALERSKITS, JsonInt(AI_HEALING_KITS));
        // Associates are permanent and don't get removed when the master dies.
        SetLocalInt(oModule, AI_RULE_PERM_ASSOC, AI_COMPANIONS_PERMANENT);
        JsonObjectSetInplace(jRules, AI_RULE_PERM_ASSOC, JsonInt(AI_COMPANIONS_PERMANENT));
        // Monster AI's chance to attack the weakest target instead of the nearest.
        SetLocalInt(oModule, AI_RULE_AI_DIFFICULTY, AI_TARGET_WEAKEST);
        JsonObjectSetInplace(jRules, AI_RULE_AI_DIFFICULTY, JsonInt(AI_TARGET_WEAKEST));
        // Monster AI's distance they can search for the enemy.
        SetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE, AI_SEARCH_DISTANCE);
        JsonObjectSetInplace(jRules, AI_RULE_PERCEPTION_DISTANCE, JsonFloat(AI_SEARCH_DISTANCE));
        // Enemy corpses remain on the floor instead of dissappearing.
        SetLocalInt(oModule, AI_RULE_CORPSES_STAY, AI_CORPSE_REMAIN);
        JsonObjectSetInplace(jRules, AI_RULE_CORPSES_STAY, JsonInt(AI_CORPSE_REMAIN));
        // Monsters will wander around when not in combat.
        SetLocalInt(oModule, AI_RULE_WANDER, AI_WANDER);
        JsonObjectSetInplace(jRules, AI_RULE_WANDER, JsonInt(AI_WANDER));
        // Increase the number of encounter creatures.
        SetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS, 0.0);
        JsonObjectSetInplace(jRules, AI_INCREASE_ENC_MONSTERS, JsonFloat(0.0));
        // Increase all monsters hitpoints by this percentage.
        SetLocalInt(oModule, AI_INCREASE_MONSTERS_HP, 0);
        JsonObjectSetInplace(jRules, AI_INCREASE_MONSTERS_HP, JsonInt(0));
        ai_SetCampaignDbJson("rules", jRules);
        // Monster's perception distance.
        SetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE, AI_PERCEPTION_DISTANCE);
        JsonObjectSetInplace(jRules, AI_RULE_MON_PERC_DISTANCE, JsonInt(AI_PERCEPTION_DISTANCE));
        // Variable name set to hold the maximum number of henchman the player wants.
        int nMaxHenchmen = GetMaxHenchmen();
        SetLocalInt(oModule, AI_RULE_MAX_HENCHMAN, nMaxHenchmen);
        JsonObjectSetInplace(jRules, AI_RULE_MAX_HENCHMAN, JsonInt(nMaxHenchmen));
        // Monster AI's distance they can wander away from their spawn point.
        SetLocalFloat(oModule, AI_RULE_WANDER_DISTANCE, AI_WANDER_DISTANCE);
        JsonObjectSetInplace(jRules, AI_RULE_WANDER_DISTANCE, JsonFloat(AI_WANDER_DISTANCE));
        ai_SetCampaignDbJson("rules", jRules);
        // Monsters will open doors when wandering around and not in combat.
        SetLocalInt(oModule, AI_RULE_OPEN_DOORS, AI_WANDER);
        JsonObjectSetInplace(jRules, AI_RULE_OPEN_DOORS, JsonInt(AI_OPEN_DOORS));
        // If the modules default XP has not been set then we do it here.
        int nDefaultXP = GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE);
        if(nDefaultXP == 0)
        {
            int nValue = GetModuleXPScale();
            if(nValue != 0) SetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE, nValue);
        }
        // Variable name set to allow the game to regulate experience based on party size.
        SetLocalInt(oModule, AI_RULE_PARTY_SCALE, AI_PARTY_SCALE);
        JsonObjectSetInplace(jRules, AI_RULE_PARTY_SCALE, JsonInt(AI_PARTY_SCALE));
    }
    else
    {
        // Variable name set to a creatures full name to set debugging on.
        string sValue = JsonGetString(JsonObjectGet(jRules, AI_RULE_DEBUG_CREATURE));
        SetLocalString(oModule, AI_RULE_DEBUG_CREATURE, sValue);
        // Moral checks on or off.
        int bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_MORAL_CHECKS));
        SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, bValue);
        // Allows monsters to prebuff before combat starts.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_BUFF_MONSTERS));
        SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, bValue);
        // Allows monsters cast summons spells when prebuffing.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_PRESUMMON));
        SetLocalInt(oModule, AI_RULE_PRESUMMON, bValue);
        // Allows monsters to use ambush AI scripts.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_AMBUSH));
        SetLocalInt(oModule, AI_RULE_AMBUSH, bValue);
        // Enemies may summon familiars and Animal companions and will be randomized.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_SUMMON_COMPANIONS));
        SetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS, bValue);
        // Allow the AI to move during combat base on the situation and action taking.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_ADVANCED_MOVEMENT));
        SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, bValue);
        // Follow Item Level Restrictions for monsters/associates.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_ILR));
        SetLocalInt(oModule, AI_RULE_ILR, bValue);
        // Allow the AI to use Use Magic Device.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_ALLOW_UMD));
        SetLocalInt(oModule, AI_RULE_ALLOW_UMD, bValue);
        // Allow the AI to use healing kits.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_HEALERSKITS));
        SetLocalInt(oModule, AI_RULE_HEALERSKITS, bValue);
        // Associates are permanent and don't get removed when the owner dies.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_PERM_ASSOC));
        SetLocalInt(oModule, AI_RULE_PERM_ASSOC, bValue);
        // Monster AI's chance to attack the weakest target instead of the nearest.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_AI_DIFFICULTY));
        SetLocalInt(oModule, AI_RULE_AI_DIFFICULTY, bValue);
        // Monster AI's perception distance from player.
        float fValue = JsonGetFloat(JsonObjectGet(jRules, AI_RULE_PERCEPTION_DISTANCE));
        SetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE, fValue);
        // Enemy corpses remain on the floor instead of dissappearing.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_CORPSES_STAY));
        SetLocalInt(oModule, AI_RULE_CORPSES_STAY, bValue);
        // Monsters will wander around when not in combat.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_WANDER));
        SetLocalInt(oModule, AI_RULE_WANDER, bValue);
        // Increase the number of encounter creatures.
        fValue = JsonGetFloat(JsonObjectGet(jRules, AI_INCREASE_ENC_MONSTERS));
        SetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS, fValue);
        // Increase all monsters hitpoints by this percentage.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_INCREASE_MONSTERS_HP));
        SetLocalInt(oModule, AI_INCREASE_MONSTERS_HP, bValue);
        // Monster's perception distance.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_MON_PERC_DISTANCE));
        if(bValue < 8 || bValue > 11) bValue = 11;
        SetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE, bValue);
        // Variable name set to hold the maximum number of henchman the player wants.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_MAX_HENCHMAN));
        if(bValue == 0) bValue = GetMaxHenchmen();
        else SetMaxHenchmen(bValue);
        SetLocalInt(oModule, AI_RULE_MAX_HENCHMAN, bValue);
        // Monster AI's wander distance from their spawn point.
        fValue = JsonGetFloat(JsonObjectGet(jRules, AI_RULE_WANDER_DISTANCE));
        SetLocalFloat(oModule, AI_RULE_WANDER_DISTANCE, fValue);
        // Monsters will open doors while wandering around and not in combat.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_OPEN_DOORS));
        SetLocalInt(oModule, AI_RULE_OPEN_DOORS, bValue);
        // If the modules default XP has not been set then we do it here.
        int nDefaultXP = GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE);
        if(nDefaultXP == 0)
        {
            bValue = GetModuleXPScale();
            if(bValue != 0) SetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE, bValue);
        }
        // Variable name set to allow the game to regulate experience based on party size.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_RULE_PARTY_SCALE));
        if(bValue)
        {
            int nBasePartyXP = GetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP);
            if(nBasePartyXP == 0)
            {
                nDefaultXP = GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE);
                SetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP, nDefaultXP);
            }
        }
        SetLocalInt(oModule, AI_RULE_PARTY_SCALE, bValue);
   }
}
int ai_GetIsCharacter(object oCreature)
{
    return (GetIsPC(oCreature) && !GetIsDM(oCreature) && !GetIsDMPossessed(oCreature));
}
int ai_GetIsDungeonMaster(object oCreature)
{
    return (GetIsDM(oCreature) || GetIsDMPossessed(oCreature));
}
object ai_GetPlayerMaster(object oAssociate)
{
    if(ai_GetIsCharacter(oAssociate)) return oAssociate;
    object oMaster = GetMaster(oAssociate);
    if(ai_GetIsCharacter(oMaster)) return oMaster;
    return OBJECT_INVALID;
}
int ai_GetPercHPLoss(object oCreature)
{
    int nHP = GetCurrentHitPoints(oCreature);
    if(nHP < 1) return 0;
    return(nHP * 100) / GetMaxHitPoints(oCreature);
}
int ai_RollDiceString(string sDice)
{
    int nNegativePos, nBonus = 0;
    string sRight = GetStringRight(sDice, GetStringLength(sDice) - FindSubString(sDice, "d") - 1);
    int nPlusPos = FindSubString(sRight, "+");
    if(nPlusPos != -1)
    {
        nBonus = StringToInt(GetStringRight(sRight, GetStringLength(sRight) - nPlusPos - 1));
        sRight = GetStringLeft(sRight, nPlusPos);
    }
    else
    {
        nNegativePos = FindSubString(sRight, "-");
        if(nNegativePos != -1)
        {
            nBonus = StringToInt(GetStringRight(sRight, GetStringLength(sRight) - nNegativePos - 1));
            sRight = GetStringLeft(sRight, nNegativePos);
            nBonus = nBonus * -1;
        }
    }
    int nDie = StringToInt(sRight);
    int nNumOfDie = StringToInt(GetStringLeft(sDice, FindSubString(sDice, "d")));
    int nResult;
    while(nNumOfDie > 0)
    {
        nResult += Random(nDie) + 1;
        nNumOfDie --;
    }
    return nResult + nBonus;
}
int ai_HexStringToInt(string sString)
{
    sString = GetStringLowerCase(sString);
    int nInt = 0;
    int nLength = GetStringLength(sString);
    int i;
    for(i = nLength - 1; i >= 0; i--)
    {
        int n = FindSubString("0123456789abcdef", GetSubString(sString, i, 1));
        if(n == -1) return nInt;
        nInt |= n << ((nLength - i - 1) * 4);
    }
    return nInt;
}
float ai_GetCosAngleBetween(object oObject1, object oObject2)
{
    vector v1 = GetPositionFromLocation(GetLocation(oObject1));
    vector v2 = GetPositionFromLocation(GetLocation(oObject2));
    vector v3 = GetPositionFromLocation(GetLocation(OBJECT_SELF));

    v1.x -= v3.x; v1.y -= v3.y; v1.z -= v3.z;
    v2.x -= v3.x; v2.y -= v3.y; v2.z -= v3.z;

    float dotproduct = v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;

    return dotproduct/(VectorMagnitude(v1)*VectorMagnitude(v2));
}
string ai_RemoveIllegalCharacters(string sString, string sLegal = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
{
    string sOut, sValue;
    sString = ai_StripColorCodes(sString);
    int nLength = GetStringLength(sString);
    int Cnt;
    for(Cnt = 0; Cnt != nLength; ++Cnt)
    {
        sValue = GetSubString(sString, Cnt, 1);
        if(TestStringAgainstPattern("**" + sValue + "**", sLegal))
            sOut += sValue;
    }
    return sOut;
}
int ai_GetCharacterLevels(object oCreature)
{
    int nLevels, nPosition = 1;
    while(nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        nLevels += GetLevelByPosition(nPosition, oCreature);
        nPosition++;
    }
    return nLevels;
}
string ai_StringReplaceText(string sSource, string sFind, string sReplace)
{
    int nFindLength = GetStringLength(sFind);
    int nPosition = 0;
    string sReturnValue = "";
    // Locate all occurences of sFind.
    int nFound = FindSubString(sSource, sFind);
    while(nFound >= 0 )
    {
        // Build the return string, replacing this occurence of sFind with sReplace.
        sReturnValue += GetSubString(sSource, nPosition, nFound - nPosition) + sReplace;
        nPosition = nFound + nFindLength;
        nFound = FindSubString(sSource, sFind, nPosition);
    }
    // Tack on the end of sSource and return.
    return sReturnValue + GetStringRight(sSource, GetStringLength(sSource) - nPosition);
}
string ai_GetStringArray(string sArray, int nIndex, string sSeperator = ":")
{
   int nCnt = 0, nMark = 0, nStringLength = GetStringLength(sArray);
   string sCharacter;
   // Search the string.
   while(nCnt < nStringLength)
   {
      sCharacter = GetSubString(sArray, nCnt, 1);
      // Look for the mark.
      if(sCharacter == sSeperator)
      {
         // If we have not found it then lets see if this mark is the one.
         if(nMark < 1)
         {
             // If we are down to 0 in the index then we have found the mark.
             if(nIndex > 0) nIndex --;
             // Mark the start of the string we need.
             else nMark = nCnt + 1;
         }
         else
         {
            // We have the first mark so the next mark will mean we have the string we need.
            // Now pull it and return.
            sArray = GetSubString(sArray, nMark, nCnt - nMark);
            return sArray;
         }
      }
      nCnt ++;
   }
   // If we hit the end without finding it then return "" as an error.
   return "";
}
string ai_SetStringArray(string sArray, int nIndex, string sField, string sSeperator = ":")
{
   int nCnt = 1, nMark = 1, nStringLength = GetStringLength(sArray);
   int nIndexCounter = 0;
   string sCharacter, sNewArray = sSeperator, sText;
   // Check to make sure this is not a new array.
   // If it is new then set it with 1 slot.
   if(nStringLength < 2)
   {
        sArray = sSeperator + " " + sSeperator;
        nStringLength = 3;
   }
   // Search the string.
   while(nCnt <= nStringLength)
   {
      sCharacter = GetSubString(sArray, nCnt, 1);
      // Look for the mark.
      if(sCharacter == sSeperator)
      {
            // First check to see if this is the index we are replacing.
            if(nIndex == nIndexCounter) sText = sField;
            else
            {
                // Get the original text for this field.
                sText = GetSubString(sArray, nMark, nCnt - nMark);
            }
            // Add the field to the new index.
            sNewArray = sNewArray + sText + sSeperator;
            // Now set the marker to the new starting point.
            nMark = nCnt + 1;
            // Increase the index counter as well.
            nIndexCounter ++;
      }
      nCnt ++;
   }
   // if we are at the end of the array and still have not set the data
   // then add blank data until we get to the correct index.
   while(nIndexCounter <= nIndex)
   {
        // If they match add the field.
        if(nIndexCounter == nIndex) sNewArray = sNewArray + sField + sSeperator;
        // Otherwise just add a blank field.
        else sNewArray = sNewArray + " " + sSeperator;
        nIndexCounter ++;
   }
   // When done return the new array.
   return sNewArray;
}
int ai_GetNumberOfProperties(object oItem)
{
    int nNumOfProperties = 0, nPropertyType, nPropertySubType;
    // Get first property
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        // Ignore double type properties such as bane.
        nPropertyType = GetItemPropertyType(ipProperty);
        switch(nPropertyType)
        {
            // Skip these properties as they don't count.
            case 8 : break; // EnhanceAlignmentGroup
            case 44 : break; // Light
            case 62 : break; // UseLimitationAlignmentGroup
            case 63 : break; // UseLimitationClass
            case 64 : break; // UseLimitationRacial
            case 65 : break; // UseLimitationSpecificAlignment
            case 66 : break; // UseLimitationTerrain
            case 86 : break; // Quality
            case 150 : break; // UseLimitationGender
            case 15 :
            {
                nPropertySubType = GetItemPropertySubType(ipProperty);
                if(nPropertySubType == IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY) break;
                if(nPropertySubType == IP_CONST_CASTSPELL_UNIQUE_POWER) break;
            }
            default : nNumOfProperties ++;
        }
        // Get the next property
        ipProperty = GetNextItemProperty(oItem);
    }
    // Reduce the number of properties by one on whips.
    if(GetBaseItemType(oItem) == BASE_ITEM_WHIP) nNumOfProperties --;
   return nNumOfProperties;
}
void ai_CreateCampaignDataTable()
{
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE,
        "CREATE TABLE IF NOT EXISTS " + AI_TABLE + "(" +
        "name              TEXT, " +
        "plugins           TEXT, " +
        "rules             TEXT, " +
        "PRIMARY KEY(name));");
    SqlStep(sql);
    //if(AI_DEBUG) ai_Debug("0i_main", "343", We are creating a campaign table [" +
    //         AI_TABLE + "] in the database.");
}
void ai_CheckCampaignDataTableAndCreateTable()
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@table", AI_TABLE);
    if(!SqlStep(sql)) ai_CreateCampaignDataTable();
    //else if(AI_DEBUG) ai_Debug("0i_main", "490", We have a database with table [" + AI_TABLE + "].");
}
void ai_InitializeCampaignData()
{
    string sQuery = "INSERT INTO " + AI_TABLE + "(name, plugins, rules) " +
        "VALUES(@name, @plugins, @rules);";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", "PEPS_DATA");
    SqlBindJson(sql, "@plugins", JsonArray());
    SqlBindJson(sql, "@rules", JsonObject());
    //if(AI_DEBUG) ai_Debug("0i_main", "363", "We are initializing campaign " +
    //         " data for table[" + AI_TABLE + "].");
    SqlStep(sql);
}
void ai_CheckCampaignDataAndInitialize()
{
    ai_CheckCampaignDataTableAndCreateTable();
    string sQuery = "SELECT name FROM " + AI_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", "PEPS_DATA");
    if(!SqlStep(sql)) ai_InitializeCampaignData();
}
void ai_CreateDMDataTable()
{
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE,
        "CREATE TABLE IF NOT EXISTS " + AI_DM_TABLE + "(" +
        "name              TEXT, " +
        "buttons           TEXT, " +
        "plugins           TEXT, " +
        "locations          TEXT, " +
        "options           TEXT, " +
        "saveslots         TEXT, " +
       "PRIMARY KEY(name));");
    SqlStep(sql);
}
void ai_CheckDMDataTableAndCreateTable()
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@table", AI_DM_TABLE);
    if(!SqlStep(sql)) ai_CreateDMDataTable();
}
void ai_InitializeDMData(string sName)
{
    string sQuery = "INSERT INTO " + AI_DM_TABLE + "(name, buttons, plugins, " +
                    "location, options, saveslots) " +
                    "VALUES(@name, @buttons, @plugins, @location, @options, @saveslots);";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindJson(sql, "@buttons", JsonArray());
    SqlBindJson(sql, "@plugins", JsonArray());
    SqlBindJson(sql, "@location", JsonObject());
    SqlBindJson(sql, "@options", JsonObject());
    SqlBindJson(sql, "@saveslots", JsonObject());
    SqlStep(sql);
}
void ai_CheckDMDataAndInitialize(object oDM)
{
    string sName = ai_RemoveIllegalCharacters(ai_StripColorCodes(GetName(oDM)));
    string sQuery = "SELECT name FROM " + AI_DM_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sName);
    if(!SqlStep(sql))
    {
        ai_CheckDMDataTableAndCreateTable();
        ai_InitializeDMData(sName);
    }
}
void ai_SetCampaignDbJson(string sDataField, json jData, string sName = "PEPS_DATA", string sTable = AI_TABLE)
{
    string sQuery = "UPDATE " + sTable + " SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindJson(sql, "@data", jData);
    SqlBindString(sql, "@name", sName);
    SqlStep(sql);
}
json ai_GetCampaignDbJson(string sDataField, string sName = "PEPS_DATA", string sTable = AI_TABLE)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", sName);
    json jReturn;
    if(SqlStep(sql)) return SqlGetJson (sql, 0);
    else return JsonArray();
    return jReturn;
}
void ai_CreateAssociateDataTable(object oPlayer)
{
    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "CREATE TABLE IF NOT EXISTS " + AI_TABLE + "(" +
        "name              TEXT, " +
        "modes             TEXT, " +
        "buttons           TEXT, " +
        "aidata            TEXT, " +
        "lootfilters       TEXT, " +
        "plugins           TEXT, " +
        "locations         TEXT, " +
        "PRIMARY KEY(name));");
    SqlStep(sql);
    //ai_Debug("0i_main", "489", GetName(oPlayer) + " is creating a table [" +
    //         AI_TABLE + "] in the database.");
}
void ai_CheckDataTableAndCreateTable(object oPlayer)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@table", AI_TABLE);
    if(!SqlStep(sql)) ai_CreateAssociateDataTable (oPlayer);
    //else ai_Debug("0i_main", "499", GetName(oPlayer) + " has a database with table [" + AI_TABLE + "].");
}
void ai_InitializeAssociateData(object oPlayer, string sAssociateType)
{
    string sQuery = "INSERT INTO " + AI_TABLE + "(name, modes, buttons, " +
        "aidata, lootfilters, plugins, locations) " +
        "VALUES(@name, @modes, @buttons, @aidata, @lootfilters, @plugins, @locations);";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociateType);
    SqlBindJson(sql, "@modes", JsonArray());
    SqlBindJson(sql, "@buttons", JsonArray());
    SqlBindJson(sql, "@aidata", JsonArray());
    SqlBindJson(sql, "@lootfilters", JsonArray());
    SqlBindJson(sql, "@plugins", JsonArray());
    SqlBindJson(sql, "@locations", JsonObject());
    //ai_Debug("0i_main", "514", GetName(oPlayer) + " is initializing associate " +
    //         sAssociateType + " data for table[" + AI_TABLE + "].");
    SqlStep(sql);
}
void ai_CheckDataAndInitialize(object oPlayer, string sAssociateType)
{
    ai_CheckDataTableAndCreateTable(oPlayer);
    string sQuery = "SELECT name FROM " + AI_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociateType);
    if(!SqlStep(sql)) ai_InitializeAssociateData(oPlayer, sAssociateType);
}
object ai_GetAssociateByStringType(object oPlayer, string sAssociateType)
{
    if(sAssociateType == "pc") return oPlayer;
    else if (sAssociateType == "familiar") return GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPlayer);
    else if (sAssociateType == "companion") return GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPlayer);
    else if (sAssociateType == "summons") return GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPlayer);
    else if (sAssociateType == "dominated") return GetAssociate(ASSOCIATE_TYPE_DOMINATED, oPlayer);
    else return GetNearestObjectByTag(sAssociateType, oPlayer);
    return OBJECT_INVALID;
}
string ai_GetAssociateType(object oPlayer, object oAssociate)
{
    if(GetIsPC(oAssociate)) return "pc";
    int nAssociateType = GetAssociateType(oAssociate);
    if(nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION) return "companion";
    else if(nAssociateType == ASSOCIATE_TYPE_FAMILIAR) return "familiar";
    else if(nAssociateType == ASSOCIATE_TYPE_SUMMONED) return "summons";
    else if(nAssociateType == ASSOCIATE_TYPE_DOMINATED) return "dominated";
    else if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN) return GetTag(oAssociate);
    return "";
}
void ai_SetAssociateDbInt(object oPlayer, string sAssociatetype, string sDataField, int nData, string sTable = AI_TABLE)
{
    string sQuery = "UPDATE " + sTable + " SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    SqlBindInt(sql, "@data", nData);
    //ai_Debug("0i_main", "368", "SETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField + " nData: " + IntToString(nData));
    SqlStep(sql);
}
int ai_GetAssociateDbInt(object oPlayer, string sAssociatetype, string sDataField, string sTable = AI_TABLE)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    //ai_Debug("0i_main", "377", "GETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField);
    if(SqlStep(sql)) return SqlGetInt(sql, 0);
    else return 0;
}
void ai_SetAssociateDbFloat(object oPlayer, string sAssociatetype, string sDataField, float fData, string sTable = AI_TABLE)
{
    string sQuery = "UPDATE " + sTable + " SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    SqlBindFloat(sql, "@data", fData);
    //ai_Debug("0i_main", "368", "SETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField + " fData: " + FloatToString(fData, 0, 0));
    SqlStep(sql);
}
float ai_GetAssociateDbFloat(object oPlayer, string sAssociatetype, string sDataField, string sTable = AI_TABLE)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    //ai_Debug("0i_main", "377", "GETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField);
    if(SqlStep(sql)) return SqlGetFloat(sql, 0);
    else return 0.0;
}
void ai_SetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, json jData, string sTable = AI_TABLE)
{
    //ai_Debug("0i_main", "629", "Set DbJson - sAssociateType: " + sAssociateType + " sDataField: " + sDataField + " jData: " + JsonDump(jData));
    string sQuery = "UPDATE " + sTable + " SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson(sql, "@data", jData);
    SqlBindString(sql, "@name", sAssociateType);
    SqlStep(sql);
}
json ai_GetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_TABLE)
{
    //ai_Debug("0i_main", "638", "Get DbJson - sAssociateType: " + sAssociateType + " sDataField: " + sDataField);
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@name", sAssociateType);
    if(SqlStep(sql))
    {
        json jReturn = SqlGetJson(sql, 0);
        //ai_Debug("0i_main", "646", JsonDump(jReturn, 1));
        if(JsonGetType(jReturn) == JSON_TYPE_NULL) return JsonArray();
        return jReturn;
    }
    else return JsonNull();
}
void aiSaveAssociateModesToDb(object oPlayer, object oAssociate)
{
    string sAssociateType = ai_GetAssociateType(oPlayer, oAssociate);
    json jModes = ai_GetAssociateDbJson(oPlayer, sAssociateType, "modes");
    int nAIMode = GetLocalInt(oAssociate, sAIModeVarname);
    jModes = JsonArraySet(jModes, 0, JsonInt(nAIMode));
    int nMagicMode = GetLocalInt(oAssociate, sMagicModeVarname);
    jModes = JsonArraySet(jModes, 1, JsonInt(nMagicMode));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes);
}
void ai_CheckPlayerForData(object oPlayer)
{
    // If the player has no data then lets create some.
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@table", AI_TABLE);
    if(!SqlStep(sql)) ai_CheckDataAndInitialize(oPlayer, "pc");
    ai_CheckAssociateData(oPlayer, oPlayer, "pc");
}
void ai_SetupModes(object oPlayer, object oAssociate, string sAssociateType)
{
    json jModes = JsonArray();
    jModes = JsonArrayInsert(jModes, JsonInt(0)); // AI Modes.
    // Set magic modes to use Normal magic, Bit 256.
    jModes = JsonArrayInsert(jModes, JsonInt(256)); // Magic Modes.
    SetLocalInt(oAssociate, sMagicModeVarname, 256);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes, AI_TABLE);
}
void ai_SetupButtons(object oPlayer, object oAssociate, string sAssociateType)
{
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, JsonInt(0)); // Command buttons.
    jButtons = JsonArrayInsert(jButtons, JsonInt(0)); // AI buttons.
    jButtons = JsonArrayInsert(jButtons, JsonInt(0)); // AI buttons 2.
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons, AI_TABLE);
}
void ai_SetupAIData(object oPlayer, object oAssociate, string sAssociateType)
{
    json jAIData = JsonArray();
    jAIData = JsonArrayInsert(jAIData, JsonInt(0));      // 0 - Difficulty adjustment.
    jAIData = JsonArrayInsert(jAIData, JsonInt(70));     // 1 - Heal out of combat.
    SetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    jAIData = JsonArrayInsert(jAIData, JsonInt(50));     // 2 - Heal in combat.
    SetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT, 50);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(20.0)); // 3 - Loot check range.
    SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, 20.0);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(20.0)); // 4 - Lock check range.
    SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, 20.0);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(20.0)); // 5 - Trap check range.
    SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, 20.0);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(3.0));  // 6 - Associate Distance.
    SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, 3.0);
    // This can be replaced as it is not used in the database.
    // We keep it for now as we don't want to move other data.
    jAIData = JsonArrayInsert(jAIData, JsonInt(11));     // 7 - Associate Perception DistanceDistance.
    SetLocalInt(oAssociate, AI_PERCEPTION_RANGE, 11);
    jAIData = JsonArrayInsert(jAIData, JsonString(""));  // 8 - Associate Combat Tactics.
    jAIData = JsonArrayInsert(jAIData, JsonFloat(20.0)); // 9 - Open Doors check range.
    SetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE, 20.0);
    json jSpells = JsonArray();
    jAIData = JsonArrayInsert(jAIData, jSpells);         // 10 - Castable spells.
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData, AI_TABLE);
}
void ai_SetupLootFilters(object oPlayer, object oAssociate, string sAssociateType)
{
    json jLootFilters = JsonArray();
    // Maximum weight to pickup an item.
    jLootFilters = JsonArrayInsert(jLootFilters, JsonInt(200));
    SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, 200);
    // Bitwise int for checkbox pickup filter.
    jLootFilters = JsonArrayInsert(jLootFilters, JsonInt(AI_LOOT_ALL_ON));
    SetLocalInt(oAssociate, sLootFilterVarname, AI_LOOT_ALL_ON);
    // Minimum gold value to pickup.
    int nIndex;
    for(nIndex = 2; nIndex < 20; nIndex++)
    {
        jLootFilters = JsonArrayInsert(jLootFilters, JsonInt(0));
    }
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters, AI_TABLE);
}
void ai_SetupLocations(object oPlayer, object oAssociate, string sAssociateType)
{
    json jLocations = JsonObject();
    json jNUI = JsonObject();
    jNUI = JsonObjectSet(jNUI, "x", JsonFloat(-1.0));
    jNUI = JsonObjectSet(jNUI, "y", JsonFloat(-1.0));
    jLocations = JsonObjectSet(jLocations, AI_MAIN_NUI, jNUI);
    jLocations = JsonObjectSet(jLocations, AI_COMMAND_NUI, jNUI);
    jLocations = JsonObjectSet(jLocations, AI_NUI, jNUI);
    jLocations = JsonObjectSet(jLocations, AI_LOOTFILTER_NUI, jNUI);
    jLocations = JsonObjectSet(jLocations, AI_COPY_NUI, jNUI);
    if(ai_GetIsCharacter(oAssociate)) jLocations = JsonObjectSet(jLocations, AI_PLUGIN_NUI, jNUI);
    jNUI = JsonObjectSet(jLocations, "x", JsonFloat(1.0));
    jNUI = JsonObjectSet(jLocations, "y", JsonFloat(1.0));
    jLocations = JsonObjectSet(jLocations, AI_WIDGET_NUI, jNUI);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocations, AI_TABLE);
}
void ai_SetupAssociateData(object oPlayer, object oAssociate, string sAssociateType)
{
    //ai_Debug("0i_main", "744", GetName(oAssociate) + " is initializing associate data.");
    // Default behavior for associates at start.
    ai_SetupModes(oPlayer, oAssociate, sAssociateType);
    ai_SetupButtons(oPlayer, oAssociate, sAssociateType);
    ai_SetupAIData(oPlayer, oAssociate, sAssociateType);
    ai_SetupLootFilters(oPlayer, oAssociate, sAssociateType);
    // ********** Plugins ************
    // These are pulled straight from the database.
    ai_SetupLocations(oPlayer, oAssociate, sAssociateType);
}
void ai_RestoreDatabase(object oPlayer, object oAssociate, string sAssociateType)
{
    // ********** Modes **********
    json jModes = JsonArray();
    // AI Modes (0).
    int nValue = GetLocalInt(oAssociate, sAIModeVarname);
    jModes = JsonArrayInsert(jModes, JsonInt(nValue));
    // Magic Modes (1).
    nValue = GetLocalInt(oAssociate, sMagicModeVarname);
    jModes = JsonArrayInsert(jModes, JsonInt(nValue));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes, AI_TABLE);
    // ********** Buttons **********
    json jButtons = JsonArray();
    // Command buttons (0).
    nValue = GetLocalInt(oAssociate, sWidgetButtonsVarname + sAssociateType);
    jButtons = JsonArrayInsert(jButtons, JsonInt(nValue));
    // AI buttons Group 1 (1).
    nValue = GetLocalInt(oAssociate, sAIButtonsVarname + sAssociateType);
    jButtons = JsonArrayInsert(jButtons, JsonInt(nValue));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons, AI_TABLE);
    // ********** AI Data **********
    json jAIData = JsonArray();
    nValue = GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT);
    jAIData = JsonArrayInsert(jAIData, JsonInt(nValue));
    nValue = GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT);
    jAIData = JsonArrayInsert(jAIData, JsonInt(nValue));
    nValue = GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT);
    jAIData = JsonArrayInsert(jAIData, JsonInt(nValue));
    float fValue = GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(fValue));
    fValue = GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(fValue));
    fValue = GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(fValue));
    fValue = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(fValue));
    // No need to keep in the database AI_PERCEPTION_RANGE!
    jAIData = JsonArrayInsert(jAIData, JsonInt(11));
    string sValue = GetLocalString(oAssociate, AI_DEFAULT_SCRIPT);
    jAIData = JsonArrayInsert(jAIData, JsonString(sValue));
    fValue = GetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE);
    jAIData = JsonArrayInsert(jAIData, JsonFloat(fValue));
    json jValue = GetLocalJson(oPlayer, AI_SPELLS_WIDGET);
    if(JsonGetType(jValue) == JSON_TYPE_NULL)
    {
        jValue = JsonArray();
        jValue = JsonArrayInsert(jValue, JsonInt(1)); // 0 - Class selected.
        jValue = JsonArrayInsert(jValue, JsonInt(10)); // 1 - Level selected.
        jValue = JsonArrayInsert(jValue, JsonArray()); // Spell list for widget.
        SetLocalJson(oPlayer, AI_SPELLS_WIDGET, jValue);
    }
    jAIData = JsonArrayInsert(jAIData, jValue);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData);
    // ********** LootFilters **********
    json jLootFilters = JsonArray();
    nValue = GetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT);
    jLootFilters = JsonArrayInsert(jLootFilters, JsonInt(nValue));
    nValue = GetLocalInt(oAssociate, sLootFilterVarname);
    jLootFilters = JsonArrayInsert(jLootFilters, JsonInt(nValue));
    int nIndex;
    for(nIndex = 2; nIndex < 20; nIndex++)
    {
       nValue = GetLocalInt(oAssociate, AI_MIN_GOLD_ + IntToString(nIndex));
       jLootFilters = JsonArrayInsert(jLootFilters, JsonInt(nValue));
    }
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters, AI_TABLE);
    // ********** Plugins ************
    // These are pulled straight from the database.
    // ********** Locations **********
    // These are only in the database.
}
void ai_CheckAssociateData(object oPlayer, object oAssociate, string sAssociateType, int bLoad = FALSE)
{
    //ai_Debug("0i_main", "810", "Checking data for oAssociate: " + GetName(oAssociate));
    // Do quick check to see if they have a variable saved if so then exit.
    if(GetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE) != 0.0)
    {
        if(!bLoad) return;
        // If the database gets destroyed lets drop an error and restore values
        // From the locals.
        ai_RestoreDatabase(oPlayer, oAssociate, sAssociateType);
    }
    ai_CheckDataAndInitialize(oPlayer, sAssociateType);
    // ********** Modes **********
    json jModes = ai_GetAssociateDbJson(oPlayer, sAssociateType, "modes");
    if(JsonGetType(JsonArrayGet(jModes, 0)) == JSON_TYPE_NULL)
    {
        ai_SetupModes(oPlayer, oAssociate, sAssociateType);
    }
    else
    {
        SetLocalInt(oAssociate, sAIModeVarname, JsonGetInt(JsonArrayGet(jModes, 0)));
        SetLocalInt(oAssociate, sMagicModeVarname, JsonGetInt(JsonArrayGet(jModes, 1)));
    }
    // ********** Buttons **********
    json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
    if(JsonGetType(JsonArrayGet(jButtons, 0)) == JSON_TYPE_NULL)
    {
        ai_SetupButtons(oPlayer, oAssociate, sAssociateType);
    }
    else
    {
        // ********** Associate Command Buttons **********
        int nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
        string sWidgetButtonName = sWidgetButtonsVarname + sAssociateType;
        if(nWidgetButtons) SetLocalInt(oAssociate, sWidgetButtonName, nWidgetButtons);
        // ********** Associate AI Buttons **********
        int nAIButtons = JsonGetInt(JsonArrayGet(jButtons, 1));
        string sAIButtonName = sAIButtonsVarname + sAssociateType;
        if(nAIButtons) SetLocalInt(oAssociate, sAIButtonName, nAIButtons);
    }
    // ********** AI Data **********
    json jAIData = ai_GetAssociateDbJson(oPlayer, sAssociateType, "aidata");
    if(JsonGetType(JsonArrayGet(jAIData, 0)) == JSON_TYPE_NULL)
    {
        ai_SetupAIData(oPlayer, oAssociate, sAssociateType);
    }
    else
    {
        SetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT, JsonGetInt(JsonArrayGet(jAIData, 0)));
        SetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT, JsonGetInt(JsonArrayGet(jAIData, 1)));
        SetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT, JsonGetInt(JsonArrayGet(jAIData, 2)));
        SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 3)));
        SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 4)));
        SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 5)));
        SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 6)));
        // No need to keep in the database!
        //int nPercRange = JsonGetInt(JsonArrayGet(jAIData, 7));
        //if(nPercRange != 8 || nPercRange != 9 || nPercRange != 10 || nPercRange != 11) nPercRange = 11;
        //SetLocalInt(oAssociate, AI_PERCEPTION_RANGE, nPercRange);
        string sScript = JsonGetString(JsonArrayGet(jAIData, 8));
        if(sScript != "") SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, sScript);
        json jDoorRange = JsonArrayGet(jAIData, 9);
        if(JsonGetType(jDoorRange) == JSON_TYPE_NULL)
        {
            jAIData = JsonArrayInsert(jAIData, JsonFloat(20.0));
            ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData);
            SetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE, 20.0);
        }
        else SetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE, JsonGetFloat(jDoorRange));
        json jSpellsWidget = JsonArrayGet(jAIData, 10);
        if(JsonGetType(jSpellsWidget) == JSON_TYPE_NULL)
        {
            jSpellsWidget = JsonArray();
            jSpellsWidget = JsonArrayInsert(jSpellsWidget, JsonInt(0)); // 0 - Class selected.
            jSpellsWidget = JsonArrayInsert(jSpellsWidget, JsonInt(0)); // 1 - Level selected.
            jAIData = JsonArrayInsert(jAIData, jSpellsWidget);
            ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData);
            SetLocalJson(oPlayer, AI_SPELLS_WIDGET, jSpellsWidget);
        }
    }
    // ********** LootFilters **********
    json jLootFilters = ai_GetAssociateDbJson(oPlayer, sAssociateType, "lootfilters");
    if(JsonGetType(JsonArrayGet(jLootFilters, 0)) == JSON_TYPE_NULL)
    {
        ai_SetupLootFilters(oPlayer, oAssociate, sAssociateType);
    }
    else
    {
        SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, JsonGetInt(JsonArrayGet(jLootFilters, 0)));
        SetLocalInt(oAssociate, sLootFilterVarname, JsonGetInt(JsonArrayGet(jLootFilters, 1)));
        int nIndex;
        for(nIndex = 2; nIndex < 20; nIndex++)
        {
            SetLocalInt(oAssociate, AI_MIN_GOLD_ + IntToString(nIndex), JsonGetInt(JsonArrayGet(jLootFilters, nIndex)));
        }
    }
    // ********** Plugins ************
    // These are pulled straight from the database.
    // ********** Locations **********
    json jLocations = ai_GetAssociateDbJson(oPlayer, sAssociateType, "locations");
    if(JsonGetType(JsonObjectGet(jLocations, AI_WIDGET_NUI)) == JSON_TYPE_NULL)
    {
        ai_SetupLocations(oPlayer, oAssociate, sAssociateType);
    }
    // They are always pulled from the database, so no copies to local variables.
}
void ai_SetupDMData(object oPlayer, string sName)
{
    //ai_Debug("0i_main", "870", GetName(oPlayer) + " is initializing DM data.");
    // ********** Buttons **********
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, JsonInt(0)); // DM Widget Buttons.
    ai_SetCampaignDbJson("buttons", jButtons, sName, AI_DM_TABLE);
    // ********** Plugins ************
    // These are pulled straight from the database.
    json jPlugins = JsonArray();
    ai_SetCampaignDbJson("plugins", jPlugins, sName, AI_DM_TABLE);
    // ********** Locations **********
    json jLocations = JsonObject();
    json jNUI = JsonObject();
    jNUI = JsonObjectSet(jNUI, "x", JsonFloat(-1.0));
    jNUI = JsonObjectSet(jNUI, "y", JsonFloat(-1.0));
    jLocations = JsonObjectSet(jLocations, AI_MAIN_NUI, jNUI);
    jLocations = JsonObjectSet(jLocations, AI_PLUGIN_NUI, jNUI);
    jNUI = JsonObjectSet(jLocations, "x", JsonFloat(1.0));
    jNUI = JsonObjectSet(jLocations, "y", JsonFloat(1.0));
    jLocations = JsonObjectSet(jLocations, AI_WIDGET_NUI, jNUI);
    ai_SetCampaignDbJson("locations", jLocations, sName, AI_DM_TABLE);
    // ********** Options **********
    json jOptions = JsonArray();
    ai_SetCampaignDbJson("options", jOptions, sName, AI_DM_TABLE);
    // ********** SaveSlots **********
    json jSaveSlots = JsonObject();
    ai_SetCampaignDbJson("saveslots", jSaveSlots, sName, AI_DM_TABLE);
}
void ai_CheckDMData(object oPlayer)
{
    //ai_Debug("0i_main", "898", "Checking data for DM: " + GetName(oPlayer));
    string sName = ai_RemoveIllegalCharacters(GetName(oPlayer));
    // ********** Buttons **********
    json jButtons = ai_GetCampaignDbJson("buttons", sName, AI_DM_TABLE);
    // if there is no saved AImodes then set the defaults.
    if(JsonGetType(JsonArrayGet(jButtons, 0)) == JSON_TYPE_NULL)
    {
        ai_SetupDMData(oPlayer, sName);
    }
    else
    {
        //ai_Debug("0i_main", "909", GetName(oPlayer) + " is loading DM data from the database.");
        // Get data from the database and place on to the associates and player.
        // ********** Buttons **********
        json jButtons = ai_GetCampaignDbJson("buttons", sName, AI_DM_TABLE);
        if(JsonGetType(JsonArrayGet(jButtons, 0)) == JSON_TYPE_NULL)
        {
            ai_SetupDMData(oPlayer, sName);
        }
        SetLocalInt(oPlayer, sDMWidgetButtonVarname, JsonGetInt(JsonArrayGet(jButtons, 0)));
        // ********** Associate Command Buttons **********
        int nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
        SetLocalInt(oPlayer, sDMWidgetButtonVarname, nWidgetButtons);
        // ********** Plugins ************
        // These are pulled straight from the database.
        // ********** Locations **********
        // These are pulled straight from the database.
        // ********** Options **********
        // ********** SaveSltos **********
    }
}
json ai_Plugin_Add(object oPC, json jPlugins, string sPluginScript)
{
    if(ResManGetAliasFor(sPluginScript, RESTYPE_NCS) == "")
    {
        ai_SendMessages("The script (" + sPluginScript + ") was not found by ResMan!", AI_COLOR_RED, oPC);
        return jPlugins;
    }
    int nIndex;
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        if(JsonGetString(JsonArrayGet(jPlugin, 0)) == sPluginScript)
        {
            ai_SendMessages("Plugin (" + sPluginScript + ") is already installed!", AI_COLOR_RED, oPC);
            return jPlugins;
        }
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    SetLocalInt(oPC, AI_ADD_PLUGIN, TRUE);
    SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugins);
    ExecuteScript(sPluginScript, oPC);
    if(GetLocalInt(oPC, AI_PLUGIN_SET))
    {
        jPlugin = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
    }
    else
    {
        jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString(sPluginScript));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString(sPluginScript));
        int nCount = JsonGetLength(jPlugins) + 1;
        string sIcon = "is_summon" + IntToString(nCount);
        jPlugin = JsonArrayInsert(jPlugin, JsonString(sIcon));
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
    }
    DeleteLocalInt(oPC, AI_ADD_PLUGIN);
    DeleteLocalInt(oPC, AI_PLUGIN_SET);
    DeleteLocalJson(oPC, AI_JSON_PLUGINS);
    return jPlugins;
}
// Temporary function to addapt old plugin json to new plugin json.
void ai_CheckOldPluginJson(object oPC)
{
    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
    int nIndex;
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    // If the first array is not an array then this is the old version.
    if(JsonGetType(jPlugin) != JSON_TYPE_ARRAY)
    {
        string sScript;
        json jNewPlugins = JsonArray();
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            sScript = JsonGetString(jPlugin);
            if(sScript != "") jNewPlugins = ai_Plugin_Add(oPC, jNewPlugins, sScript);
            jPlugin = JsonArrayGet(jPlugins, ++nIndex);

        }
        ai_SetAssociateDbJson(oPC, "pc", "plugins", jNewPlugins);
    }
}
json ai_UpdatePluginsForPC(object oPC, string sAssociateType)
{
    // Check if the server is running or single player.
    ai_CheckDataAndInitialize(oPC, "pc");
    if(!AI_SERVER)
    {
        ai_CheckOldPluginJson(oPC);
        return ai_GetAssociateDbJson(oPC, "pc", "plugins");
    }
    int nJsonType, nCounter, nIndex, bWidget, bAllow;
    string sScript, sName, sIcon;
    json jServerPlugins = ai_GetCampaignDbJson("plugins");
    json jPCPlugin, jPCPlugins = ai_GetAssociateDbJson(oPC, sAssociateType, "plugins");
    json jNewPCPlugins = JsonArray();
    json jServerPlugin = JsonArrayGet(jServerPlugins, nIndex);
    while(JsonGetType(jServerPlugin) != JSON_TYPE_NULL)
    {
        bAllow = JsonGetInt(JsonArrayGet(jServerPlugin, 1));
        if(bAllow)
        {
            sName = JsonGetString(JsonArrayGet(jServerPlugin, 0));
            nCounter = 0;
            jPCPlugin = JsonArrayGet(jPCPlugins, nCounter);
            nJsonType = JsonGetType(jPCPlugin);
            while(nJsonType != JSON_TYPE_NULL)
            {
                if(sName == JsonGetString(JsonArrayGet(jPCPlugin, 0)))
                {
                    // Boolean - Add to widget.
                    bWidget = JsonGetInt(JsonArrayGet(jPCPlugin, 1));
                    JsonArraySetInplace(jServerPlugin, 1, JsonBool(bWidget));
                    break;
                }
                jPCPlugin = JsonArrayGet(jPCPlugins, ++nCounter);
                nJsonType = JsonGetType(jPCPlugin);
            }
            if(nJsonType == JSON_TYPE_NULL)
            {
                JsonArraySetInplace(jServerPlugin, 1, JsonBool(FALSE));
            }
            JsonArrayInsertInplace(jNewPCPlugins, jServerPlugin);
        }
        jServerPlugin = JsonArrayGet(jServerPlugins, ++nIndex);
    }
    ai_SetAssociateDbJson(oPC, sAssociateType, "plugins", jNewPCPlugins);
    return jNewPCPlugins;
}
json ai_UpdatePluginsForDM(object oPC)
{
    int nJsonType, nCounter, nIndex, bWidget, bAllow;
    string sName, sIcon, sDbName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jServerPlugins = ai_GetCampaignDbJson("plugins");
    ai_CheckDMDataAndInitialize(oPC);
    json jDMPlugin, jDMPlugins = ai_GetCampaignDbJson("plugins", sDbName, AI_DM_TABLE);
    json jNewDMPlugins = JsonArray();
    json jServerPlugin = JsonArrayGet(jServerPlugins, nIndex);
    while(JsonGetType(jServerPlugin) != JSON_TYPE_NULL)
    {
        sName = JsonGetString(JsonArrayGet(jServerPlugin, 0));
        nCounter = 0;
        jDMPlugin = JsonArrayGet(jDMPlugins, nCounter);
        nJsonType = JsonGetType(jDMPlugin);
        while(nJsonType != JSON_TYPE_NULL)
        {
            if(sName == JsonGetString(JsonArrayGet(jDMPlugin, 0)))
            {
                // Boolean - Add to widget.
                bWidget = JsonGetInt(JsonArrayGet(jDMPlugin, 1));
                JsonArraySetInplace(jServerPlugin, 1, JsonBool(bWidget));
                break;
            }
            jDMPlugin = JsonArrayGet(jDMPlugins, ++nCounter);
            nJsonType = JsonGetType(jDMPlugin);
        }
        if(nJsonType == JSON_TYPE_NULL)
        {
            JsonArraySetInplace(jServerPlugin, 1, JsonBool(FALSE));
        }
        JsonArrayInsertInplace(jNewDMPlugins, jServerPlugin);
        jServerPlugin = JsonArrayGet(jServerPlugins, ++nIndex);
    }
    ai_SetCampaignDbJson("plugins", jNewDMPlugins, sDbName, AI_DM_TABLE);
    return jNewDMPlugins;
}
void ai_StartupPlugins(object oPC)
{
    SetLocalInt(oPC, AI_STARTING_UP, TRUE);
    json jPlugins;
    if(GetIsDM(oPC)) jPlugins = ai_UpdatePluginsForDM(oPC);
    else jPlugins = ai_UpdatePluginsForPC(oPC, "pc");
    int nIndex;
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        ExecuteScript(JsonGetString(JsonArrayGet(jPlugin, 0)), oPC);
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    DeleteLocalInt(oPC, AI_STARTING_UP);
}

