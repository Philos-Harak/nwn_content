/*////////////////////////////////////////////////
 Script: NW_S0_ConUnd
 Programmer: Philos
////////////////////////////////////////////////
Necromancy
Level:  Sor/Wiz 7
Components: V, S, M
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Targets:    Up to 2 HD/level of undead creatures, no two of which can be more than 30 ft. apart
Duration:   1 min./level
Saving Throw:   Will negates
Spell Resistance:   Yes

This spell enables you to command undead creatures for a short period of time.
You command them by voice and they understand you, no matter what language you
speak. Even if vocal communication is impossible the controlled undead do not
attack you. At the end of the spell, the subjects revert to their normal behavior.

Intelligent undead creatures remember that you controlled them.

Material Component: A small piece of bone and a small piece of raw meat.
/*//////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 2;
    Spell.iModPerLvl = 1;
    Spell.iImpact = VFX_IMP_DOMINATE_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iLevel, iCreatureHD, iHD, iLowest, iRacialType;
    object oLowest;
    // Create effects.
    effect eDominate = EffectDominated();
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCircle = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eMind, eDominate);
    eLink = EffectLinkEffects (eLink, eDuration);
    // Used to tell the script we have hit this creature already.
    string sSpellLocal = "CONTROL_UNDEAD_" + GetName (Spell.oCaster);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    iHD = Spell.iResult;
    iLowest = iHD + 1;
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCircle, Spell.lTarget);
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
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, oLowest));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, oLowest));
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
