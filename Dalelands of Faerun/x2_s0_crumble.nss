/*////////////////////////////////////////////////
 Script: X2_S0_Crumble
 Programmer: Georg Zoeller
////////////////////////////////////////////////
Caster Level(s): Druid 6
Innate Level: 6
School: Transmutation
Descriptor(s): Sonic
Component(s): Verbal, Somatic
Range: Medium
Area of Effect / Target: One Construct
Duration: Instantaneous
Save: No
Spell Resistance: No

This spell inflicts 1d6 points of damage per caster level to a selected Construct
(to a maximum of 15d6) by sending specific vibrations through the construct.
This spell does not affect living creatures and ignores magic immunities!
/*///////////////////////////////////////////////
#include "0i_spells"

void DoCrumble (struct stSpell Spell);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_SONIC;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iDamageType = DAMAGE_TYPE_SONIC;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 15;
    Spell.iImpact = 135; /*VFX_IMP_ROCKEXPLODE*/
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iType, iRacial;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        iType = GetObjectType (Spell.oAreaTarget);
        iRacial = GetRacialType (Spell.oAreaTarget);
        if (iType != OBJECT_TYPE_CREATURE) return;
        if (iRacial != RACIAL_TYPE_CONSTRUCT &&
            GetLevelByClass (CLASS_TYPE_CONSTRUCT, Spell.oAreaTarget) == 0) return;
        // Sever the tie between spellId and effect, allowing it to bypass any magic resistance.
        DelayCommand (Spell.fDelay + 0.1f, DoCrumble (Spell));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

//------------------------------------------------------------------------------
// This part is moved into a delayed function in order to allow it to bypass
// Golem Spell Immunity. Magic works by rendering all effects applied
// from within a spellscript useless. Delaying the creation and application of
// an effect causes it to loose it's SpellId, making it possible to ignore
// Magic Immunity. Hacktastic!
//------------------------------------------------------------------------------
void DoCrumble (struct stSpell Spell)
{
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // Create effect.
    effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
    // Create visual effects.
    effect eMissile = EffectVisualEffect (477); /*VFX_FNF_MYSTICAL_EXPLOSION*/
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Apply visual effect for spell.
    effect eShake = EffectVisualEffect (VFX_FNF_SCREEN_SHAKE);
    ApplyEffectToObject (Spell.iDurationType, eShake, Spell.oAreaTarget);
    ApplyEffectToObject(Spell.iDurationType, eImpact, Spell.oAreaTarget);
    ApplyEffectToObject(Spell.iDurationType, eDmg, Spell.oAreaTarget);
    DelayCommand (0.5f, ApplyEffectToObject (Spell.iDurationType, eMissile, Spell.oAreaTarget));
}
