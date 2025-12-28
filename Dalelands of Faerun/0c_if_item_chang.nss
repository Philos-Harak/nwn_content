/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_item_chang
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that checks if they have changed an items appearance.
*///////////////////////////////////////////////////////////////////////////////

int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    // Get the ranks required.
    int nRanksRequired = GetLocalInt (oPC, "0_Item_Change_DC");
    // Get the players ranks.
    int nRanks = GetSkillRank (23, oPC, TRUE);
    if (nRanksRequired > nRanks) return FALSE;
    return TRUE;
}
