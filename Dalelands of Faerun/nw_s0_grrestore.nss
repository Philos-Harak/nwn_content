/*////////////////////////////////////////////////
 Script: NW_S0_GrRestore.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Healing)
Level:	Clr 7
Components:	V, S, XP
Casting Time:	10 minutes
Range:	Touch
Target:	Creature touched
Duration:	Instantaneous
Saving Throw:	Will negates (harmless)
Spell Resistance:	Yes (harmless)

It dispels all negative levels afflicting the healed creature. This effect also
reverses level drains by a force or creature, restoring the creature to the
highest level it had previously attained.

Greater restoration also dispels all magical effects penalizing the creature’s
abilities, cures all temporary ability damage, and restores all points permanently
drained from all ability scores. Removes all forms of insanity, confusion, and
similar mental effects.

XP Cost: 500 XP.
/*/////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_HEALING;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_RESTORATION_GREATER;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iEffectType;
    object oCreator;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eEffect;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        eEffect = GetFirstEffect (Spell.oAreaTarget);
        //Search for negative effects
        while (GetIsEffectValid (eEffect))
        {
        iEffectType = GetEffectType(eEffect);
        if (iEffectType == EFFECT_TYPE_ABILITY_DECREASE ||
            iEffectType == EFFECT_TYPE_AC_DECREASE ||
            iEffectType == EFFECT_TYPE_ATTACK_DECREASE ||
            iEffectType == EFFECT_TYPE_DAMAGE_DECREASE ||
            iEffectType == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
            iEffectType == EFFECT_TYPE_SAVING_THROW_DECREASE ||
            iEffectType == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
            iEffectType == EFFECT_TYPE_SKILL_DECREASE ||
            iEffectType == EFFECT_TYPE_BLINDNESS ||
            iEffectType == EFFECT_TYPE_DEAF ||
            iEffectType == EFFECT_TYPE_CURSE ||
            iEffectType == EFFECT_TYPE_DISEASE ||
            iEffectType == EFFECT_TYPE_POISON ||
            iEffectType == EFFECT_TYPE_PARALYZE ||
            iEffectType == EFFECT_TYPE_CHARMED ||
            iEffectType == EFFECT_TYPE_DOMINATED ||
            iEffectType == EFFECT_TYPE_DAZED ||
            iEffectType == EFFECT_TYPE_CONFUSED ||
            iEffectType == EFFECT_TYPE_FRIGHTENED ||
            iEffectType == EFFECT_TYPE_NEGATIVELEVEL ||
            iEffectType == EFFECT_TYPE_PARALYZE ||
            iEffectType == EFFECT_TYPE_SLOW ||
            iEffectType == EFFECT_TYPE_STUNNED)
            {
                //Remove effect if it is negative.
                RemoveEffect (Spell.oAreaTarget, eEffect);
            }
            eEffect = GetNextEffect (Spell.oAreaTarget);
        }
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
