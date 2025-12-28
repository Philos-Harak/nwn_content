/*////////////////////////////////////////////////
 Script: X0_S0_AcidSplash
 Programmer: Brent
////////////////////////////////////////////////
Conjuration (Creation) [Acid]
Level: Sor/Wiz 0
Components: V, S
Casting Time: 1 standard action
Range:  Medium
Effect: One orb of acid
Duration: Instantaneous
Saving Throw: None
Spell Resistance: No

You fire a small orb of acid at the target.
The orb deals 1d3 points of acid damage.
/*///////////////////////////////////////////////

#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.iDescriptor = DESC_ACID;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iDamageType = DAMAGE_TYPE_ACID;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 3;
    Spell.iImpact = VFX_IMP_ACID_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eDmg;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        //Apply the VFX impact and damage effect
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}




