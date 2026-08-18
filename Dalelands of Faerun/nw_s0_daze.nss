/*////////////////////////////////////////////////
 Script: nw_s0_daze
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Brd 0, Sor/Wiz 0
Components: V, S, M
Casting Time:   1 standard action
Range:  Short
Target: One humanoid creature of 4 HD or less
Duration:   1 round
Saving Throw:   Will negates
Spell Resistance:   Yes

This enchantment clouds the mind of a humanoid creature with 4 or fewer Hit Dice
so that it takes no actions. Humanoids of 5 or more HD are not affected.
A dazed subject is not stunned, so attackers get no special advantage against it.

Material Component: A pinch of wool or similar substance.
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
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 2;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iSpellResistance = TRUE;
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
    // Create effect.
    effect eDaze = EffectDazed();
    // Create visual effects.
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    // Link effects.
    effect eLink = EffectLinkEffects(eVisual, eDaze);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        //Make sure the target is a humaniod
        if (IsAHumanoid (Spell.oAreaTarget) == TRUE)
        {
            // Must be less than 5 HD.
            if (GetHitDice(Spell.oAreaTarget) <= 5)
            {
                // Make resistance and save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    //Apply VFX impact and effect
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, Spell.oAreaTarget, Spell.fDuration));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
