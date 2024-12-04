/*//////////////////////////////////////////////////////////////////////////////
Script Name x2_hen_2comp
Copyright (c) 2001 Bioware Corp.
///////////////////////////////////////////////////////////////////////////////
    Test to see if the PC has two companions already.
    Return True if PC already has more than 1 companion
    NOTE - July 15 - multiple henchmen not implemented yet
         - testing for 1 henchman
    UPDATE - July 25th - support for multiple henchmen added
    NOW checks to see how many henchman are set in the game.
////////////////////////////////////////////////////////////////////////////////
 Created By: Keith Warner
 Created On: July 15/03
 Changed By: Philos
*///////////////////////////////////////////////////////////////////////////////
#include "x0_i0_henchman"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nNumHench = X2_GetNumberOfHenchmen(oPC);
    if (nNumHench >= GetMaxHenchmen()) return TRUE;
    else return FALSE;
}

