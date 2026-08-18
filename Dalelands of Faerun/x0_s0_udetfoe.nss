/*////////////////////////////////////////////////
 Script: x0_s0_udetfoe
 Pogrammer: Brent
////////////////////////////////////////////////
Caster Level(s): Cleric 9
Innate Level: 9
School: Abjuration
Component(s): Verbal, Somatic, Divine Focus
Range: Long
Area of Effect / Target: Medium
Duration: 1 round / level
Save: None
Spell Resistance: No

All allies in the area of effect will receive the following bonuses: immunity to
negative damage, immunity to level/energy drain, immunity to ability score
decreases, immunity to poisons, immunity to diseases and a +4 deflection bonus
to AC as well as saves.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 1;
    Spell.iModifier = 4;
    Spell.iImpact = VFX_IMP_HOLY_AID;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedAC, nStack;
        int nAlestoneDust, nJasmalDust, nSatinSparDust;
        float fEnhancedDuration;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nAlestoneDust && GetTag(oItem) == "alestone_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nAlestoneDust = TRUE;
                fEnhancedDuration += 0.5;
            }
            else if(!nJasmalDust && GetTag(oItem) == "jasmal_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nJasmalDust = TRUE;
                    nEnhancedAC += 1;
                }
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nEnhancedAC)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase armor bonus by +" + IntToString(nEnhancedAC) + "!", COLOR_GREEN, oObject);
            Spell.iResult += nEnhancedAC;
        }
        if(fEnhancedDuration > 0.0)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase the duration by +" + FloatToString(fEnhancedDuration * 100.0) + "%!", COLOR_GREEN, oObject);
            Spell.fDuration *= 1.0 + fEnhancedDuration;
        }
    }
    // Create effects.
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult);
    effect eAC = EffectACIncrease (Spell.iResult, AC_DEFLECTION_BONUS);
    effect eNegativeDmg = EffectDamageImmunityIncrease (DAMAGE_TYPE_NEGATIVE, 100);
    effect eNegativeLevel = EffectImmunity (IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbDecrease = EffectImmunity (IMMUNITY_TYPE_ABILITY_DECREASE);
    effect ePoison = EffectImmunity (IMMUNITY_TYPE_POISON);
    effect eDisease = EffectImmunity (IMMUNITY_TYPE_DISEASE);
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    effect eCaster = EffectVisualEffect (VFX_IMP_HEAD_HOLY);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Link effects
    effect eLink = EffectLinkEffects(eNegativeDmg, eNegativeLevel);
    eLink = EffectLinkEffects(eLink, eAbDecrease);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, ePoison);
    eLink = EffectLinkEffects(eLink, eDisease);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply vfx at spells center and over caster.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eCaster, Spell.oCaster);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply the effects.
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
