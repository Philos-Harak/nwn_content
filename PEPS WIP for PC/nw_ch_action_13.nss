/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_action13
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
Action Script used by the original campaign to swap henchman out when asked
to join.
    Originally it only allowed one henchman.
    Now it allows up to Max Henchman.
*///////////////////////////////////////////////////////////////////////////////
#include "nw_i0_henchman"
void main()
{
    object oPC = GetPCSpeaker();
    if(GetIsObjectValid(GetHenchman(oPC,GetMaxHenchmen())))
    {
        object oHenchman = GetHenchman(oPC);
        SetFormerMaster(oPC, oHenchman);
        RemoveHenchman(oPC, oHenchman);
        ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
        AssignCommand(oHenchman, ClearAllActions());
    }
    SetWorkingForPlayer(oPC);
    SetBeenHired();
    SetFormerMaster(oPC, OBJECT_SELF);
    ExecuteScript("NW_CH_JOIN", OBJECT_SELF);
    GivePersonalItem(oPC);
}
