/*////////////////////////////////////////////////
 Script: NW_S0_BarkSkin.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:  Drd 2, Rgr 2, Plant 2
Components: V, S, DF
Casting Time:   1 standard action
Range:  Touch
Target: Living creature touched
Duration:   10 min./level
Saving Throw:   None
Spell Resistance:   Yes (harmless)

Barkskin toughens a creature’s skin. The effect grants a +2 enhancement bonus to
the creature’s existing natural armor bonus. This enhancement bonus increases
by 1 for every three caster levels above 3rd, to a maximum of +5 at caster level 12th.
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
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 3;
    Spell.iMaxModifier = 5;
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
    // Make sure the Armor Bonus is of type Natural
    effect eAC = EffectACIncrease(Spell.iResult, AC_NATURAL_BONUS);
    // Create visual effects.
    effect eVis = EffectVisualEffect (VFX_DUR_PROT_BARKSKIN);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eVis, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply the effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
