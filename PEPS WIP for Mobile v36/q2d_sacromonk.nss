//::///////////////////////////////////////////////////
//:: q2d_sacromonk.NSS
//:: OnOpened/OnDeath script for a treasure container.
//:: Treasure type: Any, random selection from whatever is in base container
//:: Treasure level: TREASURE_TYPE_MED
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/21/2002
//:: Updated by Philos to work with Philos' AI
//:: This must be in the development folder to work.
//::///////////////////////////////////////////////////
#include "x0_i0_treasure"
#include "nw_i0_generic"
void SpawnMonk(object oSac, location lLoc, object oPC)
{
    SetLocalInt(oSac, "DO_MUMMY_ONCE", 1);
    object oMonk = CreateObject(OBJECT_TYPE_CREATURE, "undeadmonk", lLoc);
    AssignCommand(oMonk, SetFacingPoint(GetPosition(oPC)));
    // This is removed as Philos' AI will start the combat.
    //AssignCommand(oMonk, DetermineCombatRound(oPC));
    AssignCommand(oMonk, PlaySound(""));
}
void main()
{
    object oOpener = GetLastOpenedBy();
    if(oOpener == OBJECT_INVALID) oOpener = GetLastOpener();
// ********************* ADD AI CODE FOR LOOTING *******************************
// *************** SHOULD NOT CHANGE ORIGINAL BEHAVIOR *************************
    object oPC = GetLocalObject(OBJECT_SELF, "AI_GET_LAST_OPENED_BY");
    if(GetIsObjectValid(oPC)) oOpener = oPC;
// ********************* ADD AI CODE FOR LOOTING *******************************
    CTG_CreateTreasure(TREASURE_TYPE_MED, oOpener, OBJECT_SELF);
    int nDoOnce = GetLocalInt(OBJECT_SELF, "DO_MUMMY_ONCE");
    if(nDoOnce == 1) return;
    AssignCommand(oOpener, ClearAllActions());
    SpawnMonk(OBJECT_SELF, GetLocation(OBJECT_SELF), oOpener);
    object oSac1 = GetNearestObjectByTag(GetTag(OBJECT_SELF), OBJECT_SELF, 1);
    object oSac2 = GetNearestObjectByTag(GetTag(OBJECT_SELF), OBJECT_SELF, 2);
    object oSac3 = GetNearestObjectByTag(GetTag(OBJECT_SELF), OBJECT_SELF, 3);
    DelayCommand(1.0, SpawnMonk(oSac1, GetLocation(oSac1), oOpener));
    DelayCommand(2.0, SpawnMonk(oSac2, GetLocation(oSac2), oOpener));
    DelayCommand(3.0, SpawnMonk(oSac3, GetLocation(oSac3), oOpener));
}



