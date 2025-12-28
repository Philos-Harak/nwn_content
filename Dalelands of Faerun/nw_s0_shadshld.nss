/*////////////////////////////////////////////////
 Script: NW_S0_ShadShld
 Programmer: Preston Watamaniuk
//////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 7
Innate Level: 7
School: Illusion
Descriptor(s):
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Turn / Level
Additional Counter Spells:
Save: Harmless
Spell Resistance: No

The caster is shrouded in a cloak of shadow that protects them with the following effects:
+5 natural AC bonus
10 / +3 Damage reduction
Immunity to instant death effects
Immunity to Necromancy spells
Immunity to Negative Engergy Damage
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_SHADOW;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_TURNS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 5;
    Spell.iImpact = VFX_IMP_DEATH_WARD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eVisual = EffectVisualEffect (VFX_DUR_PROT_SHADOW_ARMOR);
    effect eSpell = EffectSpellLevelAbsorption (9, 0, SPELL_SCHOOL_NECROMANCY);
    effect eImmDeath = EffectImmunity (IMMUNITY_TYPE_DEATH);
    effect eImmNeg = EffectDamageImmunityIncrease (DAMAGE_TYPE_NEGATIVE, 100);
    // Create effects.
    effect eDmgReduction = EffectDamageReduction (10, DAMAGE_POWER_PLUS_THREE);
    effect eAC = EffectACIncrease (Spell.iResult, AC_NATURAL_BONUS);
    // Link effects.
    effect eLink = EffectLinkEffects (eDmgReduction, eAC);
    eLink = EffectLinkEffects(eLink, eVisual);
    eLink = EffectLinkEffects(eLink, eImmDeath);
    eLink = EffectLinkEffects(eLink, eImmNeg);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = EffectLinkEffects(eLink, eSpell);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply the effects and VFX Impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
