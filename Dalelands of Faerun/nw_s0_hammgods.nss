/*////////////////////////////////////////////////
 Scirpt: NW_S0_HammGods
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 4
Innate Level: 4
School: Evocation
Descriptor(s): Divine
Component(s): Verbal, Somatic, Divine Focus
Range: Long
Area of Effect / Target: 100 foot radius.
Duration: Instant
Save: Will Partial
Spell Resistance: Yes

The caster smites a group of enemies with divine light for 1d8 points of damage
for every two caster levels, to a maximum of 5d8.  Enemies that make a Will save
take half damage and avoid being dazed for 1d6 rounds.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_LIGHT;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 100.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 6;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_DIVINE;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_DIVINE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModDicePerLvl = 2;
    Spell.iMaxModNumOfDice = 5;
    Spell.iImpact = VFX_IMP_DIVINE_STRIKE_HOLY;
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
    //Declare major variables
    effect eDamage;
    // Create visual effects
    effect eImpact = EffectVisualEffect (VFX_IMP_DIVINE_STRIKE_HOLY);
    effect eCenter = EffectVisualEffect (VFX_FNF_STRIKE_HOLY);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Create effects
    effect eDaze = EffectDazed ();
    // Link effects
    effect eLink = EffectLinkEffects (eMind, eDaze);
    eLink = EffectLinkEffects (eLink, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        // Failed saving throw.
        if (!Spell.iSaveResult)
        {
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDaze, Spell.oAreaTarget, Spell.fDuration));
        }
        // Check to see if they take damage.
        if (Spell.iResult > 0)
        {
            // Set the damage effect
            eDamage = EffectDamage (Spell.iResult, Spell.iDamageType);
            eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
            // Apply effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDamage, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
