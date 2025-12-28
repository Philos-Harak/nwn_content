/*//////////////////////////////////////////////////////////////////////////////
 Sprict Name: 0i_merchant
////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with merchants (stores).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_datetime"
int GetMinimumNumberOfItemsForMerchant (object oMerchant);
int GetNumberOfUniqueItemsOnMerchant (object oMerchant);
int GetLevelForMerchant (object oMerchant);
int GetTypeOfItemsToRoll (object oStore);
// Clears a merchants shop items - Used in the conversation.
void ClearMerchantItems(object oPC, object oNPC, string sTag, int bClearAll);
// Clears a shop of items - Used in OnExit of a shop.
void ClearStoreItems(object oStore, int nItems, int nMaxItems, int bClearAll);

int GetMinimumNumberOfItemsForMerchant (object oMerchant)
{
   int nMinItems = GetLocalInt (oMerchant, "0_MinItems");
   if (nMinItems == 0) return MIN_MERCHANT_ITEMS;
   return nMinItems;
}

int GetNumberOfUniqueItemsOnMerchant (object oMerchant)
{
    int i = 0;
    object oItem = GetFirstItemInInventory (oMerchant);
    while (oItem != OBJECT_INVALID)
    {
       if (!GetInfiniteFlag (oItem)) i ++;
       oItem = GetNextItemInInventory (oMerchant);
    }
    return i;
}

int GetLevelForMerchant(object oStore)
{
    int nLevel = GetLocalInt (oStore, "0_Level");
    if(nLevel == 0) nLevel = GetLocalInt(GetArea (oStore), "0_Area_Level");
    if(nLevel < 3) return 3;
    else if(nLevel > 20) return 20;
    return nLevel;
}

int GetTypeOfItemsToRoll (object oStore)
{
    int iItemType = GetLocalInt (OBJECT_SELF, "0_ItemType");
    if (iItemType == 0) return 150;
    return iItemType;
}

// Use formula to get % chance to keep. Value used = GPV / ((Lvl * Lvl)*3)
// Example: lvl 3 (1350/27) = 50%       (2,700/27) = 100%
// Example: lvl 5 (3750/75) = 50%     (7,500/75) = 100%
// Example: lvl 10 (15,000/300) = 50%  (30,000/300) = 100%
// Example: lvl 15 (33,750/675) = 50%  (67,500/675) = 100%
// Example: lvl 20 (60,000/1200) = 50%  (120,000/1200) = 100%
int ConvertItemToChanceToKeep(object oItem, int nLevel)
{
    int nGoldValue = GetGoldPieceValue(oItem);
    nGoldValue = (nGoldValue / (nLevel * nLevel * 3));
    return nGoldValue;
}

void ClearMerchantItems(object oPC, object oNPC, string sTag, int bClearAll)
{
    object oStore = GetNearestObjectByTag(sTag);
    // Check to see if they have a patron!
    if(GetLocalInt(oStore, "0_Patron") > 0)
    {
        SendMessages("I'm sorry but I'm busy with someone at the moment! Check back later.", COLOR_RED, oPC);
        return;
    }
    int nChanceToKeepItem, nNumOfItems;
    float fDelay = 0.1f;
    int nLevel = GetLevelForMerchant(oStore);
    int nMinItems = GetMinimumNumberOfItemsForMerchant(oStore);
    object oItem = GetFirstItemInInventory(oStore);
    while(oItem != OBJECT_INVALID)
    {
        if(!GetInfiniteFlag(oItem))
        {
            if(bClearAll) nChanceToKeepItem = 0;
            else nChanceToKeepItem = ConvertItemToChanceToKeep(oItem, nLevel);
            if (d100() > nChanceToKeepItem)
            {
                DestroyObject (oItem, fDelay);
                fDelay = fDelay + 0.1f;
            }
            else nNumOfItems++;
        }
        oItem = GetNextItemInInventory (oStore);
    }
    // Now check if we are not down to the minimum number of shop items, then
    // we need to remove older items until we are.
    if(nNumOfItems > nMinItems)
    {
        nNumOfItems = nNumOfItems - nMinItems;
        fDelay = 0.0;
        oItem = GetFirstItemInInventory(oStore);
        while(oItem != OBJECT_INVALID && nNumOfItems > 0)
        {
            if (!GetInfiniteFlag (oItem))
            {
                // This assumes that the first items in the list will be the oldest
                // Usually destroying older items first.
                DestroyObject(oItem, fDelay);
                fDelay = fDelay + 0.05f;
                nNumOfItems --;
            }
            oItem = GetNextItemInInventory(oStore);
        }
    }
    SetLocalInt(oNPC, "0_BUSY", TRUE);
    DelayCommand(fDelay, DeleteLocalInt (oNPC, "0_BUSY"));
}
void ClearStoreItems(object oStore, int nNumOfItems, int nMaxItems, int bClearAll)
{
    // Check to see if they have a patron!
    if(GetLocalInt(oStore, "0_Patron") > 0) return;
    int nRoll, nChanceToKeepItem;
    float fDelay = 0.1f;
    int nLevel = GetLevelForMerchant(oStore);
    object oItem = GetFirstItemInInventory(oStore);
    while(oItem != OBJECT_INVALID && nNumOfItems > nMaxItems)
    {
        if(!GetInfiniteFlag(oItem))
        {
            if(bClearAll) nChanceToKeepItem = 0;
            else nChanceToKeepItem = ConvertItemToChanceToKeep(oItem, nLevel);
            nRoll = d100();
            if (nRoll > nChanceToKeepItem)
            {
                DestroyObject (oItem, fDelay);
                fDelay = fDelay + 0.1f;
                nNumOfItems--;
            }
        }
        oItem = GetNextItemInInventory (oStore);
    }
    // Now check if we are not down to the minimum number of shop items, then
    // we need to remove older items until we are.
    if(nNumOfItems > nMaxItems)
    {
        nNumOfItems = nNumOfItems - nMaxItems;
        fDelay = 0.0;
        oItem = GetFirstItemInInventory(oStore);
        while(oItem != OBJECT_INVALID && nNumOfItems > 0)
        {
            if(!GetInfiniteFlag (oItem))
            {
                // This assumes that the first items in the list will be the oldest
                // Usually destroying older items first.
                DestroyObject(oItem, fDelay);
                fDelay = fDelay + 0.05f;
                nNumOfItems--;
            }
            oItem = GetNextItemInInventory(oStore);
        }
    }
}

