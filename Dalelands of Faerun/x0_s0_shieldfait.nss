/*////////////////////////////////////////////////
 Script: x0_s0_ShieldFait.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Abjuration
Level:  Clr 1
Components: V,
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 min./level
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)
This spell creates a shimmering, magical field around the touched creature that
averts attacks. The spell grants the subject a +2 deflection bonus to AC, with
an additional +1 to the bonus for every six levels you have
(maximum +5 deflection bonus at 18th level).
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // +2 AC +1 per 6 levels to max of +5.
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 6;
    Spell.iMaxModifier = 4;
    Spell.iImpact = VFX_IMP_AC_BONUS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAC, eLink;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Create effect and link.
        eAC = EffectACIncrease (Spell.iResult, AC_DEFLECTION_BONUS);
        eLink = EffectLinkEffects (eAC, eDur);
        //Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
