/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_win_functions
////////////////////////////////////////////////////////////////////////////////
 Include scripts for handling nui window functions.
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "nw_inc_nui_insp"
#include "0i_character"
#include "nwnx_admin"
#include "0i_webhook"
struct stItemStats
{
    string sText;
    int nEGoldValue;
    int nIGoldValue;
};

// Creates a text of the race.
string GetRaceText (object oTarget);
// Creates a text of the alignment.
string GetAlignText (object oTarget);
// Creates a text of the class and level (used to look like the char sheet).
string GetClassText (object oTarget, int nPosition);
// Sets up a combo box with the classes usable by NPC's.
json JArrayInsertClasses ();
// Converts a class to the combo selection number.
int GetClassForCombo (int nPosition, object oCreature);
// Updates DM creature screen
void UpdateDMCreatureScreen (object oPlayer, object oTarget);
// Gets a targets total wealth with gold and item values.
int GetWealth (object oTarget);
// Gets the wealth level from itemvalue.2da (characters base wealth per level).
int GetWealthByLevel (int nWealth);
// Gets the evaluation based on wealth level and character level.
string GetWealthByLevelEvaluation (int nWealthLevel, object oTarget);
// Lists out the targets inventory items information.
string GetInventoryGoldValues (object oTarget);
// Set a trap from a combo menu.
string GetVariableText (object oTarget);
// Sets up a combo box for traps.
json JsonArrayInsertTraps ();
// Sets up a combo box with a tiles main light colors.
json JsonArrayInsertTileLightMainColors ();
// Sets up a combo box with a tiles source light colors.
json JsonArrayInsertTileLightSourceColors ();
// Sets an areas Light colors.
// oArea is the area to set.
// nColor is the color to use.
// nType is either 1 Main1, 2 Main2, 3 Source1, 4 Source2.
// Note: Source nColor will be limited for Main (0-31) or Source (0-15)
void SetAreaMainLightColor (object oArea, int nColor, int nType);
// Changes Combo number to correct fog color.
// nNumber is the color to use.
int ComboNumberToFogColor (int nNumber);
// Changes fog color to correct combo number.
// nColor is the color to use.
int FogColorToComboNumber (int nColor);
// Update Dm's targets in all windows.
void SetPlayerWinTarget (object oPC, string sTarget);
// Clears up any windows on the screen linked to examining.
void RemoveAllExamineWindows (object oPC);
// Clears any databases for a character that is deleted.
void DeleteCharacterFromDatabase (object oPC);

string GetRaceText (object oTarget)
{
    string sRace = GetSubRace (oTarget);
    if (sRace == "") sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oTarget))));
    return sRace;
}

string GetAlignText (object oTarget)
{
    string sAlign1, sAlign2;
    switch (GetAlignmentLawChaos (oTarget))
    {
        case ALIGNMENT_LAWFUL : sAlign1 = "L"; break;
        case ALIGNMENT_NEUTRAL : sAlign1 = "N"; break;
        case ALIGNMENT_CHAOTIC : sAlign1 = "C"; break;
    }
    switch (GetAlignmentGoodEvil (oTarget))
    {
        case ALIGNMENT_GOOD : sAlign2 = "G"; break;
        case ALIGNMENT_NEUTRAL : sAlign2 = "N"; break;
        case ALIGNMENT_EVIL : sAlign2 = "E"; break;
    }
    string sAlign = sAlign1 + sAlign2;
    if (sAlign == "NN") sAlign = "TN";
    return sAlign;
}

string GetLawChaosText (int nValue)
{
    if (nValue < 31) return "Chaos (" + IntToString (nValue) + ")";
    else if (nValue < 71) return "Neutral (" + IntToString (nValue) + ")";
    return "Lawful (" + IntToString (nValue) + ")";
}

string GetGoodEvilText (int nValue)
{
    if (nValue < 31) return "Evil (" + IntToString (nValue) + ")";
    else if (nValue < 71) return "Neutral (" + IntToString (nValue) + ")";
    return "Good (" + IntToString (nValue) + ")";
}

string GetClassText (object oTarget, int nPosition)
{
    string sClass = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oTarget))));
    if (sClass == "Bad Strref") return sClass = "";
    return sClass + " (" + IntToString (GetLevelByPosition (nPosition, oTarget)) + ")";
}

json JArrayInsertClasses ()
{
    // Insert elements into the combo box array for classes.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Barbarian", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bard", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cleric", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Druid", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fighter", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Monk", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Paladin", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Ranger", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Rogue", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Sorcerer", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Wizard", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Swashbuckler", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("FavoredSoul", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Warmage", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Arcane Archer", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Artificer", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Assassin", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Blackgaurd", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Champion of Torm", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dragon Desciple", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dwarven Defender", 20));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Harper", 21));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Mystic Theurge", 22));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Orc Warlord", 23));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Master", 24));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Purple Dragon Knight", 25));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shadowdancer", 26));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shifter", 27));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Weapon Master", 28));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Aberration", 29));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Animal", 30));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Beast", 31));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Commoner", 32));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Construct", 33));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dragon", 34));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Elemental", 35));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fey", 36));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Giant", 37));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Humanoid", 38));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Magical Beast", 39));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Monstrous", 40));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Ooze", 41));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Outsider", 42));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shapechanger", 43));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Undead", 44));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Vermin", 45));
    return JsonArrayInsert (jCombo, NuiComboEntry ("None", 46));
}

int GetClassForCombo (int nPosition, object oCreature)
{
    int nClass = GetClassByPosition (nPosition, oCreature);
    switch (nClass)
    {
        case CLASS_TYPE_BARBARIAN: return 0;
        case CLASS_TYPE_BARD: return 1;
        case CLASS_TYPE_CLERIC: return 2;
        case CLASS_TYPE_DRUID: return 3;
        case CLASS_TYPE_FIGHTER: return 4;
        case CLASS_TYPE_MONK: return 5;
        case 45: return 6; // Paladin
        case 46: return 7; // Ranger
        case CLASS_TYPE_ROGUE: return 8;
        case CLASS_TYPE_SORCERER: return 9;
        case CLASS_TYPE_WIZARD: return 10;
        case 43: return 11; // Swashbuckler
        case 47: return 12; // Favored Soul
        case 48: return 13; // Warmage
        case CLASS_TYPE_ARCANE_ARCHER: return 14;
        case 42: return 15; // Artificer
        case CLASS_TYPE_ASSASSIN: return 16;
        case CLASS_TYPE_BLACKGUARD: return 17;
        case CLASS_TYPE_DIVINE_CHAMPION: return 18;
        case CLASS_TYPE_DRAGON_DISCIPLE: return 19;
        case CLASS_TYPE_DWARVEN_DEFENDER: return 20;
        case CLASS_TYPE_HARPER: return 21;
        case 49: return 22; // Mystic Theurge
        case 44: return 23; // Orc Warlord
        case CLASS_TYPE_PALE_MASTER: return 24;
        case CLASS_TYPE_PURPLE_DRAGON_KNIGHT: return 25;
        case CLASS_TYPE_SHADOWDANCER: return 26;
        case CLASS_TYPE_SHIFTER: return 27;
        case CLASS_TYPE_WEAPON_MASTER: return 28;
        case CLASS_TYPE_ABERRATION: return 29;
        case CLASS_TYPE_ANIMAL: return 30;
        case CLASS_TYPE_BEAST: return 31;
        case CLASS_TYPE_COMMONER: return 32;
        case CLASS_TYPE_CONSTRUCT: return 33;
        case CLASS_TYPE_DRAGON: return 34;
        case CLASS_TYPE_ELEMENTAL: return 35;
        case CLASS_TYPE_FEY: return 36;
        case CLASS_TYPE_GIANT: return 37;
        case CLASS_TYPE_HUMANOID: return 38;
        case CLASS_TYPE_MAGICAL_BEAST: return 39;
        case CLASS_TYPE_MONSTROUS: return 40;
        case CLASS_TYPE_OOZE: return 43;
        case CLASS_TYPE_OUTSIDER: return 42;
        case CLASS_TYPE_SHAPECHANGER: return 43;
        case CLASS_TYPE_UNDEAD: return 44;
        case CLASS_TYPE_VERMIN: return 45;
        default : return 46;
    }
    return 46;
}

int GetSelectedClassForCombo (int nSelected)
{
    switch (nSelected)
    {
        case 0: return CLASS_TYPE_BARBARIAN;
        case 1: return CLASS_TYPE_BARD;
        case 2: return CLASS_TYPE_CLERIC;
        case 3: return CLASS_TYPE_DRUID;
        case 4: return CLASS_TYPE_FIGHTER;
        case 5: return CLASS_TYPE_MONK;
        case 6: return 45; // Paladin
        case 7: return 46; // Ranger
        case 8: return CLASS_TYPE_ROGUE;
        case 9: return CLASS_TYPE_SORCERER;
        case 10: return CLASS_TYPE_WIZARD;
        case 11: return 43; // Swashbuckler
        case 12: return 47; // Favored Soul
        case 13: return 48; // Warmage
        case 14: return CLASS_TYPE_ARCANE_ARCHER;
        case 15: return 42; // Artificer
        case 16: return CLASS_TYPE_ASSASSIN;
        case 17: return CLASS_TYPE_BLACKGUARD;
        case 18: return CLASS_TYPE_DIVINE_CHAMPION;
        case 19: return CLASS_TYPE_DRAGON_DISCIPLE;
        case 20: return CLASS_TYPE_DWARVEN_DEFENDER;
        case 21: return CLASS_TYPE_HARPER;
        case 22: return 49; // Mystic Theurge
        case 23: return 44; // Orc Warlord
        case 24: return CLASS_TYPE_PALE_MASTER;
        case 25: return CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
        case 26: return CLASS_TYPE_SHADOWDANCER;
        case 27: return CLASS_TYPE_SHIFTER;
        case 28: return CLASS_TYPE_WEAPON_MASTER;
        case 29: return CLASS_TYPE_ABERRATION;
        case 30: return CLASS_TYPE_ANIMAL;
        case 31: return CLASS_TYPE_BEAST;
        case 32: return CLASS_TYPE_COMMONER;
        case 33: return CLASS_TYPE_CONSTRUCT;
        case 34: return CLASS_TYPE_DRAGON;
        case 35: return CLASS_TYPE_ELEMENTAL;
        case 36: return CLASS_TYPE_FEY;
        case 37: return CLASS_TYPE_GIANT;
        case 38: return CLASS_TYPE_HUMANOID;
        case 39: return CLASS_TYPE_MAGICAL_BEAST;
        case 40: return CLASS_TYPE_MONSTROUS;
        case 41: return CLASS_TYPE_OOZE;
        case 42: return CLASS_TYPE_OUTSIDER;
        case 43: return CLASS_TYPE_SHAPECHANGER;
        case 44: return CLASS_TYPE_UNDEAD;
        case 45: return CLASS_TYPE_VERMIN;
        default : return 256;
    }
    return 256;
}

void UpdateDMCreatureScreen (object oPC, object oTarget)
{
    int nToken = NuiFindWindow (oPC, "dmcreaturewin");
    if (nToken != 0)
    {
        // Set Class and levels.
        NuiSetBind (oPC, nToken, "class1_label", JsonString (GetClassText (oTarget, 1)));
        NuiSetBind (oPC, nToken, "class2_label", JsonString (GetClassText (oTarget, 2)));
        NuiSetBind (oPC, nToken, "class3_label", JsonString (GetClassText (oTarget, 3)));
        NuiSetBind (oPC, nToken, "class4_label", JsonString (GetClassText (oTarget, 4)));
        NuiSetBind (oPC, nToken, "class5_label", JsonString (GetClassText (oTarget, 5)));
        //NuiSetBind (oPC, nToken, "class6_label", JsonString (GetClassText (oTarget, 6)));
        // Update gold.
        string sValue = IntToString (GetGold (oTarget));
        NuiSetBind (oPC, nToken, "gold_value_label", JsonString (sValue));
        // Update hitpoints.
        sValue = IntToString (GetCurrentHitPoints (oTarget));
        sValue = sValue + "/" + IntToString (GetMaxHitPoints (oTarget));
        NuiSetBind (oPC, nToken, "hp_value_label", JsonString (sValue));
        if (GetIsCharacter (oTarget))
        {
            // Update racial experience.
            sValue = FloatToString (GetLocalFloat (oTarget, "0_RacialXP"), 0, 0);
            NuiSetBind (oPC, nToken, "racial_xp_value_label", JsonString (sValue));
            // Update experience.
            sValue = IntToString (GetXP (oTarget));
            NuiSetBind (oPC, nToken, "xp_value_label", JsonString (sValue));
            // Update fame/infamy
            int nRep = GetCharacterReputation (oTarget);
            NuiSetBind (oPC, nToken, "fame_value_label", JsonInt (nRep));
            nRep = GetCharacterReputation (oTarget, FALSE);
            NuiSetBind (oPC, nToken, "infamy_value_label", JsonInt (nRep));
        }
    }
}

int GetWealth (object oTarget)
{
    int nWealth;
    object oItem = GetFirstItemInInventory(oTarget);
    while(GetIsObjectValid(oItem))
    {
        nWealth = nWealth + GetGoldPieceValue (oItem);
        oItem = GetNextItemInInventory (oTarget);
    }
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_ARMS, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_ARROWS, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_BELT, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_BOLTS, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_BOOTS, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_BULLETS, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_CARMOUR, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_CHEST, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_CLOAK, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_CWEAPON_B, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_CWEAPON_L, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_CWEAPON_R, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_HEAD, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_LEFTRING, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_NECK, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oTarget));
    nWealth = nWealth + GetGoldPieceValue (GetItemInSlot (INVENTORY_SLOT_RIGHTRING, oTarget));
    return nWealth + GetGold (oTarget);
}

int GetWealthByLevel (int nWealth)
{
    int nCounter = 0, nTotalValue;
    while (nCounter < 41)
    {
        nTotalValue = StringToInt (Get2DAString ("itemvalue", "TOTALVALUEFILTER", nCounter));
        if (nWealth <= nTotalValue) return nCounter;
        nCounter ++;
    }
    return nCounter;
}

string GetWealthByLevelEvaluation (int nWealthLevel, object oTarget)
{
    int nLevel = GetCharacterLevels (oTarget);
    int nDifference = nLevel - nWealthLevel;
    if (nDifference < -8) return "Wealth: Monty Haul!";
    else if (nDifference < -6) return "Wealth: Excessive!";
    else if (nDifference < -4) return "Wealth: Extreme!";
    else if (nDifference < -2) return "Wealth: High!";
    else if (nDifference < 1) return "Wealth: Good";
    else if (nDifference < 3) return "Wealth: Low";
    else return "Wealth: Poor!";
}

struct stItemStats GetItemInformation (object oItem, struct stItemStats stItemStats, string sText)
{
    if (GetIsObjectValid (oItem))
    {
        string sStack = "", sBaseType, sState;
        sBaseType = Get2DAString ("baseitems", "label", GetBaseItemType (oItem));
        int nStack = GetItemStackSize (oItem);
        if (nStack > 1) sStack = IntToString (nStack) + " ";
        if (!GetIdentified (oItem)) sState = "*";
        if (GetStolenFlag (oItem)) sState += "!";
        if (GetPlotFlag (oItem)) sState += "#";
        if (GetItemCursedFlag (oItem)) sState += "@";
        if (sState != "") sState = "{" + sState + "}";
        int nGPValue = GetGoldPieceValue (oItem);
        stItemStats.sText += "\n" + sStack + StripColorCodes (GetName (oItem)) + " (" + sBaseType + ") [" + IntToString (nGPValue) + "] " + sState;
        stItemStats.nIGoldValue += nGPValue;
    }
    return stItemStats;
}

string GetInventoryGoldValues (object oTarget)
{
   string sBaseType;
   struct stItemStats stItemStats;
   stItemStats.sText = "***** EQUIPED *****";
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_ARMS, oTarget), stItemStats, "Armor: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_BELT, oTarget), stItemStats, "\nBelt: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_BOOTS, oTarget), stItemStats, "\nBoots: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_CHEST, oTarget), stItemStats, "\nChest: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_CLOAK, oTarget), stItemStats, "\nCloak: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_HEAD, oTarget), stItemStats, "\nHead: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_NECK, oTarget), stItemStats, "\nNeck: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oTarget), stItemStats, "\nLeft Hand: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_LEFTRING, oTarget), stItemStats, "\nLeft Ring: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oTarget), stItemStats, "\nRight Hand: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_RIGHTRING, oTarget), stItemStats, "\nRight Ring: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_ARROWS, oTarget), stItemStats, "\nArrows: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_BOLTS, oTarget), stItemStats, "\nBolts: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_BULLETS, oTarget), stItemStats, "\nBullets: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_CARMOUR, oTarget), stItemStats, "\nCreature Armor: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_CWEAPON_B, oTarget), stItemStats, "\nCreature Bite: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_CWEAPON_L, oTarget), stItemStats, "\nCreature Left Attack: ");
   stItemStats = GetItemInformation (GetItemInSlot (INVENTORY_SLOT_CWEAPON_R, oTarget), stItemStats, "\nCreature Right Attack: ");
   stItemStats.sText += "\nEquiped gold value: " + IntToString (stItemStats.nIGoldValue);
   stItemStats.nEGoldValue = stItemStats.nIGoldValue;
   stItemStats.nIGoldValue = 0;
   stItemStats.sText += "\n\n********** INVENTORY **********";
   object oItem = GetFirstItemInInventory (oTarget);
   while (oItem != OBJECT_INVALID)
   {
      stItemStats = GetItemInformation (oItem, stItemStats, "\n");
      oItem = GetNextItemInInventory  (oTarget);
   };
   stItemStats.sText += "\nUnequiped gold value: " + IntToString (stItemStats.nIGoldValue);
   int nGold = GetGold (oTarget);
   stItemStats.sText += "\nGold carried: " + IntToString (nGold);
   stItemStats.sText += "\n\n********** TOTALS **********";
   int nItemGold = stItemStats.nEGoldValue + stItemStats.nIGoldValue;
   stItemStats.sText += "\nTotal item gold value: " + IntToString (nItemGold);
   stItemStats.sText += "\nTotal gold value: " + IntToString (nItemGold + nGold);
   stItemStats.sText += "\n\n* Not identified\n! Stolen\n# Plot\n@ Cursed";
   return stItemStats.sText;
}

string GetVariableText (object oTarget)
{
    int nMaxVar = NWNX_Object_GetLocalVariableCount (oTarget), nIndex = 0;
    string sText;
    struct NWNX_Object_LocalVariable stVar = NWNX_Object_GetLocalVariable (oTarget, nIndex);
    while (nIndex <= nMaxVar)
    {
        sText = sText + stVar.key;
        if (stVar.type == 0) sText += " (Unknown)";
        else if (stVar.type == 1)
        {
            sText = sText + " (Int) = " + IntToString (GetLocalInt (oTarget, stVar.key)) + "\n";
        }
        else if (stVar.type == 2)
        {
            sText = sText + " (Float) = " + FloatToString (GetLocalFloat (oTarget, stVar.key), 0, 2) + "\n";
        }
        else if (stVar.type == 3)
        {
            sText = sText + " (String) = " + GetLocalString (oTarget, stVar.key) + "\n";
        }
        else if (stVar.type == 4)
        {
            sText = sText + " (Object) = " + GetName (GetLocalObject (oTarget, stVar.key)) + "\n";
        }
        else if (stVar.type == 5)
        {
            sText = sText + " (Location) = " + LocationToStringArray (GetLocalLocation (oTarget, stVar.key)) + "\n";
        }
        nIndex ++;
        stVar = NWNX_Object_GetLocalVariable (oTarget, nIndex);
    }
    return sText;
}

// Sets up a combo box for traps.
json JsonArrayInsertTraps ()
{
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("None", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Random", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bludgeoning", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Piercing", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Slashing", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Acid", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cold", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Electric", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fire", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Magical", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Negative", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Positive", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Sonic", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Disease", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Poison", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Confusion", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Sleep", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Slow", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Tangled", 18));
    return JsonArrayInsert (jCombo, NuiComboEntry ("Spell", 19));

}

// Sets up a combo box with a tiles main light colors.
json JsonArrayInsertTileLightMainColors ()
{
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Black", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dim White", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("White", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bright White", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Yellow", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Yellow", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Yellow", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Yellow", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Green", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Green", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Green", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Green", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Aqua", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Aqua", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Aqua", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Aqua", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Blue", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Blue", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Blue", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Blue", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Purple", 20));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Purple", 21));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Purple", 22));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Purple", 23));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Red", 24));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Red", 25));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Red", 26));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Red", 27));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Dark Orange", 28));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Orange", 29));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Orange", 30));
    return JsonArrayInsert (jCombo, NuiComboEntry ("Orange", 31));
}

// Sets up a combo box with a tiles source light colors.
json JsonArrayInsertTileLightSourceColors ()
{
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Black", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("White", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Yellow", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale yellow", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Green", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Green", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Aqua", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Aqua", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Blue", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Blue", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Purple", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Purple", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Red", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Red", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Orange", 14));
    return JsonArrayInsert (jCombo, NuiComboEntry ("Pale Orange", 15));
}

// Sets up a combo box with fog colors.
json JsonArrayInsertFogColors ()
{
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Black", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Grey", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("White", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Blue", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Blue", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cyan", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Green", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Green", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Red", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Red", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Brown", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Brown", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Orange", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Orange", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Magenta", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dark Yellow", 15));
    return JsonArrayInsert (jCombo, NuiComboEntry ("Yellow", 16));
}

// Sets an areas Light colors.
// oArea is the area to set.
// nColor is the color to use.
// nType is either 1 Main1, 2 Main2, 3 Source1, 4 Source2.
// Note: Source nColor will be limited for Main (0-31) or Source (0-15)
void SetAreaMainLightColor (object oArea, int nColor, int nType)
{
    int nColor2;
    float fX = 0.0f;
    float fY = 0.0f;
    float fXMaxSize = IntToFloat (GetAreaSize (AREA_WIDTH  , oArea));
    float fYMaxSize = IntToFloat (GetAreaSize (AREA_HEIGHT  , oArea));
    location lLocation = Location (oArea, Vector (fX, fY, 0.0f), 0.0f);
    while (fY <= fYMaxSize)
    {
        if (nType == 1) // Main 1
        {
            nColor2 = GetTileMainLight2Color (lLocation);
            SetTileMainLightColor (lLocation, nColor, nColor2);
        }
        else if (nType == 2) // Main 2
        {
            nColor2 = GetTileMainLight1Color (lLocation);
            SetTileMainLightColor (lLocation, nColor2, nColor);
        }
        else if (nType == 3) // Source 1
        {
            nColor2 = GetTileSourceLight2Color (lLocation);
            SetTileSourceLightColor (lLocation, nColor, nColor2);
        }
        else if (nType == 4) // Source 2
        {
            nColor2 = GetTileSourceLight1Color (lLocation);
            SetTileSourceLightColor (lLocation, nColor2, nColor);
        }
            fX += 1.0f;
        // Check to see if we need to go the next fY.
        if (fX > fXMaxSize) { fX = 0.0f; fY = fY + 1.0f; }
        lLocation = Location (oArea, Vector (fX, fY, 0.0f), 0.0f);
    }
    RecomputeStaticLighting (oArea);
}

// Changes Combo number to correct fog color.
// nNumber is the color to use.
int ComboNumberToFogColor (int nNumber)
{
    switch (nNumber)
    {
        case 0 : return FOG_COLOR_BLACK;
        case 1 : return FOG_COLOR_GREY;
        case 2 : return FOG_COLOR_WHITE;
        case 3 : return FOG_COLOR_BLUE_DARK;
        case 4 : return FOG_COLOR_BLUE;
        case 5 : return FOG_COLOR_CYAN;
        case 6 : return FOG_COLOR_GREEN_DARK;
        case 7 : return FOG_COLOR_GREEN;
        case 8 : return FOG_COLOR_RED_DARK;
        case 9 : return FOG_COLOR_RED;
        case 10 : return FOG_COLOR_BROWN_DARK;
        case 11 : return FOG_COLOR_BROWN;
        case 12 : return FOG_COLOR_ORANGE_DARK;
        case 13 : return FOG_COLOR_ORANGE;
        case 14 : return FOG_COLOR_MAGENTA;
        case 15 : return FOG_COLOR_YELLOW_DARK;
        case 16 : return FOG_COLOR_YELLOW;
    }
    return FOG_COLOR_BLACK;
}

// Changes fog color to correct combo number.
// nColor is the color to use.
int FogColorToComboNumber (int nColor)
{
    switch (nColor)
    {
        case FOG_COLOR_BLACK : return 0;
        case FOG_COLOR_GREY : return 1;
        case FOG_COLOR_WHITE : return 2;
        case FOG_COLOR_BLUE_DARK : return 3;
        case FOG_COLOR_BLUE : return 4;
        case FOG_COLOR_CYAN : return 5;
        case FOG_COLOR_GREEN_DARK : return 6;
        case FOG_COLOR_GREEN : return 7;
        case FOG_COLOR_RED_DARK : return 8;
        case FOG_COLOR_RED : return 9;
        case FOG_COLOR_BROWN_DARK : return 10;
        case FOG_COLOR_BROWN : return 11;
        case FOG_COLOR_ORANGE_DARK : return 12;
        case FOG_COLOR_ORANGE : return 13;
        case FOG_COLOR_MAGENTA : return 14;
        case FOG_COLOR_YELLOW_DARK : return 15;
        case FOG_COLOR_YELLOW : return 16;
    }
    return 0;
}

json JsonArrayInsertAmbientSounds ()
{
    string sText;
    json jCombo = JsonArray ();
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("None", 0));
    int nCount = 1;
    while (nCount < 114)
    {
        sText = GetStringByStrRef (StringToInt (Get2DAString ("ambientsound", "Description", nCount)));
        if (sText == "") sText = "None";
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    return jCombo;
}

json JArrayInsertNPCRaces ()
{
    // Insert elements into the combo box array for races.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Human", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Damaran", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Illuskan", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Rashemi", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Mulan", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Tethyrian", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Chondathan", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dwarf, Shield", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dwarf, Gold", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dwarf, Duergar", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Elf, Moon", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Elf, Sun", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Elf, Wood", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Elf, Drow", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Elf, Star", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Gnome, Rock", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Gnome, Forest", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Gnome, Svirfneblin", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Goblin", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Halfling, Lightfoot", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Halfling, Strongheart", 20));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Halfling, Ghostwise", 21));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Half-elf, Moon", 22));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Half-elf, Sun", 23));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Half-elf, Wood", 24));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Half-elf, Drow", 25));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Half-elf, Star", 26));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Half-orc", 27));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Kobold", 28));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Orc, Mountain", 29));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Orc, Gray", 30));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Aasimar", 31));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Tiefling", 32));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Air Genasi", 33));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Earth Genasi", 34));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fire Genasi", 35));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Water Genasi", 36));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Gloaming", 37));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Random", 38));
    return jCombo;
}

int GetNPCRaceForCombo (json jNPC)
{
    int nRace = JsonGetInt (JsonObjectGet (jNPC, "race"));
    switch (nRace)
    {
        case 6: return 0;
        case 30: return 1;
        case 31: return 2;
        case 32: return 3;
        case 33: return 4;
        case 34: return 5;
        case 35: return 6;
        case 36: return 7;
        case 37: return 8;
        case 38: return 9;
        case 39: return 10;
        case 40: return 11;
        case 41: return 12;
        case 42: return 13;
        case 43: return 14;
        case 44: return 15;
        case 45: return 16;
        case 46: return 17;
        case 47: return 18;
        case 48: return 19;
        case 49: return 20;
        case 50: return 21;
        case 51: return 22;
        case 52: return 23;
        case 53: return 24;
        case 54: return 25;
        case 55: return 26;
        case 56: return 27;
        case 57: return 28;
        case 58: return 29;
        case 59: return 30;
        case 60: return 31;
        case 61: return 32;
        case 62: return 33;
        case 63: return 34;
        case 64: return 35;
        case 65: return 36;
        case 66: return 37;
        default : return 38;
    }
    return 38;
}

int GetSelectedNPCRaceForCombo (int nSelected)
{
    switch (nSelected)
    {
        case 0: return 6;
        case 1: return 30;
        case 2: return 31;
        case 3: return 32;
        case 4: return 33;
        case 5: return 34;
        case 6: return 35;
        case 7: return 36;
        case 8: return 37;
        case 9: return 38;
        case 10: return 39;
        case 11: return 40;
        case 12: return 41;
        case 13: return 42;
        case 14: return 43;
        case 15: return 44;
        case 16: return 45;
        case 17: return 46;
        case 18: return 47;
        case 19: return 48;
        case 20: return 49;
        case 21: return 50;
        case 22: return 51;
        case 23: return 52;
        case 24: return 53;
        case 25: return 54;
        case 26: return 55;
        case 27: return 56;
        case 28: return 57;
        case 29: return 58;
        case 30: return 59;
        case 31: return 60;
        case 32: return 61;
        case 33: return 62;
        case 34: return 63;
        case 35: return 64;
        case 36: return 65;
        case 37: return 66;
        default : return -1;
    }
    return -1;
}

json JArrayInsertNPCBaseClasses ()
{
    // Insert elements into the combo box array for classes.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Barbarian", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bard", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cleric", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Druid", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fighter", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Monk", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Paladin", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Ranger", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Rogue", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Sorcerer", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Wizard", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Swashbuckler", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("FavoredSoul", 12));
    return JsonArrayInsert (jCombo, NuiComboEntry ("Random", 13));
}

int GetNPCBaseClassForCombo (int nClass)
{
    switch (nClass)
    {
        case CLASS_TYPE_BARBARIAN: return 0;
        case CLASS_TYPE_BARD: return 1;
        case CLASS_TYPE_CLERIC: return 2;
        case CLASS_TYPE_DRUID: return 3;
        case CLASS_TYPE_FIGHTER: return 4;
        case CLASS_TYPE_MONK: return 5;
        case 45: return 6; // Paladin
        case 46: return 7; // Ranger
        case CLASS_TYPE_ROGUE: return 8;
        case CLASS_TYPE_SORCERER: return 9;
        case CLASS_TYPE_WIZARD: return 10;
        case 43: return 11; // Swashbuckler
        case 47: return 12; // Favored Soul
        case 255: return 14;
        default : return 13;
    }
    return 13;
}

json JArrayInsertNPCClasses ()
{
    // Insert elements into the combo box array for classes.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Barbarian", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bard", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cleric", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Druid", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fighter", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Monk", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Paladin", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Ranger", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Rogue", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Sorcerer", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Wizard", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Swashbuckler", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("FavoredSoul", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Warmage", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Arcane Archer", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Artificer", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Assassin", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Blackgaurd", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Champion of Torm", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dragon Desciple", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dwarven Defender", 20));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Harper", 21));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Mystic Theurge", 22));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Orc Warlord", 23));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pale Master", 24));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Purple Dragon Knight", 25));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shadowdancer", 26));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shifter", 27));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Weapon Master", 28));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("None", 29));
    return JsonArrayInsert (jCombo, NuiComboEntry ("Random", 30));
}

int GetNPCClassForCombo (int nClass)
{
    switch (nClass)
    {
        case CLASS_TYPE_BARBARIAN: return 0;
        case CLASS_TYPE_BARD: return 1;
        case CLASS_TYPE_CLERIC: return 2;
        case CLASS_TYPE_DRUID: return 3;
        case CLASS_TYPE_FIGHTER: return 4;
        case CLASS_TYPE_MONK: return 5;
        case 45: return 6; // Paladin
        case 46: return 7; // Ranger
        case CLASS_TYPE_ROGUE: return 8;
        case CLASS_TYPE_SORCERER: return 9;
        case CLASS_TYPE_WIZARD: return 10;
        case 43: return 11; // Swashbuckler
        case 47: return 12; // Favored Soul
        case 48: return 13; // Warmage
        case CLASS_TYPE_ARCANE_ARCHER: return 14;
        case 42: return 15; // Artificer
        case CLASS_TYPE_ASSASSIN: return 16;
        case CLASS_TYPE_BLACKGUARD: return 17;
        case CLASS_TYPE_DIVINE_CHAMPION: return 18;
        case CLASS_TYPE_DRAGON_DISCIPLE: return 19;
        case CLASS_TYPE_DWARVEN_DEFENDER: return 20;
        case CLASS_TYPE_HARPER: return 21;
        case 49: return 22; // Mystic Theurge
        case 44: return 23; // Orc Warlord
        case CLASS_TYPE_PALE_MASTER: return 24;
        case CLASS_TYPE_PURPLE_DRAGON_KNIGHT: return 25;
        case CLASS_TYPE_SHADOWDANCER: return 26;
        case CLASS_TYPE_SHIFTER: return 27;
        case CLASS_TYPE_WEAPON_MASTER: return 28;
        case 255: return 29;
        default : return 30;
    }
    return 30;
}

int GetSelectedNPCClassForCombo (int nSelected)
{
    switch (nSelected)
    {
        case 0: return CLASS_TYPE_BARBARIAN;
        case 1: return CLASS_TYPE_BARD;
        case 2: return CLASS_TYPE_CLERIC;
        case 3: return CLASS_TYPE_DRUID;
        case 4: return CLASS_TYPE_FIGHTER;
        case 5: return CLASS_TYPE_MONK;
        case 6: return 45; // Paladin
        case 7: return 46; // Ranger
        case 8: return CLASS_TYPE_ROGUE;
        case 9: return CLASS_TYPE_SORCERER;
        case 10: return CLASS_TYPE_WIZARD;
        case 11: return 43; // Swashbuckler
        case 12: return 47; // Favored Soul
        case 13: return 48; // Warmage
        case 14: return CLASS_TYPE_ARCANE_ARCHER;
        case 15: return 42; // Artificer
        case 16: return CLASS_TYPE_ASSASSIN;
        case 17: return CLASS_TYPE_BLACKGUARD;
        case 18: return CLASS_TYPE_DIVINE_CHAMPION;
        case 19: return CLASS_TYPE_DRAGON_DISCIPLE;
        case 20: return CLASS_TYPE_DWARVEN_DEFENDER;
        case 21: return CLASS_TYPE_HARPER;
        case 22: return 49; // Mystic Theurge
        case 23: return 44; // Orc Warlord
        case 24: return CLASS_TYPE_PALE_MASTER;
        case 25: return CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
        case 26: return CLASS_TYPE_SHADOWDANCER;
        case 27: return CLASS_TYPE_SHIFTER;
        case 28: return CLASS_TYPE_WEAPON_MASTER;
        case 29: return 255;
        default : return -1;
    }
    return -1;
}

json JArrayInsertNPCLevels ()
{
    int nCount = 0;
    string sText;
    json jCombo = JsonArray ();
    // Insert elements into the combo box array for Levels.
    while (nCount < 21)
    {
        sText = IntToString (nCount);
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    return jCombo;
}

json JArrayInsertNPCAlign1 ()
{
    // Insert elements into the combo box array for alignment.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Random", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Lawful", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Neutral", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Chaotic", 3));
    return jCombo;
}

json JArrayInsertNPCAlign2 ()
{
    // Insert elements into the combo box array for alignment.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Random", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Good", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Neutral", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Evil", 3));
    return jCombo;
}

json JArrayInsertNPCFactions ()
{
    // Insert elements into the combo box array for factions.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Hostile", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Commoner", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Merchant", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Defender", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Neutral", 4));
    return jCombo;
}
void UpdateNPCWindow (object oPC, int nToken)
{
    string sValue, sID;
    SetLocalInt (oPC, "0_No_NPCWin_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_NPCWin_Save"));
    json jNPC = GetLocalJson (oPC, "0_JNPC");
    NuiSetBind (oPC, nToken, "npc_name", JsonString (JsonGetString (JsonObjectGet (jNPC, "name"))));
    NuiSetBind (oPC, nToken, "npc_deity", JsonString (JsonGetString (JsonObjectGet (jNPC, "deity"))));
    int nValue = JsonGetInt (JsonObjectGet (jNPC, "gender"));
    NuiSetBind (oPC, nToken, "npc_gender_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "npc_race_selected", JsonInt (GetNPCRaceForCombo (jNPC)));
    int nClass1 = JsonGetInt (JsonObjectGet (jNPC, "class1"));
    nClass1 = GetNPCBaseClassForCombo (nClass1);
    NuiSetBind (oPC, nToken, "npc_class1_selected", JsonInt (nClass1));
    nValue = JsonGetInt (JsonObjectGet (jNPC, "level1"));
    NuiSetBind (oPC, nToken, "npc_level1_selected", JsonInt (nValue));
    int nClass2 = JsonGetInt (JsonObjectGet (jNPC, "class2"));
    nClass2 = GetNPCClassForCombo (nClass2);
    NuiSetBind (oPC, nToken, "npc_class2_selected", JsonInt (nClass2));
    nValue = JsonGetInt (JsonObjectGet (jNPC, "level2"));
    NuiSetBind (oPC, nToken, "npc_level2_selected", JsonInt (nValue));
    if (nClass1 != 13)
    {
        NuiSetBind (oPC, nToken, "npc_class2_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "npc_level2_event", JsonBool (TRUE));
    }
    else
    {
        NuiSetBind (oPC, nToken, "npc_class2_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "npc_level2_event", JsonBool (FALSE));
    }
    int nClass3 = JsonGetInt (JsonObjectGet (jNPC, "class3"));
    nClass3 = GetNPCClassForCombo (nClass3);
    NuiSetBind (oPC, nToken, "npc_class3_selected", JsonInt (nClass3));
    NuiSetBindWatch (oPC, nToken, "npc_class3_selected", TRUE);
    nValue = JsonGetInt (JsonObjectGet (jNPC, "level3"));
    NuiSetBind (oPC, nToken, "npc_level3_selected", JsonInt (nValue));
    NuiSetBindWatch (oPC, nToken, "npc_level3_selected", TRUE);
    if (nClass2 < 29)
    {
        NuiSetBind (oPC, nToken, "npc_class3_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "npc_level3_event", JsonBool (TRUE));
    }
    else
    {
        NuiSetBind (oPC, nToken, "npc_class3_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "npc_level3_event", JsonBool (FALSE));
    }
    // Strength
    nValue = JsonGetInt (JsonObjectGet (jNPC, "str"));
    if (nValue < 3)
    {
        NuiSetBind (oPC, nToken, "str_value_label", JsonString ("-"));
        NuiSetBind (oPC, nToken, "str_mod_label", JsonString ("-"));
    }
    else
    {
        NuiSetBind (oPC, nToken, "str_value_label", JsonString (IntToString (nValue)));
        if (nValue > 9) sValue = IntToString ((nValue - 10) / 2);
        else sValue = IntToString ((nValue - 10) / 2);
        NuiSetBind (oPC, nToken, "str_mod_label", JsonString (sValue));
    }
    // Dexterity
    nValue = JsonGetInt (JsonObjectGet (jNPC, "dex"));
    if (nValue < 3)
    {
        NuiSetBind (oPC, nToken, "dex_value_label", JsonString ("-"));
        NuiSetBind (oPC, nToken, "dex_mod_label", JsonString ("-"));
    }
    else
    {
        NuiSetBind (oPC, nToken, "dex_value_label", JsonString (IntToString (nValue)));
        if (nValue > 9) sValue = IntToString ((nValue - 10) / 2);
        else sValue = IntToString ((nValue - 10) / 2);
        NuiSetBind (oPC, nToken, "dex_mod_label", JsonString (sValue));
    }
    // Constitution
    nValue = JsonGetInt (JsonObjectGet (jNPC, "con"));
    if (nValue < 3)
    {
        NuiSetBind (oPC, nToken, "con_value_label", JsonString ("-"));
        NuiSetBind (oPC, nToken, "con_mod_label", JsonString ("-"));
    }
    else
    {
        NuiSetBind (oPC, nToken, "con_value_label", JsonString (IntToString (nValue)));
        if (nValue > 9) sValue = IntToString ((nValue - 10) / 2);
        else sValue = IntToString ((nValue - 10) / 2);
        NuiSetBind (oPC, nToken, "con_mod_label", JsonString (sValue));
    }
    // Intelligence
    nValue = JsonGetInt (JsonObjectGet (jNPC, "int"));
    if (nValue < 3)
    {
        NuiSetBind (oPC, nToken, "int_value_label", JsonString ("-"));
        NuiSetBind (oPC, nToken, "int_mod_label", JsonString ("-"));
    }
    else
    {
        NuiSetBind (oPC, nToken, "int_value_label", JsonString (IntToString (nValue)));
        if (nValue > 9) sValue = IntToString ((nValue - 10) / 2);
        else sValue = IntToString ((nValue - 10) / 2);
        NuiSetBind (oPC, nToken, "int_mod_label", JsonString (sValue));
    }
    // Wisdom
    nValue = JsonGetInt (JsonObjectGet (jNPC, "wis"));
    if (nValue < 3)
    {
        NuiSetBind (oPC, nToken, "wis_value_label", JsonString ("-"));
        NuiSetBind (oPC, nToken, "wis_mod_label", JsonString ("-"));
    }
    else
    {
        NuiSetBind (oPC, nToken, "wis_value_label", JsonString (IntToString (nValue)));
        if (nValue > 9) sValue = IntToString ((nValue - 10) / 2);
        else sValue = IntToString ((nValue - 10) / 2);
        NuiSetBind (oPC, nToken, "wis_mod_label", JsonString (sValue));
    }
    // Charisma
    nValue = JsonGetInt (JsonObjectGet (jNPC, "cha"));
    if (nValue < 3)
    {
        NuiSetBind (oPC, nToken, "cha_value_label", JsonString ("-"));
        NuiSetBind (oPC, nToken, "cha_mod_label", JsonString ("-"));
    }
    else
    {
        NuiSetBind (oPC, nToken, "cha_value_label", JsonString (IntToString (nValue)));
        if (nValue > 9) sValue = IntToString ((nValue - 10) / 2);
        else sValue = IntToString ((nValue - 10) / 2);
        NuiSetBind (oPC, nToken, "cha_mod_label", JsonString (sValue));
    }
    // Portrait
    int nID = JsonGetInt (JsonObjectGet (jNPC, "portrait_id"));
    if (nID == 65535)
    {
        sID = "Custom Portrait";
        sValue = JsonGetString (JsonObjectGet (jNPC, "portrait_resref"));
    }
    else
    {
        sID = IntToString (nID);
        sValue = "po_" + Get2DAString ("portraits", "BaseResRef", nID);
    }
    NuiSetBindWatch (oPC, nToken, "npc_port_resref", TRUE);
    NuiSetBind (oPC, nToken, "npc_port_resref", JsonString (sValue));
    NuiSetBind (oPC, nToken, "npc_port_id_label", JsonString (sID));
    NuiSetBind (oPC, nToken, "npc_port_resref_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "npc_port_image", JsonString (sValue + "l"));
    NuiSetBind (oPC, nToken, "npc_port_tooltip", JsonString ("You may also type the portrait file name."));
    NuiSetBind (oPC, nToken, "btn_portrait_prev_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_portrait_next_event", JsonBool (TRUE));
    // Alignment
    nValue = JsonGetInt (JsonObjectGet (jNPC, "alignlc"));
    NuiSetBind (oPC, nToken, "npc_align1_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "npc_align1_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_align1_selected", TRUE);
    nValue = JsonGetInt (JsonObjectGet (jNPC, "alignge"));
    NuiSetBind (oPC, nToken, "npc_align2_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "npc_align2_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_align2_selected", TRUE);
    // Factions
    nValue = JsonGetInt (JsonObjectGet (jNPC, "faction"));
    NuiSetBind (oPC, nToken, "npc_faction_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "npc_faction_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_faction_selected", TRUE);
    // Description
    NuiSetBind (oPC, nToken, "desc_tooltip", JsonString ("Color codes can be used!"));
    sValue = JsonGetString (JsonObjectGet (jNPC, "description"));
    NuiSetBind (oPC, nToken, "desc_value", JsonString (sValue));
    // Buttons
    NuiSetBind (oPC, nToken, "btn_clear", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_random", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_random_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_create", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_create_event", JsonBool (TRUE));
}

void ServerShutDown (object oPlayer)
{
    object oModule = GetModule ();
    int nShutDownTimer = GetLocalInt (oModule, "0_SHUT_DOWN_TIMER");
    if (nShutDownTimer == 0)
    {
        SendServerMessageToDiscord ("", "The server is off-line! We are doing maintenance and will be back up soon.",
                                    SERVER_NAME, SERVER_COLOR, "https://nwn.wiki/download/thumbnails/3473429/logo-small.png");
        NWNX_Administration_ShutdownServer ();
    }
    else if (nShutDownTimer > 0)
    {
        int nSeconds = nShutDownTimer * 5;
        SpeakString ("NOTICE: Server shut down in " + IntToString (nSeconds) + " seconds! Please log off now!", TALKVOLUME_SHOUT);
        nShutDownTimer --;
        SetLocalInt (oModule, "0_SHUT_DOWN_TIMER", nShutDownTimer);
        DelayCommand (5.0f, ServerShutDown (oPlayer));
    }
}

// Update Dm's targets in all windows.
void SetPlayerWinTarget (object oPC, string sTarget)
{
    int nDMToken = NuiFindWindow (oPC, "plplayerwin");
    if (nDMToken != 0) NuiSetBind (oPC, nDMToken, "dm_target_value_label", JsonString (sTarget));
    nDMToken = NuiFindWindow (oPC, "ploptionwin");
    if (nDMToken != 0) NuiSetBind (oPC, nDMToken, "dm_target_value_label", JsonString (sTarget));
    nDMToken = NuiFindWindow (oPC, "pclangwin");
    if (nDMToken != 0) NuiSetBind (oPC, nDMToken, "pc_target_value_label", JsonString (sTarget));
}

void RemoveAllExamineWindows (object oPC)
{
    // Remove all examin windows.
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmcreaturewin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmmainquestwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmxpwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmhpwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmclasswin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmreputationwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmgoldwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmalignwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmplayerwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmobjectwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dminventorywin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmitemwin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmvariableswin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmareawin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmcolorswin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmsoundswin"));
    NuiDestroy (oPC, NuiFindWindow (oPC, "dmfactionswin"));
}

// Clears any databases for a character that is deleted.
void DeleteCharacterFromDatabase (object oPC)
{
    int nSpell, nCntr = 1;
    string sCntr;
    // Delete any objects the player may have, Chests and NPC's.
    while(nCntr < 11)
    {
        sCntr = IntToString(nCntr);
        DeleteServerDatabaseObject(oPC, OBJECT_TABLE, "chest" + sCntr);
        DeleteServerDatabaseObject(oPC, OBJECT_TABLE, "henchmen" + sCntr);
        DeleteServerDatabaseObject(oPC, OBJECT_TABLE, "npc" + sCntr);
        nCntr ++;
    }
    // Delete any quest data.
    int bDelete;
    string sQuery = "DELETE FROM QuestTable WHERE name = @name AND playername = @playername;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", GetName(oPC, TRUE));
    SqlBindString (sql, "@playername", GetPCPlayerName(oPC));
    if(SqlStep(sql)) bDelete = TRUE;
    while(bDelete)
    {
        if(SqlStep (sql)) bDelete = TRUE;
        else bDelete = FALSE;
    }
    // Delete any adventures a DM/Player may have.
    // Delete any areas that a DM/Player may have in an adventure.
    // Delete any objects that a DM/Player may have in an area.
    DeleteServerDatabase(oPC, DM_TABLE);
    // Delete any Fast Buff spell lists.
    nCntr = 1;
    while (nCntr <= 4)
    {
        DeleteServerDatabaseObject (oPC, BUFF_TABLE, "list" + IntToString (nCntr));
        nCntr ++;
    }
    // Don't forget to remove the list entry as well!
    DeleteServerDatabaseObject(oPC, BUFF_TABLE, "list");
    DecreaseServerDatabaseCounter(oPC, PLAYER_TABLE, "characters");
    SendMessages(GetPCPlayerName(oPC) + " has deleted the " +
                  "character named " + GetName (oPC) + ".", COLOR_RED, OBJECT_INVALID, TRUE, TRUE);
    SendPlayerLogToDiscord(oPC, TEXT_CHAR_DELETE);
    NWNX_Administration_DeletePlayerCharacter(oPC, FALSE, "Your character has been deleted!");
}
