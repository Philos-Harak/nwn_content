/*////////////////////////////////////////////////
 Script Name: NW_S0_NegBurst
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3
Innate Level: 3
School: Necromancy
Descriptor(s): Negative
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Huge
Duration: Instant
Additional Counter Spells: Negative Energy Protection
Save: Will 1/2
Spell Resistance: Yes

All creatures caught in the area of effect take 1d8 points of negative energy
damage, +1 per caster level, to a maximum of +20. All creatures caught in the
area also lose 1 point of strength per 4 caster levels. Negative energy spells
have a reverse effect on undead, healing instead of harming them and giving
1 point of strength per 4 caster levels.

Enchanting:
Bracers, belts, cloaks, and helmets gain a saving throw bonus vs death.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
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
    effect eEffect;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_EVIL_20);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eImpactHeal = EffectVisualEffect (VFX_IMP_HEALING_M);
    // Get strength drain amount.
    int iStr = Spell.iCasterLevel / 4;
    if (iStr == 0) iStr = 1;
    // Create effects.
    effect eStrIncrease = EffectAbilityIncrease (ABILITY_STRENGTH, iStr);
    effect eStrDrain = EffectAbilityDecrease (ABILITY_STRENGTH, iStr);
    effect eDurationPositive = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eDurationNegative = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Link effects.
    effect eLinkStrIncrease = EffectLinkEffects(eStrIncrease, eDurationPositive);
    effect eLinkStrDrain = EffectLinkEffects(eStrDrain, eDurationNegative);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Heal and boost undead's str.
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
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_PERMANENT, eLinkStrIncrease, Spell.oAreaTarget));
        }
        // Do damage and str drain to all other creatures.
        else
        {
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (Spell.iResult > 0)
            {
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // Create the damage effect.
                eEffect = EffectDamage (Spell.iResult, Spell.iDamageType);
                // Apply effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eEffect, Spell.oAreaTarget));
                // Apply visual effects.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_PERMANENT, eLinkStrDrain, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
