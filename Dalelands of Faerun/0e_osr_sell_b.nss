/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_osr_sell_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when an object is sold to a store.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"
#include "nwnx_events"
void main()
{
    int i;
    object oItem = StringToObject (NWNX_Events_GetEventData ("ITEM"));
    object oEquipedItem, oPC = OBJECT_SELF;
    // Check for Bartering. Don't sell items while in barter mode.
    //if (GetLocalInt (oPC, "0_BARTERING"))
    //{
    //    SendMessages ("Cannot sell items while bartering!", COLOR_RED, oPC);
    //    NWNX_Events_SkipEvent ();
    //    return;
    //}
    if (CheckForTemporaryItemProperty (oItem))
    {
        SendMessages ("Cannot sell temporary enchanted items!", COLOR_RED, oPC);
        NWNX_Events_SkipEvent ();
        return;
    }
    // Check to see if the items is equiped.
    for (i = 0; i < 14; i++)
    {
        oEquipedItem = GetItemInSlot (i, oPC);
        if (oItem == oEquipedItem)
        {
            SendMessages ("Cannot sell equiped items! Unequip before selling.", COLOR_RED, oPC);
            NWNX_Events_SkipEvent ();
            return;
        }
    }
}

