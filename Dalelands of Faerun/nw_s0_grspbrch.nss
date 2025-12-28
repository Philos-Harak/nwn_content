/*////////////////////////////////////////////////
 Script: NW_S0_grSpBrch
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 6
Innate Level: 6
School: Abjuration
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Single
Duration: Special
Additional Counter Spells: Minor Globe of Invulnerability, Lesser Spell Mantle
Save: None
Spell Resistance: No

This spell strips an enemy mage of up to four magical defenses, including
Spell Mantles, Globes of Invulnerability, Stoneskins, Premonition,
Protection from Elements, Ghostly and Ethereal Visage, Mage Armor,
Shadow Shield and Elemental Shield. This spell will also reduce the target
creature's SR by 5 for ten rounds
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        DoSpellBreach (Spell.oAreaTarget, 4, 5, Spell.iSpellID);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
