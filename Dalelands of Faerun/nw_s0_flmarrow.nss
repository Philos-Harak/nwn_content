/*////////////////////////////////////////////////
 Script Name: NW_S0_FlmArrow
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3
Innate Level: 3
School: Conjuration
Descriptor(s): Fire
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Single
Duration: Instant
Additional Counter Spells:
Save: Reflex 1/2
Spell Resistance: Yes
The caster launches 1 conjured fiery arrow at the target creature for every 4
caster levels. Each arrow does 4d6 points of damage.

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
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 4;
    Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_FLAME_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iCounter;
    float fDistance, fDelay, fDelay2, fTime;
    effect eDmg;
    effect eMissile = EffectVisualEffect (VFX_IMP_MIRV_FLAME);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Get the number of missles to fire by using the iModDicePerLvl.
    int iMissiles = Spell.iCasterLevel / 4;
    // Minimum number of missles to launch is one.
    if (iMissiles < 1) iMissiles = 1;
    // Do not go over maximum spell level.
    if (iMissiles > 5) iMissiles = 5;
    // Now set the Spell.iModDicePerLvl to 0 so we can roll damage per missle.
    // This makes the dice roll not use the casters level.
    Spell.iModDicePerLvl = 0;
    Spell.iModPerLvl = 0;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Get distance and delay per target.
        fDistance = GetDistanceBetween (Spell.oCaster, Spell.oAreaTarget);
        fDelay = fDistance / (3.0 * log (fDistance) + 2.0);
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            //Apply a single damage hit for each missile instead of as a single mass
            for (iCounter = 1; iCounter <= iMissiles; iCounter ++)
            {
                //Roll damage
                Spell = GetModifier (Spell);
                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;
                //Set damage effect
                eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
                //Apply the MIRV and damage effect
                DelayCommand(fTime, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
                DelayCommand(fTime, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact, Spell.oAreaTarget));
                DelayCommand(fDelay2, ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, Spell.oAreaTarget));
            }
        }
        // Show the missle go to the target but they do no damage as they are spell resistant.
        else
        {
            for (iCounter = 1; iCounter <= iMissiles; iCounter ++)
            {
                ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, Spell.oAreaTarget);
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

