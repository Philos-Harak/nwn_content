/*////////////////////////////////////////////////
 Script: 0s_corupt_ray
 Programmer: Philos
////////////////////////////////////////////////
Evocation
Level: Innate 1
Components: S
Casting Time: 1 standard action
Range:  Medium
Effect: One creature
Duration: Instantaneous
Saving Throw: None
Spell Resistance: Yes

This automatically hits with no saving throw, but they do get a spell resistance
check. When hit the creature is immediately shaken (-2 to all ability checks,
attacks, saves, and skill checks).
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_FEAR_S;
    Spell.iBeam = VFX_BEAM_EVIL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHit;
    effect eRay;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Create effects.
    effect eAb1 = EffectAbilityDecrease (ABILITY_STRENGTH, 2);
    effect eAb2 = EffectAbilityDecrease (ABILITY_DEXTERITY, 2);
    effect eAb3 = EffectAbilityDecrease (ABILITY_CONSTITUTION, 2);
    effect eAb4 = EffectAbilityDecrease (ABILITY_INTELLIGENCE, 2);
    effect eAb5 = EffectAbilityDecrease (ABILITY_WISDOM, 2);
    effect eAb6 = EffectAbilityDecrease (ABILITY_CHARISMA, 2);
    effect eSkills = EffectSkillDecrease (SKILL_ALL_SKILLS, 2);
    effect eSaves = EffectSavingThrowDecrease (SAVING_THROW_ALL, 2);
    effect eAttack = EffectAttackDecrease (2);
    // Link effects.
    effect eLink = EffectLinkEffects (eAb1, eAb2);
    eLink = EffectLinkEffects (eAb3, eLink);
    eLink = EffectLinkEffects (eAb4, eLink);
    eLink = EffectLinkEffects (eAb5, eLink);
    eLink = EffectLinkEffects (eAb6, eLink);
    eLink = EffectLinkEffects (eSkills, eLink);
    eLink = EffectLinkEffects (eSaves, eLink);
    eLink = EffectLinkEffects (eAttack, eLink);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Apply the VFX impact and effect
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}




