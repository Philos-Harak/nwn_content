/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_pick_henchmen
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action taken script to select henchman for higher.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
#include "0i_items"
#include "0i_henchmen"
#include "nwnx_object"
void main ()
{
    int nClass, nRoll, nRace;
    string sSummonsArray, sArray, sText, sName, sGender, sClass, sRace, sLevel;
    string sHenchman = GetScriptParam ("iHenchman");
    object oPC = GetPCSpeaker ();
    // Do we need to remove/clear the henchman.
    if (sHenchman == "-1")
    {
        int i = 1;
        object oHenchman = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oPC, i);
        while(oHenchman != OBJECT_INVALID)
        {
            if(GetLocalInt(oHenchman, "0_PCAssociate") == ASSOCIATE_TYPE_HENCHMAN) FireHenchman (oPC, oHenchman);
            oHenchman = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oPC, ++i);
        }
        return;
    }
    string sPCName = RemoveIllegalCharacters (GetName (oPC));
    // Get the type of henchman so we can get the saved arrays.
    string sType = GetLocalString (oPC, "0_Henchman_Type");
    string sIndex = "0_H_" + sType + sPCName + "_" + sHenchman;
    int nLevel = GetCharacterLevels (oPC);
    // Create henchman cost: 50 * PC's Level ^2 in gold.
    int nCost = 50 * (nLevel * nLevel);
    if(HasMaxNumberOfHenchman(oPC))
    {
        SendMessages ("You do not have room in your party for this henchman!", COLOR_RED, oPC);
        return;
    }
    if (GetGold (oPC) < nCost)
    {
        SendMessages ("You do not have enough gold to purchase this henchman!", COLOR_RED, oPC);
        return;
    }
    //TakeGoldFromCreature (nCost, oPC, TRUE);
    sArray = GetLocalString (OBJECT_SELF, sIndex);
    // Erase them from the list.
    SetLocalString (OBJECT_SELF, sIndex, "");
    // Get location to safely create creatures and objects.
    location lLocation = GetLocation (GetWaypointByTag (WP_CREATURE_SPAWN));
    object oHenchmen = CreateNPC(lLocation, sArray);
    // Check for Favored souls.
    if(GetClassByPosition(1, oHenchmen) == CLASS_TYPE_FAVORED_SOUL)
    {
        SelectDeityForFavoredSoul(oHenchmen);
    }
    // Give equipment to the Henchmen.
    int iPackage = StringToInt(GetStringArray (sArray, 6, "-"));
    DelayCommand(0.5f, GiveCreatureEquipment (oHenchmen, 2, TRUE, iPackage));
    // Equip Items.
    DelayCommand(1.0f, EquipItems  (oHenchmen, TRUE, TRUE));
    SetUpHenchman(oPC, oHenchmen);
    AddHenchman(oPC, oHenchmen);
    DelayCommand(2.0f, AssignCommand (oHenchmen, ActionJumpToObject (oPC)));
    //DelayCommand(3.0f, LevelUpCurrentHenchman(oPC));
}
