/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ac_enchant_box
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Activate item script for enchanting box.
 Used to change the name of the item enchanted.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_items"
void main()
{
    object oPC = OBJECT_SELF;
    object oItem = GetSpellTargetObject ();
    string sEnchantName = GetLocalString (oItem, "0_EnchantedBy");
    string sPCName = GetName (oPC, TRUE);
    if (sPCName == sEnchantName)
    {
        SetLocalString (oPC, "0_Input", "ChangeEnchantedName");
        SetLocalObject (oPC, "0_Enchanted_Item", oItem);
        SendMessages ("Now Type the new name of the Item in the chat box.", COLOR_GREEN, oPC);
    }
    else SendMessages ("You can only change the names of Items you have enchanted!", COLOR_RED, oPC);
}
