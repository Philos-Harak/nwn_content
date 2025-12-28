/*////////////////////////////////////////////////
 Ray of EnFeeblement
 Created By: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy
Level:  Sor/Wiz 1
Components:     V, S
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Effect:     Ray
Duration: 1 minute / level
Saving Throw:   None
Spell Resistance:   Yes
A coruscating ray springs from your hand. You must succeed on a ranged touch
attack to strike a target. The subject takes a penalty to Strength equal to
1d6+1 per two caster levels (maximum 1d6+5).
The subject’s Strength score cannot drop below 3.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 2;
    Spell.iMaxModifier = 5;
    Spell.iImpact = VFX_IMP_REDUCE_ABILITY_SCORE;
    Spell.iBeam = VFX_BEAM_ODD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Declare variables.
    int iHit;
    effect eFeeble, eRay, eLink;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a touch attack to hit.
        iHit = TouchAttackRanged (Spell.oAreaTarget);
        // Setup the beam effect to hit or miss.
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND, !iHit);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.0f));
        if (iHit)
        {
            // Get the strength reduction.
            Spell = GetModifier (Spell);
            // Make resistance check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Create effects.
                eFeeble = EffectAbilityDecrease (ABILITY_STRENGTH, Spell.iResult);
                eLink = EffectLinkEffects(eFeeble, eDuration);
                //Apply the ability damage effect and VFX impact
                DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact, Spell.oAreaTarget));
             }
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
