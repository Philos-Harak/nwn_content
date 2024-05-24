//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

This must support the OC henchmen and all summoned/companion
creatures.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//****************************  ADDED AI CODE  *****************************
#include "0i_associates"
//****************************  ADDED AI CODE  *****************************
//#include "X0_INC_HENAI"
void main()
{
    //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();
    // Set additional henchman listening patterns
    //bkSetListeningPatterns();
    // Set starting location
    SetAssociateStartLocation();
    //****************************  ADDED AI CODE  *****************************
    ai_OnAssociateSpawn(OBJECT_SELF);
    //****************************  ADDED AI CODE  *****************************
}


