/*////////////////////////////////////////////////
 Script Name: 0s_destructsmite
 Programmer: Philos
////////////////////////////////////////////////
Innate Level: 1
School: Evocation
Component(s): Verbal
Range: Personal
Area of Effect: Caster
Duration: see description
Save: None
Spell Resistance: None

The caster gians +4 to hit and damage of +1/level for the next 2 rounds.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 2;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
    Spell.iImpact = VFX_IMP_HEAD_HOLY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Create effects.
    effect eAttackBonus = EffectAttackIncrease (4);
    effect eDamageBonus = EffectDamageIncrease (Spell.iResult);
    // Link effects.
    effect eLink = EffectLinkEffects (eAttackBonus, eDamageBonus);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Get the result for the effect, sets Spell.iResult.
        //Apply the VFX impact and effect
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

