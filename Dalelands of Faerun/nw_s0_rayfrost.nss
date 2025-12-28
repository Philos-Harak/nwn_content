/*////////////////////////////////////////////////
 Script: [NW_S0_RayFrost.nss]
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Cold]
Level:  Sor/Wiz 0
Components: V, S
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Effect: Ray
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   Yes
A ray of freezing air and ice projects from your pointing finger.
The ray deals 1d3 points of cold damage.

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
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_COLD;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 3;
    Spell.iImpact = VFX_IMP_FROST_S;
    Spell.iBeam = VFX_BEAM_COLD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDmg, eRay;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Set damage effect, sets Spell.iResult
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            //Apply the VFX impact and damage effect
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
