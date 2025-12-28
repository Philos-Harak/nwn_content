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
    int nBonus, nDC, nCheck, bDone, bTake20 = TRUE;
    string sResRef, sName;
    object oTarget = GetLocalObject (OBJECT_SELF, "0_target");
    object oItem = GetLocalObject (OBJECT_SELF, "0_item");
    effect eEffect;
    int nHenchman = GetLocalInt (oTarget, PC_ASSOCIATE_TYPE);
    // Check the item for its bonus.
    sName = GetName (oTarget);
    sResRef = GetResRef(oItem);
    if (sResRef == "0_healer_kit_1") nBonus = 1;
    else if (sResRef == "0_healer_kit_2") nBonus = 2;
    else if (sResRef == "0_healer_kit_3") nBonus = 3;
    else if (sResRef == "0_healer_kit_4") nBonus = 4;
    else if (sResRef == "0_healer_kit_5") nBonus = 5;
    else if (sResRef == "0_healer_kit_6") nBonus = 6;
    else if (sResRef == "0_healer_kit_7") nBonus = 7;
    else if (sResRef == "0_healer_kit_8") nBonus = 8;
    else if (sResRef == "0_healer_kit_9") nBonus = 9;
    else if (sResRef == "0_healer_kit_10") nBonus = 10;
    // Check to make sure the target is a creature and not themselves.
    if (GetIsEnemy (oTarget))
    {
        SendMessages ("You must target a friend with this ability.", COLOR_RED, OBJECT_SELF);
    }
    else if (OBJECT_SELF == oTarget)
    {
        SendMessages ("You cannot target yourself with this ability.", COLOR_RED, OBJECT_SELF);
    }
    // Check to see if we can use our skill on them.
    // Do in order... Stabilize, Poison, then Disease.
    else
    {
        // Check to see if we should stabilize them first.
        // If the target is at - hitpoints then use skill.
        int nHp;
        if (GetIsPC (oTarget)) nHp = GetCurrentHitPoints (oTarget);
        else nHp = GetLocalInt (oTarget, "0_Hitpoints");
        if (nHp < 1 && nHp > -10)
        {
            if (nHp < -9)
            {
                SendMessages (GetName (oTarget) + " is dead!", COLOR_RED, OBJECT_SELF);
                return;
            }
            else
            {
                // check to see if they are in combat. If so make a roll!
                if (GetIsInCombat (OBJECT_SELF)) bTake20 = FALSE;
                nDC = HEAL_STABILIZE_DC - nHp;
                nCheck = GetSkillCheck (OBJECT_SELF, SKILL_HEAL, FALSE, nBonus, nDC, TRUE, bTake20);
                if (nCheck >= 0)
                {
                    if (nHenchman == ASSOCIATE_TYPE_HENCHMAN || nHenchman == ASSOCIATE_TYPE_NPC)
                    {
                        SetLocalInt (oTarget, "0_Hitpoints", 1);
                    }
                    else SetLocalInt (oTarget, "0_FirstAid", TRUE);
                    SendMessages ("You have stabilized " + sName + ".", COLOR_GREEN, OBJECT_SELF);
                }
                else SendMessages ("You could not stabilized " + sName + "!", COLOR_RED, OBJECT_SELF);
            }
        }
        // Now check to see if they are poisoned.
        else
        {
            // Check effects for poison and disease.
            // Check to see if they can use this now.
            if (GetLocalInt (OBJECT_SELF, "0_healing_kit"))
            {
                SendMessages ("You have to wait use a healing kit again.", COLOR_RED, OBJECT_SELF);
                return;
            }
            SetLocalInt (OBJECT_SELF, "0_healing_kit", TRUE);
            DelayCommand (FIVE_MINUTE_DELAY, DeleteLocalInt (OBJECT_SELF, "0_healing_kit"));
            int bPoison = FALSE;
            int bDisease = FALSE;
            eEffect = GetFirstEffect (oTarget);
            while (GetIsEffectValid (eEffect) && !bDone)
            {
                if (GetEffectType (eEffect) == EFFECT_TYPE_POISON)
                {
                    bPoison = TRUE;
                    bDone = TRUE;
                }
                else if (GetEffectType (eEffect) == EFFECT_TYPE_DISEASE)
                {
                    bDisease = TRUE;
                    bDone = TRUE;
                }
                else eEffect = GetNextEffect (oTarget);
            }
            if (bPoison)
            {
                // check to see if they are in combat. If so make a roll!
                if (GetIsInCombat (OBJECT_SELF)) bTake20 = FALSE;
                // Make check to see if we can remove the poison.
                nDC = HEAL_POISON_DC + Random (HEAL_POISON_DIE) + 1;
                nCheck = GetSkillCheck (OBJECT_SELF, SKILL_HEAL, FALSE, nBonus, nDC, 1, bTake20);
                if (nCheck >= 0)
                {
                     RemoveEffect (oTarget, eEffect);
                     SendMessages ("You have removed the poison.", COLOR_GREEN, OBJECT_SELF);
                }
                else SendMessages ("You have not removed the poison!", COLOR_RED, OBJECT_SELF);
            }
            // Are they diseased?
            else if (bDisease)
            {
                // check to see if they are in combat. If so make a roll!
                if (GetIsInCombat (OBJECT_SELF)) bTake20 = FALSE;
                // Make check to see if we can remove the poison.
                nDC = HEAL_DISEASE_DC + Random (HEAL_DISEASE_DIE) + 1;
                nCheck = GetSkillCheck (OBJECT_SELF, SKILL_HEAL, FALSE, nBonus, nDC, 1, bTake20);
                if (nCheck >= 0)
                {
                     RemoveEffect (oTarget, eEffect);
                     SendMessages ("You have removed the disease.", COLOR_GREEN, OBJECT_SELF);
                }
                else SendMessages ("You have not removed the disease!", COLOR_RED, OBJECT_SELF);
            }
        }
    }
}
