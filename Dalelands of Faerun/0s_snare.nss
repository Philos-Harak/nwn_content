/*////////////////////////////////////////////////
 Script Name: 0s_snare
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Druid 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Divine Focus
Range: Touch
Area of Effect / Target: 10' x 10' area
Duration: Until triggered
Save: None
Spell Resistance: No

This spell enables you to make a snare that functions as a magic trap. The snare
can be made from any supple vine, a thong, or a rope. When you cast snare upon
it, the cordlike object blends with its surroundings (Search DC 23 for a character
with the trapfinding ability to locate).the cordlike object tightens around the
creature, dealing no damage but causing it to be entangled.
The snare is magical. To escape, a trapped creature must make a DC 23 Athletics
check.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eVisual = EffectVisualEffect (VFX_FNF_LOS_NORMAL_10);
    CreateTrapAtLocation (48, Spell.lTarget, 10.0f, "SNARE_SPELL", STANDARD_FACTION_DEFENDER, "", "");
    CleanUpSpell (Spell);
}

