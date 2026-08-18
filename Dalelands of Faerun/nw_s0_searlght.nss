/*////////////////////////////////////////////////
 Script Name: s_SearLght
 Programmer: Keith Soleski
////////////////////////////////////////////////
Caster Level(s): Cleric 3
Innate Level: 3
School: Evocation
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: Single
Duration: Instant
Save: None
Spell Resistance: Yes

The caster directs a beam of white-hot light at a single target.
The damage is based on the target's racial type:
Creature: 1d8 per 2 caster levels, to a maximum of 5d8 divine damage.
Undead: 1d8 per caster level, to a maximum of 10d8 divine damage.
Construct: 1d6 for every 2 caster levels, to a maximum of 5d6 divine damage.

Enchanting:
Weapons and rings gain the light property.
Special: Colored gems can be used to change the color of the light.
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
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_DIVINE;
    Spell.iImpact = VFX_IMP_SUNSTRIKE;
    Spell.iBeam = VFX_BEAM_HOLY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHit;
    effect eDmg, eRay;
    // Create visual effect.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a touch attack to hit.
        iHit = TouchAttackRanged (Spell.oAreaTarget);
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND, !iHit);
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7));
        if (iHit)
        {
            // Check for racial type undead
            if (GetRacialType (Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD)
            {
                Spell.iModNumOfDice = 1;
                Spell.iModifierDie = 8;
                Spell.iModDicePerLvl = 1;
                Spell.iMaxModNumOfDice = 10;
            }
            // Check for racial type construct
            else if (GetRacialType (Spell.oAreaTarget) == RACIAL_TYPE_CONSTRUCT)
            {
                Spell.iModNumOfDice = 1;
                Spell.iModifierDie = 6;
                Spell.iModDicePerLvl = 2;
                Spell.iMaxModNumOfDice = 5;
            }
            // All other creatures.
            else
            {
                Spell.iModNumOfDice = 1;
                Spell.iModifierDie = 8;
                Spell.iModDicePerLvl = 2;
                Spell.iMaxModNumOfDice = 5;
            }
            // Set damage effect, sets Spell.iResult
            Spell = GetModifier (Spell);
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                //Apply the VFX impact and damage effect
                DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
            }
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}

