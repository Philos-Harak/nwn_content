/*////////////////////////////////////////////////
 Script Name: NW_S0_StinkCld
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3
Innate Level: 3
School: Conjuration
Component(s): Verbal, Somatic, Material
Range: Medium
Area of Effect / Target: Huge
Duration: 1 Round / Level
Save: Fortitude Negates
Spell Resistance: Yes

All creatures caught within the area of effect are dazed. These effects last as
long as they remain within the cloud and for 1 round after they leave.

Material Component
A rotten egg or several skunk cabbage leaves.

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
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
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
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_FOGSTINK))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Stinking cloud spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_FOGSTINK);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        // Create visual effect.
        effect eCenter = EffectVisualEffect (259);
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

