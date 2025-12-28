/*////////////////////////////////////////////////
 Script: NW_S0_Premo
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Druid 8, Wizard / Sorcerer 8
Innate Level: 8
School: Divination
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Hour / Level
Additional Counter Spells: Feeblemind
Save: Harmless
Spell Resistance: No

Premonition allows the caster to see a few moments into the future. This grants
him damage reduction 30/+5, and absorbs 10 points of melee damage per caster
level before collapsing.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 10;
    Spell.iModPerLvl = 1;
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
    // Create visual effects
    effect eVisual = EffectVisualEffect (VFX_DUR_PROT_PREMONITION);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effect
    effect eStone = EffectDamageReduction (30, DAMAGE_POWER_PLUS_FIVE, Spell.iResult);
    // Link effects
    effect eLink = EffectLinkEffects (eStone, eVisual);
    eLink = EffectLinkEffects(eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
