/*////////////////////////////////////////////////
 Script: NW_S0_TensTrans
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:  Sor/Wiz 6
Components: V, S, M
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 round/level

You become a virtual fighting machine stronger, tougher, faster, and more skilled
in combat. Your mind-set changes so that you relish combat and you can't cast spells,
even from magic items.

You gain a +4 enhancement bonus to Strength, Dexterity, and Constitution, a +4
natural armor bonus to AC, a +5 competence bonus on Fortitude saves, and proficiency
with all simple and martial weapons. Your base attack bonus equals your character
level (which may give you multiple attacks).

You lose your spellcasting ability, including your ability to use spell trigger
or spell completion magic items, just as if the spells were no longer on your class list.

Material Component
A potion of bull's strength, which you drink (and whose effects are subsumed by the spell effects).
/*///////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_creature"
#include "nwnx_effect"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "p_bullsstrength";
    Spell.iCompAmount = 1;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 4;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
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
    /*/----------------------------------------------------------------------------
     There is a serious problems with creatures turning into unstoppable killer
     machines when affected by tensors transformation. NPC AI can't handle that
     spell anyway, so I added this code to disable the use of Tensors by any NPC.
    *///----------------------------------------------------------------------------
    if (!GetIsPC(OBJECT_SELF))
    {
        WriteTimestampedLogEntry (GetName(OBJECT_SELF) + "[" + GetTag (OBJECT_SELF) +"] tried to cast Tensors Transformation. Bad! Remove that spell from the creature");
        return;
    }
    int nACBonus;
    // Do a special check for enhancing components in one inventory pass.
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        int nEnhancedAmount, nEnhancedLimit, nStack;
        int nAlestoneDust, nCarnelianDust, nCrownOfSilverDust, nJasmalDust;
        float fEnhancedDuration;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nJasmalDust && GetTag(oItem) == "jasmal_dust")
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
    }
    nACBonus += Spell.iResult;
    int nTotalLevels, nEpicBAB;
    object oSkin;
    itemproperty ipFeat = ItemPropertyBonusFeat (IP_CONST_FEAT_WEAPON_PROF_SIMPLE);
    ipFeat = TagItemProperty (ipFeat, "Tensers_Transformation");
    itemproperty ipFeat2 = ItemPropertyBonusFeat (IP_CONST_FEAT_WEAPON_PROF_MARTIAL);
    ipFeat2 = TagItemProperty (ipFeat2, "Tensers_Transformation");
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effects.
    effect eStrength = EffectAbilityIncrease (ABILITY_STRENGTH, Spell.iResult);
    effect eDexterity = EffectAbilityIncrease (ABILITY_DEXTERITY, Spell.iResult);
    effect eConstitution = EffectAbilityIncrease (ABILITY_CONSTITUTION, Spell.iResult);
    effect eFortitude = EffectSavingThrowIncrease (SAVING_THROW_FORT, Spell.iResult + 1);
    effect eAC = EffectACIncrease (nACBonus, AC_NATURAL_BONUS);
    // Link effects.
    effect eLink = EffectLinkEffects (eStrength, eDuration);
    eLink = EffectLinkEffects(eLink, eDexterity);
    eLink = EffectLinkEffects(eLink, eConstitution);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Setup an expire script passing data in a string array.
    // Setup an expire script to remove spells non-effects effects.
    effect eScript = EffectRunScript("", "0s_tenstrans_r");
    // Link the effects
    eFortitude = EffectLinkEffects (eFortitude, eScript);
    eFortitude = SetEffectCasterLevel(eFortitude, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects(Spell.iSpellID, Spell.oAreaTarget);
        ExecuteScript("0s_tenstrans_r", Spell.oAreaTarget);
        // Add attacks.
        nTotalLevels = GetHitDice(Spell.oAreaTarget);
        if(nTotalLevels > 20)
        {
            nEpicBAB = (nTotalLevels - 19) / 2;
            nTotalLevels = 20 + nEpicBAB;
            SetBaseAttackBonus(4, Spell.oAreaTarget);
        }
        NWNX_Creature_SetBaseAttackBonus(Spell.oAreaTarget, nTotalLevels);
        // Add feats.
        oSkin = GetItemInSlot (INVENTORY_SLOT_CARMOUR, Spell.oAreaTarget);
        AddItemProperty (DURATION_TYPE_TEMPORARY, ipFeat, oSkin, Spell.fDuration);
        AddItemProperty (DURATION_TYPE_TEMPORARY, ipFeat2, oSkin, Spell.fDuration);
        //Apply the armor bonuses and the VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eFortitude, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        // Set to keep the caster from casting spells.
        SetLocalInt (OBJECT_SELF, "0_Cannot_Cast", TRUE);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
