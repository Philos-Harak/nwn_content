/*////////////////////////////////////////////////
 Script Name: NW_S0_MindBlk.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 8
Innate Level: 8
School: Abjuration
Descriptor(s): Mind
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Huge
Duration: 24 Hours
Additional Counter Spells: Mass Charm
Spell Resistance: No

This spell renders the target creature immune to mind-affecting spells and
spell-like effects, and removes all negative effects caused by such spells.

Enchanting:
Helmets gain a saving throw bonus vs mind spells.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
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
    // Create visual effect.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_20);
    // Apply area effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // All of the area targeting and spell effects are in ApplyMindBlank function!
    ApplyMindBlank (Spell);
    CleanUpSpell (Spell);
}
