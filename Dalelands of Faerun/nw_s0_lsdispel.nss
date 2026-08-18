/*////////////////////////////////////////////////
 Script: NW_S0_LsDispel
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
School: Abjuration
Component(s): Somatic
Range: Medium
Area of Effect / Target: Single or Colossal
Duration: Instant
Save: No
Spell Resistance: Yes

This spell attempts to strip all magical effects from a single target.
It can also target a group of creatures, attempting to remove the most powerful
spell effect from each creature. To remove an effect from a creature the caster
makes a dispel check of 1d20, +1 per caster level (to a maximum of +5) against
a DC of 11 + the spell effect's caster level.

NOTE: To make creatures immune to dispell set 0_IMMUNE_TO_DISPEL = true on the creature.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sEnhancingComp = "nune_dust";
    Spell.iCompAmount = 4; // 100gp worth of Nune Dust.
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 5;
    Spell.iImpact = VFX_IMP_HEAD_SONIC;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(Spell.sEnhancingComp == "TRUE") Spell.iResult += 2;;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eFnf = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    // Check to see if they selected one target.
    if (GetIsObjectValid (Spell.oTarget))
    {
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        while(GetIsObjectValid(Spell.oAreaTarget))
        {
            //Signal spell cast at event to fire.
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult) DispelMagicEffect (Spell.oAreaTarget, Spell.iResult, eImpact, eFnf);
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    // Checks multiple creatures removing the best effect only.
    else
    {
        Spell.iAreaShape = SHAPE_SPHERE;
        Spell.fAreaSize = 20.0f;
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eFnf, Spell.lTarget);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        while(GetIsObjectValid(Spell.oAreaTarget))
        {
            // Check to see if the first object is an area of effect.
            if (GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_AREA_OF_EFFECT) DispelAoEEffect (Spell.oAreaTarget, Spell.oCaster, Spell.iResult);
            // Check placeables.
            else if (GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_PLACEABLE)
            {
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            }
            // Check creatures.
            else
            {
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // Make resistance and save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult) DispelMagicEffect (Spell.oAreaTarget, Spell.iResult, eImpact, eFnf, FALSE);
            }
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    CleanUpSpell (Spell);
}
