//::///////////////////////////////////////////////////
//:: q2d_sacro.NSS
//:: OnOpened/OnDeath script for a treasure container.
//:: Treasure type: Any, random selection from whatever is in base container
//:: Treasure level: TREASURE_TYPE_MED
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/21/2002
//:: Updated by Philos to work with Philos' AI
//:: This must be in the development folder to work.
//::///////////////////////////////////////////////////
#include "x0_i0_treasure"
#include "nw_i0_generic"
void main()
{
    object oOpener = GetLastOpenedBy();
    if(oOpener == OBJECT_INVALID) oOpener = GetLastOpener();
// ********************* ADD AI CODE FOR LOOTING *******************************
// *************** SHOULD NOT CHANGE ORIGINAL BEHAVIOR *************************
    object oPC = GetLocalObject(OBJECT_SELF, "AI_GET_LAST_OPENED_BY");
    WriteTimestampedLogEntry(GetName(OBJECT_SELF) + " oPC: " + GetName(oPC));
    if(GetIsObjectValid(oPC)) oOpener = oPC;
// ********************* ADD AI CODE FOR LOOTING *******************************
    CTG_CreateTreasure(TREASURE_TYPE_MED, oOpener, OBJECT_SELF);
    int nDoOnce = GetLocalInt(OBJECT_SELF, "DO_MUMMY_ONCE");
    if(nDoOnce == 1) return;
    SetLocalInt(OBJECT_SELF, "DO_MUMMY_ONCE", 1);
    object oMummy = CreateObject(OBJECT_TYPE_CREATURE, "nw_mummy", GetLocation(oOpener));
    AssignCommand(oMummy, SetFacingPoint(GetPosition(oOpener)));
    // This is removed as Philos' AI will start the combat.
    //AssignCommand(oMummy, DetermineCombatRound(oPC));
    AssignCommand(oOpener, PlaySound("c_mummycom_bat1"));

}

