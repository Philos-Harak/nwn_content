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
// Checks if oMaster has the Table created for Associate data.
// If no table found then the table is created and then initialized.
void ai_CheckDataAndInitialize(object oMaster, string sAssociateType);
// Returns the associate defined by sAssociateType string
// Text must be one of the following: pc, familiar, companion, summons, henchman#
object ai_GetAssociateByStringType(object oMaster, string sAssociateType);
// Returns the associatetype int string format for oAssociate.
// They are pc, familar, companion, summons, henchman#
string ai_GetAssociateType(object oMaster, object oAssociate);
// Sets nData to sDataField for sAssociateType that is on oMaster.
// sDataField can be modes, magicmodes, widgetbuttons, aibuttons, magic,
//                   healoutcombat, healincombat.
void ai_SetAssociateDbInt(object oMaster, string sAssociateType, string sDataField, int nData);
// Returns nData from sDataField for sAssociateType that is on oMaster.
// sDataField can be modes, magicmodes, widgetbuttons, aibuttons, magic,
//                   healoutcombat, healincombat.
int ai_GetAssociateDbInt(object oMaster, string sAssociateType, string sDataField);
// Saves Associate conversation data from oAssociate to the database on oMaster.
void ai_SaveAssociateData(object oMaster, object oAssociate);
// Reverts a single players NPC's and associate event scripts back to their default.
void ai_FixEventScripts(object oCreature);

int ai_GetIsCharacter(object oCreature)
{
    return (GetIsPC(oCreature) && !GetIsDM(oCreature) && !GetIsDMPossessed(oCreature));
}
int ai_GetIsDungeonMaster(object oCreature)
{
    return (GetIsDM(oCreature) || GetIsDMPossessed(oCreature));
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
void ai_CreateAssociateDataTable(object oPlayer)
{
    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "CREATE TABLE IF NOT EXISTS ASSOCIATE_TABLE(" +
        "name              TEXT, " +
        "modes          INTEGER, " +
        "magicmodes     INTEGER, " +
        "widgetbuttons  INTEGER, " +
        "aibuttons      INTEGER, " +
        "magic          INTEGER, " +
        "healoutcombat  INTEGER, " +
        "healincombat   INTEGER, " +
        "PRIMARY KEY(name));");
    SqlStep(sql);
    //ai_Debug("0i_main", "291", "CREATING DATABASE: " + GetName(oPlayer));
}
void ai_CheckDataTableAndCreateTable(object oPlayer)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' " +
                    "AND name =@table;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString (sql, "@table", "ASSOCIATE_TABLE");
    if(!SqlStep(sql)) ai_CreateAssociateDataTable (oPlayer);
    //else ai_Debug("0i_main", "298", "CHECKING DATABASE: Database is there, " + GetName(oPlayer));
}
void ai_InitializeAssociateData(object oPlayer, string sAssociateType)
{
    string sQuery = "INSERT INTO ASSOCIATE_TABLE(name, " +
        "modes, magicmodes, widgetbuttons, aibuttons, magic, healoutcombat, " +
        "healincombat) VALUES(@name, @modes, @magicmodes, " +
        "@widgetbuttons, @aibuttons, @magic, @healoutcombat, @healincombat);";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociateType);
    SqlBindInt(sql, "@modes", 0);
    SqlBindInt(sql, "@magicmodes", 0);
    SqlBindInt(sql, "@widgetbuttons", 0);
    SqlBindInt(sql, "@aibuttons", 0);
    SqlBindInt(sql, "@magic", 0);
    SqlBindInt(sql, "@healoutcombat", 70);
    SqlBindInt(sql, "@healincombat", 50);
    //ai_Debug("0i_main", "315", "INITIALIZING DATABASE: " + GetName(oPlayer) +
    //         " sAssociatetype: " + sAssociateType);
    SqlStep(sql);
}
void ai_CheckDataAndInitialize(object oPlayer, string sAssociatetype)
{
    ai_CheckDataTableAndCreateTable(oPlayer);
    string sQuery = "SELECT name FROM ASSOCIATE_TABLE WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oPlayer, sQuery);
    SqlBindString (sql, "@name", sAssociatetype);
    if (!SqlStep (sql)) ai_InitializeAssociateData(oPlayer, sAssociatetype);
}
object ai_GetAssociateByStringType(object oMaster, string sAssociateType)
{
    if(sAssociateType == "pc") return oMaster;
    else if (sAssociateType == "familiar") return GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oMaster);
    else if (sAssociateType == "companion") return GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oMaster);
    else if (sAssociateType == "summons") return GetAssociate(ASSOCIATE_TYPE_SUMMONED, oMaster);
    else if (sAssociateType == "henchman1") return GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster);
    else if (sAssociateType == "henchman2") return GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, 2);
    else if (sAssociateType == "henchman3") return GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, 3);
    else if (sAssociateType == "henchman4") return GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, 4);
    else if (sAssociateType == "henchman5") return GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, 5);
    else if (sAssociateType == "henchman6") return GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oMaster, 6);
    return OBJECT_INVALID;
}
string ai_GetAssociateType(object oMaster, object oAssociate)
{
    int sAssociateType = GetAssociateType(oAssociate);
    if(GetIsPC(oAssociate)) return "pc";
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
void ai_SetAssociateDbInt(object oPlayer, string sAssociatetype, string sDataField, int nData)
{
    string sQuery = "UPDATE ASSOCIATE_TABLE SET " + sDataField +
                    " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    SqlBindInt(sql, "@data", nData);
    //ai_Debug("0i_main", "368", "SETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField + " nData: " + IntToString(nData));
    SqlStep(sql);
}
int ai_GetAssociateDbInt(object oPlayer, string sAssociatetype, string sDataField)
{
    string sQuery = "SELECT " + sDataField + " FROM ASSOCIATE_TABLE WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject(oPlayer, sQuery);
    SqlBindString(sql, "@name", sAssociatetype);
    //ai_Debug("0i_main", "377", "GETTING DATA: " + GetName(oPlayer) + " sAssociatetype: " +
    //         sAssociatetype + " sDataField: " + sDataField);
    if(SqlStep(sql)) return SqlGetInt(sql, 0);
    else return 0;
}
void ai_SaveAssociateData(object oPlayer, object oAssociate)
{
    if(GetIsPC(oAssociate)) return;
    string sAssociatetype = ai_GetAssociateType(oPlayer, oAssociate);
    ai_CheckDataAndInitialize(oPlayer, sAssociatetype);
    int nAssociateModes = GetLocalInt(oAssociate, sAssociateModeVarname);
    //ai_Debug("0i_main", "388", "Save - nAssociateModes: " + IntToString(nAssociateModes));
    ai_SetAssociateDbInt(oPlayer, sAssociatetype, "modes", nAssociateModes);
    nAssociateModes = GetLocalInt(oAssociate, sAssociateMagicModeVarname);
    //ai_Debug("0i_main", "391", "Save - nAssociateMagicModes: " + IntToString(nAssociateModes));
    ai_SetAssociateDbInt(oPlayer, sAssociatetype, "magicmodes", nAssociateModes);
    // Lets also save the variables to the player db.
    ai_SetAssociateDbInt(oPlayer, sAssociatetype, "magic", GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
    ai_SetAssociateDbInt(oPlayer, sAssociatetype, "healoutcombat", GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
    ai_SetAssociateDbInt(oPlayer, sAssociatetype, "healincombat", GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
}
void ai_FixEventScripts(object oCreature)
{
    //ai_Debug("0i_main", "498", "Reverting " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetLocalString(oCreature, "AI_ON_HEARTBEAT");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_NOTICE");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_END_COMBATROUND");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DIALOGUE");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_MELEE_ATTACKED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DAMAGED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetLocalString(oCreature, "AI_ON_DISTURBED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetLocalString(oCreature, "AI_ON_RESTED");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_SPELLCASTAT");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
