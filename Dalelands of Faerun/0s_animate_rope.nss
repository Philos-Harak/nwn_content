/*////////////////////////////////////////////////
 Script: 0s_animate_rope
 Programmer: Philos
////////////////////////////////////////////////
Transmutation
Level: Brd 1, Sor/Wiz 1
Components: V, S, M
Casting Time: 1 standard action
Range: Short
Target: One creature
Duration: 1 round/level
Saving Throw: Reflex negates
Spell Resistance: No

You can animate a nonliving ropelike object.
The rope can enwrap only a creature and it must be thrown near the intended target.
Doing so requires a successful ranged touch attack roll and requires a DC 23
Strength check to burst it. The rope does not deal damage, but it can be used to
cause a single opponent that fails a Reflex saving throw to become entangled.

Material component: A rope.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "0_climber_kit";
    Spell.sDivineComponent = "0_climber_kit";
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iImpact = VFX_IMP_DAZED_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Define variables
    int iHit;
    // Create effects
    effect eEntangle = EffectEntangle ();
    // Create visual effects
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect (VFX_DUR_ENTANGLE);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Link effects.
    effect eLink = EffectLinkEffects (eVisual, eEntangle);
    eLink = EffectLinkEffects (eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a touch attack to hit.
        iHit = TouchAttackRanged (Spell.oAreaTarget);
        if (iHit)
        {
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
               //Apply VFX Impact and daze effect
               DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
               DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
