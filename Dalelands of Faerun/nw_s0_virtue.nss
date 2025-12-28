/*////////////////////////////////////////////////
 Script: NW_S0_Aid.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:  Clr 0, Drd 0
Components:     V, S, DF
Casting Time: 1 standard action
Range: Touch
Target: Living creature touched
Duration: 1 min.
Saving Throw: None
 The Subject gains 1 temporary hit point
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
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_HOLY_AID;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects.
    effect eHP = EffectTemporaryHitpoints (1);
    // Create visual effects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eHP, eDur);
    // Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt(Spell.oCaster, Spell.iSpellID, FALSE));
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, Spell.oAreaTarget, Spell.fDuration));
        // Get the spells next target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

