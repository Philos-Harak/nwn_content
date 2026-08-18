/*////////////////////////////////////////////////
 Script:0s_prissphere
 Programmer: Philos
////////////////////////////////////////////////
Abjuration
Level:  Sor/Wiz 9
Components: V
Casting Time: 1 standard action
Range:  Personal.
Area:   10ft area around caster
Duration: 10 min / level
Saving Throw: See text
Spell Resistance: Yes

This spell conjures up an immobile multicolored sphere that you can walk in and
out of at will. While in the sphere you are protected and your enemies that
attempt to pass through the sphere suffer the effects of each color one at a time.

      Color     Effect
1     Red     20 points fire damage (Reflex half)
2     Orange  40 points acid damage (Reflex half)
3     Yellow  80 points electricity damage (Reflex half)
4     Green   Poison (Kills or DC:20, Take Constitution damage)
5     Blue    Turned to stone (Fortitude negates)
6     Indigo  Insane, as insanity spell (Will negates)
7     Violet  Death (Will negates)
/*/////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAOE = EffectAreaOfEffect (50/*VFX_PRISMATIC_SPHERE*/);
    eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_20);
    Spell = GetSaveDC (Spell);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    ApplyEffectAtLocation (Spell.iDurationType, eAOE, GetLocation (Spell.oCaster), Spell.fDuration);
    SetAreaOfEffectSpellVariables (50, Spell);
    CleanUpSpell (Spell);
}

