/*////////////////////////////////////////////////
 Scripts: X2_S0_Ironguts
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 1
Innate Level: 1
School: Abjuration
Descriptor(s): Poison Resistance
Component(s): Verbal, Somatic, Material
Range: Touch
Area of Effect / Target: Creature touched
Duration: 10 minutes / level
Additional Counter Spells:
Save: No
Spell Resistance: No

When touched, the target creature gains a +4 circumstance bonus on Fortitude
saves against all poisons.

Material Component: A vial containing the diluted poison of four different creatures.
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
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 4;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eSave, eLink;
    effect eVis2 = EffectVisualEffect (VFX_IMP_HEAD_ACID);
    effect eVis = EffectVisualEffect (VFX_IMP_HEAD_HOLY);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        //Set the bonus save effect
        eSave = EffectSavingThrowIncrease (SAVING_THROW_FORT, Spell.iResult, SAVING_THROW_TYPE_POISON);
        eLink = EffectLinkEffects (eSave, eDur);
        //Apply the bonus effect and VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis2, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay + 0.3f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

