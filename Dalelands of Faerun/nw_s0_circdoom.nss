/*////////////////////////////////////////////////
 Script Name: NW_S0_CircDoom.nss
 Programmer: Preston Watamaniuk and Keith Soleski
////////////////////////////////////////////////
Caster Level(s): Cleric 5
Innate Level: 5
School: Necromancy
Descriptor(s): Negative
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Huge
Duration: Instant
Save: Fortitude 1/2
Spell Resistance: Yes

All enemies within the area of effect are struck with negative energy that
causes 1d8 points of damage, +1 point per caster level (Max of 20).
Negative energy spells have a reverse effect on undead, healing them instead of
harming them.
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
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_NEGATIVE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 20;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect variables.
    effect eEffect;
    // Create visual effects
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eImpactHeal = EffectVisualEffect (VFX_IMP_HEALING_M);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_EVIL_10);
    effect eHeal;
    // Apply base area effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Heal undead's if its a negative energy.
        if (GetRacialType (Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD && Spell.iDamageType == DAMAGE_TYPE_NEGATIVE)
        {
            //Fire cast spell at event for the specified target.
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Create the heal effect.
            eEffect = EffectHeal (Spell.iResult);
            // Apply effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eEffect, Spell.oAreaTarget));
            // Apply visual effects.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpactHeal, Spell.oAreaTarget));
        }
        // Damage all other creatures or undead if it is not negative energy.
        else
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (Spell.iResult > 0)
            {
                // Create the damage effect.
                eEffect = EffectDamage (Spell.iResult, Spell.iDamageType);
                // Apply effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eEffect, Spell.oAreaTarget));
                // Apply visual effects.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

