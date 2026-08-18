/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_fly
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////

Caster Level(s): Wizard / Sorcerer 3, Travel 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Focus, Divine Focus
Range: Touch
Area of Effect/Target: Creature touched.
Duration: 1 minute / level.
Save: Fortitude None
Spell Resistance: No
 The creature touched gains the ability to fly to any location within sight for the duration of the spell. To use the flight ability the spells focus a birds feather can be used to target locations to fly to.
Arcane Focus: A wing feather from any bird.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_IMP_HEAD_ODD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables
    object oItem;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    eImpact = SetEffectCasterLevel(eImpact, Spell.iCasterLevel);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Apply effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDuration, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        oItem = CreateItemOnObject ("0_fly_token", Spell.oAreaTarget);
        DestroyObject (oItem, Spell.fDuration);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
