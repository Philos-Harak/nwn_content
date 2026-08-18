/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_findthepath
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
Caster Level(s): Bard 6, Cleric 6, Druid 6, Cavern 6, Knowledge 6, Travel 6
Innate Level: 6
School: Divination
Component(s): Verbal, Somatic, Focus
Range: Touch
Area of Effect: One creature.
Duration: 10 minute / level.
Save: Fortitude None
Spell Resistance: No

The recipient of this spell can find the shortest, most direct physical route to
a specified destination. The spell enables the subject to sense the correct direction
that will eventually lead it to a quests destination.

Focus: A set of divination counters of the sort you favor - bones, ivory counters,
sticks, carved runes, or the like.

Note this spells actual effect is in game in the on_enter script.
The script looks for the spell effect and will find quest paths based on that.
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
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
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
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
