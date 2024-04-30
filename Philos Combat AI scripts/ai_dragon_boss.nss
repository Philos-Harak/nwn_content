/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_dragon_boss
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script a unique dragon that lives deep in a dark cave using it as a defense.
 OBJECT_SELF is the dragon running the ai.
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
    //**************************************************************************
    //************************ ROUND BASED AI SCRIPTS *************************
    //**************************************************************************
    int nRound = ai_GetCurrentRound(oCreature);
    // First time fly to our enemy, the rest of combat lets not do that!
    object oTarget;
    if(!GetLocalInt(OBJECT_SELF, "AI_DONE_FLYING"))
    {
        SetLocalInt(OBJECT_SELF, "AI_DONE_FLYING", TRUE);
        oTarget = ai_GetLowestCRTarget(oCreature);
        // We assign the voice to the PC so they get to hear it.
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
        AssignCommand(oPC, PlaySound("vs_ndredm_bat2"));
        // Can we do a crush attack(HD 18+)?
        if(ai_TryCrushAttack(oCreature, oTarget)) return;
        ai_FlyToTarget(oCreature, oTarget);
        return;
    }
    else if(nRound == 2)
    {
        oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_CLOSE);
        ai_TryDragonBreathAttack(oCreature, nRound, oTarget);
        return;
    }
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    // Check to see if we need to retreat to get healing.
    int nPercentageHP = ai_GetPercHPLoss(oCreature);
    //ai_Debug("ai_dragon_boss", "43", "nPercentageHP: " + IntToString(nPercentageHP));
    if(nPercentageHP < 75 && !GetLocalInt(oCreature, "AI_HOME"))
    {
        string sWaypoint;
        // If we are below half then go to last defensive position.
        if(nPercentageHP < 50)
        {
            SetLocalInt(oCreature, "AI_HOME", TRUE);
            sWaypoint = "0_wp_dragon2";
        }
        // else we just go back a little bit to heal up.
        else sWaypoint = "0_wp_dragon1";
        if(!GetLocalInt(oCreature, sWaypoint))
        {
            string sVoice;
            switch(d6())
            {
                case 1 :
                case 2 : sVoice = "vs_ndredm_attk"; break;
                case 3 :sVoice = "vs_ndredm_heal"; break;
                case 4 :sVoice = "vs_ndredm_help"; break;
                case 5 :sVoice = "vs_ndredm_no"; break;
                case 6 :sVoice = "vs_ndredm_bat3"; break;
            }
            SetImmortal(oCreature, TRUE);
            DelayCommand(6.0f, SetImmortal(oCreature, FALSE));
            AssignCommand(ai_GetNearestTarget(oCreature), PlaySound(sVoice));
            object oWaypoint = GetNearestObjectByTag(sWaypoint);
            //ai_Debug("ai_dragon_boss", "71", "Flying to " + sWaypoint + ".");
            effect eFly = EffectDisappearAppear(GetLocation(oWaypoint));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFly, oCreature, 6.0f);
            SetLocalInt(oCreature, sWaypoint, TRUE);
            return;
        }
    }
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // ************************  MELEE ATTACKS  ********************************
    oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryDragonBreathAttack(oCreature, nRound)) return;
        ai_TryWingAttacks(oCreature);
        // If we don't do a Tail sweep attack(HD 30+) then see if we can do a Tail slap(HD 12+)!
        if(!ai_TryTailSweepAttack(oCreature)) ai_TryTailSlap(oCreature);
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
}
