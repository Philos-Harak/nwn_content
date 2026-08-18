//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: ac_0_healer_kit
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Activate item script for Healer's Kits.
 Used to stabilize, cure poisons, and diseases.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 3/29/15
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
#include "0i_master"
#include "0i_creature"
void main()
{
    string sUserName = "You have";
    object oPC, oUser = OBJECT_SELF;
    if(!GetIsCharacter(oUser)) 
    {
        oPC = GetPlayerMaster(oUser);
        sUserName = GetName(oUser);
    }
    else oPC = oUser;
    object oTarget = GetLocalObject(oUser, "0_target");
    // Check to make sure the target is not an enemy.
    if(GetIsEnemy(oTarget)) 
    {
        if(oPC == oUser) SendMessages ("You must target a friend with this ability.", COLOR_RED, OBJECT_SELF);
        else SendMessages (GetName(oUser) + " must target a friend with this ability.", COLOR_RED, OBJECT_SELF);
        return;
    }
    string sTargetName = GetName (oTarget);
    // Set a 5 minute cooldown on using healing kits on the same target.
    string sVariableName = "0_healing_kit" + RemoveIllegalCharacters(GetName(oUser));
    if(DifferenceInCalendarDates(GetCurrentDateTimeInMinutes(), GetLocalInt(oTarget, sVariableName)) < 5)
    {
        SendMessages(sUserName + " to wait to use a healing kit again on " + sTargetName + ".", COLOR_RED, oPC);
        return;
    }
    else DeleteLocalInt(oTarget, sVariableName);
    SetLocalInt(oTarget, sVariableName, GetCurrentDateTimeInMinutes());
    object oItem = GetLocalObject(oUser, "0_item");
    effect eEffect;
    int nBonus, nDC, nCheck;
    int bTake20 = TRUE;
    int nHenchman = GetLocalInt(oTarget, PC_ASSOCIATE_TYPE);
    // Check the item for its bonus.
    string sResRef = GetResRef(oItem);
    if(sResRef == "0_healer_kit_1") nBonus = 1;
    else if(sResRef == "0_healer_kit_2") nBonus = 2;
    else if(sResRef == "0_healer_kit_3") nBonus = 3;
    else if(sResRef == "0_healer_kit_4") nBonus = 4;
    else if(sResRef == "0_healer_kit_5") nBonus = 5;
    else if(sResRef == "0_healer_kit_6") nBonus = 6;
    else if(sResRef == "0_healer_kit_7") nBonus = 7;
    else if(sResRef == "0_healer_kit_8") nBonus = 8;
    else if(sResRef == "0_healer_kit_9") nBonus = 9;
    else if(sResRef == "0_healer_kit_10") nBonus = 10;
    // Check to see if we should stabilize them first.
    // If the target is at - hitpoints then use skill.
    int nHp;
    if(GetIsPC(oTarget)) nHp = GetCurrentHitPoints(oTarget);
    else nHp = GetLocalInt(oTarget, "0_Hitpoints");
    if(nHp < 1)
    {
        if(nHp < -9)
        {
            SendMessages(sTargetName + " is dead!", COLOR_RED, oPC);
            return;
        }
        else
        {
            // check to see if they are in combat. If so make a roll!
            bTake20 = !GetIsInCombat(OBJECT_SELF);
            nDC = HEAL_STABILIZE_DC - nHp;
            nCheck = GetSkillCheck(oUser, SKILL_HEAL, FALSE, nBonus, nDC, TRUE, bTake20);
            if(nCheck >= 0)
            {
                if(nHenchman == ASSOCIATE_TYPE_HENCHMAN || nHenchman == ASSOCIATE_TYPE_NPC)
                {
                    SetLocalInt(oTarget, "0_Hitpoints", 1);
                }
                else SetLocalInt(oTarget, "0_FirstAid", TRUE);
                SendMessages(sUserName + " stabilized " + sTargetName + ".", COLOR_GREEN, oPC);
            }
            else SendMessages(sUserName + " not stabilized " + sTargetName + "!", COLOR_RED, oPC);
        }
    }
    // Now check to see if they are poisoned or diseased.
    else
    {
        int bPoison = FALSE;
        int bDisease = FALSE;
        eEffect = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eEffect))
        {
            if(GetEffectType(eEffect) == EFFECT_TYPE_POISON)
            {
                bPoison = TRUE;
                break;
            }
            else if(GetEffectType(eEffect) == EFFECT_TYPE_DISEASE)
            {
                bDisease = TRUE;
                break;
            }
            else eEffect = GetNextEffect(oTarget);
        }
        if(bPoison || bDisease)
        {
            string sCondition = bPoison ? "poison" : "disease";
            // check to see if they are in combat. If so make a roll!
            bTake20 = !GetIsInCombat(OBJECT_SELF);
            // Make check to see if we can remove the poison.
            if(bPoison) nDC = HEAL_POISON_DC + Random(HEAL_POISON_DIE) + 1;
            else nDC = HEAL_DISEASE_DC + Random(HEAL_DISEASE_DIE) + 1;
            nCheck = GetSkillCheck(OBJECT_SELF, SKILL_HEAL, FALSE, nBonus, nDC, 1, bTake20);
            if(nCheck >= 0)
            {
                RemoveEffect(oTarget, eEffect);
                SendMessages(sUserName + " removed the " + sCondition + ".", COLOR_GREEN, oPC);
            }
            else SendMessages(sUserName + " failed to remove the " + sCondition + "!", COLOR_RED, oPC);
        }
        // If they are not bleeding, poisoned, or diseased then set them for healing when they rest.
        else if(nHp < GetMaxHitPoints(oTarget)) 
        {
            SetLocalInt(oTarget, "0_Healing_Kit_Resting", TRUE);
            SendMessages(sUserName + " treated " + sTargetName + " with bandages. They will heal faster when they rest.", COLOR_GREEN, oPC);
        }
        else SendMessages(sTargetName + " has nothing that can be treated!", COLOR_RED, oPC);
    }
}
