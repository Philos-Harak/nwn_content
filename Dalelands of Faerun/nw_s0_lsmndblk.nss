/*////////////////////////////////////////////////
 Script Name: NW_S0_LsMndBlk.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 5
Innate Level: 5
School: Abjuration
Descriptor(s):
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Single
Duration: 1 Hour / Level
Additional Counter Spells: Confusion
Save: Harmless
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
    Spell.sEnhancingComp = "green_stone_dust";
    Spell.iCompAmount = 4; // 100gp worth of Green Stone Dust.
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if(Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    ApplyMindBlank(Spell);
    CleanUpSpell(Spell);
}
