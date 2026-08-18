/*////////////////////////////////////////////////
 Script Name: 0s_circlevsalign
 Programmer:  Preston Watamaniuk
////////////////////////////////////////////////
School: Abjuration
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Single, Medium
Duration: 2 Minutes / Level
Additional Counter Spells:
Save: Harmless
Spell Resistance: No

When this spell is cast, the caster chooses to be protected from either chaos,
law, good or evil. The spell target and all allies within 10 feet receive a +2
deflection bonus to Armor Class, +2 to all saving throws, and immunity to any
mind-affecting spells and spell-like abilities used by creatures of the chosen
alignment.

Enchanting:
Armor, bracers, clothing, and shields gain an armor bonus vs alignment.
Rings and cloaks gain a deflection bonus vs alignment.
Amulets gain a natural armor bonus vs alignment.

Arcane Material Component
A little powdered silver with which you trace a 3-foot diameter circle on the
floor (or ground) around the creature to be warded.
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
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 2;
    Spell.iDurPerLvl = 1;
    int iAOE, iVisual, iImpact, iSpellID = GetSpellId ();
    if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_CHAOS)
    {
        Spell.iDescriptor = DESC_CHAOTIC;
        iAOE = AOE_MOB_CIRCCHAOS;
        iVisual = VFX_DUR_PROTECTION_EVIL_MINOR;
        iImpact = VFX_IMP_EVIL_HELP;
    }
    else if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_EVIL)
    {
        Spell.iDescriptor = DESC_EVIL;
        iAOE = AOE_MOB_CIRCEVIL;
        iVisual = VFX_DUR_PROTECTION_EVIL_MINOR;
        iImpact = VFX_IMP_EVIL_HELP;
    }
    else if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_GOOD)
    {
        Spell.iDescriptor = DESC_GOOD;
        iAOE = AOE_MOB_CIRCGOOD;
        iVisual = VFX_DUR_PROTECTION_GOOD_MINOR;
        iImpact = VFX_IMP_GOOD_HELP;
    }
    else if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_LAW)
    {
        Spell.iDescriptor = DESC_LAWFUL;
        iAOE = AOE_MOB_CIRCLAW;
        iVisual = VFX_DUR_PROTECTION_GOOD_MINOR;
        iImpact = VFX_IMP_GOOD_HELP;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nSaveBonus, nACBonus;
    // Do a special check for enhancing components in one inventory pass.
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        int nEnhancedAmount, nEnhancedLimit, nStack;
        int nAlestoneDust, nCarnelianDust, nCrownOfSilverDust, nJasmalDust;
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
            else if(!nCarnelianDust && GetTag(oItem) == "carnelian_dust" && 
                    Spell.iSpellID == SPELL_PROTECTION_FROM_EVIL)
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nCarnelianDust = TRUE;
                nACBonus += 1;
                nSaveBonus += 1;    
            }
            else if(!nCrownOfSilverDust && GetTag(oItem) == "crown_of_silver_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nCrownOfSilverDust = TRUE;
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
        if(nSaveBonus)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase saving throws by +" + IntToString(nSaveBonus) + "!", COLOR_GREEN, oObject);
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
    nSaveBonus += Spell.iResult;
    SetLocalInt(Spell.oCaster, "0_PROT_AC_BONUS", nACBonus);
    SetLocalInt(Spell.oCaster, "0_PROT_SAVE_BONUS", nSaveBonus);
    // Create area effect.
    effect eAOE = EffectAreaOfEffect (iAOE);
    // Create visual effect.
    effect eVisual = EffectVisualEffect (iVisual);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eImpact = EffectVisualEffect (iImpact);
    // Link effects.
    effect eLink = EffectLinkEffects (eAOE, eVisual);
    eLink = EffectLinkEffects (eLink, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
     //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Create an instance of the AOE Object using the Apply Effect function
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
