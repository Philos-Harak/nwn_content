/*////////////////////////////////////////////////
 Scripts: 0s_spiderskin
 Programmer: Philos
////////////////////////////////////////////////
Caster Level(s): Druid 3, Sorcerer/Wizard 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Material, Divine Focus
Range: Touch
Area of Effect / Target: Creature touched
Duration: 10 minutes / level
Save: No
Spell Resistance: No

Spiderskin makes the subject's skin tougher and more like a carapace.
The spell grants the recipient a +1 enhancement bonus to its natural armor
bonus, a +1 racial bonus on saves against poison, and a +1 racial bonus on Hide checks.
Each of these bonuses increases by 1 for every three caster levels above 3rd,
for a maximum of +5 at caster level 12th.

Material Component: A piece of a spider.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 3;
    Spell.iMaxModifier = 5;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nACBonus;
    // Do a special check for enhancing components in one inventory pass.
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        int nEnhancedAmount, nEnhancedLimit, nStack;
        int nAlestoneDust, nJasmalDust;
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
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nJasmalDust = TRUE;
                nACBonus += 1;
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nACBonus)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase AC by +" + IntToString(nACBonus) + "!", COLOR_GREEN, oObject);
        }
        if(fEnhancedDuration > 0.0)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase the duration by +" + FloatToString(fEnhancedDuration * 100.0) + "%!", COLOR_GREEN, oObject);
            Spell.fDuration *= (1.0 + fEnhancedDuration);
        }
    }
    nACBonus += Spell.iResult;
    effect eImpact = EffectVisualEffect (VFX_IMP_HEAD_ODD);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eAC = EffectACIncrease (nACBonus, AC_DEFLECTION_BONUS);
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult, SAVING_THROW_TYPE_POISON);
    effect eHide = EffectSkillIncrease (FEAT_EPIC_SKILL_FOCUS_HIDE, Spell.iResult);
    effect eLink = EffectLinkEffects (eAC, eDuration);
    eLink = EffectLinkEffects (eLink, eSave);
    eLink = EffectLinkEffects (eLink, eHide);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply the effects and VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

