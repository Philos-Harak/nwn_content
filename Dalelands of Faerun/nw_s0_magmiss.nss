/*////////////////////////////////////////////////
 Script: nw_s0_magmiss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Force]
Level:  Sor/Wiz 1
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Targets:    Up to five creaturs
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   Yes
A missile of magical energy darts forth from your fingertip and strikes its
target, dealing 1d4+1 points of force damage.

The missile strikes unerringly, even if the target is in melee combat or has
less than total cover or total concealment. Specific parts of a creature can’t
be singled out. Inanimate objects are not damaged by the spell.

For every two caster levels beyond 1st, you gain an additional missile — two at
3rd level, three at 5th, four at 7th, and the maximum of five missiles at
9th level or higher.
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
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_MAGBLUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iCounter;
    float fDistance, fDelay, fDelay2, fTime;
    effect eDmg;
    effect eMissile = EffectVisualEffect (VFX_IMP_MIRV);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Get the number of missles to fire by using the iModDicePerLvl.
    int iMissiles = (Spell.iCasterLevel + 1) / 2;
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
        if (!Spell.iSaveResult)
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
