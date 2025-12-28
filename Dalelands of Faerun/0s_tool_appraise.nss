/*////////////////////////////////////////////////////////////////
 Script Name: 0s_appraise_tool
 Programmer: Philos
//////////////////////////////////////////////////////////////////
     Used to determine the base cost of an item
     by checking the Appraise skill vs Lore item cost table.
*/////////////////////////////////////////////////////////////////
#include "0i_master"
void main()
{
    int iRanks, i2daValue, iItemValue, iCount, iLevel;
    itemproperty ipProperty;
    string sGold;
    float fAdjustment;
    object oPC = OBJECT_SELF;
    object oItem = GetSpellTargetObject();
    // First make sure the item is not unidentified first.
    if (!GetIdentified (oItem))
    {
        SendMessages ("You cannot appraise and unidentified item!", COLOR_RED, oPC, FALSE, FALSE);
        return;
    }
    // Check to see if this item has been appraised by this character.
    fAdjustment = GetLocalFloat (oItem, "appraise_" + GetName (oPC));
    // Get the value of the item.
    iItemValue = GetGoldPieceValue(oItem);
    // Has this item already been appraised by this character?
    if (fAdjustment == 0.0f)
    {
        // Get the ranks of the skill.
        iRanks = GetSkillRank(SKILL_APPRAISE, oPC, FALSE);
        // Get the items 2da value and compare.
        i2daValue = StringToInt (Get2DAString("skillvsitemcost", "DeviceCostMax", iRanks));
        // Check skill against the skillvsitemcost 2da (Lore ranks).
        if (iItemValue > i2daValue)
        {
          // Roll adjustment since they have no idea 50% to 150% of value.
          fAdjustment = IntToFloat (Random (110) + 50) * 0.01f;
        }
        else
        {
          // Make minor adjustment so they can't tell if the appraised the item 90% to 110% of value.
          fAdjustment = IntToFloat (Random (30) + 90) * 0.01f;
        }
        // Set that this item has been appraised.
        SetLocalFloat (oItem, "appraise_" + GetName (oPC), fAdjustment);
     }
     // Adjust the value of the item if they are not a DM.
     if (!GetIsDungeonMaster (oPC)) iItemValue = FloatToInt (IntToFloat (iItemValue) * fAdjustment);
     // Get the comma version of the value.
     sGold = GetGoldString (iItemValue);
     // Get the level that this item is.
     iCount = 0;
     // Reset the gold value to get the correct item level power.
     iItemValue = GetGoldPieceValue(oItem);
     while (iCount < 41 && iLevel == 0)
     {
        if (iItemValue <= StringToInt (Get2DAString ("itemvalue", "MAXSINGLEITEMVALUE", iCount))) iLevel = iCount + 1;
        iCount++;
     }
     // Send the message.
     // check to see if it has a magical power so we can add that to the message.
     ipProperty = GetFirstItemProperty (oItem);
     if (GetIsItemPropertyValid (ipProperty))
     {
        SendMessages ("You value the " + GetName (oItem) + " at " + sGold + " with a magic power of " + IntToString (iLevel) + ".", COLOR_BLUE, oPC, FALSE, FALSE);
     }
     else SendMessages ("You value the " + GetName (oItem) + " at " + sGold + ".", COLOR_BLUE, oPC, FALSE, FALSE);
}

