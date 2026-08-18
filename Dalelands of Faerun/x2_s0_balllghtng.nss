/*////////////////////////////////////////////////
 Script Name: x2_s0_balllghtng
 Programmer: Brent
////////////////////////////////////////////////
School: Evocation
Descriptor(s): Electricity
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Gargantuan
Duration: Instantaneous
Additional Counter Spells:
Save: Reflex 1/2
Spell Resistance: Yes

You create a number of lightning balls (one per caster level up to a maximum
of 15) that appear and target any hostile creature in the area of effect.
If there are more creatures than balls, only the closest targets will be hit up
to the number of balls created. If there are more balls than creatures, the
creatures will be hit with an even number of balls. Each ball of lightning does
1d6 points of electrical damage.
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
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_LIGHTNING_S;
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
    MissileStorm(Spell, iNumOfMissles, 503, FALSE, FALSE, TRUE);
    CleanUpSpell (Spell);
}
