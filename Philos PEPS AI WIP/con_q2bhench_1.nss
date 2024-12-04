/*//////////////////////////////////////////////////////////////////////////////
 Script Name con_q2bhench_1
 Copyright (c) 2001 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
    Test to see if the PC has max companions already.
    Return True if PC already has the max companions.
////////////////////////////////////////////////////////////////////////////////
 Created By: Keith Warner
 Created On: July 15/03
 Changed By: Philos
*///////////////////////////////////////////////////////////////////////////////

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    //See if the 2nd Henchman slot is already filled, Now checks Max Henchman.
    object oHench = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, GetMaxHenchmen());
    if(GetIsObjectValid(oHench)) return TRUE;
    return FALSE;
}
