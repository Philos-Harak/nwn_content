//::///////////////////////////////////////////////
//:: Name 0e_spawn_myrkul
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default OnDeath script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
#include "nwnx_object"
#include "0i_server_colors"
void main()
{
    object oItem = CreateItemOnObject("itemset_4_" + IntToString(d4()));
    SetName(oItem, AddColorToText(GetName(oItem), COLOR_SET));
    SetIdentified(oItem, TRUE);
    // Give bonus hitpoints.
    int nHitpoints = GetMaxHitPoints(OBJECT_SELF) * 5;
    NWNX_Object_SetMaxHitPoints(OBJECT_SELF, nHitpoints);
    NWNX_Object_SetCurrentHitPoints(OBJECT_SELF, nHitpoints);
    ExecuteScript("nw_c2_default9", OBJECT_SELF);
}
