/*////////////////////////////////////////////////
Script Name: NW_S0_IceStorm
Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Cold]
Level:  Drd 4, Sor/Wiz 4, Water 5
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   Cylinder (20-ft. radius, 40 ft. high)
Duration:   1 full round
Saving Throw:   None
Spell Resistance:   Yes
Great magical hailstones pound down for 1 full round, dealing 3d6 points of
bludgeoning damage and 2d6 + 1d6 per 3 levels (maximum of 5d6 extra damage
of cold damage to every creature in the area.

Arcane Material Component
A pinch of dust and a few drops of water.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_COLD;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_COLD;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 3;
    Spell.iMaxModNumOfDice = 5;
    Spell.iImpact = VFX_IMP_FROST_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    int iBludgeonDmg, iElementalDmg;
    effect eBludgeonDmg, eElementalDmg;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_ICESTORM);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Gets extra elemental damage (1d6 per 3 caster levels).
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            // Get the blugeoning damage.
            iBludgeonDmg = d6(3);
            iElementalDmg = d6(1);
            // Get the result for the effect, sets Spell.iResult.
            //Resolve metamagic for blugeaoning damage.
            if (Spell.iMetaMagic == METAMAGIC_MAXIMIZE)
            {
                iBludgeonDmg = 18;
                iElementalDmg = 12;
            }
            else if (Spell.iMetaMagic == METAMAGIC_EMPOWER)
            {
                iBludgeonDmg = iBludgeonDmg + (iBludgeonDmg / 2);
                iElementalDmg = iElementalDmg + (iElementalDmg / 2);
            }
            // If has Improved Evasion even on a failed reflex save half the result.
            else if (GetHasFeat(FEAT_IMPROVED_EVASION, Spell.oAreaTarget) &&
                     Spell.iSave == SAVING_THROW_REFLEX) Spell.iResult = Spell.iResult / 2;
            // Add the additional elemental damage.
            iElementalDmg = iElementalDmg + Spell.iResult;
            // Set the damage effect
            eBludgeonDmg = EffectDamage (iBludgeonDmg, DAMAGE_TYPE_BLUDGEONING);
            eElementalDmg = EffectDamage (iElementalDmg, Spell.iDamageType);
            // Apply effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eBludgeonDmg, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eElementalDmg, Spell.oAreaTarget));
            // Apply impact effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

