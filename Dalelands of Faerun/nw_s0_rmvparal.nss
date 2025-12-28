/*////////////////////////////////////////////////
 Script: NW_S0_RmvParal
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Healing)
Level:  Clr 2, Pal 2
Components: V, S
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Targets: 1 creature per 4 levels within 30ft.
Duration:   Instantaneous
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

You can free one or more creatures from the effects of any temporary paralysis
or related magic, including a ghoul’s touch or a slow spell. Effects one creature
per four levels of the caster to a maximum of four creatures at 12th level.
The spell does not restore ability scores reduced by penalties, damage, or drain.
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_REMOVE_CONDITION;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 4;
    Spell.iMaxModifier = 4;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iEffectType, iCounter = 0;
    effect eEffect;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eImpactLocation = EffectVisualEffect (VFX_FNF_LOS_HOLY_20);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpactLocation, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    // Also check to make sure we are only doing targets up to the maximum for this caster.
    while(GetIsObjectValid(Spell.oAreaTarget) && iCounter <= Spell.iResult)
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        eEffect = GetFirstEffect (Spell.oAreaTarget);
        while (GetIsEffectValid (eEffect))
        {
            iEffectType = GetEffectType(eEffect);
            //Check if the current effect is paralyzed or slowed.
            if (iEffectType == EFFECT_TYPE_PARALYZE || iEffectType == EFFECT_TYPE_SLOW)
            {
                //Remove the effect and apply VFX impact
                RemoveEffect (Spell.oAreaTarget, eEffect);
                DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                iCounter ++;
            }
            //Get the next effect on the target
            eEffect = GetNextEffect (Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
