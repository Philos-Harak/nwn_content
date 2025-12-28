/*////////////////////////////////////////////////
 Script: 0s_insanity
 Programmer: Philos
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Sor/Wiz 7
Components: V, S
Casting Time:   1 standard action
Range: Medium
Target: One creature
Duration: Permanent, see below
Saving Throw: Will negates
Spell Resistance: Yes

The affected non-player creature suffers from a continuous confusion effect, as the spell.
Players are affected for 1 minute per level.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_CONFUSION_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects.
    effect eConfused = EffectConfused ();
    // Create visual effects.
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    // Link effects.
    effect eLink = EffectLinkEffects (eVisual, eConfused);
    eLink = EffectLinkEffects(eLink, eDuration);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Check for PC's
            if (GetIsPC (Spell.oAreaTarget))
            {
                Spell.iDurationType = DURATION_TYPE_MINUTES;
                Spell.iDuration = 1;
                Spell.iDurPerLvl = 1;
                // Get the duration of the spell, sets Spell.fDuration.
                Spell = GetDuration (Spell);
            }
            else
            {
                Spell.iDurationType = DURATION_TYPE_PERMANENT;
                Spell.fDuration = 0.0f;
            }
            //Apply VFX Impact and effects.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
