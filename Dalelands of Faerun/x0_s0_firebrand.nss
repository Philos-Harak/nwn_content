/*////////////////////////////////////////////////
 Script Name:x0_x0_Firebrand
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 5
Innate Level: 5
School: Evocation
Descriptor(s): Fire
Component(s): Verbal, Somatic, Material
Range: Medium
Area of Effect / Target: Colossal
Duration: Instant
Save: Reflex 1/2
Spell Resistance: Yes

Masses of flame (one per caster level) appear and randomly target and hit any
hostile creature in the area of effect. If there are more creatures than balls
of flame, only the closest targets will be damaged. If there are more balls of
flame than creatures, the excess balls of flame disappear. Each ball of flame
explodes for 1d6 points of damage per caster level (max 15d6).

Material Component: A flask of alchemist's fire.

Enchanting:
Weapons and gloves gain fire damage.
Armors gains fire damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs fire.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 15;
    Spell.iImpact = VFX_IMP_FLAME_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iNumOfMissles = Spell.iCasterLevel;
    if (iNumOfMissles > 15) iNumOfMissles = 15;
    MissileStorm (Spell, iNumOfMissles, VFX_IMP_MIRV_FLAME, TRUE, FALSE);
    CleanUpSpell (Spell);
}




