/*////////////////////////////////////////////////
 Script: X0_S0_Inflict
 Programmer: Brent
////////////////////////////////////////////////
    Fires all Inflict spell scripts.
    Inflict Minor Wounds 1d4 damage.
    Inflict Light Wounds 1d8 +1/level max +5 damage.
    Inflict Moderate Wounds 2d8 +1/level max +10 damage.
    Inflict Serious Wounds 3d8 +1/level max +15 damage.
    Inflict Critical Wounds 4d8 + 1/level max +20 damage.
    Harm 10 / level max 150 damage.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_NEGATIVE;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    switch (Spell.iSpellID)
    {
        case SPELL_INFLICT_MINOR_WOUNDS:
        {
            Spell.iSaveHalf = FALSE;
            Spell.iMaxModifier = 0;
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 4;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 0;
            Spell.iModPerLvl = 0;
            InflictSpell (Spell, VFX_IMP_NEGATIVE_ENERGY, VFX_IMP_HEALING_S);
            break;
        }
        case SPELL_INFLICT_LIGHT_WOUNDS:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 5;
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            InflictSpell (Spell, VFX_IMP_NEGATIVE_ENERGY, VFX_IMP_HEALING_S);
            break;
        }
        case SPELL_INFLICT_MODERATE_WOUNDS:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 10;
            Spell.iModNumOfDice = 2;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            InflictSpell (Spell, VFX_IMP_NEGATIVE_ENERGY, VFX_IMP_HEALING_S);
            break;
        }
        case SPELL_INFLICT_SERIOUS_WOUNDS: case 611:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 15;
            Spell.iModNumOfDice = 3;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            InflictSpell (Spell, VFX_IMP_NEGATIVE_ENERGY, VFX_IMP_HEALING_S);
            break;
        }
        case SPELL_INFLICT_CRITICAL_WOUNDS: case 612:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 20;
            Spell.iModNumOfDice = 4;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            InflictSpell (Spell, VFX_IMP_NEGATIVE_ENERGY, VFX_IMP_HEALING_S);
            break;
        }
        case SPELL_HARM:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 15;
            Spell.iModNumOfDice = 0;
            Spell.iModifierDie = 0;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 10;
            Spell.iModPerLvl = 1;
            InflictSpell (Spell, 246, VFX_IMP_HEALING_G);
            break;
        }
    }
    CleanUpSpell (Spell);
}
