/*////////////////////////////////////////////////
 Script Name: NW_S0_NegProt
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 3
Innate Level: 3
School: Abjuration
Component(s): Verbal, Somatic, Divine Focus
Range: Touch
Area of Effect / Target: Single
Duration: 2 Minutes / Level
Additional Counter Spells:
Save: Harmless
Spell Resistance: No

The target creature is rendered immune to all negative energy attacks, including
supernatural ability damage and level drains.

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
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 2;
    Spell.iDurPerLvl = 2;
    Spell.iImpact = VFX_IMP_HOLY_AID;
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
    effect eNeg = EffectDamageImmunityIncrease (DAMAGE_TYPE_NEGATIVE, 100);
    effect eLevel = EffectImmunity (IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbility = EffectImmunity (IMMUNITY_TYPE_ABILITY_DECREASE);
    // Create visual effects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Link Effects
    effect eLink = EffectLinkEffects(eNeg, eLevel);
    eLink = EffectLinkEffects (eLink, eAbility);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

