/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_detectdoors
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
Caster Level(s): Bard 1, Wizard / Sorcerer 1, Caverns 1, Knowledge 1
Innate Level: 1
School: Divination
Component(s): Verbal, Somatic
Range: 10'
Area of Effect: Personal.
Duration: 1 minute / level.
Save: Fortitude None
Spell Resistance: No

 You can detect secret doors, compartments, caches, and so forth. Only passages,
 doors, or openings that have been speciffically constructed to escape detection
 are detected.

Note this spells actual effect is in game with secret triggers.
The triggers look for the spell and if the player has it they will
go off without a search check.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eVisual = EffectVisualEffect (VFX_DUR_MAGICAL_SIGHT);
    // Used to anchor the spell to the creature so we can test for it.
    effect eEffect = EffectSpellImmunity (SPELL_HORSE_MOUNT);
    eEffect = RemoveEffectIcon (eEffect);
    // Link the effects
    effect eLink = EffectLinkEffects (eDuration, eVisual);
    eLink = EffectLinkEffects (eLink, eEffect);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Apply effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
