/*//////////////////////////////////////////////////////////////////////////////
 Script Name con_q2bhench_2
 Copyright (c) 2001 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
    Test to see if the PC has max companions already.
    Return True if PC does not have max companions.
    Used in Horde of the Underdark - Chapter 1
////////////////////////////////////////////////////////////////////////////////
 Created By: Keith Warner
 Created On: July 15/03
 Changed By: Philos
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    //See if the 2nd Henchman slot is empty, Now checks if Max Henchman slot is empty.
    object oHench = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, GetMaxHenchmen());
    if(!GetIsObjectValid(oHench)) return TRUE;
    return FALSE;
}
