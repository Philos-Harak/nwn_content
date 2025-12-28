/*////////////////////////////////////////////////
 Script Name: 0s_neut_poison
 Programmer : Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 4, Cleric 4, Druid 3, Paladin 4, Ranger 3
Innate Level: 3
School: Conjuration
Component(s): Verbal, Somatic, Material, Divine Focus
Range: Touch
Area of Effect / Target: Single
Duration: 10 Minutes / Level
Additional Counter Spells: Poison
Save: Harmless

You detoxify any sort of venom in the creature or object touched. A poisoned creature suffers no additional effects from the poison.
The creature is immune to any poison it is exposed to during the duration of the spell.

Enchanting:
Bracers, belts, cloaks, and helmets gain a saving throw vs poison.
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
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 10;
    Spell.iImpact = VFX_IMP_REMOVE_CONDITION;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects.
    effect eProt = EffectImmunity (IMMUNITY_TYPE_POISON);
    //Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eDuration, eProt);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply the effect
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oTarget, Spell.fDuration));
        // Apply visual effect
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        // Remove any poison effects.
        RemoveASpecificEffect (Spell.oAreaTarget, EFFECT_TYPE_POISON);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


