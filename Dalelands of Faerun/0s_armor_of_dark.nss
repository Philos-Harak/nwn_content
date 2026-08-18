/*////////////////////////////////////////////////
 Scripts: 0s_armor_of_dark
 Programmer: Philos
////////////////////////////////////////////////
Caster Level(s): Darkness 4
Innate Level: 4
School: Abjuration
Descriptor(s): Darkness
Component(s): Verbal, Somatic, Divine Focus
Range: Touch
Area of Effect / Target: Creature touched
Duration: 10 minutes / level
Save: No
Spell Resistance: No

The dark shroud grants the subject a +2 deflection bonus to Armor Class plus an
additional +1 for every three caster levels (maximum of +8 at 19th level).
The subject can see through the armor as if it did not exist and is also
afforded darkvision out to 60 feet. The subject gains a +2 saving throw bonus
against any holy, good, or light spells or effects. Undead creatures that are
subjects of armor of darkness also gain +4 turn resistance.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DARKNESS;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModNumOfDice = 2;
    Spell.iModifierDie = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 3;
    Spell.iMaxModifier = 6;
    Spell = SetSpell (Spell);
    if(Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration(Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedAC, nStack;
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
    object oSkin;
    itemproperty ipDarkvision = ItemPropertyDarkvision();
    effect eImpact = EffectVisualEffect(VFX_IMP_HEAD_ODD);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eAC = EffectACIncrease(Spell.iResult, AC_DEFLECTION_BONUS);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2, SAVING_THROW_TYPE_GOOD);
    effect eLink = EffectLinkEffects(eAC, eDuration);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    Spell = GetSpellTarget(Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt(Spell.oCaster, Spell.iSpellID, FALSE));
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply the effects and VFX impact
        DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, Spell.oAreaTarget);
        AddItemProperty(DURATION_TYPE_TEMPORARY, ipDarkvision, oSkin, Spell.fDuration);
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}

