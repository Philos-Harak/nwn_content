/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_cntrspell
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the combat mode counter spell.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
//#include "0i_actions"
#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(ai_MoralCheck(oCreature)) return;
    // We are not in melee combat then we don't attack.
    int bAttack = nInMelee;
    // If there are no casters, i.e. CLERIC or MAGES in the battle then attack.
    struct stClasses stClasses = ai_GetFactionsClasses(oCreature);
    if(!stClasses.CLERICS && !stClasses.MAGES) bAttack = TRUE;
    // If we are not attacking then setup for counter spelling.
    if(!bAttack)
    {
        //ai_Debug("ai_cntrspell", "34", " Counterspell Mode? " +
        //          IntToString(GetActionMode(OBJECT_SELF, ACTION_MODE_COUNTERSPELL)));
        if(!GetActionMode(oCreature, ACTION_MODE_COUNTERSPELL))
        {
            object oTarget = ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER);
            // We can only counter spells from a hasted caster if we are hasted as well.
            if(ai_GetHasEffectType(oTarget, EFFECT_TYPE_HASTE) &&
                !ai_GetHasEffectType(oCreature, EFFECT_TYPE_HASTE))
            {
                // If we have haste then we should cast it.
                if(GetHasSpell(SPELL_HASTE, oCreature))
                {
                    ActionCastSpellAtObject(SPELL_HASTE, OBJECT_SELF);
                    ai_SetLastAction(oCreature, SPELL_HASTE);
                    return;
                }
                // If not then we need to go into normal combat.
                else bAttack = TRUE;
            }
            if(oTarget != OBJECT_SELF && !bAttack)
            {
                // First a good tactic for counter spelling is to be invisible.
                if(ai_TryToBecomeInvisible(oCreature)) return;
                // If we have attempted to become invisible or are invisible then
                // it is time to counter spell.
                //ai_Debug("ai_cntrspell", "57", "Setting Counterspell mode!");
                ActionCounterSpell(oTarget);
            }
        }
        // We are just going to stay back so set our action as if we cast a spell.
        // ai_CheckCombatMovement() to keep us 8 meters + from the nearest enemy.
        ai_SetLastAction(oCreature, 0);
    }
    // Here is where we have the attack code.
    if(bAttack)
    {
        int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
        //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
        // Check the battlefield for a group of enemies to shoot a big talent at!
        // We are checking here since these opportunities are rare and we need
        // to take advantage of them as often as possible.
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
        //****************************  SKILL FEATURES  ****************************
        if(ai_TryAnimalEmpathy(oCreature)) return;
        //****************************  CLASS FEATURES  ****************************
        if(ai_TryBardSongFeat(oCreature)) return;
        if(ai_TryTurningTalent(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
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
                // Lets pick off the nearest targets.
                if(!nInMelee) oTarget = ai_GetNearestTarget(oCreature);
                else oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget != OBJECT_INVALID)
                {
                    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                    return;
                }
                else
                {
                    ai_SearchForInvisibleCreature(oCreature);
                    return;
                }
            }
            if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
        }
        // *************************  MELEE ATTACKS  *******************************
        if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
        oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee, FALSE);
        // If we have a target so lets see what our options are.
        if(oTarget != OBJECT_INVALID)
        {
            // If we are not getting attacked then we might want to move back.
            if(ai_GetEnemyAttackingMe(oCreature) == OBJECT_INVALID)
            {
                object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
                ai_Debug("ai_cntrspell", "111", "oNearestEnemy: " + GetName(oNearestEnemy) + " fDistance: " + FloatToString(GetDistanceToObject(oNearestEnemy), 0, 2));
                // If we cast a spell last round or are using a bow then lets move back.
                if((GetLocalInt(oCreature, sLastActionVarname) > -1 ||
                     ai_HasRangedWeaponWithAmmo(oCreature)) &&
                     GetDistanceBetween(oCreature, oNearestEnemy) < AI_RANGE_CLOSE)
                {
                    ai_Debug("ai_cntrspell", "117", GetName(oCreature) +
                              " is moving away from " + GetName(oTarget));
                    ai_SetLastAction(oCreature, AI_LAST_ACTION_NONE);
                    ActionMoveAwayFromObject(oNearestEnemy, TRUE, AI_RANGE_CLOSE);
                    return;
                }
            }
            ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
        }
        // We do not have a target probably due to them being to strong so lets do nothing!
        else ai_SetLastAction(oCreature, AI_LAST_ACTION_NONE);
    }
}
