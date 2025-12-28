//::///////////////////////////////////////////////
//:: Glyph of Warding: On Enter
//:: X2_S0_GlphWardA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script creates a Glyph of Warding Placeable
    object.

    Check x2_o0_hhb.nss and the Glyph of Warding
    placeable object for details
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-02
//:://////////////////////////////////////////////
#include "0i_spells"

void main()
{
    object oTarget = GetEnteringObject ();
    object oPlaceable = GetAreaOfEffectCreator (OBJECT_SELF);
    object oCreator = GetLocalObject (oPlaceable, "PLC_GLYPH_CASTER") ;

    if (!GetLocalInt (oPlaceable, "GLYPH_PLAYERCREATED")) oCreator = oPlaceable;
    // If the placeable or creator is no longer there
    if (!GetIsObjectValid (oPlaceable) || !GetIsObjectValid (oCreator))
    {
        DestroyObject (OBJECT_SELF);
        return;
    }
    SetLocalObject (oPlaceable, "GLYPH_LAST_ENTER", oTarget );
    SignalEvent (oPlaceable, EventUserDefined (2000));
}
