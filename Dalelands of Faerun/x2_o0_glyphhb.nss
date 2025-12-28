//::///////////////////////////////////////////////
//:: Glyph of Warding Heartbeat
//:: x2_o0_glyphhb
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Heartbeat for glyph of warding object

    Short rundown:

    Casting "glyph of warding" will create a GlyphOfWarding
    object from the palette and store all required variables
    on that object. You can also manually add those variables
    through the toolset.

    On the first heartbeat, the glyph creates the glyph visual
    effect on itself for the duration of the spell.

    Each subsequent heartbeat the glyph checks if the effect
    is still there. If it is no longer there, it has either been
    dispelled or removed, and the glyph will terminate itself.

    Also on the first heartbeat, this object creates an AOE object
    around itself, which, when getting the OnEnter Event from a
    Creature Hostile to the player, will  signal User Defined Event
    2000 to the glyph placeable which will fire the spell
    stored on a variable on it self on the intruder

    Note that not all spells might work because this is a placeable
    object casting them, but the more populare ones are working.

    The default spell cast is id 764, which is the script for
    the standard glyph of warding.

    Check the comments on the Glyph of Warding object on the palette
    for more information

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-02
//:://////////////////////////////////////////////

#include "x2_inc_switches"
void main()
{

    int iSetup = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_INIT");
    int iLevel = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_CASTER_LEVEL");
    // If not setup then create the glyph.
    if (!iSetup)
    {
        SetLocalInt (OBJECT_SELF, "PLC_GLYPH_INIT", 1);
        float fDuration = GetLocalFloat (OBJECT_SELF, "PLC_GLYPH_DURATION");
        // show glyph symbol only for 6 seconds
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, EffectVisualEffect (445), OBJECT_SELF, 6.0f);
        // use blur VFX therafter (which should be invisible);
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, EffectVisualEffect (0), OBJECT_SELF, fDuration);
        // Create the area effect for the spell.
        effect eAOE = EffectAreaOfEffect (38, "x2_s0_glphwarda");
        // If permanent then set as a permanent spell.
        if (GetLocalInt (OBJECT_SELF, "PLC_GLYPH_PERMANENT"))
        {
            ApplyEffectAtLocation (DURATION_TYPE_PERMANENT, eAOE, GetLocation(OBJECT_SELF));
        }
        // else make it last for the duration of the spell.
        else ApplyEffectAtLocation (DURATION_TYPE_TEMPORARY, eAOE, GetLocation(OBJECT_SELF), fDuration);
    }
    // If the glyph is setup then check to see if it is over.
    else
    {
        // Look for the visual effect, once it is done then destroy the object.
        effect eDur = GetFirstEffect (OBJECT_SELF);
        int iFound = FALSE;
        while (GetIsEffectValid(eDur) && !iFound)
        {
            if (GetEffectType(eDur) == EFFECT_TYPE_VISUALEFFECT)
            {
                if (GetEffectCreator(eDur) == OBJECT_SELF) iFound = TRUE;
            }
            eDur = GetNextEffect (OBJECT_SELF);
        }
        if (!iFound)
        {
            DestroyObject (OBJECT_SELF);
            return;
        }
    }
    // check if caster left the game
    object oCaster = GetLocalObject (OBJECT_SELF, "PLC_GLYPH_CASTER");
    if (!GetIsObjectValid (oCaster) || GetIsDead (oCaster))
    {
        if (GetLocalInt(OBJECT_SELF,"PLC_GLYPH_PLAYERCREATED") == TRUE)
        {
            DestroyObject(OBJECT_SELF);
        }
        return;
    }
}
