/*////////////////////////////////////////////////
 Script: NW_S0_FlmStrike
 Programmer: Noel Borstad
////////////////////////////////////////////////
Evocation [Fire]
Level:  Clr 5, Drd 4, Sun 5, War 5
Components: V, S, DF
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Area:   Cylinder (10-ft. radius, 40 ft. high)
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes

A flame strike produces a vertical column of divine fire roaring downward.
The spell deals 1d6 points of damage per caster level (maximum 15d6).
Half the damage is fire damage, but the other half results directly from divine
power and is therefore not subject to being reduced by resistance to fire-based
attacks.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iDivineFocus = TRUE;
    Spell.sEnhancingComp = "euclase_dust";
    Spell.iCompAmount = 2; // 50gp worth of Euclase Dust.
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 15;
    Spell.iImpact = VFX_IMP_FLAME_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if (Spell.sEnhancingComp == "TRUE") Spell.iModifier += Spell.iCasterLevel;
    // Declare major variables
    int iElementDamage, iDivineDamage;
    effect eHoly, eElement;
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_IMP_DIVINE_STRIKE_FIRE);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    // Apply the location impact visual to the caster location instead of caster target creature.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Get the spells DC.
            Spell = GetSaveDC (Spell);
            //Adjust the damage based on Reflex Save, Evasion and Improved Evasion
            iDivineDamage = GetReflexAdjustedDamage (Spell.iResult / 2, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_DIVINE);
            if(iDivineDamage > 0)
            {
                eHoly = EffectDamage (iDivineDamage, DAMAGE_TYPE_DIVINE);
                eHoly = SetEffectCasterLevel(eHoly, Spell.iCasterLevel);
                DelayCommand (Spell.fDelay + 0.6, ApplyEffectToObject (DURATION_TYPE_INSTANT, eHoly, Spell.oAreaTarget));
            }
            iElementDamage = GetReflexAdjustedDamage (Spell.iResult / 2, Spell.oAreaTarget, Spell.iSaveDC, Spell.iSaveType);
            if(iElementDamage > 0)
            {
                // Apply effects to the currently selected target.
                eElement = EffectDamage (iElementDamage, Spell.iDamageType);
                eElement = SetEffectCasterLevel(eElement, Spell.iCasterLevel);
                DelayCommand (Spell.fDelay + 0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eElement, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay + 0.6, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
