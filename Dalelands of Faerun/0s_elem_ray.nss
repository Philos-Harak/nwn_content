/*////////////////////////////////////////////////
 Script: 0s_elem_ray
 Programmer: Philos
////////////////////////////////////////////////
Evocation [VARIES]
Level: Innate 5
Components: S
Casting Time: 1 standard action
Range:  Medium
Effect: One ray of choosen element
Duration: Instantaneous
Saving Throw: None
Spell Resistance: No

You may shoot an elemental ray once per day. The sorcerer must make a touch attack
up to 30' away and does 1d6 + 1/2 sorcerer levels in elemental damage on a successful hit.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iClass = CLASS_TYPE_SORCERER;
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 2;
    // Set which spell this is structure variables.
    Spell.iSpellID = GetSpellId ();
    // Electric Ray
    if (Spell.iSpellID == 908)
    {
        Spell.iDescriptor = DESC_ELECTRICITY;
        Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
        Spell.iImpact = VFX_IMP_LIGHTNING_S;
        Spell.iBeam = VFX_BEAM_LIGHTNING;
    }
    // Fire Ray
    else if (Spell.iSpellID == 909)
    {
        Spell.iDescriptor = DESC_FIRE;
        Spell.iDamageType = DAMAGE_TYPE_FIRE;
        Spell.iImpact = VFX_IMP_FLAME_S;
        Spell.iBeam = VFX_BEAM_FIRE;
    }
    // Cold Ray
    else if (Spell.iSpellID == 910)
    {
        Spell.iDescriptor = DESC_COLD;
        Spell.iDamageType = DAMAGE_TYPE_COLD;
        Spell.iImpact = VFX_IMP_FROST_S;
        Spell.iBeam = VFX_BEAM_COLD;
    }
    // Acid Ray
    else if (Spell.iSpellID == 911)
    {
        Spell.iDescriptor = DESC_ACID;
        Spell.iDamageType = DAMAGE_TYPE_ACID;
        Spell.iImpact = VFX_IMP_ACID_S;
        Spell.iBeam = VFX_BEAM_DISINTEGRATE;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHit;
    effect eDmg, eRay;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a touch attack to hit.
        iHit = TouchAttackRanged (Spell.oAreaTarget);
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND, !iHit);
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7));
        if (iHit)
        {
            // Get the modifier for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                //Apply the VFX impact and damage effect
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            }
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}




