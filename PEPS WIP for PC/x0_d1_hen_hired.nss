/*//////////////////////////////////////////////////////////////////////////////
 Script Name: X0_D1_HEN_HIRED
 Copyright (c) 2002 Floodgate Entertainment
////////////////////////////////////////////////////////////////////////////////
    Handles the hiring of a henchman.
////////////////////////////////////////////////////////////////////////////////
 Created By: Naomi Novik
 Created On: 09/13/2002
 Changed By: Philos
*///////////////////////////////////////////////////////////////////////////////
#include "x0_i0_henchman"
void main()
{
    object oHench = OBJECT_SELF;
    SetPlotFlag(oHench, FALSE);
    SetImmortal(oHench, FALSE);
    // Philos - This is the hired henchman code to allow multiple henchman.
    // Fire the PC's former henchman if necessary
    object oPC = GetPCSpeaker();
    int nCountHenchmen = X2_GetNumberOfHenchmen(oPC);
    int nNumberOfFollowers = X2_GetNumberOfHenchmen(oPC, TRUE);
    // * The true number of henchmen are the number of hired
    nCountHenchmen = nCountHenchmen ;
    int nMaxHenchmen = GetMaxHenchmen();
    // Adding this henchman would exceed the module imposed henchman limit.
    // Fire the first henchman The third slot is reserved for the follower
    if(nCountHenchmen >= nMaxHenchmen) X2_FireFirstHenchman(oPC);
    // Mark the henchman as working for the given player
    if(!GetPlayerHasHired(oPC, oHench))
    {
        // This keeps track if the player has EVER hired this henchman
        // Floodgate only (XP1). Should never store info to a database as game runs, only between modules or in Persistent setting
        if (GetLocalInt(GetModule(), "X2_L_XP2") !=  1)
        {
            SetPlayerHasHiredInCampaign(oPC, oHench);
        }
        SetPlayerHasHired(oPC, oHench);
    }
    SetLastMaster(oPC, oHench);
    // Clear the 'quit' setting in case we just persuaded the henchman to rejoin us.
    SetDidQuit(oPC, oHench, FALSE);
    // If we're hooking back up with the henchman after s/he died, clear that.
    SetDidDie(FALSE, oHench);
    SetKilled(oPC, oHench, FALSE);
    SetResurrected(oPC, oHench, FALSE);
    // Turn on standard henchman listening patterns
    SetAssociateListenPatterns(oHench);
    // By default, companions come in with Attack Nearest and Follow modes enabled.
    SetLocalInt(oHench, "NW_COM_MODE_COMBAT",ASSOCIATE_COMMAND_ATTACKNEAREST);
    SetLocalInt(oHench, "NW_COM_MODE_MOVEMENT",ASSOCIATE_COMMAND_FOLLOWMASTER);
    // Add the henchman
    AddHenchman(oPC, oHench);
    DelayCommand(1.0, AssignCommand(oHench, LevelUpXP1Henchman(oPC)));
}
