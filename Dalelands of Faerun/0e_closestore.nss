/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_closestore
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the OnStoreClosed script for closing a store.
 This prunes the store of unwanted items to keep lag down.
 Such as non-magic items and low cost items.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_datetime"
#include "0i_merchant"
#include "0i_itemproperty"
void main ()
{
    int nItems, nItemGoldPieceValue, nMaxItems;
    float fDelay;
    object oItem, oStore = OBJECT_SELF;
    // Remove a patron.
    int nPatrons = GetLocalInt(oStore, "0_Patrons") - 1;
    SetLocalInt(oStore, "0_Patrons", nPatrons);
    // Clear unwanted items if there are no patrons.
    if(nPatrons < 1)
    {
       oItem = GetFirstItemInInventory(oStore);
       while(oItem != OBJECT_INVALID)
       {
           if(!GetInfiniteFlag(oItem))
           {
               if(GetGoldPieceValue(oItem) <= MIN_MERCHANT_ITEM_PRICE ||
                  GetNumberOfProperties(oItem) < 1)
               {
                   DestroyObject(oItem, fDelay);
                   fDelay = fDelay + 0.05f;
               }
               else nItems++;
           }
           oItem = GetNextItemInInventory(oStore);
       }
       nMaxItems = GetMinimumNumberOfItemsForMerchant(oStore) * 2;
       // Checks for too many items in the shop and removes some!
       if(nItems > nMaxItems) ClearStoreItems(oStore, nItems, nMaxItems, FALSE);
    }
}

