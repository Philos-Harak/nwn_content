/*////////////////////////////////////////////////
 Script: NW_S0_NatureBal
////////////////////////////////////////////////
Caster Level(s): Druid 8
Innate Level: 8
School: Transmutation
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Large
Duration: 1 round / 3 levels
Save: Will Negates
Spell Resistance: No

All enemies within the area of effect have their spell resistance lowered by 1d4
for every 5 caster levels. All allies within the area of effect are healed for
3d8 Hit Points, +1 point per caster level.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.fAreaSize = 15.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 3;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 5;
    Spell.iImpact = VFX_IMP_HEALING_L;
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
    int iHeal;
    effect eHeal, eSR, eLink;
    // Setup visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eImpact2 = EffectVisualEffect (VFX_IMP_BREACH);
    effect eCenter = EffectVisualEffect (VFX_FNF_NATURES_BALANCE);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Apply spell center vfx effect.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eCenter, GetLocation(OBJECT_SELF));
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Check to see how the caster feels about the targeted object
        if (GetIsFriend (Spell.oAreaTarget))
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            iHeal = d8 (3) + Spell.iCasterLevel;
            //Enter Metamagic conditions
            if (Spell.iMetaMagic == METAMAGIC_MAXIMIZE) iHeal = 24 + Spell.iCasterLevel;
            else if (Spell.iMetaMagic == METAMAGIC_EMPOWER) iHeal = iHeal + iHeal / 2;
            eHeal = EffectHeal (iHeal);
            //Apply heal effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eHeal, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        else if (IsSpellTargetValid (Spell.oAreaTarget, TARGET_TYPE_ENEMIES, Spell.oCaster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Get the result for the effect, sets Spell.iResult.
                Spell = GetModifier (Spell);
                eSR = EffectSpellResistanceDecrease (Spell.iResult);
                eLink = EffectLinkEffects (eSR, eDuration);
                //Apply reduce SR effects
                DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact2, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
