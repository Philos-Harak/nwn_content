/*////////////////////////////////////////////////
 Script: x0_s0_shield.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Abjuration [Force]
Level:  Sor/Wiz 1
Components: V, S
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 min./level (D)
Shield creates an invisible, tower shield-sized mobile disk of force that hovers
in front of you. It negates magic missile attacks directed at you. The disk also
provides a +4 shield bonus to AC. The shield has no armor check penalty or
arcane spell failure chance. Unlike with a normal tower shield, you can�t use
the shield spell for cover.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FORCE;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 4;
    Spell.iImpact = VFX_IMP_AC_BONUS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
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
            else if(!nSatinSparDust && GetTag(oItem) == "satin_spar_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nSatinSparDust = TRUE;
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
    effect eArmor, eLink;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eSpell = EffectSpellImmunity (SPELL_MAGIC_MISSILE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Create effects and link.
        eArmor = EffectACIncrease(Spell.iResult, AC_DEFLECTION_BONUS);
        eLink = EffectLinkEffects(eArmor, eDur);
        eLink = EffectLinkEffects(eLink, eSpell);
        eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
        //Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}



