/*////////////////////////////////////////////////
 Resistance
 Created By: Aidan Scanlan
////////////////////////////////////////////////
Abjuration
Level:  Brd 0, Clr 0, Drd 0, Pal 1, Sor/Wiz 0
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 minute
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

You imbue the subject with magical energy that protects it from harm, granting
it a +1 resistance bonus on saves.

Arcane Material Component: A miniature cloak.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_HEAD_HOLY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult);
    // Create visual effects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create links.
    effect eLink = EffectLinkEffects(eSave, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply the bonus effect and VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
