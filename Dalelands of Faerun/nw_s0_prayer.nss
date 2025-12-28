/*////////////////////////////////////////////////
 Script Name: NW_S0_Prayer
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 3, Paladin 3
Innate Level: 3
School: Conjuration
Component(s): Verbal, Somatic, Divine Focus
Range: Personal
Area of Effect / Target: Caster, Colossal
Duration: 1 Round / Level
Additional Counter Spells: Bestow Curse
Save: Harmless
Spell Resistance: Yes

All allies within the area of effect gain +1 to attack and damage rolls,
skill checks, and saving throws. Enemies receive -1 penalties to the same.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 40.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 1;
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
    // Create positive effects.
    effect eBonAttack = EffectAttackIncrease (Spell.iResult);
    effect eBonSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult);
    effect eBonDam = EffectDamageIncrease (Spell.iResult, DAMAGE_TYPE_SLASHING);
    effect eBonSkill = EffectSkillIncrease (SKILL_ALL_SKILLS, Spell.iResult);
    effect ePosDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link good effects.
    effect ePosLink = EffectLinkEffects (eBonAttack, eBonSave);
    ePosLink = EffectLinkEffects (ePosLink, eBonDam);
    ePosLink = EffectLinkEffects (ePosLink, eBonSkill);
    ePosLink = EffectLinkEffects (ePosLink, ePosDur);
    // Create negative effects.
    effect eNegAttack = EffectAttackDecrease(Spell.iResult);
    effect eNegSave = EffectSavingThrowDecrease(SAVING_THROW_ALL, Spell.iResult);
    effect eNegDam = EffectDamageDecrease(Spell.iResult, DAMAGE_TYPE_SLASHING);
    effect eNegSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, Spell.iResult);
    effect eNegDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    // Link negative effects.
    effect eNegLink = EffectLinkEffects(eNegAttack, eNegSave);
    eNegLink = EffectLinkEffects(eNegLink, eNegDam);
    eNegLink = EffectLinkEffects(eNegLink, eNegSkill);
    eNegLink = EffectLinkEffects(eNegLink, eNegDur);
    // Create visual effects.
    effect ePosVis = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eNegVis = EffectVisualEffect(VFX_IMP_DOOM);
    effect ePoint = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    //Apply Impact
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, ePoint, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        if(GetIsFriend (Spell.oAreaTarget, Spell.oCaster))
        {
            //Signal spell cast at event as friendly.
            SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePosVis, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, ePosLink, Spell.oAreaTarget, Spell.fDuration));
        }
        else if (IsSpellTargetValid (Spell.oAreaTarget, TARGET_TYPE_ALLIES, Spell.oCaster))
        {
            //Signal spell cast at event as hostile.
            SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Apply VFX impact and bonus effects
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eNegVis, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eNegLink, Spell.oAreaTarget, Spell.fDuration));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


