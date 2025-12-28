/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_master
////////////////////////////////////////////////////////////////////////////////
 Include script for handling main/basic functions not defined by other includes.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_server_const"
#include "nwnx_skillranks"
#include "0i_s_message"

struct stSpell
{
    object oCaster;         // Caster of the spell.
    int iClass;             // Class used to cast the spell.
    int iSpellID;           // ID of the spell cast. If the Spell is to be stopped this will be changed to SPELL_STOP = -1
    int iSubType;           // 8)SUBTYPE_MAGICAL 16)SUBTYPE_SUPERNATURAL 24)SUBTYPE_EXTRAORDINARY
    int iSubSchool;         // 1)Calling 2)Creation 3)Healing 4)Summoning 5)Teleportation 6)Scrying 7)Charm 8)Compulsion
                            // 9)Figment 10)Glamer 11)Pattern 12)Phantasm 13)Shadow
    int iDescriptor;        // 1)Acid 2)air 3)chaotic 4)cold 5)darkness 6)death 7)earth 8)electricity 9)evil 10)fear
                            // 11)fire 12)force 13)good 14)language 15)lawful 16)light 17)mind 18)sonic 19)water
    int iCasterLevel;       // Level of the caster casting the spell. Used for duration and Spell Resistance.
    string sArcaneComponent;// Tag of any components an arcane spell requires. Used for arcane casters.
    string sDivineComponent;// Tag of any components a divine spell requires. Used for divine casters.
    int iDivineFocus;       // TRUE means the spell requires a divine focus (Clerics/Favored Soul = (Un)Holy Symbol,
                            // Druids = Holly/Mistletoe.
    string sEnhancingComp;  // Tag of any components used to boost the spell. If they have and consume the
                            // component then this variable is passed back to the spell with "TRUE" otherwise its "FALSE".
    int iCompAmount;        // The gold piece amount of the s*Comp. Used mostly in gem dust as gem dust is set in 25gp
                            // increments. If 0 or "" then it will assume the item is a focus and is not removed.
                            // Set to -1 if you want to just remove one component no matter the cost. Used for gems.
    object oTarget;         // Object targeted.
    location lTarget;       // Location the spell has targeted, if no location the set to the oTarget location.
    object oAreaTarget;     // Used in area effects to track the spell has a targets.
    int iAreaShape;         // 0)SHAPE_SPELLCYLINDER (line) 1)SHAPE_CONE (xdeg) 2)SHAPE_CUBE 3)SHAPE_SPELLCONE (60deg)
                            // 4)SHAPE_SPHERE 5)SHAPE_RANGE_TARGET 6)SHAPE_TOUCH_TARGET 7)SHAPE_PERSONAL.
    float fAreaSize;        // Line is the length, Cone(xdeg) is the width, Cube is 1/2 the length of one side
                            // Cone(60deg) is the length, Sphere is the radius. Put in feet, system will adjust to correct size.
    int iLineOfSight;       // Default(FALSE) TRUE must be able to see them from the center of the areas start.
    int iObjectFilter;      // Defualt(All) Type of object to find OBJECT_TYPE_ALL, OBJECT_TYPE_CREATURE, OBJECT_TYPE_DOOR, etc.
    int iTargetType;        // Type of object to ignore in the area of effect. 1)TARGET_TYPE_ALL 2) TARGET_TYPE_ENEMIES 3)TARGET_TYPE_ALLIES
    float fDelay;           // The delay in a spells area effect.
    int iDurationType;      // 0)Instant 1)Temporary 2)Permanent 3)Concentration 4)Rounds 5)Minutes 6)Turns 7)Hours
    int iDurNumOfDice;      // Number of dice used in duration.
    int iDurationDie;       // Dice used for duration.
    int iDurDicePerLvl;     // The Duration * Spells level / iDurPerLvl for duration dice. i.e. 1 is every level, 2 every other level, etc.
    int iMaxDurNumOfDice;   // The maximum number of dice that can be rolled for the spell.
    int iDuration;          // Duration number used for either rounds, minutes, turns, or hours.
    int iDurPerLvl;         // The Duration * Spells level / iDurPerLvl for duration. i.e. 1 is every level, 2 every other level, etc.
    int iMaxDuration;       // The maximum the duration can be for the spell.
    float fDuration;        // The duration to be used in an effect.
    int iFireAgain;         // Default (0) defines how many times this spell fires again. 1 = once, 2 = twice, etc.
    int iSpellResistance;   // Default (FALSE) If there is a spell resistance check.
    int iSave;              // The base save to be made 0)None 1) SAVING_THROW_FORT 2)SAVING_THROW_REFLEX 3)SAVING_THROW_WILL
    int iSaveDC;            // If set to 0 then use spell save DC otherwise one can be defined here.
    int iSaveHalf;          // Default (FALSE) if true then any save will reduce the damage in half for reflex save.
    int iSaveType;          // The type of savingthrow it may have SAVING_THROW_TYPE_*  acid, chaos, cold, death, disease, etc.
    int iSaveResult;        // The result of a Resistance check and save check.
    int iDamageType;        // 1)DAMAGE_TYPE_BLUDGEONING 2)DAMAGE_TYPE_PIERCING 4)DAMAGE_TYPE_SLASHING 8)DAMAGE_TYPE_MAGICAL
                            // 16)DAMAGE_TYPE_ACID 32)DAMAGE_TYPE_COLD 64)DAMAGE_TYPE_DIVINE 128)DAMAGE_TYPE_ELECTRICAL
                            // 256)DAMAGE_TYPE_FIRE 512)DAMAGE_TYPE_NEGATIVE 1024)DAMAGE_TYPE_POSITIVE 2048)DAMAGE_TYPE_SONIC
    int iModNumOfDice;      // Number of dice to be used.
    int iModifierDie;       // Die to be used for damage, penalty, or buff.
    int iModDicePerLvl;     // The number of levels per dice added to roll. 1 is every level, 2 every other level, etc.
    int iMaxModNumOfDice;   // The maximum number of dice that can be rolled for the spell.
    int iModifier;          // Number to be added to a dice roll. If no dice then the number to be used.
    int iModPerLvl;         // The number of times to add iBonus per caster level. 1 is every caster level, 2 every other level, etc.
    int iMaxModifier;       // The maximum modifier the spell can have for a modifier.
    int iResult;            // The result to be used for damage or number with the spell.
    int iImpact;            // The impact graphic of the spell such as VFX_IMP_FLAME_S for a fire spell.
    int iBeam;              // The beam graphic of the spell such as VFX_BEAM_COLD for a cold spell.
    int iCounter;           // Used in calculating the closest target in some beam effects.
    object oBeamEffector;   // The staring object for a beam effect in a spell.
    int iMetaMagic;         // Any MetaMagic feats attached to the spell.
};

// Makes extensive check for player characters (not DM's)
int GetIsCharacter(object oCreature);
// Makes extensive check for dm's.
int GetIsDungeonMaster(object oCreature);
// Gets the top master and returns them if they are a player.
object GetPlayerMaster(object oAssociate);
// Will return a rolled result from a dice string.
// example: "1d6" will be 1-6 or "3d6" will be 3-18 or 1d6+5 will be 6-11.
int RollDiceString(string sDice);
// Executes a script and returns a value passed.
// sScript is the script to run.
// oObjectSelf is the object running the script.
int ExecuteScriptReturnInt(string sScript, object oObjectSelf);
// Turns a location into a stringarray.
// lLocation is the location to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
string LocationToStringArray(location lLocation);
// Turns a stringarray into a location.
// sArray is the stringarray to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
location StringArrayToLocation(string sArray);
// Return true if the skill has master skill ranks based on the skill.
// Crafting skills use the Lore item cost table.
int IfMasterSkillRanks(int iSkill, object oPC, int iItemCost = 0);
// This function will replace any occurrence of sFind in sSource with sReplace.
// sSource is the sourse text.
// sFind it what to find in the text.
// sReplace is what to replace sFind with.
string StringReplaceText(string sSource, string sFind, string sReplace);
// Gets a string of characters between the predefined marker of ":".
// sText is the text holding the array.
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays).
string GetStringArray(string sText, int iIndex, string sSeperator = ":");
// Sets a string of characters between the predefined markers of ":".
// sText is the text holding the array.
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sField is the field of characters to replace that index.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays).
string SetStringArray(string sText, int iIndex, string sField, string sSeperator = ":");

// Rolls on a 2da table that is set up to work with this script.
// This is a weighted rolling table (2da) system. If you want an item to have a higher chance
// then place more than one row of the entry into the 2da file.
// s2DA is the 2da file to roll on.
// iMaxOnRoll uses a specific number instead of the rows in the 2da file.
// if a PC is passed then the roll will use the PC's luck.
// Returns the Row in the 2da it rolled.
int RollOn2daTable(string s2DA, int iMaxOnRoll = 0, object oPC = OBJECT_INVALID);

// Rolls until it gets a magic item that is within the ilevel passed.
// s2DAFile is the 2da file name to roll on.
// iLevel is the CR or area level passed to the treasure scripts.
// if a PC is passed then the roll will use the PC's luck.
int RollOn2daTableWithMinItems(string s2DAFile, int iLevel, object oPC = OBJECT_INVALID);

// Returns a integer as a two digit string.
// Example 1 is returned as 01. Will reduce any number over 99 to 99.
// iNumber is the integer to change.
string Get2Digits(int iNumber);

// This uses the character's luck when making rolls.
// oPC is the PC making the roll.
int d20LuckRoll(object oPC);

// This uses the character's luck when making rolls.
// oPC is the PC making the roll.
int d100LuckRoll(object oPC);

// This uses the character's luck when making rolls.
// Rolling from 1 to nDie.
// oPC is the PC making the roll.
// nDie is the die you want to roll.
int RandomLuckRoll(object oPC, int nDie);

// Return a number as a string with commas.
string GetGoldString(int iGold);

// Get a specific object based on the tag in oArea. Indexes with "0_AreaByTag" + sNested.
// oArea is the area to search.
// sTag is the tag to search for all objects in the area.
// iIndex is the numbered object you are looking for from 1 to number of objects.
// iObjectType allows to select a specific object type.
// iLastCall Set to true if this is the last call, does not need to be set if
//   looking at all objects, last object will be an automatic iLastCall.
// WARNING: Do not create objects while using this function. It will mess up the order.
object GetObjectInAreaByTag (object oArea, string sTag, int iIndex = 1, int iObjectType = OBJECT_TYPE_ALL, int iLastCall = FALSE);

// Get a specific object type in oArea. Indexes with "0_AreaObject" + sNested.
// oArea is the area to search.
// iIndex is the numbered object you are looking for from 1 to number of objects.
// iObjectType allows to select a specific object type.
// iLastCall Set to true if this is the last call, does not need to be set if
//   looking at all objects, last object will be an automatic iLastCall.
// WARNING: Do not create objects while using this function. It will mess up the order.
object GetObjectInArea (object oArea, int iIndex = 1, int iObjectType = OBJECT_TYPE_ALL, int iLastCall = FALSE);

// Removes characters not in the sLegal string.
string RemoveIllegalCharacters (string sString, string sLegal = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");

float GetRandomDelay(float fMinimumTime = 0.4, float MaximumTime = 1.1);

// Sets up new skill feats.
void SetNewSkillFeats ();

// Creates a json array with sString up to nIndex.
json CreateJsonArrayWithString (string sString, int nIndex);

// Makes extensive check for player characters (not DM's)
int GetIsCharacter (object oCreature)
{
    if (GetIsPC(oCreature) && !GetIsDM(oCreature) && !GetIsDMPossessed(oCreature)) return TRUE;
    return FALSE;
}

// Makes extensive check for dm's.
int GetIsDungeonMaster (object oCreature)
{
    if (GetIsDM (oCreature) || GetIsDMPossessed (oCreature) || GetIsPlayerDM (oCreature)) return TRUE;
    return FALSE;
}
// Gets the top master and returns them if they are a player.
object GetPlayerMaster(object oAssociate)
{
    if(GetIsCharacter(oAssociate)) return oAssociate;
    object oMaster = GetMaster(oAssociate);
    if(GetIsCharacter(oMaster)) return oMaster;
    else if(oMaster != OBJECT_INVALID) GetPlayerMaster(oMaster);
    return OBJECT_INVALID;
}

// Will return a rolled result from a dice string.
// example: "1d6" will be 1-6 or "3d6" will be 3-18 or 1d6+5 will be 6-11.
int RollDiceString (string sDice)
{
    int nNegativePos, nBonus = 0;
    string sRight = GetStringRight (sDice, GetStringLength (sDice) - FindSubString (sDice, "d") - 1);
    int nPlusPos = FindSubString (sRight, "+");
    if (nPlusPos != -1)
    {
        nBonus = StringToInt (GetStringRight (sRight, GetStringLength (sRight) - nPlusPos - 1));
        sRight = GetStringLeft (sRight, nPlusPos);
    }
    else
    {
        nNegativePos = FindSubString (sRight, "-");
        if (nNegativePos != -1)
        {
            nBonus = StringToInt (GetStringRight (sRight, GetStringLength (sRight) - nNegativePos - 1));
            sRight = GetStringLeft (sRight, nNegativePos);
            nBonus = nBonus * -1;
        }
    }
    int nDie = StringToInt (sRight);
    int nNumOfDie = StringToInt (GetStringLeft (sDice, FindSubString (sDice, "d")));
    int nResult;
    while (nNumOfDie > 0)
    {
        nResult += Random (nDie) + 1;
        nNumOfDie --;
    }
    return nResult + nBonus;
}

// Executes a script and returns a value passed.
// sScript is the script to run.
// oObjectSelf is the object running the script.
int ExecuteScriptReturnInt (string sScript, object oObjectSelf)
{
    // Execute the script.
    ExecuteScript (sScript, oObjectSelf);
    // Get the return value from the script.
    return GetLocalInt (oObjectSelf, "0_ReturnInt");
}

// Turns a location into a stringarray.
// lLocation is the location to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
string LocationToStringArray (location lLocation)
{
    string sLocation;
    object oArea;
    vector vPosition;
    float fFacing;
    oArea = GetAreaFromLocation (lLocation);
    vPosition = GetPositionFromLocation (lLocation);
    fFacing = GetFacingFromLocation (lLocation);
    sLocation = ":" + GetTag (oArea) + ":" + FloatToString(vPosition.x, 0, 2) + ":" +
          FloatToString(vPosition.y, 0, 2) + ":" + FloatToString(vPosition.z, 0, 2) + ":" +
          FloatToString (fFacing, 0, 2) + ":";
    return sLocation;
}

// Turns a stringarray into a location.
// sArray is the stringarray to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
location StringArrayToLocation (string sArray)
{
    object oArea;
    float fX, fY, fZ, fFacing;
    vector vPosition;
    oArea = GetObjectByTag (GetStringArray (sArray, 0));
    fX = StringToFloat (GetStringArray (sArray, 1));
    fY = StringToFloat (GetStringArray (sArray, 2));
    fZ = StringToFloat (GetStringArray (sArray, 3));
    vPosition = Vector(fX, fY, fZ);
    fFacing = StringToFloat (GetStringArray (sArray, 4));
    return Location (oArea, vPosition, fFacing);
}

// Return true if the skill has master skill ranks based on the skill.
// Crafting skills use the Lore item cost table.
int IfMasterSkillRanks (int iSkill, object oPC, int iItemCost = 0)
{
    int iRanks, i2daValue;
    // Get the ranks of the skill.
    iRanks = GetSkillRank(iSkill, oPC, FALSE);
    // Check the skill and see what needs to be done.
    if (iSkill == SKILL_CRAFT_ARMOR || iSkill == SKILL_CRAFT_WEAPON)
    {
        // Get the items 2da value and compare.
        i2daValue = StringToInt (Get2DAString("skillvsitemcost", "DeviceCostMax", iRanks));
        //Debug ("0i_main", "88", "ItemValue: " + IntToString (iItemCost) + " 2daValue: " + IntToString (i2daValue) + " Ranks: " + IntToString (iRanks));
        if (iItemCost <= i2daValue) return TRUE;
    }
    return FALSE;
}

// This function will replace any occurrence of sFind in sSource with sReplace.
// sSource is the sourse text.
// sFind it what to find in the text.
// sReplace is what to replace sFind with.
string StringReplaceText (string sSource, string sFind, string sReplace)
{
    int iFindLength = GetStringLength (sFind);
    int iPosition = 0;
    string sRetVal = "";
    // Locate all occurences of sFind.
    int iFound = FindSubString (sSource, sFind);
    while (iFound >= 0 )
    {
        // Build the return string, replacing this occurence of sFind with sReplace.
        sRetVal += GetSubString (sSource, iPosition, iFound - iPosition) + sReplace;
        iPosition = iFound + iFindLength;
        iFound = FindSubString (sSource, sFind, iPosition);
    }
    // Tack on the end of sSource and return.
    return sRetVal + GetStringRight (sSource, GetStringLength(sSource) - iPosition);
}

// Gets a string of characters between the predefined marker of ":".
// sArray is the text holding the array.
// sArray should look as follows ":0:0:0:0:0:"
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays).
string GetStringArray (string sArray, int iIndex, string sSeperator = ":")
{
   int iCount = 0, iMark = 0, iStringLength = GetStringLength (sArray);
   string sChar;
   // Search the string.
   while (iCount < iStringLength)
   {
      sChar = GetSubString (sArray, iCount, 1);
      // Look for the mark.
      if (sChar == sSeperator)
      {
         // If we have not found it then lets see if this mark is the one.
         if (iMark < 1)
         {
             // If we are down to 0 in the index then we have found the mark.
             if (iIndex > 0) iIndex --;
             // Mark the start of the string we need.
             else iMark = iCount + 1;
         }
         else
         {
            // We have the first mark so the next mark will mean we have the string we need.
            // Now pull it and return.
            sArray = GetSubString (sArray, iMark, iCount - iMark);
            return sArray;
         }
      }
      iCount ++;
   }
   // If we hit the end without finding it then return "" as an error.
   return "";
}

// Sets a string of characters between the predefined markers of ":".
// sArray is the text holding the array.
// sArray should look as follows ":0:0:0:0:0:"
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sField is the field of characters to replace that index.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays in one string).
string SetStringArray (string sArray, int iIndex, string sField, string sSeperator = ":")
{
   int iCount = 1, iMark = 1, iStringLength = GetStringLength (sArray);
   int iIndexCounter = 0;
   string sChar, sNewArray = sSeperator, sText;
   // Check to make sure this is not a new array.
   // If it is new then set it with 1 slot.
   if (iStringLength < 2)
   {
        sArray = sSeperator + " " + sSeperator;
        iStringLength = 3;
   }
   // Search the string.
   while (iCount <= iStringLength)
   {
      sChar = GetSubString (sArray, iCount, 1);
      // Look for the mark.
      if (sChar == sSeperator)
      {
            // First check to see if this is the index we are replacing.
            if (iIndex == iIndexCounter) sText = sField;
            else
            {
                // Get the original text for this field.
                sText = GetSubString (sArray, iMark, iCount - iMark);
            }
            // Add the field to the new index.
            sNewArray = sNewArray + sText + sSeperator;
            // Now set the marker to the new starting point.
            iMark = iCount + 1;
            // Increase the index counter as well.
            iIndexCounter ++;
      }
      iCount ++;
   }
   // if we are at the end of the array and still have not set the data
   // then add blank data until we get to the correct index.
   while (iIndexCounter <= iIndex)
   {
        // If they match add the field.
        if (iIndexCounter == iIndex) sNewArray = sNewArray + sField + sSeperator;
        // Otherwise just add a blank field.
        else sNewArray = sNewArray + " " + sSeperator;
        iIndexCounter ++;
   }
   // When done return the new array.
   return sNewArray;
}

// Rolls on a 2da table that is set up to work with this script.
// This is a weighted 2da system. If you want an item to have a higher chance
// then place more than one row of it in the file.
// s2DAFile is the 2da file to roll on.
// iMaxOnRoll uses a specific number instead of the rows in the 2da file.
// if a PC is passed then the roll will use the PC's luck.
// The first row of the 2da file must have maximum rows in the 2da file in COUNT column.
// Returns the Row in the 2da it rolled.
int RollOn2daTable (string s2DAFile, int iMaxOnRoll = 0, object oPC = OBJECT_INVALID)
{
   int iMaxRows, iRow;
   // Get the max num of rows. Row 0 is always reserved for the maximum rows in the 2da in the Count column.
   iMaxRows = StringToInt (Get2DAString (s2DAFile, "Count", 0));
   // adjust to the new max as long as its not off the chart.
   if (iMaxOnRoll > 0 && iMaxOnRoll < iMaxRows) iMaxRows = iMaxOnRoll;
   // Roll to get the random row, rows are always 1 to max.
   iRow = RandomLuckRoll (oPC, iMaxRows);
   return iRow;
}

// Rolls until it gets a magic item that is within the ilevel passed.
// s2DAFile is the 2da file name to roll on.
// iLevel is the CR or area level passed to the treasure scripts.
// if a PC is passed then the roll will use the PC's luck.
int RollOn2daTableWithMinItems (string s2DAFile, int iLevel, object oPC = OBJECT_INVALID)
{
    // Make sure iMaxRow is reset to get all possible results.
    int iMaxRows = 0, iCount = 0, iRow, iMinLevel;
    // Get the max num of rows. Row 0 is always reserved for the maximum rows in the 2da in the Count column.
    iMaxRows = StringToInt (Get2DAString (s2DAFile, "Count", 0));
    while (iCount < MAX_REROLLS)
    {
        iRow = RollOn2daTable (s2DAFile, iMaxRows, oPC);
        iMinLevel = StringToInt (Get2DAString (s2DAFile, "MinLevel", iRow));
        // If the level meets the MinLevel of the item then exit the loop.
        if (iMinLevel <= iLevel) iCount = MAX_REROLLS;
        // IF not get the new max roll and roll again.
        else iMaxRows = StringToInt (Get2DAString (s2DAFile, "Reroll", iRow));
        iCount ++;
    }
    return iRow;
}

// Returns a integer as a two digit string.
// Example 1 is returned as 01.
// Note:Will reduce any number over 99 to 99.
// Note:Will increase any number under 0 to 0.
// iNumber is the integer to change.
string Get2Digits (int iNumber)
{
    if (iNumber < 0) iNumber = 0;
    if (iNumber < 10) return "0" + IntToString (iNumber);
    else
    {
        if (iNumber > 99) iNumber == 99;
        return IntToString (iNumber);
    }
}

// This uses the character's luck when making rolls.
// oPC is the PC making the roll.
int d20LuckRoll (object oPC)
{
    int nLuck = GetLocalInt (oPC, "0_Luck");
    int nRoll = d20() + (nLuck / 5);
    // Make sure it stays under 20.
    if (nRoll > 20) nRoll = 20;
    // Send message for testing.
    //Debug ("0i_main", "616", GetName (oPC) + " Roll(20):" + IntToString (nRoll) + " Luck:" + IntToString (nLuck));
    return nRoll;
}

// This uses the character's luck when making rolls.
// oPC is the PC making the roll.
int d100LuckRoll (object oPC)
{
    int nLuck = GetLocalInt (oPC, "0_Luck");
    int nRoll = d100() + nLuck;
    // Make sure all rolls under 100.
    if (nRoll > 100) nRoll = 100;
    // Send message for testing.
    //Debug ("0i_main", "640", GetName (oPC) + " Roll(100):" + IntToString (nRoll) + " Luck:" + IntToString (nLuck));
    return nRoll;
}

// This uses the character's luck when making rolls.
// Rolling from 1 to nDie.
// oPC is the PC making the roll.
// iDie is the die you want to roll.
int RandomLuckRoll (object oPC, int nDie)
{
    // Get the players luck.
    int nLuck = GetLocalInt (oPC, "0_Luck");
    float fLuck = IntToFloat (nLuck);
    float fDie = IntToFloat (nDie);
    // Make roll.
    int nRoll = Random (nDie) + 1 + FloatToInt ((fDie * (fLuck / 100.0f)));
    // Make sure it says under the top end of the roll.
    if (nRoll > nDie) nRoll = nDie;
    // Send message for testing.
    //Debug ("0i_main", "675", GetName (oPC) + " Roll(" + FloatToString (fDie,0,0) + "):" + IntToString (nRoll) + " Luck:" + FloatToString (fLuck, 0,0));
    return nRoll;
}

// Return a number as a string with commas.
// will do up to 999,999,999
string GetGoldString (int iGold)
{
    int iStringLength;
    string sGold = IntToString (iGold);
    if (iGold > 999999)
    {
        iStringLength = GetStringLength (sGold);
        sGold = GetStringLeft (sGold, iStringLength - 6) + "," + GetStringRight (sGold, 6);
    }
    if (iGold > 999)
    {
        iStringLength = GetStringLength (sGold);
        sGold = GetStringLeft (sGold, iStringLength - 3) + "," + GetStringRight (sGold, 3);
    }
    return sGold;
}

// Get a specific object based on the tag in oArea. Indexes with "0_AreaByTag".
// oArea is the area to search.
// sTag is the tag to search for all objects in the area.
// iIndex is the numbered object you are looking for from 1 to number of objects.
// iObjectType allows to select a specific object type.
// iLastCall Set to true if this is the last call, does not need to be set if
//   looking at all objects, last object will be an automatic iLastCall.
// WARNING: Do not create objects while using this function. It will mess up the order.
object GetObjectInAreaByTag (object oArea, string sTag, int nIndex = 1, int nObjectType = OBJECT_TYPE_ALL, int nLastCall = FALSE)
{
    int nCounter;
    string sObjectTag;
    object oObject;
    //Debug ("0i_main", "548", "oArea: " + GetName (oArea) + " sTag: " + sTag +
    //       " nIndex: " + IntToString (nIndex) + " nObjectType: " + IntToString (nObjectType));
    // Check to see if we have alread found the first object in the area.
    nCounter = GetLocalInt (oArea, "0_AreaByTag");
    if (nCounter == 0) oObject = GetFirstObjectInArea (oArea, nObjectType);
    else oObject = GetNextObjectInArea (oArea, nObjectType);
    sObjectTag = GetTag (oObject);
    if (sObjectTag == sTag) nCounter++;
    while (oObject != OBJECT_INVALID && (sObjectTag != sTag || nIndex != nCounter))
    {
        //Debug ("0i_main", "558", " Object: " + GetName (oObject) + " nObjectType: " + IntToString (GetObjectType (oObject)) +
        //       " sObjectTag: " + sObjectTag + " nCounter: " + IntToString (nCounter));
        oObject = GetNextObjectInArea (oArea, nObjectType);
        sObjectTag = GetTag (oObject);
        if (sObjectTag == sTag) nCounter++;
    }
    if (nLastCall || oObject == OBJECT_INVALID) DeleteLocalInt (oArea, "0_AreaByTag");
    else SetLocalInt (oArea, "0_AreaByTag", nCounter);
    //Debug ("0i_main", "566", " Object: " + GetName (oObject) + " nObjectType: " + IntToString (GetObjectType (oObject)) +
    //       " sObjectTag: " + sObjectTag + " nCounter: " + IntToString (nCounter));
    return oObject;
}

// Get a specific object based on the tag in oArea. Indexes with "0_AreaObject" + sNested.
// oArea is the area to search.
// iIndex is the numbered object you are looking for from 1 to number of objects.
// iObjectType allows to select a specific object type.
// iLastCall Set to true if this is the last call, does not need to be set if
//   looking at all objects, last object will be an automatic iLastCall.
object GetObjectInArea (object oArea, int nIndex = 1, int nObjectType = OBJECT_TYPE_ALL, int nLastCall = FALSE)
{
    object oObject;
    int nCounter;
    // Check to see if we have alread found the first object in the area.
    nCounter = GetLocalInt (oArea, "0_AreaObject");
    if (nCounter == 0) oObject = GetFirstObjectInArea (oArea, nObjectType);
    else oObject = GetNextObjectInArea (oArea, nObjectType);
    nCounter++;
    while (oObject != OBJECT_INVALID && nIndex != nCounter)
    {
        //Debug ("0i_main", "588", "oArea: " + GetName (oArea) + " Object: " + GetName (oObject) +
        //       " nObjectType: " + IntToString (nObjectType) + " nIndex: " + IntToString (nIndex) +
        //       " nCounter: " + IntToString (nCounter));
        oObject = GetNextObjectInArea (oArea, nObjectType);
        nCounter++;
    }
    if (nLastCall || oObject == OBJECT_INVALID) DeleteLocalInt (oArea, "0_AreaObject");
    else SetLocalInt (oArea, "0_AreaObject", nCounter);
    return oObject;
}

// Removes characters not in the sLegal string.
string RemoveIllegalCharacters (string sString, string sLegal = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
{
    string sOut, sVal;
    int nLength = GetStringLength(sString);
    int i;
    for (i = 0; i != nLength; ++i)
    {
        sVal = GetSubString(sString, i, 1);
        if (TestStringAgainstPattern("**" + sVal + "**", sLegal))
            sOut += sVal;
    }
    return sOut;
}

float GetRandomDelay (float fMinimumTime = 0.4, float MaximumTime = 1.1)
{
    float fRandom = MaximumTime - fMinimumTime;
    if(fRandom < 0.0) return 0.0;
    else
    {
        int nRandom;
        nRandom = FloatToInt (fRandom  * 10.0);
        nRandom = Random (nRandom) + 1;
        fRandom = IntToFloat (nRandom);
        fRandom /= 10.0;
        return fRandom + fMinimumTime;
    }
}

// Sets up new skill feats.
void SetNewSkillFeats ()
{
    struct NWNX_SkillRanks_SkillFeat SkillFeat;
    // Diligent (1294): +2 bonus to Appraise and Decipher Script checks.
    SkillFeat.iSkill = SKILL_APPRAISE;
    SkillFeat.iFeat = 1294/*Diligent*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_DECIPHER_SCRIPT;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Investigator (1295): +2 bonus to Knowledge and Search checks.
    SkillFeat.iSkill = SKILL_KNOWLEDGE;
    SkillFeat.iFeat = 1295/*Investigator*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_SEARCH;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Magical Aptitude (1296): +2 bonus to Spellcraft and Use Magic Device checks.
    SkillFeat.iSkill = SKILL_SPELLCRAFT;
    SkillFeat.iFeat = 1296/*Magical Aptitude*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_USE_MAGIC_DEVICE;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Negotiator (1297): +2 bonus to Persuade and Taunt checks.
    SkillFeat.iSkill = SKILL_PERSUADE;
    SkillFeat.iFeat = 1297/*Negotiator*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_TAUNT;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Nimble Fingers (1298): +2 bonus to Disable Device and Open Locks checks.
    SkillFeat.iSkill = SKILL_DISABLE_TRAP;
    SkillFeat.iFeat = 1298/*Nimble Fingers*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_OPEN_LOCK;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Self-Sufficient (1299): +2 bonus to Heal and Survival checks.
    SkillFeat.iSkill = SKILL_HEAL;
    SkillFeat.iFeat = 1299/*Self-Sufficient*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_SURVIVAL;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Agile (1293): +2 bonus to Acrobatics and Parry checks.
    SkillFeat.iSkill = SKILL_ACROBATICS;
    SkillFeat.iFeat = 1293/*Agile*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_PARRY;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Mercantile Background (1292): +2 bonus to Appraise and Knowledge checks.
    SkillFeat.iSkill = SKILL_APPRAISE;
    SkillFeat.iFeat = 1292/*Mercantile Background*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    SkillFeat.iSkill = SKILL_KNOWLEDGE;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Skill Affinity (Acrobatics) (1300): +2 bonus to Acrobatics.
    SkillFeat.iSkill = SKILL_ACROBATICS;
    SkillFeat.iFeat = 1300/*Skill Affinity (Acrobatics)*/;
    SkillFeat.iModifier = 2;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
    // Skill Mastery (Acrobatics) (1301): +4 bonus to Acrobatics.
    SkillFeat.iSkill = SKILL_ACROBATICS;
    SkillFeat.iFeat = 1301/*Skill Affinity (Acrobatics)*/;
    SkillFeat.iModifier = 4;
    NWNX_SkillRanks_SetSkillFeat (SkillFeat, TRUE);
}

// Creates a json array with sString up to nIndex.
json CreateJsonArrayWithString (string sString, int nIndex)
{
    int nCount = 0;
    json jArray = JsonArray ();
    while (nCount <= nIndex)
    {
        jArray = JsonArrayInsert (jArray, JsonString (sString));
        nCount ++;
    }
    return jArray;
}

