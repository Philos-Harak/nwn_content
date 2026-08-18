/*////////////////////////////////////////////////
 Script: NW_S0_Restore
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Healing)
Level:  Clr
Components: V, S, M
Casting Time:   3 rounds
Range:  Touch
Target: Creature touched
Duration:   Instantaneous
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

This spell functions like lesser restoration, except that it also dispels
negative levels and restores one experience level to a creature who has had a
level drained. The drained level is restored only if the time since the creature
lost the level is equal to or less than one day per caster level. A character
who has a level restored by restoration has exactly the minimum number of
experience points necessary to restore him or her to his or her previous level.

Restoration cures all temporary ability damage, and it restores all points
permanently drained from a single ability score (your choice if more than one is
drained). It also eliminates any fatigue or exhaustion suffered by the target.

Material Component: Diamond dust worth 100 gp that is sprinkled over the target.

� Removes all negative effects unless they come from Poison, Disease or Curses.
/*///////////////////////////////////////////////
#include "0i_spells"

// return TRUE if the effect created by a supernatural force and can't be dispelled by spells
int GetIsSupernaturalCurse(effect eEff);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_HEALING;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sDivineComponent = "diamond_dust";
    Spell.iCompAmount = 4; // 100 gp worth of diamond dust
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_RESTORATION;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Declare variables
    effect eBad;
    // Create visual effects
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        eBad = GetFirstEffect (Spell.oAreaTarget);
        //Search for negative effects
        while(GetIsEffectValid(eBad))
        {
            if (GetEffectType(eBad) == EFFECT_TYPE_ABILITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_AC_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_ATTACK_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_SKILL_DECREASE ||
                GetEffectType(eBad) == EFFECT_TYPE_BLINDNESS ||
                GetEffectType(eBad) == EFFECT_TYPE_DEAF ||
                GetEffectType(eBad) == EFFECT_TYPE_PARALYZE ||
                GetEffectType(eBad) == EFFECT_TYPE_NEGATIVELEVEL)
                {
                    //Remove effect if it is negative.
                    if (!GetIsSupernaturalCurse (eBad)) RemoveEffect (Spell.oAreaTarget, eBad);
                }
            eBad = GetNextEffect (Spell.oAreaTarget);
        }
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

int GetIsSupernaturalCurse(effect eEff)
{
    object oCreator = GetEffectCreator(eEff);
    if(GetTag(oCreator) == "q6e_ShaorisFellTemple")
        return TRUE;
    return FALSE;
}
