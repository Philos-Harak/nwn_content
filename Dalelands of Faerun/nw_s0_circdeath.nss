/*////////////////////////////////////////////////
 Script: nw_s0_circdeath
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Death]
Level:  Sor/Wiz 6
Components: V, S, M
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Area:   Several living creatures within a 40-ft.-radius burst
Duration:   Instantaneous
Saving Throw:   Fortitude negates
Spell Resistance:   Yes
A circle of death snuffs out the life force of living creatures, killing them
instantly.

The spell slays 1d4 HD worth of living creatures per caster level (maximum 20d4).
Creatures with the fewest HD are affected first; among creatures with equal HD,
those who are closest to the burst’s point of origin are affected first.
No creature of 9 or more HD can be affected, and Hit Dice that are not sufficient
to affect a creature are wasted.

Material Component
The powder of a crushed pearl with a minimum value of 500 gp.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DEATH;
    Spell.sArcaneComponent = "0_pearl_dust";
    Spell.sDivineComponent = "0_pearl_dust";
    Spell.iCompAmount = 500;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 40.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    Spell.iSpellResistance = TRUE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 20;
    Spell.iImpact = VFX_IMP_DEATH;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nLevel, nCreatureHD, nLowest;
    object oLowest;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCircle = EffectVisualEffect (VFX_FNF_LOS_EVIL_20);
    effect eDeath =  EffectDeath ();
    // Used to tell the script we have hit this creature already.
    string sSpellLocal = "SPELL_CIRCLE_DEATH_" + StripColorCodes (GetName (Spell.oCaster));
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    int nHD = Spell.iResult;
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCircle, Spell.lTarget);
    //Get the spells target(s).
    while (nHD > 0)
    {
        // Check the area again for the next lowest.
        // Do this by clearing the spells target to start over.
        Spell.oAreaTarget = OBJECT_INVALID;
        oLowest = OBJECT_INVALID;
        nLowest = nHD + 1;
        Spell = GetSpellTarget (Spell);
        while (GetIsObjectValid (Spell.oAreaTarget))
        {
            // Has this creature already been hit by the spell, check Spell variable.
            if (!GetLocalInt (Spell.oAreaTarget, sSpellLocal))
            {
                // Get the current HD of the target creature
                nCreatureHD = GetHitDice (Spell.oAreaTarget);
                //Check to see if the HD are lower than the current Lowest HD stored and that the
                //HD of the monster are lower than the number of HD left to use up.
                if (nCreatureHD < nLowest && nCreatureHD <= nHD && nCreatureHD < 9)
                {
                    nLowest = nCreatureHD;
                    oLowest = Spell.oAreaTarget;
                }
            }
            Spell = GetSpellTarget (Spell);
        }
        // Check to see if we have a lowest target.
        if (GetIsObjectValid (oLowest))
        {
            // Must set the target so we can make spell checks.
            Spell.oAreaTarget = oLowest;
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Check to see if they are immune to Death;
                if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_DEATH))
                {
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDeath, Spell.oAreaTarget));
                }
                // * even though I am immune apply just the death effect for the immunity message
                else DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDeath, Spell.oAreaTarget));
            }
            // Set a local int to make sure the creature is not hit twice in the pass.
            // Destroy that variable in 1.0f seconds to remove it from the creature.
            SetLocalInt (Spell.oAreaTarget, sSpellLocal, TRUE);
            DelayCommand (1.0, DeleteLocalInt(oLowest, sSpellLocal));
            // Remove the Hit dice of the creature from the total.
            nHD -= nLowest;
        }
        // We ran out of targets so lets set HD to 0 so we can exit.
        else nHD = 0;
    }
    CleanUpSpell (Spell);
}
