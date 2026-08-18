/*////////////////////////////////////////////////
 Script Name: x0_s0_WoundWhis
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 3
Innate Level: 3
School: Abjuration
Descriptor(s): Sonic
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster
Duration: 1 round / level
Additional Counter Spells:
Save: None
Spell Resistance: No

The caster is surrounded with whispers that injure any creature that hits the
caster for 1d6 + 1 / level points of sonic damage.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_SONIC;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iDamageType = DAMAGE_TYPE_SONIC;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 0;
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
    // Create effect.
    effect eShield = EffectDamageShield (Spell.iResult, DAMAGE_BONUS_1d6, Spell.iDamageType);
    // Create visual effects.
    effect eVis = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Link effects
    effect eLink = EffectLinkEffects(eShield, eDur);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply the effect.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
