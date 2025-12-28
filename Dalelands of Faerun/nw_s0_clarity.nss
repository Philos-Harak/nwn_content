/*////////////////////////////////////////////////
 Script: NW_S0_Clarity
////////////////////////////////////////////////
Caster Level(s): Bard 2, Cleric 3, Wizard / Sorcerer 3
Innate Level: 2
School: Necromancy
Descriptor(s): Mind-Affecting
Component(s): Somatic
Range: Medium
Area of Effect / Target: Single
Duration: 5 Rounds + 1 Round / Level
Additional Counter Spells: Charm Person
Save: No
Spell Resistance: No

This spell removes the effects of Daze, Sleep, Confusion, Stun, and Charm, and
protects against all mind-affecting effects until it expires. For every effect
removed by the spell, the target creature sustains 1 point of damage.

Enchanting:
Helmets gain a saving throw bonus vs mind spells.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 5;
    Spell.iDurationDie = 1;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImm1 = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
    effect eVis = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects (eImm1, eVis);
    eLink = EffectLinkEffects (eLink, eDur);
    effect eSearch, eDmg;
    int iValid, iDamage;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Search through effects
        eSearch = GetFirstEffect (Spell.oAreaTarget);
        while (GetIsEffectValid (eSearch))
        {
            iValid = FALSE;
            //Check to see if the effect matches a particular type defined below
            if (GetEffectType(eSearch) == EFFECT_TYPE_DAZED) iValid = TRUE;
            else if(GetEffectType(eSearch) == EFFECT_TYPE_CHARMED) iValid = TRUE;
            else if(GetEffectType(eSearch) == EFFECT_TYPE_SLEEP) iValid = TRUE;
            else if(GetEffectType(eSearch) == EFFECT_TYPE_CONFUSED) iValid = TRUE;
            else if(GetEffectType(eSearch) == EFFECT_TYPE_STUNNED) iValid = TRUE;
            //Apply damage and remove effect if the effect is a match and add a point of damage.
            if (iValid == TRUE)
            {
                RemoveEffect(Spell.oAreaTarget, eSearch);
                iDamage = iDamage + 1;
            }
            eSearch = GetNextEffect (Spell.oAreaTarget);
        }
        // If we removed any effects then apply the damage.
        if (iDamage > 0)
        {
            eDmg = EffectDamage (iDamage, DAMAGE_TYPE_NEGATIVE);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
        }
        //After effects are removed we apply the immunity to mind spells to the target
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

