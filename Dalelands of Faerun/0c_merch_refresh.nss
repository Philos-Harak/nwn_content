/*/////////////////////////////////////////////////////////////////////////////////////////////////////
Script Name: 0c_StoreRefresh
Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs a script that removes older items from a NPC's store.
 Param:
 sTag - the tag of the store we are refreshing.
 sTag1 - we can clear items on more stores as well (use 1 - x for each store).
 bClearAll - will remove all items instead of just older items.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"
#include "0i_merchant"
void main()
{
    object oPC = GetPCSpeaker();
    string sTag = GetScriptParam("sTag");
    int bClearAll = StringToInt(GetScriptParam("bClearAll"));
    if(sTag != "") ClearMerchantItems(oPC, OBJECT_SELF, sTag, bClearAll);
    int i = 1;
    sTag = GetScriptParam("sTag" + IntToString (i));
    while(sTag != "")
    {
        ClearMerchantItems(oPC, OBJECT_SELF, sTag, bClearAll);
        i ++;
        sTag = GetScriptParam("sTag" + IntToString (i));
    }
}
