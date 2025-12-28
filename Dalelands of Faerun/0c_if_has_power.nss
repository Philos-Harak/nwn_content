/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_power
  Made By: Philos
////////////////////////////////////////////////////////////////////////////////
  Text Appears When script that checks to see if the item has an increased
  gold cost.
  If not then the power is not put on the item and should mean the item already
  had that power.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_crafting"
int StartingConditional()
{
    int nGoldCost;
    nGoldCost = GetLocalInt (OBJECT_SELF, "0_GoldCost");
    if (nGoldCost > 0) return FALSE;
    else return TRUE;
}
