/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default2
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnPerception script when not in combat;
  There are 4 types of perception - Heard, Inaudible, Seen, Vanished.
  Only one type will ever be true in an event trigger.
  The order of trigger is Heard/Seen and Inaudible/Vanished.
  There are two states of percepion Heard and Seen.
  These states can be set at the same time thus a heard event can see the creature.
  Fires when ever one of these states changes from TRUE to FALSE or FALSE to TRUE.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    // * if not runnning normal or better AI then exit for performance reasons
    //if (GetAILevel() == AI_LEVEL_VERY_LOW) return;
    object oCreature = OBJECT_SELF;
    ExecuteScript("prc_npc_percep", oCreature);
    if(AI_DEBUG) ai_Debug("nw_c2_default2", "19", "AI_ONSPAWN_EVENT: " + IntToString(GetLocalInt(oCreature, AI_ONSPAWN_EVENT)));
    if(!GetLocalInt(oCreature, AI_ONSPAWN_EVENT)) return;
    if(GetLastPerceptionSeen())
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default2", "22", GetName(oCreature) + " sees " +
                     GetName(GetLastPerceived()) + " Distance: " +
                     FloatToString(GetDistanceBetween(GetLastPerceived(), oCreature), 0, 2) + ".");
    }
    if(GetLastPerceptionHeard())
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default2", "28", GetName(oCreature) + " heard " +
                     GetName(GetLastPerceived()) + " Distance: " +
                     FloatToString(GetDistanceBetween(GetLastPerceived(), oCreature), 0, 2) + ".");
    }
    if(GetLastPerceptionVanished ())
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default2", "34", GetName(oCreature) + " lost sight of " +
                     GetName(GetLastPerceived ()) + ".");
    }
    // We do nothing on Inaudibles so drop out early!
    if(GetLastPerceptionInaudible())
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default2", "41", GetName(oCreature) + " lost sound of " +
                     GetName(GetLastPerceived()) + ".");
        return;
    }
    object oLastPerceived = GetLastPerceived();
    if(AI_DEBUG) ai_Debug("nw_c2_default2", "45", "Dead? " + IntToString(GetIsDead(oLastPerceived)) +
                 " Enemy? " + IntToString(GetIsEnemy(oLastPerceived, oCreature)));
    if(ai_Disabled(oCreature)) return;
    if(GetIsDead(oLastPerceived)) return;
    int bSeen = GetLastPerceptionSeen();
    // This will cause all NPC's to speak their one-liner conversation
    // on perception even if they are already in combat.
    if(GetIsPC(oLastPerceived) && bSeen)
    {
        if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION))
        {
            SpeakOneLinerConversation();
        }
    }
    if(GetIsEnemy(oLastPerceived, oCreature))
    {
        // ************************** ENEMY SEEN *******************************
        if(bSeen)
        {
            // If the creature we are perceiving was our invisible creature then
            // remove that they are invisible.
            if(oLastPerceived == GetLocalObject(oCreature, AI_IS_INVISIBLE))
            {
                DeleteLocalObject(oCreature, AI_IS_INVISIBLE);
            }
            ai_MonsterEvaluateNewThreat(oCreature, oLastPerceived, AI_I_SEE_AN_ENEMY);
        }
        // ************************** ENEMY HEARD ******************************
        else if(GetLastPerceptionHeard())
        {
            ai_MonsterEvaluateNewThreat(oCreature, oLastPerceived, AI_I_HEARD_AN_ENEMY);
        }
        // ************************** ENEMY VANISHED ***************************
        else if(GetLastPerceptionVanished())
        {
            // Lets keep a mental note of the invisible creature.
            SetLocalObject(oCreature, AI_IS_INVISIBLE, oLastPerceived);
            if(AI_DEBUG) ai_Debug("0e_c2_2_percept", "82", " We saw " + GetName(oLastPerceived) + " disappear!");
            if(ai_GetIsBusy(oCreature)) return;
            // If in combat check to see if our target disappeared.
            // If they have and we are not in melee with them then reevaluate combat
            // since we lost our target.
            if(ai_GetIsInCombat(oCreature))
            {
                if(AI_DEBUG) ai_Debug("nw_c2_default2", "89", "Is this our target? " +
                             IntToString(ai_GetAttackedTarget(oCreature, TRUE, TRUE) == oLastPerceived));
                if(ai_GetAttackedTarget(oCreature, TRUE, TRUE) == oLastPerceived)
                {
                    ai_DoMonsterCombatRound(oCreature);
                }
            }
            // We are not in combat so lets move to that location and check it out.
            else ActionMoveToLocation(GetLocation(oLastPerceived), TRUE);
            // we use to move to the object but thats a bit creepy!
            //else ActionMoveToObject(oLastPerceived, TRUE, AI_RANGE_CLOSE);
        }
        // ************************ ENEMY INAUDIBLE*****************************
        // Not used.
    }
    else
    {
        // ************************ NON_ENEMY SEEN *****************************
        if(bSeen)
        {
            if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) ai_DetermineSpecialBehavior(oCreature);
            else if(GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION) && GetIsPC(oLastPerceived))
            {
                ActionStartConversation(oCreature);
            }
        }
    }
    if(!IsInConversation(oCreature))
    {
        if(GetIsPostOrWalking())
        {
            WalkWayPoints();
        }
        else if(GetIsPC(oLastPerceived) &&
               (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) ||
                GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN) ||
                GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS) ||
                GetIsEncounterCreature()))
        {
            SetAnimationCondition(NW_ANIM_FLAG_IS_ACTIVE);
        }
    }
    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT) && bSeen)
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_PERCEIVE));
    }
}
