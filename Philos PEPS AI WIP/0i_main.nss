/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_main
////////////////////////////////////////////////////////////////////////////////
 Include script for handling main/basic functions not defined by other includes.

 Database structure: Json with indexes.
 name (string) - The associatetype to link the data. "pc", "familiar", etc.
 modes (jsonarray) - 0-aimodes (int), 1-magicmodes (int)
 buttons (jsonarray) - 0-widgetbuttons (int), 1-aibuttons (int)
 aidata (jsonarray) - 0-difficulty (int), 1-healoutcombat (int), 2-healincombat (int),
                      3-lootrange (float), 4-lockrange (float), 5-traprange (float),
                      6-Follow range (float).
 lootfilters (jsonarray) - 0-maxweight (int), 1-lootfilters (int),
      Item filters in min gold json array; 2-plot, 3-armor, 4-belts, 5-boots,
          6-cloaks, 7-gems, 8-gloves, 9-headgear, 10-jewelry, 11-misc, 12-potions,
          13-scrolls, 14-shields, 15-wands, 16-weapons, 17-arrow, 18-bolt, 19-bullet.
 plugins (jsonarray) - 0+ (string). * Only used in the "pc" data.
 location (jsonobject) - geometry (json), used in widgets for pc and associates.
*///////////////////////////////////////////////////////////////////////////////
const string AI_OLD_TABLE_I = "ASSOCIATE_TABLE";
const string AI_OLD_TABLE_II = "ASSOCIATE_DB_TABLE";
const string AI_NEW_TABLE = "PEPS_TABLE";
const string AI_CAMPAIGN_DATABASE = "peps_ai_rules";
#include "0i_constants"
#include "0i_messages"
// Check if AI rules is set on the module and if not the it sets them.
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
// Checks if the campaign database has been created.
void ai_CheckCampaignDataAndInitialize();
// Sets json to a campaign database.
void ai_SetCampaignDbJson(string sDataField, json jData);
// Gets json from a campaign database.
json ai_GetCampaignDbJson(string sDataField);
// Checks if oMaster has the Table created for Associate data.
// If no table found then the table is created and then initialized.
void ai_CheckDataAndInitialize(object oPlayer, string sAssociateType);
// Returns the associate defined by sAssociateType string
// Text must be one of the following: pc, familiar, companion, summons, henchman#
object ai_GetAssociateByStringType(object oPlayer, string sAssociateType);
// Returns the associatetype int string format for oAssociate.
// They are pc, familar, companion, summons, henchman#
string ai_GetAssociateType(object oPlayer, object oAssociate);
// Sets nData to sDataField for sAssociateType that is on oPlayer.
// sDataField can be modes, magicmodes, lootmodes, widgetbuttons, aibuttons, magic,
//                   healoutcombat, healincombat, mingold*.
void ai_SetAssociateDbInt(object oPlayer, string sAssociateType, string sDataField, int nData, string sTable = AI_NEW_TABLE);
// Returns nData from sDataField for sAssociateType that is on oPlayer.
// sDataField can be modes, magicmodes, lootmodes, widgetbuttons, aibuttons, magic,
//                   healoutcombat, healincombat, mingold*.
int ai_GetAssociateDbInt(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_NEW_TABLE);
// Sets fData to sDataField for sAssociateType that is on oPlayer.
// sDataField can be lootrange, lockrange, traprange.
void ai_SetAssociateDbFloat(object oPlayer, string sAssociatetype, string sDataField, float fData, string sTable = AI_NEW_TABLE);
// Returns fData from sDataField for sAssociateType that is on oPlayer.
// sDataField can be lootrange, lockrange, traprange.
float ai_GetAssociateDbFloat(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_NEW_TABLE);
// sDataField should be one of the data fields for that table.
// jData is the json data to be saved.
void ai_SetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, json jData, string sTable = AI_NEW_TABLE);
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
json ai_GetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_NEW_TABLE);
// Saves Associate AIModes and MagicModes to the database.
void aiSaveAssociateAIModesToDb(object oPlayer, object oAssociate);
// Copies all data from old table to new table for the player.
void ai_UpdateOldTableIToNewTable(object oPlayer, string sAssociateType);
// Copies all data from another old table to new table for the player.
void ai_UpdateOldTableIIToNewTable(object oPlayer, string sAssociateType);
// Sets Associate conversation data from the database on oPlayer to oAssociate.
// Used when an associate is created or a henchman is hired.
void ai_GetAssociateDataFromDB(object oPlayer, object oAssociate);
// Moves old henchman data to new henchman data by tag.
void ai_CheckForHenchmanOldDataToNewData(object oPlayer, string sAssociateData);

void ai_CheckAIRules()
{
    object oModule = GetModule();
    ai_CheckCampaignDataAndInitialize();
    json jRules = ai_GetCampaignDbJson("rules");
    if(JsonGetType(JsonObjectGet(jRules, AI_RULE_MORAL_CHECKS)) == JSON_TYPE_NULL)
    {
        jRules = JsonObject();
        SetLocalInt(oModule, "AI_RULES_SET", TRUE);
        // Variable name set to a creatures full name to set debugging on.
        JsonObjectSetInplace(jRules, AI_RULE_DEBUG_CREATURE, JsonString(""));
        // Moral checks on or off.
        SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, FALSE);
        JsonObjectSetInplace(jRules, AI_RULE_MORAL_CHECKS, JsonInt(FALSE));
        // Allows monsters to prebuff before combat starts.
        SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, TRUE);
        JsonObjectSetInplace(jRules, AI_RULE_BUFF_MONSTERS, JsonInt(TRUE));
        // Allows monsters cast summons spells when prebuffing.
        SetLocalInt(oModule, AI_RULE_PRESUMMON, TRUE);
        JsonObjectSetInplace(jRules, AI_RULE_PRESUMMON, JsonInt(TRUE));
        // Allow the AI to move during combat base on the situation and action taking.
        SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, TRUE);
        JsonObjectSetInplace(jRules, AI_RULE_ADVANCED_MOVEMENT, JsonInt(TRUE));
        // Follow Item Level Restrictions for monsters/associates.
        SetLocalInt(oModule, AI_RULE_ILR, FALSE);
        JsonObjectSetInplace(jRules, AI_RULE_ILR, JsonInt(FALSE));
        // Allow the AI to use Use Magic Device.
        SetLocalInt(oModule, AI_RULE_ALLOW_UMD, TRUE);
        JsonObjectSetInplace(jRules, AI_RULE_ALLOW_UMD, JsonInt(TRUE));
        // Allow the AI to use healing kits.
        SetLocalInt(oModule, AI_RULE_HEALERSKITS, TRUE);
        JsonObjectSetInplace(jRules, AI_RULE_HEALERSKITS, JsonInt(TRUE));
        // Associates are permanent and don't get removed when the master dies.
        SetLocalInt(oModule, AI_RULE_PERM_ASSOC, FALSE);
        JsonObjectSetInplace(jRules, AI_RULE_PERM_ASSOC, JsonInt(FALSE));
        // Monster AI's chance to attack the weakest target instead of the nearest.
        SetLocalInt(oModule, AI_RULE_AI_DIFFICULTY, 0);
        JsonObjectSetInplace(jRules, AI_RULE_AI_DIFFICULTY, JsonInt(0));
        // Monster AI's perception distance from player.
        SetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE, 30.0);
        JsonObjectSetInplace(jRules, AI_RULE_PERCEPTION_DISTANCE, JsonFloat(30.0));
        ai_SetCampaignDbJson("rules", jRules);
    }
    else if(!GetLocalInt(oModule, "AI_RULES_SET"))
    {
        SetLocalInt(oModule, "AI_RULES_SET", TRUE);
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
        "CREATE TABLE IF NOT EXISTS " + AI_NEW_TABLE + "(" +
        "name              TEXT, " +
        "rules             TEXT, " +
        "PRIMARY KEY(name));");
    SqlStep(sql);
    //ai_Debug("0i_main", "343", We are creating a campaign table [" +
    //         AI_NEW_TABLE + "] in the database.");
}
void ai_CheckCampaignDataTableAndCreateTable()
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@table", AI_NEW_TABLE);
    if(!SqlStep(sql)) ai_CreateCampaignDataTable();
    //else ai_Debug("0i_main", "354", We have a database with table [" + AI_NEW_TABLE + "].");
}
void ai_InitializeCampaignData()
{
    string sQuery = "INSERT INTO " + AI_NEW_TABLE + "(name, rules) " +
        "VALUES(@name, @rules);";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", "PEPS_DATA");
    SqlBindJson(sql, "@rules", JsonObject());
    //ai_Debug("0i_main", "363", "We are initializing campaign " +
    //         " data for table[" + AI_NEW_TABLE + "].");
    SqlStep(sql);
}
void ai_CheckCampaignDataAndInitialize()
{
    ai_CheckCampaignDataTableAndCreateTable();
    string sQuery = "SELECT name FROM " + AI_NEW_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString(sql, "@name", "PEPS_DATA");
    if(!SqlStep(sql)) ai_InitializeCampaignData();
}
void ai_SetCampaignDbJson(string sDataField, json jData)
{
    string sQuery = "UPDATE " + AI_NEW_TABLE + " SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", "PEPS_DATA");
    SqlStep (sql);
}
json ai_GetCampaignDbJson(string sDataField)
{
    string sQuery = "SELECT " + sDataField + " FROM " + AI_NEW_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(AI_CAMPAIGN_DATABASE, sQuery);
    SqlBindString (sql, "@name", "PEPS_DATA");
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
}
void ai_CreateAssociateDataTable(object oPlayer)
{
    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "CREATE TABLE IF NOT EXISTS " + AI_NEW_TABLE + "(" +
        "name              TEXT, " +
        "modes             TEXT, " +
        "buttons           TEXT, " +
        "aidata            TEXT, " +
        "lootfilters       TEXT, " +
        "plugins           TEXT, " +
        "locations         TEXT, " +
        "PRIMARY KEY(name));");
    SqlStep(sql);
    //ai_Debug("0i_main", "326", GetName(oPlayer) + " is creating a table [" +
    //         AI_NEW_TABLE + "] in the database.");
}
void ai_CheckDataTableAndCreateTable(object oPlayer)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@table", AI_NEW_TABLE);
    if(!SqlStep(sql)) ai_CreateAssociateDataTable (oPlayer);
    //else ai_Debug("0i_main", "335", GetName(oPlayer) + " has a database with table [" + AI_NEW_TABLE + "].");
}
void ai_InitializeAssociateData(object oPlayer, string sAssociateType)
{
    string sQuery = "INSERT INTO " + AI_NEW_TABLE + "(name, modes, buttons, " +
        "aidata, lootfilters, plugins, locations) " +
        "VALUES(@name, @modes, @buttons, @aidata, @lootfilters, @plugins, @locations);";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociateType);
    SqlBindJson(sql, "@modes", JsonArray());
    SqlBindJson(sql, "@buttons", JsonArray());
    SqlBindJson(sql, "@aidata", JsonArray());
    SqlBindJson(sql, "@lootfilters", JsonArray());
    SqlBindJson(sql, "@plugins", JsonArray());
    SqlBindJson(sql, "@locations", JsonArray());
    //ai_Debug("0i_main", "350", GetName(oPlayer) + " is initializing associate " +
    //         sAssociateType + " data for table[" + AI_NEW_TABLE + "].");
    SqlStep(sql);
}
void ai_CheckDataAndInitialize(object oPlayer, string sAssociateType)
{
    ai_CheckDataTableAndCreateTable(oPlayer);
    string sQuery = "SELECT name FROM " + AI_NEW_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociateType);
    if(!SqlStep(sql))
    {
        ai_InitializeAssociateData(oPlayer, sAssociateType);
        // Check old sAssociateTypes for data.
        ai_CheckForHenchmanOldDataToNewData(oPlayer, sAssociateType);
        // Check Old Database table ASSOCIATE_DB_TABLE.
        // New Database table is PEPS_TABLE.
        // Check for old table and if found then copy data to new table.
        sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                        "AND name =@table;";
        sql = SqlPrepareQueryObject(oPlayer, sQuery);
        SqlBindString(sql, "@table", AI_OLD_TABLE_II);
        if(SqlStep(sql))
        {
            ai_UpdateOldTableIIToNewTable(oPlayer, sAssociateType);
            return;
        }
        // Old Database table is ASSOCIATE_TABLE.
        // New Database table is PEPS_TABLE.
        // Check for old table and if found then copy data to new table.
        string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                        "AND name =@table;";
        sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
        SqlBindString(sql, "@table", AI_OLD_TABLE_I);
        if(SqlStep(sql))
        {
            ai_UpdateOldTableIToNewTable(oPlayer, sAssociateType);
        }
    }
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
    int sAssociateType = GetAssociateType(oAssociate);
    if(sAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION) return "companion";
    else if(sAssociateType == ASSOCIATE_TYPE_FAMILIAR) return "familiar";
    else if(sAssociateType == ASSOCIATE_TYPE_SUMMONED) return "summons";
    else if(sAssociateType == ASSOCIATE_TYPE_HENCHMAN) return GetTag(oAssociate);
    return "";
}
void ai_SetAssociateDbInt(object oPlayer, string sAssociatetype, string sDataField, int nData, string sTable = AI_NEW_TABLE)
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
int ai_GetAssociateDbInt(object oPlayer, string sAssociatetype, string sDataField, string sTable = AI_NEW_TABLE)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    //ai_Debug("0i_main", "377", "GETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField);
    if(SqlStep(sql)) return SqlGetInt(sql, 0);
    else return 0;
}
void ai_SetAssociateDbFloat(object oPlayer, string sAssociatetype, string sDataField, float fData, string sTable = AI_NEW_TABLE)
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
float ai_GetAssociateDbFloat(object oPlayer, string sAssociatetype, string sDataField, string sTable = AI_NEW_TABLE)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    //ai_Debug("0i_main", "377", "GETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField);
    if(SqlStep(sql)) return SqlGetFloat(sql, 0);
    else return 0.0;
}
void ai_SetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, json jData, string sTable = AI_NEW_TABLE)
{
    string sQuery = "UPDATE " + sTable + " SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindJson (sql, "@data", jData);
    SqlBindString (sql, "@name", sAssociateType);
    SqlStep (sql);
}
json ai_GetAssociateDbJson(object oPlayer, string sAssociateType, string sDataField, string sTable = AI_NEW_TABLE)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@name", sAssociateType);
    if (SqlStep (sql)) return SqlGetJson (sql, 0);
    else return JsonArray ();
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
    ai_CheckAIRules();
    // If the player has no data then lets create some.
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@table", AI_NEW_TABLE);
    if(!SqlStep(sql))
    {
        ai_CheckDataAndInitialize(oPlayer, "pc");
    }
    ai_GetAssociateDataFromDB(oPlayer, oPlayer);
}
void ai_UpdateOldTableIToNewTable(object oPlayer, string sAssociateType)
{
    //ai_Debug("0i_main", "501", GetName(oPlayer) + " is updating from " + AI_OLD_TABLE_I + " to " + AI_NEW_TABLE +
    //         " for associate:" + sAssociateType);
    json jModes = JsonArray();
    json jButtons = JsonArray();
    json jAIData = JsonArray();
    json jLootFilters = JsonArray();
    json jPlugins = JsonArray();
    json jLocations = JsonObject();
    // ********** Associate Modes **********
    // Modes go from int in the database to Json in the database.
    int nModes = ai_GetAssociateDbInt(oPlayer, sAssociateType, "modes", AI_OLD_TABLE_I);
    JsonArrayInsertInplace(jModes, JsonInt(nModes));
    nModes = ai_GetAssociateDbInt(oPlayer, sAssociateType, "magicmodes", AI_OLD_TABLE_I);
    JsonArrayInsertInplace(jModes, JsonInt(nModes));
    // ********** Buttons **********
    // Modes go from int on player to json in the database.
    int nButtons = GetLocalInt(oPlayer, sWidgetButtonsVarname + sAssociateType);
    JsonArrayInsertInplace(jButtons, JsonInt(nButtons));
    nButtons = GetLocalInt(oPlayer, sAIButtonsVarname + sAssociateType);
    JsonArrayInsertInplace(jButtons, JsonInt(nButtons));
    // ********** AI Data **********
    // AIData goes from ints in the database to json in the database.
    int nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "magic", AI_OLD_TABLE_I);
    JsonArrayInsertInplace(jAIData, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "healoutcombat", AI_OLD_TABLE_I);
    JsonArrayInsertInplace(jAIData, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "healincombat", AI_OLD_TABLE_I);
    JsonArrayInsertInplace(jAIData, JsonInt(nData));
    // The below values are not in this version set them to defaut values.
    JsonArrayInsertInplace(jAIData, JsonFloat(20.0)); // Loot check range.
    JsonArrayInsertInplace(jAIData, JsonFloat(20.0)); // Lock check range.
    JsonArrayInsertInplace(jAIData, JsonFloat(20.0)); // Trap check range.
    JsonArrayInsertInplace(jAIData, JsonFloat(3.0)); // Follow range.
    // ********** LootFilters **********
    // The below values are not in this version set them to defaut values.
    JsonArrayInsertInplace(jLootFilters, JsonInt(200)); // Max Weight.
    JsonArrayInsertInplace(jLootFilters, JsonInt(AI_LOOT_ALL_ON)); // Loot filters.
    // Minimum Gold limits. Was not in this version so lets set them to 0.
    //  Item filters in min gold json array; 2-plot, 3-armor, 4-belts, 5-boots,
    //      6-cloaks, 7-gems, 8-gloves, 9-headgear, 10-jewelry, 11-misc, 12-potions,
    //      13-scrolls, 14-shields, 15-wands, 16-weapons, 17-arrow, 18-bolt, 19-bullet.
    int nIndex;
    for(nIndex = 2; nIndex < 20; nIndex++)
    {
        JsonArrayInsertInplace(jLootFilters, JsonInt(0));
    }
    // ********** Plugins **********
    // This will be setup once a player adds a plugin.
    // ********** Menu Locations **********
    // We cannot get these from this TABLE version.
    JsonObjectSetInplace(jLocations, "h", JsonFloat(92.0));
    JsonObjectSetInplace(jLocations, "w", JsonFloat(98.0));
    JsonObjectSetInplace(jLocations, "x", JsonFloat(1.0));
    JsonObjectSetInplace(jLocations, "y", JsonFloat(1.0));
    // ********** Save data to new database **********
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "plugins", jPlugins, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocations, AI_NEW_TABLE);
    //ai_Debug("0i_main", "588", "Done updating from " + AI_OLD_TABLE_I);
}
void ai_UpdateOldTableIIToNewTable(object oPlayer, string sAssociateType)
{
    //ai_Debug("0i_main", "563", GetName(oPlayer) + " is updating from " + AI_OLD_TABLE_II + " to " + AI_NEW_TABLE +
    //         " for associate:" + sAssociateType);
    json jModes = JsonArray();
    json jButtons = JsonArray();
    json jAIData = JsonArray();
    json jLootFilters = JsonArray();
    json jPlugins = JsonArray();
    json jLocations = JsonObject();
    // ********** Modes **********
    // Modes go from int in the DB to Json.
    int nModes = ai_GetAssociateDbInt(oPlayer, sAssociateType, "modes", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jModes, JsonInt(nModes));
    // ********** Associate Magic Modes **********
    nModes = ai_GetAssociateDbInt(oPlayer, sAssociateType, "magicmodes", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jModes, JsonInt(nModes));
    // ********** Buttons **********
    int nButtons = GetLocalInt(oPlayer, sWidgetButtonsVarname + sAssociateType);
    JsonArrayInsertInplace(jButtons, JsonInt(nButtons));
    nButtons = GetLocalInt(oPlayer, sAIButtonsVarname + sAssociateType);
    JsonArrayInsertInplace(jButtons, JsonInt(nButtons));
    // ********** AI Data **********
    int nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "magic", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jAIData, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "healoutcombat", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jAIData, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "healincombat", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jAIData, JsonInt(nData));
    float fData = ai_GetAssociateDbFloat(oPlayer, sAssociateType, "lootrange", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jAIData, JsonFloat(fData));
    fData = ai_GetAssociateDbFloat(oPlayer, sAssociateType, "lockrange", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jAIData, JsonFloat(fData));
    fData = ai_GetAssociateDbFloat(oPlayer, sAssociateType, "traprange", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jAIData, JsonFloat(fData));
    // Follow range. Not in this version so set to 3.0 meters.
    JsonArrayInsertInplace(jAIData, JsonFloat(3.0));
    // ********** LootFilters **********
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "maxweight", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "lootmodes", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    // Minimum Gold limits. Was not in this version so lets set them to 0.
    //  Item filters in min gold json array; 2-plot, 3-armor, 4-belts, 5-boots,
    //      6-cloaks, 7-gems, 8-gloves, 9-headgear, 10-jewelry, 11-misc, 12-potions,
    //      13-scrolls, 14-shields, 15-wands, 16-weapons, 17-arrow, 18-bolt, 19-bullet.
    JsonArrayInsertInplace(jLootFilters, JsonInt(0));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldarmor", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldbelts", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldboots", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldcloaks", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldgems", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldgloves", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldheadgear", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldjewelry", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldmisc", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldpotions", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldscrolls", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldshields", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldwands", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldweapons", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    nData = ai_GetAssociateDbInt(oPlayer, sAssociateType, "mingoldammo", AI_OLD_TABLE_II);
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    // min gold limit - bolts.
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    // min gold limit - bullets.
    JsonArrayInsertInplace(jLootFilters, JsonInt(nData));
    // ********** Plugins **********
    // This will be setup once a player adds a plugin.
    // ********** Locations **********
    jLocations = ai_GetAssociateDbJson(oPlayer, sAssociateType, "locations", AI_OLD_TABLE_II);
    // ********** Save data to new database **********
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "plugins", jPlugins, AI_NEW_TABLE);
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocations, AI_NEW_TABLE);
    //ai_Debug("0i_main", "680", "Done updating from " + AI_OLD_TABLE_I);
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
    // ********** Associate AI Buttons 2 **********
    int nAIButtons2 = JsonGetInt(JsonArrayGet(jButtons, 2));
    string sAIButton2Name = sAIButtons2Varname + sAssociateType;
    if(nAIButtons2) SetLocalInt(oAssociate, sAIButton2Name, nAIButtons2);
}
void ai_GetAssociateDataFromDB(object oPlayer, object oAssociate)
{
    //ai_Debug("0i_main", "681", "Loading db data from Player:" + GetName(oPlayer) +
    //         " to variables on associate: " + GetName(oAssociate));
    string sAssociateType = ai_GetAssociateType(oPlayer, oAssociate);
    // ********** AI Modes **********
    json jModes = ai_GetAssociateDbJson(oPlayer, sAssociateType, "modes");
    // if there is no saved AImodes then set the defaults.
    if(JsonGetType(JsonArrayGet(jModes, 0)) == JSON_TYPE_NULL)
    {
        json jButtons = JsonArray();
        json jAIData = JsonArray();
        json jLootFilters = JsonArray();
        json jPlugins = JsonArray();
        json jLocations = JsonObject();
        //ai_Debug("0i_main", "689", GetName(oAssociate) + " is initializing data.");
        // Default behavior for associates at start.
        // ********** Modes **********
        JsonArrayInsertInplace(jModes, JsonInt(0)); // AI Modes.
        // Set magic modes to use Normal magic, Bit 256.
        JsonArrayInsertInplace(jModes, JsonInt(256)); // Magic Modes.
        SetLocalInt(oAssociate, sMagicModeVarname, 256);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes);
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
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData);
        // ********** LootFilters **********
        // Maximum weight to pickup an item.
        JsonArrayInsertInplace(jLootFilters, JsonInt(200));
        SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, 200);
        // Bitwise int for time pickup filter.
        JsonArrayInsertInplace(jLootFilters, JsonInt(AI_LOOT_ALL_ON));
        SetLocalInt(oAssociate, sLootFilterVarname, AI_LOOT_ALL_ON);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters);
        // Minimum gold value to pickup.
        int nIndex;
        for(nIndex = 2; nIndex < 20; nIndex++)
        {
            JsonArrayInsertInplace(jLootFilters, JsonInt(0));
        }
        // ********** Plugins ************
        // These are pulled straight from the database.
        // ********** Locations **********
        JsonObjectSetInplace(jLocations, "h", JsonFloat(92.0));
        JsonObjectSetInplace(jLocations, "w", JsonFloat(98.0));
        JsonObjectSetInplace(jLocations, "x", JsonFloat(1.0));
        JsonObjectSetInplace(jLocations, "y", JsonFloat(1.0));
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocations);
        // ********** Save data to new database **********
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes, AI_NEW_TABLE);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons, AI_NEW_TABLE);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData, AI_NEW_TABLE);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters, AI_NEW_TABLE);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "plugins", jPlugins, AI_NEW_TABLE);
        ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocations, AI_NEW_TABLE);
    }
    else
    {
        //ai_Debug("0i_main", "739", GetName(oAssociate) + " is loading data from " + GetName(oPlayer) + ".");
        // Get data from the database and place on to the associates and player.
        // ********** Modes **********
        SetLocalInt(oAssociate, sAIModeVarname, JsonGetInt(JsonArrayGet(jModes, 0)));
        SetLocalInt(oAssociate, sMagicModeVarname, JsonGetInt(JsonArrayGet(jModes, 1)));
        // ********** Buttons **********
        ai_GetButtons(oPlayer, oAssociate, sAssociateType);
        // ********** AI Data **********
        json jAIData = ai_GetAssociateDbJson(oPlayer, sAssociateType, "aidata");
        SetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT, JsonGetInt(JsonArrayGet(jAIData, 0)));
        SetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT, JsonGetInt(JsonArrayGet(jAIData, 1)));
        SetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT, JsonGetInt(JsonArrayGet(jAIData, 2)));
        SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 3)));
        SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 4)));
        SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 5)));
        SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, JsonGetFloat(JsonArrayGet(jAIData, 6)));
        // ********** LootFilters **********
        json jLootFilters = ai_GetAssociateDbJson(oPlayer, sAssociateType, "lootfilters");
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
    //ai_Debug("0i_main", "765", "Done setting data to " + GetName(oAssociate));
}
void ai_CheckForHenchmanOldDataToNewData(object oPlayer, string sAssociateType)
{
    if(sAssociateType == "pc" || sAssociateType == "familiar" ||
       sAssociateType == "companion" || sAssociateType == "summons") return;
    object oAssociate = GetNearestObjectByTag(sAssociateType, oPlayer);
    int nIndex = 1;
    string sOldAssociateType, sName = GetName(oAssociate);
    while(nIndex < 7)
    {
        if(sName == GetName(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPlayer, nIndex)))
        {
            sOldAssociateType = "henchman" + IntToString(nIndex);
            break;
        }
        nIndex++;
    }
    json jModes = ai_GetAssociateDbJson(oPlayer, sOldAssociateType, "modes");
    if(JsonGetType(JsonArrayGet(jModes, 0)) == JSON_TYPE_NULL) return;
    //ai_Debug("0i_main", "791", GetName(oAssociate) + " is loading data from old " + sOldAssociateType + " + to new " + sAssociateType + ".");
    // Get data from the database and place on to the associates and player.
    // ********** Modes **********
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "modes", jModes);
    // ********** Buttons **********
    json jButtons = ai_GetAssociateDbJson(oPlayer, sOldAssociateType, "buttons");
    if(JsonGetType(jButtons) == JSON_TYPE_NULL)
    {
        jButtons = JsonArray();
        int nWidgetButtons = GetLocalInt(oAssociate, sWidgetButtonsVarname);
        int nAIButtons = GetLocalInt(oAssociate, sAIButtonsVarname);
        JsonArrayInsertInplace(jButtons, JsonInt(nWidgetButtons)); // Command buttons.
        JsonArrayInsertInplace(jButtons, JsonInt(nAIButtons)); // AI buttons.
    }
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons);
    // ********** AI Data **********
    json jAIData = ai_GetAssociateDbJson(oPlayer, sOldAssociateType, "aidata");
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "aidata", jAIData);
    // ********** LootFilters **********
    json jLootFilters = ai_GetAssociateDbJson(oPlayer, sOldAssociateType, "lootfilters");
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "lootfilters", jLootFilters);
    // ********** Plugins ************
    // These are pulled straight from the database on the player only.
    // ********** Locations **********
    json jLocations = ai_GetAssociateDbJson(oPlayer, sOldAssociateType, "locations");
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "locations", jLocations);
    //ai_Debug("0i_main", "822", "Done setting old " + sOldAssociateType + " data to new " + sAssociateType + " data.");
}
