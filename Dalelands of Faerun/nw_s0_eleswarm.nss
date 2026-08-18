/*////////////////////////////////////////////////
 Script: NW_S0_EleSwarm
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Druid 9
Innate Level: 9
School: Conjuration
Descriptor(s): Air, Earth, Fire, Water
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Point
Duration: 24 Hours
Additional Counter Spells: Dismissal
Save: None
Spell Resistance: None

The caster summons a 21 HD air elemental to act as a loyal servant until it dies
or until the spell expires. If the air elemental dies before the spell ends, a
21 HD water elemental is automatically summoned to replace it. This process
continues with an earth and fire elemental until the spell expires. After the
fire elemental, no more are summoned.

// This spell needs reworked into the real spell later!
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    //Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eSummon;
    effect eVisual = EffectVisualEffect (VFX_FNF_SUMMON_MONSTER_3);
    //Set the summoning effect
    eSummon = EffectSwarm (FALSE, "NW_SW_AIRGREAT", "NW_SW_WATERGREAT", "NW_SW_EARTHGREAT", "NW_SW_FIREGREAT");
    eSummon = SetEffectCasterLevel(eSummon, Spell.iCasterLevel);
    //Apply the summon effect
    ApplyEffectToObject (Spell.iDurationType, eSummon, Spell.oCaster, Spell.fDuration);
    CleanUpSpell (Spell);
}

