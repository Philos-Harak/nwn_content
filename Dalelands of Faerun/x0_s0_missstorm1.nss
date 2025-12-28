/*////////////////////////////////////////////////
 Script Name:0_s0_MissStorm1
 Programmer: Brent
////////////////////////////////////////////////
 Up to 10 missiles, each doing 1d6 damage to all
 targets in area.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FORCE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_MAGBLUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iNumOfMissles = Spell.iCasterLevel;
    if (iNumOfMissles > 10) iNumOfMissles = 10;
    MissileStorm (Spell, iNumOfMissles);
    CleanUpSpell (Spell);
}


