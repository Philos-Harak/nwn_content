/*////////////////////////////////////////////////
 Script: NW_S0_EneDrain
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy
Level:  Cleric 9, Sor/Wiz 9
Components: V, S
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Effect: Ray of negative energy
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   Yes

You point your finger and utter the incantation, releasing a black ray of
crackling negative energy that suppresses the life force of any living creature
it strikes. You must make a ranged touch attack to hit. If the attack succeeds,
and the subject fails a Fortitude save they then gain 2d4 negative levels.

If the subject has at least as many negative levels as HD, it dies.
Each negative level gives a creature a -1 penalty on attack rolls, saving throws,
skill checks, ability checks, and effective level (for determining the power,
duration, DC, and other details of spells or special abilities).
Negative levels stack.

Assuming the subject survives, these negative levels are permanent.
An undead creature struck by the ray gains 1d4×5 temporary hit points for a number
of hours equal to your caster level (maximum 15 hours).
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iMaxDuration = 15;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_TYPE_NONE;
    Spell.iModNumOfDice = 2;
    Spell.iModifierDie = 4;
    Spell.iImpact = VFX_IMP_REDUCE_ABILITY_SCORE;
    Spell.iBeam = VFX_BEAM_BLACK;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Declare variables.
    int iHit;
    effect eDrain, eRay, eHeal, eDeath;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // If the target is undead.
        if (GetRacialType (Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD)
        {
            //Fire cast spell at event for the specified target and make in non-hostile.
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Setup the beam effect to hit.
            eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.0f));
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Create effects heal effect of 2d4 * 5.
            eHeal = EffectTemporaryHitpoints (Spell.iResult * 5);
            //Apply the VFX impact and effects
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHeal, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        // Else the target is not undead.
        else
        {
            //Fire cast spell at event for the specified target and make it hostile.
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make a touch attack to hit.
            iHit = TouchAttackRanged (Spell.oAreaTarget);
            // Setup the beam effect to hit or miss.
            eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND, !iHit);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.0f));
            if (iHit)
            {
                // Make resistance check, no save check.
                Spell = ResistAndSave (Spell);
                if (Spell.iSaveResult != 1 && Spell.iSaveResult != 2 && Spell.iSaveResult != 3)
                {
                    // Get the result for the effect, sets Spell.iResult.
                    Spell = GetModifier (Spell);
                    // Check to see if the creature dies.
                    if (GetCharacterLevels (Spell.oAreaTarget) <= Spell.iResult)
                    {
                        eDeath = EffectDeath ();
                        DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                        DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                    }
                    // else dain levels.
                    else
                    {
                        // Create effects.
                        eDrain = EffectNegativeLevel (Spell.iResult);
                        eDrain = SupernaturalEffect (eDrain);
                        //Apply the VFX impact and effects
                        DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDrain, Spell.oAreaTarget));
                        DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                    }
                }
            }
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
