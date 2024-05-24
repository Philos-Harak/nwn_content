/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_main
////////////////////////////////////////////////////////////////////////////////
 Include script for handling main/basic functions not defined by other includes.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_constants"
#include "0i_messages"
// Returns TRUE if oCreature is controlled by a player.
int ai_GetIsCharacter(object oCreature);
// Returns TRUE if oCreature is controlled by a dungeon master.
int ai_GetIsDungeonMaster(object oCreature);
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
// Sets Associate conversation data from the database on oMaster to oAssociate.
// Used when an associate is created or a henchman is hired.
void ai_SetAssociateConversationData(object oMaster, object oAssociate);
// Saves Associate conversation data from oAssociate to the database on oMaster.
void ai_SaveAssociateConversationData(object oMaster, object oAssociate);
// Checks a monsters scripts and replaces the ones needed to run our AI.
void ai_SetMonsterEventScripts(object oCreature);
// Checks a associate scripts and replaces the ones needed to run our AI.
void ai_SetAssociateEventScripts(object oCreature);

int ai_GetIsCharacter(object oCreature)
{
    return (GetIsPC(oCreature) && !GetIsDM(oCreature) && !GetIsDMPossessed(oCreature));
}
int ai_GetIsDungeonMaster(object oCreature)
{
    return (GetIsDM(oCreature) || GetIsDMPossessed(oCreature));
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
void ai_CreateAssociateDataTable(object oCharacter, string sTable)
{
    sqlquery sql = SqlPrepareQueryObject(oCharacter,
        "CREATE TABLE IF NOT EXISTS " + sTable + "(" +
        "name           TEXT, " +
        "playername     TEXT, " +
        "companion      int, " +
        "familiar       int, " +
        "summons        int, " +
        "henchman1      int, " +
        "henchman2      int, " +
        "henchman3      int, " +
        "henchman4      int, " +
        "PRIMARY KEY(name, playername));");
    SqlStep(sql);
}
void CheckDataTableAndCreateTable(object oMaster, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryObject(oMaster, sQuery);
    SqlBindString (sql, "@tableName", sTable);
    if (!SqlStep (sql)) ai_CreateAssociateDataTable (oMaster, sTable);
}
void ai_InitializeAssociateData(object oMaster, string sName, string sPlayerName, string sTable)
{
    string sQuery = "INSERT INTO " + sTable + "(name, playername, " +
        "companion, familiar, summons, henchman1, henchman2, henchman3, " +
        "henchman4) VALUES(@name, @playername, @companion, @familiar, " +
        "@summons, @henchman1, @henchman2, @henchman3, @henchman4);";
    sqlquery sql = SqlPrepareQueryObject(oMaster, sQuery);
    SqlBindString(sql, "@name", sName);
    SqlBindString(sql, "@playername", sPlayerName);
    SqlBindInt(sql, "@companion", 0);
    SqlBindInt(sql, "@familiar", 0);
    SqlBindInt(sql, "@summons", 0);
    SqlBindInt(sql, "@henchman1", 0);
    SqlBindInt(sql, "@henchman2", 0);
    SqlBindInt(sql, "@henchman3", 0);
    SqlBindInt(sql, "@henchman4", 0);
    //ai_Debug("0i_main", "292", GetName(oMaster) + " sName: " + sName + " sPlayerName: " + sPlayerName);
    SqlStep(sql);
}
void ai_CheckDataAndInitialize(object oMaster, string sName, string sPlayerName, string sTable)
{
    CheckDataTableAndCreateTable(oMaster, sTable);
    string sQuery = "SELECT name FROM " + sTable + " WHERE name = @name AND " +
                    "playername = @playername;";
    sqlquery sql = SqlPrepareQueryObject (oMaster, sQuery);
    SqlBindString (sql, "@playername", sPlayerName);
    SqlBindString (sql, "@name", sName);
    //ai_Debug("0i_main", "303", GetName(oMaster) + " sName: " + sName + " sPlayerName: " + sPlayerName);
    if (!SqlStep (sql)) ai_InitializeAssociateData(oMaster, sName, sPlayerName, sTable);
}
string ai_GetAssociateDataField(object oMaster, object oAssociate)
{
    int sAssociateType = GetAssociateType(oAssociate);
    if(sAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION) return "companion";
    else if(sAssociateType == ASSOCIATE_TYPE_FAMILIAR) return "familiar";
    else if(sAssociateType == ASSOCIATE_TYPE_SUMMONED) return "summons";
    else if(sAssociateType == ASSOCIATE_TYPE_HENCHMAN)
    {
        string sDataField = "henchman";
        int nCntr = 1;
        object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, nCntr);
        while (oHenchman != OBJECT_INVALID || nCntr < 5)
        {
            if (oHenchman == oAssociate) return sDataField + IntToString(nCntr);
            oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, ++nCntr);
        }
    }
    return "";
}
void ai_SetAssociateDbInt(object oMaster, string sPlayerName, string sCharName, string sTable, string sDataField, int nData)
{
    string sQuery = "UPDATE " + sTable + " SET " + sDataField +
                    " = @data WHERE name = @name AND playername = @playername;";
    sqlquery sql = SqlPrepareQueryObject(oMaster, sQuery);
    SqlBindString(sql, "@playername", sPlayerName);
    SqlBindString(sql, "@name", sCharName);
    SqlBindInt(sql, "@data", nData);
    //ai_Debug("0i_main", "333", GetName(oMaster) + " sDataField: " + sDataField +
    //         " nData: " + IntToString(nData));
    SqlStep(sql);
}
int ai_GetAssociateDbInt(object oMaster, string sPlayerName, string sCharName, string sTable, string sDataField)
{
    string sQuery = "SELECT " + sDataField + " FROM " + sTable +
                    " WHERE name = @name AND playername = @playername;";
    sqlquery sql = SqlPrepareQueryObject(oMaster, sQuery);
    SqlBindString(sql, "@playername", sPlayerName);
    SqlBindString(sql, "@name", sCharName);
    //ai_Debug("0i_main", "344", GetName(oMaster) + " sDataField: " + sDataField);
    if(SqlStep(sql)) return SqlGetInt(sql, 0);
    else return 0;
}
void ai_SetAssociateConversationData(object oMaster, object oAssociate)
{
    string sPlayerName = ai_RemoveIllegalCharacters(GetPCPlayerName(oMaster));
    string sCharName = ai_RemoveIllegalCharacters(GetName(oMaster, TRUE));
    string sDataField = ai_GetAssociateDataField(oMaster, oAssociate);
    ai_CheckDataAndInitialize(oMaster, sPlayerName, sCharName, AI_MODE_DB_TABLE);
    int nAssociateModes = ai_GetAssociateDbInt(oMaster, sPlayerName, AI_MODE_DB_TABLE, sCharName, sDataField);
    //ai_Debug("0i_main", "355", "Set - nAssociateModes: " + IntToString(nAssociateModes));
    // if there is no saved modes then set the defaults.
    if(!nAssociateModes)
    {
        // Initialize Associate modes.
        SetLocalInt(oAssociate, sAssociateModeVarname, AI_MODE_DISTANCE_CLOSE | AI_MODE_HEAL_IN_COMBAT_50 | AI_MODE_HEAL_OUT_COMBAT_75);
        // Default behavior for associates at start
        ai_SaveAssociateConversationData(oMaster, oAssociate);
    }
    // Save the players modes to the associate.
    SetLocalInt(oAssociate, sAssociateModeVarname, nAssociateModes);
    ai_CheckDataAndInitialize(oMaster, sPlayerName, sCharName, AI_MAGIC_DB_TABLE);
    nAssociateModes = ai_GetAssociateDbInt(oMaster, sPlayerName, AI_MAGIC_DB_TABLE, sCharName, sDataField);
    //ai_Debug("0i_main", "355", "Set - nAssociateMagicModes: " + IntToString(nAssociateModes));
    // if there is no saved modes then set the defaults.
    if(!nAssociateModes)
    {
        // Initialize Associate modes.
        SetLocalInt(oAssociate, sAssociateMagicModeVarname, AI_MAGIC_NORMAL_MAGIC_USE);
        // Default behavior for associates at start
        ai_SaveAssociateConversationData(oMaster, oAssociate);
    }
    // Save the players magic modes to the associate.
    SetLocalInt(oAssociate, sAssociateMagicModeVarname, nAssociateModes);
}
void ai_SaveAssociateConversationData(object oMaster, object oAssociate)
{
    string sPlayerName = ai_RemoveIllegalCharacters(GetPCPlayerName(oMaster));
    string sCharName = ai_RemoveIllegalCharacters(GetName(oMaster, TRUE));
    string sDataField = ai_GetAssociateDataField(oMaster, oAssociate);
    int nAssociateModes = GetLocalInt(oAssociate, sAssociateModeVarname);
    //ai_Debug("0i_main", "373", "Save - nAssociateModes: " + IntToString(nAssociateModes));
    ai_CheckDataAndInitialize(oMaster, sPlayerName, sCharName, AI_MODE_DB_TABLE);
    ai_SetAssociateDbInt(oMaster, sPlayerName, sCharName, AI_MODE_DB_TABLE, sDataField, nAssociateModes);
    nAssociateModes = GetLocalInt(oAssociate, sAssociateMagicModeVarname);
    //ai_Debug("0i_main", "377", "Save - nAssociateMagicModes: " + IntToString(nAssociateModes));
    ai_CheckDataAndInitialize(oMaster, sPlayerName, sCharName, AI_MAGIC_DB_TABLE);
    ai_SetAssociateDbInt(oMaster, sPlayerName, sCharName, AI_MAGIC_DB_TABLE, sDataField, nAssociateModes);
}
void ai_SetMonsterEventScripts(object oCreature)
{
    ai_Debug("0i_main", "400", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "" || sScript == "nw_c2_default1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    if(sScript == "" || sScript == "nw_c2_default2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "m1q5e01zombie2" || sScript == "m1q5dcultist_2") {/*Let the base script run*/}
    else if(sScript == "m0q0_mystmage_2") {/*Let the base script run*/}
    else if(sScript == "m1q0cboss2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    if(sScript == "" || sScript == "nw_c2_default3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if (sScript == "m1_combanter_3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_m1_3_endround");
    else if (sScript == "m1q0dboss") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q0dboss");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    if(sScript == "" || sScript == "nw_c2_default4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "m1q2daelp_4") {/*Let the base script run*/}
    else if(sScript == "m1q3adryad4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_4_m1q3adryad4");
    else if(sScript == "m1q1apyre_4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_4_m1q1apyre_4");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    if(sScript == "" || sScript == "nw_c2_default5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    if(sScript == "" || sScript == "nw_c2_default6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    if(sScript == "" || sScript == "nw_c2_default8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    if(sScript == "" || sScript == "nw_c2_defaultb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    if(sScript == "" || sScript == "nw_c2_defaulte") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetAssociateEventScripts(object oCreature)
{
    ai_Debug("0i_main", "449", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "" || sScript == "nw_ch_ac1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    if(sScript == "" || sScript == "nw_ch_ac2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    if(sScript == "" || sScript == "nw_ch_ac3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    if(sScript == "" || sScript == "nw_ch_ac4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    if(sScript == "" || sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    if(sScript == "" || sScript == "nw_ch_ac6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    if(sScript == "" || sScript == "nw_ch_ac8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    if(sScript == "" || sScript == "nw_ch_acb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    if(sScript == "" || sScript == "nw_ch_ace") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
