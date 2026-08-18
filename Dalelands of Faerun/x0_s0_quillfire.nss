/*////////////////////////////////////////////////
 Script Name: x0_s0_quillfire
 Programmer: Brent
////////////////////////////////////////////////
Caster Level(s): Druid 3
Innate Level: 3
School: Transmutation
Descriptor(s): Poison
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Single
Duration: Instant
Save: Fortitude Negates (poison only)
Spell Resistance: No

The caster throws poisonous quills at a target, doing 1d8 points of damage (+1
per 2 levels of the caster - max +5), plus inflicting Scorpion Venom on the
target if they fail a Fortitude save.
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
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_POISON;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 2;
    Spell.iMaxModifier = 5;
    Spell.iImpact = VFX_IMP_ACID_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nCnt;
    effect eDmg;
    // Create poison effect.
    effect ePoison = EffectPoison (POISON_LARGE_SCORPION_VENOM);
    ePoison = SetEffectCasterLevel(ePoison, Spell.iCasterLevel);
    // Create visual effect.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Create damage effect.
        eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        // Apply damage effect.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
        // Apply visual effect.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Apply poison effect.
            ApplyEffectToObject (DURATION_TYPE_PERMANENT, ePoison, Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}



