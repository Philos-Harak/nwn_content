/*////////////////////////////////////////////////
 Script: NW_S0_NegRay
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 2, Wizard / Sorcerer 1
Innate Level: 1
School: Necromancy
Descriptor(s): Negative
Component(s): Verbal, Somatic, Material
Range: Medium
Area of Effect / Target: Single
Duration: Instant
Additional Counter Spells:
Save: Will 1/2
Spell Resistance: Yes

A ray of negative energy projects from your pointing finger. You must succeed at
a ranged touch attack with the ray to deal damage to a target. The ray deals 1d6
points of damage to a living creature. For every two extra levels of experience
past 1st, you deal an extra 1d6 points of damage. You deal 2d6 at 3rd level,
3d6 at 5th level, 4d6 at 7th level, and a maximum of 5d6 points of damage at
9th level or higher.
Since undead are powered by negative energy, this spell cures them of a like
amount of damage, rather than harming them.

Material Component: A mirror, which you break.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_NEGATIVE;
    Spell.iSaveHalf = TRUE;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_NEGATIVE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 2;
    Spell.iImpact = VFX_IMP_NEGATIVE_ENERGY;
    Spell.iBeam = VFX_BEAM_EVIL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHit, iHeal;
    effect eVis = EffectVisualEffect(Spell.iImpact);
    effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eRay, eDmg, eHeal;
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // If the target is not undead.
        if (GetRacialType (Spell.oAreaTarget) != RACIAL_TYPE_UNDEAD)
        {
            // If beam is positive then heal.
            if (Spell.iDamageType == DAMAGE_TYPE_POSITIVE) iHeal = TRUE;
            else iHeal = FALSE;
        }
        // Target is undead.
        else
        {
            // If beam is negative then heal.
            if (Spell.iDamageType == DAMAGE_TYPE_NEGATIVE) iHeal = TRUE;
            else iHeal = FALSE;
        }
        // Try to hit and damage target.
        if (!iHeal)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make a touch attack to hit.
            iHit = TouchAttackRanged (Spell.oAreaTarget);
            eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND, !iHit);
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7));
            if (iHit)
            {
                // Roll for damage.
                Spell = GetModifier (Spell);
                // Make resistance and save check.
                Spell = ResistAndSave (Spell);
                if (Spell.iResult > 0)
                {
                    eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
                    eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                    //Apply the VFX impact and effects
                    DelayCommand (Spell.fDelay + 0.5, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay + 0.5, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
                }
            }
        }
        // We heal the target.
        else
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
            eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7));
            // Roll for damage.
            Spell = GetModifier (Spell);
            eHeal = EffectHeal (Spell.iResult);
            DelayCommand (Spell.fDelay + 0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisHeal, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay + 0.5, ApplyEffectToObject(Spell.iDurationType, eHeal, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
