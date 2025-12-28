/*////////////////////////////////////////////////
 Script: NW_S0_Stoneskin
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Drd 6, Sor/Wiz 6
Components: V, S, M
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   10 min./level or until discharged
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

The warded creature gains resistance to blows, cuts, stabs, and slashes.
The subject gains damage reduction 20/+5. (It ignores the first
10 points of damage each time it takes damage from a weapon, though an
+5 weapon bypasses the reduction.) Once the spell has prevented a total
of 10 points of damage per caster level (maximum 150 points), it is discharged.

Material Component: Granite and 500 gp worth of diamond dust sprinkled on the
target’s skin.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "0_diamond_dust";
    Spell.sDivineComponent = "0_diamond_dust";
    Spell.iCompAmount = 500;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 10;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 15;
    Spell.iImpact = VFX_IMP_POLYMORPH;
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
    // Create visual effects
    effect eVisual = EffectVisualEffect (VFX_DUR_PROT_STONESKIN);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effect
    effect eStone = EffectDamageReduction (20, DAMAGE_POWER_PLUS_FIVE, Spell.iResult);
    // Link effects
    effect eLink = EffectLinkEffects (eStone, eVisual);
    eLink = EffectLinkEffects(eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Apply effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
