/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_ambusher
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates to ambush creatures.
 OBJECT_SELF is the creature running the ai.
 Our plan...
 1 - Get nearest enemy and difficulty of the battle.
 2 - If we have been seen and we tried to hide and are not in melee then move away.
 3 - We have not been seen or tried to hide so lets hide.
 4 - We have been seen so lets drop out of stealth.
 5 - Check for healing potions if this is a simple+ battle.
 6 - Check moral if wounded and is a simple+ battle.
 7 - Check for a magical ranged attack if not in melee and a difficult+ battle.
 8 - Check for a buff if this is a difficult+ battle.
 9 - Check for a Class ability and an offensive spell if this is a simple+ battle.
 10 - Do a physical attack.
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
    // Check the battle field to see if anyone see us?
    int nEnemyIndex = ai_GetNearestIndexThatSeesUs(oCreature);
    int bTried = GetLocalInt(oCreature, "AI_TRIED_TO_HIDE");
    // If seen, tried to hide and out of combat then lets move away!
    if(nEnemyIndex)
    {
        string sEnemyIndex = IntToString(nEnemyIndex);
        object oEnemy = GetLocalObject(oCreature, AI_ENEMY + sEnemyIndex);
        float fEnemyDistance = GetLocalFloat(oCreature, AI_ENEMY + sEnemyIndex);
        if(bTried && !GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, oCreature) && fEnemyDistance > AI_RANGE_CLOSE)
        {
            //ai_Debug("ai_ambusher", "39", GetName(oCreature) + " is trying to move away to hide!");
            // Move away so we can hide.
            SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            ActionMoveAwayFromObject(oEnemy, TRUE, AI_RANGE_BATTLEFIELD);
            SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", FALSE);
            return;
        }
        // We have been seen by our nearest enemy or a hostile attacker so drop stealth.
        SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
    }
    // We have not been seen.
    else if(!bTried)
    {
        // Use any hiding talents we have
        if(!TrySpell(SPELL_IMPROVED_INVISIBILITY, oCreature, oCreature) ||
           !TrySpell(SPELL_INVISIBILITY, oCreature, oCreature))
        {
            SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
        }
        SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", TRUE);
        return;
    }
    // We are hidden or have givin up on stealth either way do our normal actions.
    int bUseMagic = !ai_GetAssociateMode(oCreature, AI_MODE_NO_MAGIC);
    //***************************  HEALING & CURES  ****************************
    if(bUseMagic)
    {
        if(ai_TryHealingTalent(oCreature, nInMelee)) return;
        if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    }
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // Check for moral and get the maximum spell level we should use.
    if(nDifficulty >= AI_COMBAT_SIMPLE)
    {
        if(ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    if(nDifficulty >= AI_COMBAT_DIFFICULT)
    {
        // ************************** CLASS FEATURES ***************************
        if(ai_TryBarbarianRageFeat(oCreature)) return;
        if(ai_TryBardSongFeat(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic && ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
    }
    // Class and Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_SIMPLE)
    {
        // ************************** CLASS FEATURES ***************************
        if(ai_TryTurningTalent(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic && !ai_GetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    ai_DoPhysicalAttackOnLowestCR(oCreature, nInMelee, !ai_GetAssociateMode(oCreature, AI_MODE_CHECK_ATTACK));
}
