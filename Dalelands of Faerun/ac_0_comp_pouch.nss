/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ac_0_comp_pouch
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Activate item script for component pouch.
 Used to check to turn off and on enhancing components for spells.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_items"
void main()
{
    object oPC = GetPCSpeaker ();
    if (oPC == OBJECT_INVALID) oPC = OBJECT_SELF;
    object oItem = GetCreatureHasItem (oPC, COMPONENT_POUCH);
    int iSwitch;
    iSwitch = GetLocalInt (oPC, "0_Use_Enhancing_Component");
    if (iSwitch)
    {
        SetLocalInt (oPC, "0_Use_Enhancing_Component", FALSE);
        SetLocalInt (oItem, "0_Use_Enhancing_Component", FALSE);
        SendMessages ("Enhancing Components have been turned off for your spells.", COLOR_RED, oPC);
    }
    else
    {
        SetLocalInt (oPC, "0_Use_Enhancing_Component", TRUE);
        SetLocalInt (oItem, "0_Use_Enhancing_Component", TRUE);
        SendMessages ("Enhancing Components have been turned on for your spells.", COLOR_GREEN, oPC);
    }
}
