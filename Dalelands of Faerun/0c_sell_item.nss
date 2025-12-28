/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_sell_item
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that will sell one item to the PCSpeaker.
 The price will be the gold value of the item and will be removed from the PC.
 Param:
 sItemToSellResRef - resref of the item to purchase
*///////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"

void main()
{
    object oPC = GetPCSpeaker ();
    // Get the Item they have purchased.
    string sItem = GetScriptParam ("sItemToSellResRef");
    // Create on NPC.
    object oItem = CreateItemOnObject (sItem, OBJECT_SELF);
    // Get the cost and take the money.
    int nCost = GetGoldPieceValue (oItem);
    if (GetGold (oPC) >= nCost)
    {
        TakeGoldFromCreature (nCost, oPC, TRUE);
        ActionGiveItem (oItem, oPC);
    }
    else SendMessages ("I'm sorry you don't have enough gold!", COLOR_RED, oPC);
}
