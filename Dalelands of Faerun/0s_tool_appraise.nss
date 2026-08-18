/*////////////////////////////////////////////////////////////////
 Script Name: 0s_appraise_tool
 Programmer: Philos
//////////////////////////////////////////////////////////////////
     Used to determine the base cost of an item
     by checking the Appraise skill vs Lore item cost table.
*/////////////////////////////////////////////////////////////////
#include "0i_itemproperty"
void main()
{
    object oPC = OBJECT_SELF;
    object oItem = GetSpellTargetObject();
    // First make sure the item is not unidentified first.
    if(!GetIdentified(oItem))
    {
        SendMessages("You cannot appraise and unidentified item!", COLOR_RED, oPC, FALSE, FALSE);
        return;
    }
    // Check to see if this item has been appraised by this character.
    float fAdjustment = GetLocalFloat(oItem, "appraise_" + GetName (oPC));
    // Get the value of the item.
    int nItemValue = GetGoldPieceValue(oItem);
    // Has this item already been appraised by this character?
    if(fAdjustment == 0.0f)
    {
        // The check is d20 + Appraise skill vs item power level +10.
        // So we subtract 10 from the roll to get the correct value to check against the 2da.
        int nRoll = GetSkillRank(SKILL_APPRAISE, oPC, FALSE) + d20() - 10;
        // Get the items 2da value and compare.
        int n2daValue = StringToInt(Get2DAString("skillvsitemcost", "DeviceCostMax", nRoll));
        // Check skill against the skillvsitemcost 2da (Lore ranks).
        if(nItemValue > n2daValue)
        {
          // Roll adjustment since they have no idea 50% to 150% of value.
          fAdjustment = IntToFloat(Random(110) + 50) * 0.01f;
        }
        else
        {
          // Make minor adjustment so they can't tell if the appraised the item 90% to 110% of value.
          fAdjustment = IntToFloat(Random(30) + 90) * 0.01f;
        }
        // Set that this item has been appraised.
        SetLocalFloat(oItem, "appraise_" + GetName(oPC), fAdjustment);
     }
     // Adjust the value of the item if they are not a DM.
     if(!GetIsDungeonMaster(oPC)) nItemValue = FloatToInt(IntToFloat(nItemValue) * fAdjustment);
     // Get the comma version of the value.
     string sGold = GetGoldString(nItemValue);
     // Get the level that this item is.
     int nCount, nLevel;
     // Reset the gold value to get the correct item level power. Lets not do this.
     //nItemValue = GetGoldPieceValue(oItem);
     while(nCount < 41)
     {
        if(nItemValue <= StringToInt(Get2DAString("itemvalue", "MAXSINGLEITEMVALUE", nCount))) 
        {
            nLevel = nCount + 1;
            break;
        }
        nCount++;
     }
     // Send the message.
     // Check to see if it has a magical power so we can add that to the message.
     if(GetNumberOfProperties(oItem))
     {
        SendMessages("You value the " + GetName(oItem) + " at " + sGold + " with a magic power of " + IntToString (nLevel) + ".", COLOR_MAGIC, oPC, FALSE, FALSE);
     }
     else SendMessages("You value the " + GetName(oItem) + " at " + sGold + ".", COLOR_MAGIC, oPC, FALSE, FALSE);
}

