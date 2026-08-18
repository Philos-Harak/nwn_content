/*////////////////////////////////////////////////
 Script: NW_S0_SplResis
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Clr 5, Magic 5, Protection 5
Components: V, S, DF
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 min./level
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)
The creature gains spell resistance equal to 12 + your caster level.
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
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iImpact = VFX_IMP_HEAD_NATURE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eSR = EffectSpellResistanceIncrease (12 + Spell.iResult);
    effect eImpact = EffectVisualEffect (VFX_IMP_MAGIC_PROTECTION);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eDur2 = EffectVisualEffect (249);
    effect eLink = EffectLinkEffects (eSR, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply the effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eDur2, Spell.oAreaTarget, 6.0));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
