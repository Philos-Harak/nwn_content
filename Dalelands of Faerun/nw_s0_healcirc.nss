/*////////////////////////////////////////////////
 Script Name:NW_S0_HealCirc
 Programmer: Noel Borstad
////////////////////////////////////////////////
Caster Level(s): Bard 5, Cleric 5, Druid 6
Innate Level: 5
School: Conjuration
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Medium
Duration: Instant
Additional Counter Spells: Circle of Doom
Save: Fortitude 1/2
Spell Resistance: Yes

All friendly creatures within the area of effect are healed for 1d8 Hit Points,
+1 points per caster level up to a maximum of +20. Healing spells have a reverse
effect when used on undead, harming instead of healing them.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_HEALING;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 15.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_POSITIVE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_POSITIVE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 20;
    Spell.iImpact = VFX_IMP_HEALING_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_HOLY_20);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    CureSpell (Spell, VFX_IMP_SUNSTRIKE, Spell.iImpact);
    CleanUpSpell (Spell);
}
