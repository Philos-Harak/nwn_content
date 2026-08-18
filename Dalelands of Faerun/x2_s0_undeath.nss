/*////////////////////////////////////////////////
 Script: X2_S0_Undeath
 Programmer: Georg Zoeller
////////////////////////////////////////////////
Necromancy
Level:  Clr 6, Sor/Wiz 6
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Area:   Several undead creatures within a 40-ft.-radius burst
Duration:   Instantaneous
Saving Throw:   Will negates
Spell Resistance:   Yes

This spell slays 1d4 HD worth of undead creatures per caster level (maximum 20d4).
Creatures with the fewest HD are affected first; among creatures with equal HD,
those closest to the point of origin of the burst are affected first.

Material Component: Diamonds crushed into a dust worth at least 500 gp.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_toollib"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "diamond_dust";
    Spell.sDivineComponent = "diamond_dust";
    Spell.iCompAmount = 20; // 500 gp worth of diamond dust
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 40.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_WILL;
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
    int iLevel, iCreatureHD, iHD, iLowest, iRacialType;
    object oLowest;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCircle = EffectVisualEffect (VFX_FNF_STRIKE_HOLY);
    effect eDeath = EffectDeath ();
    eDeath = SetEffectCasterLevel(eDeath, Spell.iCasterLevel);
    // Used to tell the script we have hit this creature already.
    string sSpellLocal = "UNDEATH_TO_DEATH_" + GetName (Spell.oCaster);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    iHD = Spell.iResult;
    iLowest = iHD + 1;
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCircle, Spell.lTarget);
    TLVFXPillar (VFX_FNF_LOS_HOLY_20, Spell.lTarget, 3, 0.0f);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget) && iHD > 0)
    {
        iRacialType = GetRacialType (Spell.oAreaTarget);
        //Make check to ignore specific creatures.
        if (iRacialType == RACIAL_TYPE_UNDEAD)
        {
            // Has this creature already been hit by the spell, check SpellLocal variable.
            if (!GetLocalInt (Spell.oAreaTarget, sSpellLocal))
            {
                //Get the current HD of the target creature
                iCreatureHD = GetHitDice(Spell.oAreaTarget);
                //Check to see if the HD are lower than the current Lowest HD stored and that the
                //HD of the monster are lower than the number of HD left to use up.
                if(iCreatureHD < iLowest && iCreatureHD <= iHD)
                {
                    iLowest = iCreatureHD;
                    oLowest = Spell.oAreaTarget;
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        //Check to see if we are done searching for creatures.
        if (!GetIsObjectValid(Spell.oAreaTarget))
        {
            // Check to see if we have a lowest target.
            if (GetIsObjectValid (oLowest))
            {
                //Fire cast spell at event for the specified target
                SignalEvent (oLowest, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // Make resistance and save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    // Check to see if they are immune to Death;
                    if (!GetIsImmune (oLowest, IMMUNITY_TYPE_DEATH))
                    {
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, oLowest));
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDeath, oLowest));
                    }
                    // * even though I am immune apply just the death effect for the immunity message
                    else DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDeath, oLowest));
                }
                // Set a local int to make sure the creature is not used twice in the pass.  Destroy that variable in
                // 1.0f seconds to remove it from the creature
                SetLocalInt (oLowest, sSpellLocal, TRUE);
                DelayCommand (1.0, DeleteLocalInt(oLowest, sSpellLocal));
                //Remove the HD of the creature from the total
                iHD = iHD - GetHitDice (oLowest);
                oLowest = OBJECT_INVALID;
                iLowest = iHD + 1;
                // Check the area again for the next lowest.
                // Do this by clearing the spells target to start over.
                Spell.oAreaTarget = OBJECT_INVALID;
                //Get the spells target(s).
                Spell = GetSpellTarget (Spell);
            }
        }
    }
    CleanUpSpell (Spell);
}
