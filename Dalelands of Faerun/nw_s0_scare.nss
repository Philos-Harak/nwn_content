/*////////////////////////////////////////////////
 Script: NW_S0_Scare - Actually called Cause Fear
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Fear, Mind-Affecting]
Level: Brd 1, Clr 1, Death 1, Sor/Wiz 1
Components: V, S
Casting Time: 1 standard action
Range: Short
Target: One living creature with 5 or fewer HD
Duration: 1d4 rounds or 1 round; see text
Saving Throw: Will partial
Spell Resistance: Yes

The affected creature becomes frightened for 1d4 rounds. If the subject succeeds on a Will save,
it is shaken for 1 round.
Scare counters and dispels remove fear.

 NOTE THIS SPELL IS EQUAL TO **CAUSE FEAR** NOT SCARE.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FEAR;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 4;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_FEAR;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_FEAR_S;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eFrightened = EffectAttackDecrease(4);
    eFrightened = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 4), eFrightened);
    eFrightened = EffectLinkEffects(EffectSkillDecrease (SKILL_ALL_SKILLS, 4), eFrightened);
    effect eShaken = EffectAttackDecrease(2);
    eShaken = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 2), eShaken);
    eShaken = EffectLinkEffects(EffectSkillDecrease (SKILL_ALL_SKILLS, 2), eShaken);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    eFrightened = EffectLinkEffects(eDuration, eFrightened);
    eShaken = EffectLinkEffects(eDuration, eShaken);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    eFrightened = EffectLinkEffects(eVisual, eFrightened);
    eShaken = EffectLinkEffects(eVisual, eShaken);

    //Get the spells target(s).
    Spell = GetSpellTarget(Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Check the Hit Dice of the creature
        if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_CREATURE)
        {
            //Fire cast spell at event for the specified target
            SignalEvent(Spell.oAreaTarget, EventSpellCastAt(Spell.oCaster, Spell.iSpellID));
            // Get the modifier for the effect.
            Spell = GetModifier(Spell);
            // Make resistance and save check.
            Spell = ResistAndSave(Spell);
            if(!Spell.iSaveResult)
            {
                //Apply linked effects and VFX impact
                DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eFrightened, Spell.oAreaTarget, Spell.fDuration));
            }
            else if (Spell.iSaveResult == 4)
            {
                //Apply linked effects and VFX impact
                DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eShaken, Spell.oAreaTarget, 6.0));
            }
        }
        // Get the spells target(s).
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}
