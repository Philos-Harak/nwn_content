/*//////////////////////////////////////////////////////////////////////////////
 Script Name: ai_a_peaceful
////////////////////////////////////////////////////////////////////////////////
 ai script mode for associates to use when they should remain out of combat.
 OBJECT_SELF is the creature running the ai.
////////////////////////////////////////////////////////////////////////////////
 Programmer: Philos
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    float fDistance = GetDistanceBetween(oCreature, oNearestEnemy);
    // In Melee combat!
    if(nInMelee > 0)
    {
        // If we are not being attacked then we should back out of combat.
        if(ai_GetEnemyAttackingMe(oCreature) == OBJECT_INVALID)
        {
            if(AI_DEBUG) ai_Debug("ai_a_peaceful", "23", GetName(oCreature) + " is moving away from " + GetName(oNearestEnemy) +
                         "[" + FloatToString(AI_RANGE_MELEE - fDistance + 1.0, 0, 2) + "]" + " to use a ranged weapon.");
            ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
            // Lets move just out of melee range!
            int bRun = ai_CanIMoveInCombat(oCreature);
            ActionMoveAwayFromObject(oNearestEnemy, bRun, AI_RANGE_CLOSE + 2.0);
            ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
            return;
        }
        if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
        if(ai_TryImprovedExpertiseFeat(oCreature)) return;
        if(ai_TryExpertiseFeat(oCreature)) return;
        // Lets get the strongest melee opponent in melee with us.
        object oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
        if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
        // Use knockdown when appropriate and the target is not immune.
        if(ai_TryKnockdownFeat(oCreature, oTarget)) return;
        if (ai_TryParry(oCreature)) return;
        // We have tried everything to protect ourselves so the only thing left
        // to do is man up and attack!
        // Physical attacks are under TALENT_CATEGORY_HARMFUL_MELEE(22).
        ai_DoPhysicalAttackOnNearest(oCreature, nInMelee);
        return;
    }
    if(fDistance <= AI_RANGE_LONG)
    {
        if(AI_DEBUG) ai_Debug("ai_a_peaceful", "49", GetName(oCreature) + " is moving away from " + GetName(oNearestEnemy) +
                     "[" + FloatToString(AI_RANGE_LONG - fDistance, 0, 2) + "]" + ".");
        ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
        // Lets move out of close range!
        ActionMoveAwayFromObject(oNearestEnemy, TRUE, AI_RANGE_LONG + 2.0);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        return;
    }
    //*************************  OUT OF COMBAT  **************************
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC);
    if(bUseMagic)
    {
        //***************************  HEALING & CURES  ****************************
        if(ai_TryHealingTalent(oCreature, 0, oCreature)) return;
        if(ai_TryCureConditionTalent(oCreature, 0)) return;
        //**************************  DEFENSIVE TALENTS  ***************************
        // If can turn invisible then we should probably do that!
        if(ai_UseTalent(oCreature, SPELL_IMPROVED_INVISIBILITY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_INVISIBILITY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_INVISIBILITY_SPHERE, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_SANCTUARY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_ETHEREALNESS, oCreature)) return; // Greater Sanctuary
        if(ai_UseTalent(oCreature, SPELLABILITY_AS_IMPROVED_INVISIBLITY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELLABILITY_AS_INVISIBILITY, oCreature)) return;
        int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
        // Summons are powerfull and should be used as much as possible.
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_SUMMON, nInMelee, nMaxLevel)) return;
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_PROTECTION, nInMelee, nMaxLevel)) return;
    }
    // Stand and watch the battle we don't want to provoke anyone!
    if(AI_DEBUG) ai_Debug("ai_a_peaceful", "80", GetName(oCreature) + " is holding here.");
}
