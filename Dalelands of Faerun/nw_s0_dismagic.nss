/*////////////////////////////////////////////////
 Script Name: NW_S0_DisMagic
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Brd 3, Clr 3, Drd 4, Magic 3, Pal 3, Sor/Wiz 3
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target or Area: One spellcaster, creature, or object; or 20-ft.-radius burst
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   No

Attempts to dispel all magic on a targeted object, or simply the most powerful
that it can on every object in an area if no target specified. Maximum caster
level is 10th.

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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 10;
    Spell.iImpact = VFX_IMP_BREACH;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eCenter = EffectVisualEffect(VFX_FNF_DISPEL);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Check for single target, Attempt to dispell all effects.
    if (Spell.oTarget != OBJECT_INVALID)
    {
         DispelMagicEffect (Spell.oTarget, Spell.iResult, eImpact, eCenter);
         // Check other spell effects and remove if needed.
         CheckSpellEffectsForRemoval (Spell.oTarget);
    }
    // Check for area of effect dispell, remove best effect from each object.
    else
    {
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        while (GetIsObjectValid(Spell.oAreaTarget))
        {
            // Check for area of effect spells.
            if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
            {
                DelayCommand (Spell.fDelay, DispelAoEEffect (Spell.oAreaTarget, Spell.oCaster, Spell.iResult));
            }
            // Check for placeables.
            else if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_PLACEABLE)
            {
                DelayCommand (Spell.fDelay, SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID)));
            }
            // Do creatures.
            else
            {
                DelayCommand (Spell.fDelay, DispelMagicEffect (Spell.oAreaTarget, Spell.iResult, eImpact, eCenter, FALSE));
                DelayCommand (Spell.fDelay, CheckSpellEffectsForRemoval (Spell.oAreaTarget));
            }
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    CleanUpSpell (Spell);
}



