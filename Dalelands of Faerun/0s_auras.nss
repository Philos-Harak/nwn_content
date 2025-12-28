/*////////////////////////////////////////////////
 Script: 0s_auras
 Programmer: Preston Watamaniuk
//:://////////////////////////////////////////////
Caster Level(s): Cleric 8
Innate Level: 8
School: Abjuration
Component(s): Verbal, Somatic, Focus
Range: Personal
Area of Effect: 20' Sphere from the caster.
Duration: 1 Round / Level
Save: Harmless
Spell Resistance: Yes

When this spell is cast, the caster chooses to be protected from either good or
evil. All allies within 20' of the caster gain the benefits of this spell.
They receives a +4 deflection bonus to Armor Class and Saves against all creatures.
Then immunity to mind-affecting spells and spell-like abilities used by creatures
of the chosen alignment, and spell resistance 25 against spells cast by creatures
of the chosen alignment. Creatures of the chosen alignment also take 1d8 + 6 damage
each time they successfully strike the those protected.

Chaos - Confusion
Evil - d6 Strength dmg
Good - Blinded
Law - Paralyze

Focus: A tiny reliquary containing some sacred relic. The reliquary costs at least 500 gp.
/*/////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sDivineComponent = "0_sacred_relic";
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 1;
    int iAlign1, iAlign2, iVisual;
    // Get the spell being cast.
    if (Spell.iSpellID == SPELL_CLOAK_OF_CHAOS)
    {
        Spell.iDescriptor = DESC_CHAOTIC;
        iAlign1 = ALIGNMENT_CHAOTIC;
        iAlign2 = ALIGNMENT_ALL;
        iVisual = VFX_DUR_PROTECTION_EVIL_MAJOR;
        Spell.iImpact = VFX_IMP_AURA_NEGATIVE_ENERGY;
        Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    }
    if (Spell.iSpellID == SPELL_HOLY_AURA)
    {
        Spell.iDescriptor = DESC_GOOD;
        iAlign1 = ALIGNMENT_ALL;
        iAlign2 = ALIGNMENT_GOOD;
        iVisual = VFX_DUR_PROTECTION_GOOD_MAJOR;
        Spell.iImpact = VFX_IMP_AURA_HOLY;
        Spell.iDamageType = DAMAGE_TYPE_POSITIVE;
    }
    else if (Spell.iSpellID == SPELL_UNHOLY_AURA)
    {
        Spell.iDescriptor = DESC_EVIL;
        iAlign1 = ALIGNMENT_ALL;
        iAlign2 = ALIGNMENT_EVIL;
        iVisual = VFX_DUR_PROTECTION_EVIL_MAJOR;
        Spell.iImpact = VFX_IMP_AURA_NEGATIVE_ENERGY;
        Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    }
    if (Spell.iSpellID == SPELL_SHIELD_OF_LAW)
    {
        Spell.iDescriptor = DESC_GOOD;
        iAlign1 = ALIGNMENT_LAWFUL;
        iAlign2 = ALIGNMENT_ALL;
        iVisual = VFX_DUR_PROTECTION_GOOD_MAJOR;
        Spell.iImpact = VFX_IMP_AURA_HOLY;
        Spell.iDamageType = DAMAGE_TYPE_POSITIVE;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects.
    effect eAC = EffectACIncrease (4, AC_DEFLECTION_BONUS);
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, 4);
    effect eImmune = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
    effect eSR = EffectSpellResistanceIncrease (25);
    effect eDmgShield = EffectDamageShield (6, DAMAGE_BONUS_1d8, Spell.iDamageType);
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eVisual = EffectVisualEffect (iVisual);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // * make them versus the alignment
    eImmune = VersusAlignmentEffect (eImmune, iAlign1, iAlign2);
    eSR = VersusAlignmentEffect (eSR, iAlign1, iAlign2);
    eDmgShield = VersusAlignmentEffect (eDmgShield, iAlign1, iAlign2);
    //Link effects
    effect eLink = EffectLinkEffects (eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eSR);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = EffectLinkEffects(eLink, eVisual);
    eLink = EffectLinkEffects(eLink, eDmgShield);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply the effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

