/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_openmerchant
 Programmer:Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that opens a merchant.
 params:
 sTag - opens the nearest store with this tag.
 sInput - runs functions based on value.
    "IdentifyPotions" - identifies potions for PCSpeaker.
    "IdentifyScrolls" - identifies scrolls for PCSpeaker.
    "IdentifyGemsAO" - identifies gems and art objects for PCSpeaker
 Variables used on merchant:
 0_NoPriceChange - The merchant does not adjust it's prices.

 Markup system:
 A merchants wares are marked up based on a PC's Appraise and Persuade.
 Formula is ((Persuade + Appraise) / 2) + 1d20 - 10
 Maximum bonus is 490. A max purchasing of 49% less and a max selling of 49%.
 All stores must be set to Markup 100 and Markdown 50 to get the correct bonus.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_animate"
#include "0i_datetime"
void TakeGoldAndMessagePC (object oPC, int i, string sType, int nCost)
{
    SendMessages ("I have identified " + IntToString (i) + " " + sType + " for you.", COLOR_GREEN, oPC, FALSE, FALSE);
    TakeGoldFromCreature (i * nCost, oPC, TRUE);
}

void IdentifyAllScrolls (object oPC)
{
    int iType, iNumIDed = 0;
    int i = GetGold (oPC) / 10;
    object oItem = GetFirstItemInInventory (oPC);
    while (oItem != OBJECT_INVALID && i > 0)
    {
        if (GetIdentified (oItem) == FALSE)
        {
            iType = GetBaseItemType (oItem);
            if (iType == BASE_ITEM_BLANK_SCROLL ||
                iType == BASE_ITEM_SCROLL ||
                iType == BASE_ITEM_SPELLSCROLL ||
                iType == BASE_ITEM_ENCHANTED_SCROLL)
            {
                SetIdentified (oItem, TRUE);
                i --;
                iNumIDed ++;
            }
        }
        oItem = GetNextItemInInventory (oPC);
    }
    if (iNumIDed > 0) TakeGoldAndMessagePC (oPC, iNumIDed, "scrolls", 10);
}

void IdentifyAllPotions (object oPC)
{
    int iNumIDed = 0;
    int i = GetGold (oPC) / 10;
    object oItem = GetFirstItemInInventory (oPC);
    while (oItem != OBJECT_INVALID && i > 0)
    {
        if (GetIdentified (oItem) == FALSE)
        {
            int iType = GetBaseItemType (oItem);
            if (iType == BASE_ITEM_ENCHANTED_POTION ||
                iType == BASE_ITEM_BLANK_POTION ||
                iType == BASE_ITEM_POTIONS)
            {
                SetIdentified (oItem, TRUE);
                i --;
                iNumIDed ++;
            }
        }
        oItem = GetNextItemInInventory (oPC);
    }
    if (iNumIDed > 0) TakeGoldAndMessagePC (oPC, iNumIDed, "potions", 10);
}

void IdentifyAllGemsArtObjects (object oPC)
{
    int iNumIDed = 0;
    int i = GetGold (oPC) / 10;
    object oItem = GetFirstItemInInventory (oPC);
    while (oItem != OBJECT_INVALID && i > 0)
    {
        if (GetIdentified (oItem) == FALSE)
        {
            string sResRef = GetResRef (oItem);
            sResRef = GetStringLeft (sResRef, 2);
            if (sResRef == "g_"
             || sResRef == "a_")
            {
                SetIdentified (oItem, TRUE);
                i --;
                iNumIDed ++;
            }
        }
        oItem = GetNextItemInInventory (oPC);
    }
    if (iNumIDed > 0) TakeGoldAndMessagePC (oPC, iNumIDed, "gems and art objects", 10);
}

void KeepMerchantStill (object oMerchant)
{
    SetAICondition(AI_IS_IMMOBILE, TRUE, oMerchant);
    DelayCommand(FIVE_MINUTE_DELAY, SetAICondition (AI_IS_IMMOBILE, FALSE, oMerchant));
}

int GetMerchantSkillCheck (object oPC)
{
    int nSkillRanks, nSkillRoll;
    string sResult, sColor;
    int nCheck = GetLocalInt (OBJECT_SELF, "0_Haggled_" + GetName (oPC));
    if (nCheck == 0)
    {
         nSkillRanks = (GetSkillRank (SKILL_PERSUADE, oPC) +
                            GetSkillRank (SKILL_APPRAISE, oPC)) / 2;
         nSkillRoll = d20();
         nCheck = nSkillRanks + nSkillRoll - 10;
         SetLocalInt (OBJECT_SELF, "0_Haggled_" + GetName (oPC), nCheck);
    }
    if (nCheck > 49) return 49;
    if (nCheck < -9) { sResult = "hostile"; sColor = COLOR_RED; }
    else if (nCheck < 1) { sResult = "unfriendly"; sColor = COLOR_RED; }
    else if (nCheck < 10) { sResult = "indifferent"; sColor = COLOR_GREEN; }
    else if (nCheck < 30) { sResult = "friendly"; sColor = COLOR_GREEN; }
    else { sResult = "helpful"; sColor = COLOR_GREEN; }
    if (nSkillRoll > 0)
    {
        if (nSkillRanks >= 0)SendMessages ("Persuasion/Appraise Check (" + IntToString (nSkillRoll) +" + " + IntToString (nSkillRanks) + " = " +IntToString (nSkillRanks + nSkillRoll) + ")", COLOR_GRAY, oPC, FALSE, FALSE);
        else SendMessages ("Persuasion/Appraise Check (" + IntToString (nSkillRoll) + " - " + IntToString (abs (nSkillRanks)) + " = " + IntToString (nSkillRanks + nSkillRoll) + ")", COLOR_GRAY, oPC, FALSE, FALSE);
    }
    SendMessages (GetName (OBJECT_SELF) + " seems " + sResult + " towards you.", sColor, oPC, FALSE, FALSE);
    return nCheck;
}

void main()
{
    int nCheck;
    string sResult, sColor;
    object oPC = GetPCSpeaker();
    string sInput = GetScriptParam("sInput");
    if(sInput == "IdentifyScrolls") IdentifyAllScrolls(oPC);
    else if(sInput == "IdentifyPotions") IdentifyAllPotions(oPC);
    else if(sInput == "IdentifyGemsAO") IdentifyAllGemsArtObjects(oPC);
    // Open the store.
    else
    {
        string sTag = GetScriptParam("sTag");
        object oMerchant = GetNearestObjectByTag(sTag);
        if(oMerchant == OBJECT_INVALID) SetModuleError("TAG", "0c_openmerchant", "150", "Tag invalid for store: " + sTag);
        else
        {
            KeepMerchantStill(OBJECT_SELF);
            if(GetLocalInt(oMerchant, "0_NoPriceChange")) nCheck = 0;
            else nCheck = GetMerchantSkillCheck(oPC);
        }
        if(GetLocalInt(OBJECT_SELF, "0_Date_Generated") == 0)
        {
            SetLocalInt(OBJECT_SELF, "0_Date_Generated", GetCurrentDateTimeInMinutes());
        }
        OpenStore(oMerchant, oPC, -nCheck, nCheck);
    }
}
