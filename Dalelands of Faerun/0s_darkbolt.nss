/*////////////////////////////////////////////////
 Script: 0s_darkbolt
 Programmer: Philos
////////////////////////////////////////////////
Evocation [Darkness]
Level:  Dark 5
Components: V, S
Casting Time: 1 standard action
Range: Medium
Area: 1 Ray per 2 levels
Duration: Instantaneous
Saving Throw: Will partial
Spell Resistance: Yes

You unleash beams of darkness from your open palm. You must succeed on a ranged
touch attack to strike your target. You can hurl one bolt for every two caster
levels you have (maximum seven bolts). All the bolts are hurled at once, and
your targets must be within 60 feet of each other.
A darkbolt deals 2d8 points of damage to a living creature, and the creature is
dazed for 1 round unless it makes a Will save (a creature struck by multiple
bolts during the same round is dazed for a maximum of 1 round, no matter how
many times it fails its save). An undead creature takes no damage but is dazed if
it fails its save.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DARKNESS;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 60.0f;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 2;
    Spell.iModifierDie = 8;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    Spell.iBeam = VFX_BEAM_BLACK;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iRacialType, iBeams;
    string sTag;
    effect eDmg, eRay;
    // Create effects.
    effect eDazed = EffectDazed ();
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Link effects
    effect eLink = EffectLinkEffects (eDazed, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Get Number of beams.
    iBeams = Spell.iCasterLevel / 2;
    if (iBeams < 1) iBeams = 1;
    if (iBeams > 7) iBeams = 7;
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    // If there are no targets then exit.
    if (!GetIsObjectValid (Spell.oAreaTarget)) return;
    while (iBeams > 0)
    {
        // Remove a beam.
        iBeams --;
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Make resistance check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            iRacialType = GetRacialType (Spell.oAreaTarget);
            // Undead take 0 damage.
            if (iRacialType == RACIAL_TYPE_UNDEAD) Spell.iResult = 0;
            // Get the result for the effect, sets Spell.iResult.
            else Spell = GetModifier (Spell);
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            if (!SavingThrowWithEffects (SAVING_THROW_WILL, Spell.oAreaTarget, Spell.iSaveDC, Spell.iSaveType, Spell.oCaster))
            {
                // Failed save so Daze them.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            }
            // If the ray did damage then apply the damage.
            if (Spell.iResult > 0)
            {
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                //Apply the VFX impact and damage effect
                DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
            }
        }
        // Sets the beam to start from the caster for each beam.
        Spell.oAreaTarget = Spell.oCaster;
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
        // If we have found the last target make sure we use all beams so start again.
        if (!GetIsObjectValid (Spell.oAreaTarget)) Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
