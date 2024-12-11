//::///////////////////////////////////////////////
//:: General Treasure Spawn Script
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spawns in general purpose treasure, usable
    by all classes.
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   February 26 2001
//:://////////////////////////////////////////////
#include "NW_O2_CONINCLUDE"
void main()
{
    if(GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0) return;
    object oLastOpener = GetLastOpener();
// ********************* ADD AI CODE FOR LOOTING *******************************
// *************** SHOULD NOT CHANGE ORIGINAL BEHAVIOR *************************
    object oPC = GetLocalObject(OBJECT_SELF, "AI_GET_LAST_OPENED_BY");
    if(GetIsObjectValid(oPC)) oLastOpener = oPC;
// ********************* ADD AI CODE FOR LOOTING *******************************
    SendMessageToPC(GetFirstPC(), "oLastOpener: " + GetName(oLastOpener));
    GenerateLowTreasure(oLastOpener, OBJECT_SELF);
    SetLocalInt(OBJECT_SELF,"NW_DO_ONCE",1);
    ShoutDisturbed();
}
