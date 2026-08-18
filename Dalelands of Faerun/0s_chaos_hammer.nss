/*////////////////////////////////////////////////
 Script Name: 0s_chaos_hammer
 Programmer: Noel Borstad
////////////////////////////////////////////////
Evocation [Chaotic]
Level:  Chaos 3
Components: V, S
Casting Time: 1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Area:   20-ft.-radius spread
Duration: 1d6 rounds
Saving Throw: Will Partial
Spell Resistance: Yes

Only lawful and neutral (not chaotic) creatures are harmed by the spell.
The spell deals 1d8 points of damage per two caster levels (maximum 5d8) to
lawful creatures (or 1d6 points of damage per caster level, maximum 10d6, to
lawful outsiders) and slows them for 1d6 rounds (see the slow spell).
A successful Will save reduces the damage by half and negates the slow effect.

The spell deals only half damage against creatures who are neither lawful nor
chaotic, and they are not slowed. Such a creature can reduce the damage by half
again (down to one-quarter) with a successful Will save.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_CHAOTIC;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 6;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    int iAlign, iOutsider;
    effect eDmg;
    // Create effect.
    effect eSlow = EffectSlow ();
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_EVIL_20);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eDuration, eSlow);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Get will save DC since we do an external will save.
    Spell = GetSaveDC (Spell);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        iAlign = GetAlignmentLawChaos (Spell.oAreaTarget);
        // Does not effect chaotic creatures.
        if (iAlign != ALIGNMENT_CHAOTIC)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                iOutsider = GetHasFeat (FEAT_RACIAL_TYPE_OUTSIDER, Spell.oAreaTarget);
                if (iAlign == ALIGNMENT_LAWFUL && iOutsider)
                {
                    Spell.iModNumOfDice = 1;
                    Spell.iModifierDie = 6;
                    Spell.iModDicePerLvl = 1;
                    Spell.iMaxModNumOfDice = 10;
                }
                else
                {
                    Spell.iModNumOfDice = 1;
                    Spell.iModifierDie = 8;
                    Spell.iModDicePerLvl = 2;
                    Spell.iMaxModNumOfDice = 5;
                }
                // Get the result for the effect, sets Spell.iResult.
                Spell = GetModifier (Spell);
                if (!WillSave (Spell.oAreaTarget, Spell.iSaveDC))
                {
                    if (iAlign == ALIGNMENT_LAWFUL && iOutsider)
                    {
                        // Get the duration of the spell, sets Spell.fDuration.
                        Spell = GetDuration (Spell);
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                    }
                }
                else Spell.iResult = Spell.iResult / 2;
                if (iAlign == ALIGNMENT_NEUTRAL) Spell.iResult = Spell.iResult / 2;
                // Set the damage effect
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                // Apply effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                // Apply impact effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

