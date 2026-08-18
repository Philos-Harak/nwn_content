/*////////////////////////////////////////////////
 Script: nw_s0_prspells
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Magic 8, Sor/Wiz 8
Components: V, , M
Casting Time:   1 standard action
Range:  Touch
Targets:    Up to one creature touched per four levels
Duration:   10 min./level
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

The subject gains a +8 resistance bonus on saving throws against spells and
spell-like abilities (but not against supernatural and extraordinary abilities).

Material Component: Diamond dust equal to at least 500 gp value, which must be
sprinkled over the targets.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "diamond_dust";
    Spell.sDivineComponent = "diamond_dust";
    Spell.iCompAmount = 20; // 500gp worth of Diamond Dust.
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 8;
    Spell.iImpact = VFX_IMP_MAGIC_PROTECTION;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Get 1 creature per 4 levels then add one for the caster.
    int iCreatures = (Spell.iCasterLevel / 4) + 1;
    if (iCreatures < 1) iCreatures = 1;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eVisual = EffectVisualEffect (VFX_DUR_MAGIC_RESISTANCE);
    // Create effects.
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult, SAVING_THROW_TYPE_SPELL);
    // Link effects.
    effect eLink = EffectLinkEffects (eSave, eDuration);
    eLink = EffectLinkEffects(eLink, eVisual);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Make the spell centered on the caster.
    Spell.lTarget = GetLocation (Spell.oCaster);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Limit the number of creatures effected by the spell, but always do caster.
        if (iCreatures > 0 || Spell.oAreaTarget == Spell.oCaster)
        {
            iCreatures --;
            // Fire spell cast at event for target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Remove any previously cast spell on this target.
            RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
            // Apply VFX impact
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            // Apply the effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
