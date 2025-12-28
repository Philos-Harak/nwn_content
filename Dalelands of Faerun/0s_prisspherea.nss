/*////////////////////////////////////////////////
 Prismatic Sphere: On Enter
 Created By: Philos
////////////////////////////////////////////////
    Enemies of the caster suffer multiple effects on entering.
      Color     Effect
1     Red     20 points fire damage (Reflex half)
2     Orange  40 points acid damage (Reflex half)
3     Yellow  80 points electricity damage (Reflex half)
4     Green   Poison (Kills or DC:20, Take Constitution damage)
5     Blue    Turned to stone (Fortitude negates)
6     Indigo  Insane, as insanity spell (Will negates)
7     Violet  Death (Will negates)
/*///////////////////////////////////////////////
#include "0i_spells"
void DoRedColor (struct stSpell Spell)
{
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iSaveType = SAVING_THROW_TYPE_FIRE;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iResult = 20;
    Spell = ResistAndSave (Spell);
    if (Spell.iResult > 0)
    {
        effect eImpact = EffectVisualEffect (VFX_IMP_FLAME_M);
        effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
    }
}
void DoOrangeColor (struct stSpell Spell)
{
    if (GetIsDead (Spell.oAreaTarget)) return;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iSaveType = SAVING_THROW_TYPE_ACID;
    Spell.iDamageType = DAMAGE_TYPE_ACID;
    Spell.iResult = 40;
    Spell = ResistAndSave (Spell);
    if (Spell.iResult > 0)
    {
        effect eImpact = EffectVisualEffect (VFX_IMP_ACID_L);
        effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
    }
}
void DoYellowColor (struct stSpell Spell)
{
    if (GetIsDead (Spell.oAreaTarget)) return;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
    Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
    Spell.iResult = 80;
    Spell = ResistAndSave (Spell);
    if (Spell.iResult > 0)
    {
        effect eImpact = EffectVisualEffect (VFX_IMP_LIGHTNING_S);
        effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
    }
}
void DoGreenColor (struct stSpell Spell)
{
    if (GetIsDead (Spell.oAreaTarget)) return;
    effect eImpact = EffectVisualEffect (VFX_IMP_POISON_L);
    effect ePoison = EffectPoison (45/*PRISMATIC_POISON*/);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, ePoison, Spell.oAreaTarget);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
}
void DoBlueColor (struct stSpell Spell)
{
    if (GetIsDead (Spell.oAreaTarget)) return;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveHalf = FALSE;
    Spell.iSaveType = SAVING_THROW_TYPE_NONE;
    Spell = ResistAndSave (Spell);
    if (!Spell.iSaveResult) ApplyPetrificationEffect (Spell);
}
void DoIndigoColor (struct stSpell Spell)
{
    if (GetIsDead (Spell.oAreaTarget)) return;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveHalf = FALSE;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell = ResistAndSave (Spell);
    if (!Spell.iSaveResult) ApplyInsanityEffect (Spell);
}
void DoVioletColor (struct stSpell Spell)
{
    if (GetIsDead (Spell.oAreaTarget)) return;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveHalf = FALSE;
    Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    Spell = ResistAndSave (Spell);
    if (!Spell.iSaveResult)
    {
        effect eImpact = EffectVisualEffect (VFX_IMP_DEATH_L);
        effect eDeath = EffectDeath ();
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
    }
}
void main()
{
    struct stSpell Spell;
    Spell.oAreaTarget = GetEnteringObject ();
    Spell.oCaster = GetAreaOfEffectCreator ();
    Spell.iSpellResistance = TRUE;
    Spell = GetAreaOfEffectSpellVariables (50, Spell);
    SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, 961/*Prismatic_Sphere*/));
    if (GetIsEnemy (Spell.oAreaTarget, Spell.oCaster))
    {
        DoRedColor (Spell);
        DelayCommand (1.0f, DoOrangeColor (Spell));
        DelayCommand (2.0f, DoYellowColor (Spell));
        DelayCommand (3.0f, DoGreenColor (Spell));
        DelayCommand (4.0f, DoBlueColor (Spell));
        DelayCommand (5.0f, DoIndigoColor (Spell));
        DelayCommand (6.0f, DoVioletColor (Spell));
    }
}
