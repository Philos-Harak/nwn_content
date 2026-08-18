/*////////////////////////////////////////////////
 Script: 0s_familyprotect
////////////////////////////////////////////////
Abjuration
Level:  Family Domain power 1
Components: V
Casting Time:   free action
Range:  Personal
Target or Area: Caster
Duration:   1 round/level
Saving Throw: None
Spell Resistance: No

 Family protection creates an aura around the caster giving all within 10'
 +4 dodge to AC.
 Greater family protection creates an aura around the caster giving all within
 10' +4 dodge to AC and all saves.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAOE = EffectAreaOfEffect (52/*VFX_PER_FAMILY_PROTECTION*/);
    eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_10);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
    CleanUpSpell (Spell);
}

