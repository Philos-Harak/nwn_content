/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_shadow
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures that are incorporeal.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    // Shadows do not flee! if(ai_MoralCheck()) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    // ************************  RANGED ATTACKS  *******************************
    object oTarget;
    if(ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            string sIndex;
            if(!nInMelee) oTarget = ai_GetNearestTarget(oCreature);
            else oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else if(ai_SearchForInvisibleCreature(oCreature)) return;
        }
        if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // *************************  MELEE ATTACKS  *******************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        // If we are using our hands then do a touch attack instead.
        if(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND) == OBJECT_INVALID)
        {
            if(GetItemInSlot(INVENTORY_SLOT_CWEAPON_L) != OBJECT_INVALID)
            {
                // Randomize so they don't appear synchronized.
                float fDelay = IntToFloat(Random(2) + 1);
                DelayCommand(fDelay, ActionCastSpellAtObject (769/*Shadow_Attack*/, oTarget, METAMAGIC_ANY, TRUE));
                ai_SetLastAction(oCreature, AI_LAST_ACTION_MELEE_ATK);
                SetLocalObject (oCreature, AI_ATTACKED_PHYSICAL, oTarget);
            }
        }
        else ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForInvisibleCreature(oCreature);
}
