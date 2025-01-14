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
void aiSaveAssociateAIModesToDb(object oPlayer, object oAssociate);
// Checks Associate local data and if none is found will initialize or load the
// correct data for oAssociate.
void ai_CheckAssociateData(object oPlayer, object oAssociate, string sAssociateType, int bLoad = FALSE);
// Checks DM's local data and if none is found will initizlize or load the
// correct data for oPlayer.
void ai_CheckDMData(object oPlayer);
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
        SetLocalInt(oModule, AI_INCREASE_ENC_MONSTERS, 0);
        JsonObjectSetInplace(jRules, AI_INCREASE_ENC_MONSTERS, JsonInt(0));
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
        ai_SetCampaignDbJson("rules", jRules);
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
        // Monsters will wander around when not in combat.
        bValue = JsonGetInt(JsonObjectGet(jRules, AI_INCREASE_ENC_MONSTERS));
        SetLocalInt(oModule, AI_INCREASE_ENC_MONSTERS, bValue);
        // Monsters will wander around when not in combat.
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
        "location          TEXT, " +
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
        return jReturn;
    }
    else return JsonNull();
}
void aiSaveAssociateAIModesToDb(object oPlayer, object oAssociate)
{
    string sAssociateType = ai_GetAssociateType(oPlayer, oAssociate);
    json jModes = ai_GetAssociateDbJson(oPlayer, sAssociateType, "modes");
    int nAIMode = GetLocalInt(oAssociate, sAIModeVarname);
    JsonArraySetInplace(jModes, 0, JsonInt(nAIMode));
    int nMagicMode = GetLocalInt(oAssociate, sMagicModeVarname);
    JsonArraySetInplace(jModes, 1, JsonInt(nMagicMode));
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
void ai_GetButtons(object oPC, object oAssociate, string sAssociateType)
{
    json jButtons = ai_GetAssociateDbJson(oPC, sAssociateType, "buttons");
    // ********** Associate Command Buttons **********
    int nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
    string sWidgetButtonName = sWidgetButtonsVarname + sAssociateType;
    if(nWidgetButtons) SetLocalInt(oAssociate, sWidgetButtonName, nWidgetButtons);
    // ********** Associate AI Buttons **********
    int nAIButtons = JsonGetInt(JsonArrayGet(jButtons, 1));
    string sAIButtonName = sAIButtonsVarname + sAssociateType;
    if(nAIButtons) SetLocalInt(oAssociate, sAIButtonName, nAIButtons);
}
void ai_SetupAssociateData(object oPlayer, object oAssociate, string sAssociateType)
{
    //ai_Debug("0i_main", "744", GetName(oAssociate) + " is initializing associate data.");
    json jModes = JsonArray();
    json jButtons = JsonArray();
    json jAIData = JsonArray();
    json jLootFilters = JsonArray();
    json jPlugins = JsonArray();
    json jLocation = JsonObject();
    // Default behavior for associates at start.
    // ********** Modes **********
    JsonArrayInsertInplace(jModes, JsonInt(0)); // AI Modes.
    // Set magic modes to use Normal magic, Bit 256.
    JsonArrayInsertInplace(jModes, JsonInt(256)); // Magic Modes.
    SetLocalInt(oAssociate, sMagicModeVarname, 256);
    // ********** Buttons **********
    JsonArrayInsertInplace(jButtons, JsonInt(0)); // Command buttons.
    JsonArrayInsertInplace(jButtons, JsonInt(0)); // AI buttons.
    JsonArrayInsertInplace(jButtons, JsonInt(0)); // AI buttons 2.
    // ********** AI Data **********
    JsonArrayInsertInplace(jAIData, JsonInt(0)); // Difficulty adjustment.
    JsonArrayInsertInplace(jAIData, JsonInt(70)); // Heal out of combat.
    SetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    JsonArrayInsertInplace(jAIData, JsonInt(50)); // Heal in combat.
    SetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT, 50);
    JsonArrayInsertInplace(jAIData, JsonFloat(20.0)); // Loot check range.
    SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, 20.0);
    JsonArrayInsertInplace(jAIData, JsonFloat(20.0)); // Lock check range.
    SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, 20.0);
    JsonArrayInsertInplace(jAIData, JsonFloat(20.0)); // Trap check range.
    SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, 20.0);
    JsonArrayInsertInplace(jAIData, JsonFloat(3.0)); // Associate Distance.
    SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, 3.0);
    JsonArrayInsertInplace(jAIData, JsonInt(11)); // Associate Perception DistanceDistance.
    SetLocalInt(oAssociate, AI_PERCEPTION_RANGE, 11);
    JsonArrayInsertInplace(jAIData, JsonString("")); // Associate Combat Tactics.
    // ********** LootFilters **********
    // Maximum weight to pickup an item.
    JsonArrayInsertInplace(jLootFilters, JsonInt(200));
    SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, 200);
    // Bitwise int for time pickup filter.
    JsonArrayInsertInplace(jLootFilters, JsonInt(AI_LOOT_ALL_ON));
    SetLocalInt(oAssociate, sLootFilterVarname, AI_LOOT_ALL_ON);
    // Minimum gold value to pickup.
    int nIndex;
    for(nIndex = 2; nIndex < 20; nIndex++)
    {
        JsonArrayInsertInplace(jLootFilters, JsonInt(0));
    }
    // ********** Plugins ************
    // These are pulled straight from the database.
    // ********** Locations **********
    JsonObjectSetInplace(jLocation, "h", JsonFloat(92.0));
    JsonObjectSetInplace(jLocation, "w", JsonFloat(98.0));
    JsonObjectSetInplace(jLocation, "x", JsonFloat(1.0));
    JsonObjectSetInplace(jLocation, "y", JsonFloat(1.0));
    // ********** Save data to new database **********
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes, AI_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons, AI_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData, AI_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters, AI_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "plugins", jPlugins, AI_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocation, AI_TABLE);
}
void ai_CheckAssociateData(object oPlayer, object oAssociate, string sAssociateType, int bLoad = FALSE)
{
    //ai_Debug("0i_main", "810", "Checking data for oAssociate: " + GetName(oAssociate));
    // Do quick check to see if they have a variable saved if so then exit.
    if(!bLoad && GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) != 0.0) return;
    ai_CheckDataAndInitialize(oPlayer, sAssociateType);
    // ********** AI Modes **********
    json jModes = ai_GetAssociateDbJson(oPlayer, sAssociateType, "modes");
    // if there is no saved AImodes then set the defaults.
    if(JsonGetType(JsonArrayGet(jModes, 0)) == JSON_TYPE_NULL)
    {
        ai_SetupAssociateData(oPlayer, oAssociate, sAssociateType);
    }
    else
    {
        //ai_Debug("0i_main", "823", GetName(oAssociate) + " is loading data from " + GetName(oPlayer) + ".");
        // Get data from the database and place on to the associates and player.
        // ********** Modes **********
        SetLocalInt(oAssociate, sAIModeVarname, JsonGetInt(JsonArrayGet(jModes, 0)));
        SetLocalInt(oAssociate, sMagicModeVarname, JsonGetInt(JsonArrayGet(jModes, 1)));
        // ********** Buttons **********
        ai_GetButtons(oPlayer, oAssociate, sAssociateType);
        // ********** AI Data **********
        json jAIData = ai_GetAssociateDbJson(oPlayer, sAssociateType, "aidata");
        if(JsonGetType(JsonArrayGet(jAIData, 0)) == JSON_TYPE_NULL)
        {
            ai_SetupAssociateData(oPlayer, oAssociate, sAssociateType);
        }
        SetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT, JsonGetInt(JsonArrayGet(jAIData, 0)));
        SetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT, JsonGetInt(JsonArrayGet(jAIData, 1)));
        SetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT, JsonGetInt(JsonArrayGet(jAIData, 2)));
        SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 3)));
        SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 4)));
        SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 5)));
        SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 6)));
        int nPercRange = JsonGetInt(JsonArrayGet(jAIData, 7));
        if(nPercRange != 8 || nPercRange != 9 || nPercRange != 10 || nPercRange != 11) nPercRange = 11;
        SetLocalInt(oAssociate, AI_PERCEPTION_RANGE, nPercRange);
        string sScript = JsonGetString(JsonArrayGet(jAIData, 8));
        if(sScript != "") SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, sScript);
        // ********** LootFilters **********
        json jLootFilters = ai_GetAssociateDbJson(oPlayer, sAssociateType, "lootfilters");
        if(JsonGetType(JsonArrayGet(jLootFilters, 0)) == JSON_TYPE_NULL)
        {
            ai_SetupAssociateData(oPlayer, oAssociate, sAssociateType);
        }
        SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, JsonGetInt(JsonArrayGet(jLootFilters, 0)));
        SetLocalInt(oAssociate, sLootFilterVarname, JsonGetInt(JsonArrayGet(jLootFilters, 1)));
        int nIndex;
        for(nIndex = 2; nIndex < 20; nIndex++)
        {
            SetLocalInt(oAssociate, AI_MIN_GOLD_ + IntToString(nIndex), JsonGetInt(JsonArrayGet(jLootFilters, nIndex)));
        }
        // ********** Plugins ************
        // These are pulled straight from the database.
        // ********** Locations **********
        // These are pulled straight from the database.
    }
}
void ai_SetupDMData(object oPlayer, string sName)
{
    //ai_Debug("0i_main", "870", GetName(oPlayer) + " is initializing DM data.");
    json jButtons = JsonArray();
    json jPlugins = JsonArray();
    json jLocation = JsonObject();
    json jOptions = JsonArray();
    json jSaveSlots = JsonObject();
    // Default behavior for associates at start.
    // ********** Buttons **********
    JsonArrayInsertInplace(jButtons, JsonInt(0)); // DM Widget Buttons.
    // ********** Plugins ************
    // These are pulled straight from the database.
    // ********** Locations **********
    JsonObjectSetInplace(jLocation, "h", JsonFloat(92.0));
    JsonObjectSetInplace(jLocation, "w", JsonFloat(98.0));
    JsonObjectSetInplace(jLocation, "x", JsonFloat(1.0));
    JsonObjectSetInplace(jLocation, "y", JsonFloat(1.0));
    // ********** Options **********
    // ********** SaveSlots **********
    // ********** Save data to new database **********
    ai_SetCampaignDbJson("buttons", jButtons, sName, AI_DM_TABLE);
    ai_SetCampaignDbJson("plugins", jPlugins, sName, AI_DM_TABLE);
    ai_SetCampaignDbJson("location", jLocation, sName, AI_DM_TABLE);
    ai_SetCampaignDbJson("options", jOptions, sName, AI_DM_TABLE);
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
json ai_UpdatePluginsForPC(object oPC, string sAssociateType)
{
    // Check if the server is running or single player.
    ai_CheckDataAndInitialize(oPC, "pc");
    if(!AI_SERVER) return ai_GetAssociateDbJson(oPC, "pc", "plugins");
    int nJsonType, nCounter, nIndex, bWidget, bAllow;
    string sText;
    json jPlugins = ai_GetCampaignDbJson("plugins");
    json jPCPlugins = ai_GetAssociateDbJson(oPC, sAssociateType, "plugins");
    json jPCPlugin, jNewPCPlugins = JsonArray();
    json jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        bAllow = JsonGetInt(JsonArrayGet(jPlugins, nIndex + 1));
        if(bAllow)
        {
            JsonArrayInsertInplace(jNewPCPlugins, jScript);
            sText = JsonGetString(jScript);
            nCounter = 0;
            jPCPlugin = JsonArrayGet(jPCPlugins, nCounter);
            nJsonType = JsonGetType(jPCPlugin);
            while(nJsonType != JSON_TYPE_NULL)
            {
                if(sText == JsonGetString(jPCPlugin))
                {
                    bWidget = JsonGetInt(JsonArrayGet(jPCPlugins, nCounter + 1));
                    JsonArrayInsertInplace(jNewPCPlugins, JsonBool(bWidget));
                    break;
                }
                nCounter += 2;
                jPCPlugin = JsonArrayGet(jPCPlugins, nCounter);
                nJsonType = JsonGetType(jPCPlugin);
            }
            if(nJsonType == JSON_TYPE_NULL)
            {
                JsonArrayInsertInplace(jNewPCPlugins, JsonBool(FALSE));
            }
        }
        nIndex += 2;
        jScript = JsonArrayGet(jPlugins, nIndex);
    }
    ai_SetAssociateDbJson(oPC, sAssociateType, "plugins", jNewPCPlugins);
    return jNewPCPlugins;
}
json ai_UpdatePluginsForDM(object oPC)
{
    int nJsonType, nCounter, nIndex, bWidget, bAllow;
    string sText, sDbName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jPlugins = ai_GetCampaignDbJson("plugins");
    ai_CheckDMDataAndInitialize(oPC);
    json jDMPlugins = ai_GetCampaignDbJson("plugins", sDbName, AI_DM_TABLE);
    json jDMPlugin, jNewDMPlugins = JsonArray();
    json jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        JsonArrayInsertInplace(jNewDMPlugins, jScript);
        sText = JsonGetString(jScript);
        nCounter = 0;
        jDMPlugin = JsonArrayGet(jDMPlugins, nCounter);
        nJsonType = JsonGetType(jDMPlugin);
        while(nJsonType != JSON_TYPE_NULL)
        {
            if(sText == JsonGetString(jDMPlugin))
            {
                bWidget = JsonGetInt(JsonArrayGet(jDMPlugins, nCounter + 1));
                JsonArrayInsertInplace(jNewDMPlugins, JsonBool(bWidget));
                break;
            }
            nCounter += 2;
            jDMPlugin = JsonArrayGet(jDMPlugins, nCounter);
            nJsonType = JsonGetType(jDMPlugin);
        }
        if(nJsonType == JSON_TYPE_NULL)
        {
            JsonArrayInsertInplace(jNewDMPlugins, JsonBool(FALSE));
        }
        nIndex += 2;
        jScript = JsonArrayGet(jPlugins, nIndex);
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
    json jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        ExecuteScript(JsonGetString(jScript), oPC);
        nIndex += 2;
        jScript = JsonArrayGet(jPlugins, nIndex);
    }
    DeleteLocalInt(oPC, AI_STARTING_UP);
}
