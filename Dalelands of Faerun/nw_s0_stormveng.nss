/*////////////////////////////////////////////////
 Script: NW_S0_StormVeng.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 9, Druid 9
Innate Level: 9
School: Conjuration
Descriptor(s): Acid, Electricity
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Colossal
Duration: 10 Rounds
Additional Counter Spells:
Save: Reflex Special
Spell Resistance: Yes

The area around the caster is blasted by lightning and acidic rain. Each round,
all enemies within the area of effect take 3d6 points of acid damage. Those who
fail a Reflex save take an additional 3d6 points of electrical damage and are
stunned for one round.

******** Needs to be reworked to closer to the Book spell *******************
/*//////////////////////////////////////////////
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
    Spell.iDuration = 10;
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
    effect eAOE = EffectAreaOfEffect (AOE_PER_STORM);
    // Create visual effect.
    effect eCenter = EffectVisualEffect (VFX_FNF_STORM);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
    CleanUpSpell (Spell);
}
