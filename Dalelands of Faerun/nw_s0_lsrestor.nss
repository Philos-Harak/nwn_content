/*////////////////////////////////////////////////
 Script: NW_S0_LsRestor.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Healing)
Level:  Clr 2, Drd 2, Pal 1
Components: V, S
Casting Time:   3 rounds
Range:  Touch
Target: Creature touched
Duration:   Instantaneous
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

Lesser restoration dispels any magical effects reducing one of the subject’s
ability scores. It does not restore permanent ability drain.
/*///////////////////////////////////////////////
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
    Spell.iImpact = VFX_IMP_RESTORATION_LESSER;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
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
            if (GetEffectType(eEffect) == EFFECT_TYPE_ABILITY_DECREASE)
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
