/*////////////////////////////////////////////////
// Cure Light Wounds
// Created By: Brennon Holmes
////////////////////////////////////////////////
    Fires all Cure spell scripts.
    Cure Minor Wounds 1 damage.
    Cure Light Wounds 1d8 +1/level max +5 damage.
    Cure Moderate Wounds 2d8 +1/level max +10 damage.
    Cure Serious Wounds 3d8 +1/level max +15 damage.
    Cure Critical Wounds 4d8 + 1/level max +20 damage.
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
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_POSITIVE;
    Spell.iSaveHalf = TRUE;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_POSITIVE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Do spell effects.
    switch (Spell.iSpellID)
    {
        // Cures 1d4
        case SPELL_CURE_MINOR_WOUNDS:
        {
            Spell.iSaveHalf = FALSE;
            Spell.iMaxModifier = 0;
            Spell.iModNumOfDice = 0;
            Spell.iModifierDie = 0;
            Spell.iModDicePerLvl = 0;
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 4;
            Spell.iModifier = 0;
            Spell.iModPerLvl = 0;
            break;
        }
        // Cures 1d8 + 1 per level up to 5.
        case SPELL_CURE_LIGHT_WOUNDS:
        case 959/*ISA_Cure_Light_Wounds*/:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 5;
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            if (Spell.iSpellID == 959/*Imbue_with_Spell_Ability_CLW*/)
                NWNX_Creature_RemoveFeat (Spell.oCaster, 1547/*FEAT_IWSA_Cast_CLW*/);
            break;
        }
        // Cures 2d8 + 1 per level up to 10.
        case SPELL_CURE_MODERATE_WOUNDS:
        case 960/*ISA_Cure_Moderate_Wounds*/:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 10;
            Spell.iModNumOfDice = 2;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            if (Spell.iSpellID == 960/*Imbue_with_Spell_Ability_CMW*/)
                NWNX_Creature_RemoveFeat (Spell.oCaster, 1548/*FEAT_IWSA_Cast_CMW*/);
            break;
        }
        // Cures 3d8 + 1 per level up to 15
        case SPELL_CURE_SERIOUS_WOUNDS:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 15;
            Spell.iModNumOfDice = 3;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            break;
        }
        // Cures 4d8 + 1 per level up to 20
        case SPELL_CURE_CRITICAL_WOUNDS:
        {
            Spell.iSaveHalf = TRUE;
            Spell.iMaxModifier = 20;
            Spell.iModNumOfDice = 4;
            Spell.iModifierDie = 8;
            Spell.iModDicePerLvl = 0;
            Spell.iModifier = 1;
            Spell.iModPerLvl = 1;
            break;
        }
    }
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nStack;
        int nBluestonesDust, nStarRubyDust, nTopazDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nBluestonesDust && GetTag(oItem) == "blue_stones_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nBluestonesDust = TRUE;
                Spell.iModifier += 1;
            }
            else if(!nStarRubyDust && GetTag(oItem) == "star_ruby_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nStarRubyDust = TRUE;
                }
            }
            else if(!nTopazDust && GetTag(oItem) == "topaz_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nTopazDust = TRUE;
                }
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nBluestonesDust)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced with +1 to each hit dice!", COLOR_GREEN, oObject);
        }
        if(nStarRubyDust)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been maximized!", COLOR_GREEN, oObject);
            Spell.iMetaMagic += METAMAGIC_MAXIMIZE;
        }
        if(nTopazDust)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been Empowered!", COLOR_GREEN, oObject);
            Spell.iMetaMagic += METAMAGIC_EMPOWER;
        }
    }
    CureSpell (Spell, VFX_IMP_NEGATIVE_ENERGY, VFX_IMP_HEALING_S);
    CleanUpSpell (Spell);
}


