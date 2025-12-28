/*////////////////////////////////////////////////
 Script: 0s_elem_blast
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Level: Innate 10
Components: S
Casting Time:   1 standard action
Range:  Medium
Area: 20-ft.-radius spread
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes

You may make a 20' elelemental blast that does 1d6 elemental damage of your
choosen type once per day. Any creature caught in the blast must make a Reflex
save to take half damage. If they fail the save then they become vulnerable to
your choosen element for 5 rounds.
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 5;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    // Set which spell this is structure variables.
    Spell.iSpellID = GetSpellId ();
    int iFnF;
// Electric Blast
    if (Spell.iSpellID == 912)
    {
        Spell.iDescriptor = DESC_ELECTRICITY;
        Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
        Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
        Spell.iImpact = VFX_IMP_LIGHTNING_M;
        iFnF = VFX_FNF_ELECTRIC_EXPLOSION;
    }
    // Fire Blast
    else if (Spell.iSpellID == 913)
    {
        Spell.iDescriptor = DESC_FIRE;
        Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
        Spell.iDamageType = DAMAGE_TYPE_FIRE;
        Spell.iImpact = VFX_IMP_FLAME_M;
        iFnF = VFX_FNF_FIREBALL;
    }
    // Cold Blast
    else if (Spell.iSpellID == 914)
    {
        Spell.iDescriptor = DESC_COLD;
        Spell.iSaveType = SAVING_THROW_TYPE_COLD;
        Spell.iDamageType = DAMAGE_TYPE_COLD;
        Spell.iImpact = VFX_IMP_FROST_L;
        iFnF = VFX_FNF_ICESTORM;
    }
    // Acid Blast
    else if (Spell.iSpellID == 915)
    {
        Spell.iDescriptor = DESC_ACID;
        Spell.iSaveType = SAVING_THROW_TYPE_ACID;
        Spell.iDamageType = DAMAGE_TYPE_ACID;
        Spell.iImpact = VFX_IMP_ACID_L;
        iFnF = VFX_FNF_GAS_EXPLOSION_ACID;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eVulnerability = EffectDamageImmunityDecrease (Spell.iDamageType, 50);
    effect eFNF = EffectVisualEffect (iFnF);
    effect eDmg;
    //Apply the FNF to the spell location
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eFNF, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event to fire.
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        // Failed the save so do vulnerablility effect.
        if (!Spell.iSaveResult)
        {
            // Apply vulnerablity effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eVulnerability, Spell.oAreaTarget, Spell.fDuration));
        }
        // Do damage if the damage is above 0.
        if (Spell.iResult > 0)
        {
            //Set the damage effect
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply the VFX impact and damage effect
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

