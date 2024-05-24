//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

    2007-12-31: Deva Winblood
    Modified to look for X3_HORSE_OWNER_TAG and if
    it is defined look for an NPC with that tag
    nearby or in the module (checks near first).
    It will make that NPC this horse's master.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////

//******************************  ADDED AI CODE  *******************************
#include "0i_associates"
//#include "0i_assoc_debug"
//******************************  ADDED AI CODE  *******************************

void main()
{
    SetAssociateListenPatterns();//Sets up the special henchmen listening patterns
    SetAssociateStartLocation();
    //****************************  ADDED AI CODE  *****************************
    ai_OnAssociateSpawn(OBJECT_SELF);
    //****************************  ADDED AI CODE  *****************************
}


