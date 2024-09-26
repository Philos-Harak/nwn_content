/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_2_percept
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
//#include "0i_assoc_debug"
void main()
{
    // * if not runnning normal or better Ai then exit for performance reasons
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;
    object oCreature = OBJECT_SELF;
    /*
    if(GetLastPerceptionSeen())
    {
        ai_Debug("0e_c2_2_percept", "23", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived()) + " Distance: " +
                 FloatToString(GetDistanceBetween(GetLastPerceived(), oCreature), 0, 2) + ".");
    }
    if(GetLastPerceptionHeard())
    {
        ai_Debug("0e_c2_2_percept", "29", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived()) + " Distance: " +
                 FloatToString(GetDistanceBetween(GetLastPerceived(), oCreature), 0, 2) + ".");
    }
    if(GetLastPerceptionVanished ())
    {
        ai_Debug("0e_c2_2_percept", "35", GetName(oCreature) + " lost sight of " +
                 GetName(GetLastPerceived ()) + ".");
    } */
    // We do nothing on Inaudibles so drop out early!
    if(GetLastPerceptionInaudible())
    {
        //ai_Debug("xx_pc_2_percept", "41", GetName(oCreature) + " lost sound of " +
        //         GetName(GetLastPerceived()) + ".");
        return;
    }
    object oLastPerceived = GetLastPerceived();
    //ai_Debug("0e_c2_2_percept", "46", "Dead? " + IntToString(GetIsDead(oLastPerceived)) +
    //         " Enemy? " + IntToString(GetIsEnemy(oLastPerceived)));
    if(GetIsDead(oLastPerceived)) return;
    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT) && GetLastPerceptionSeen())
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_PERCEIVE));
    }
    int bSeen = GetLastPerceptionSeen();
    // This will cause the all NPC's to speak their one-liner conversation
    // on perception even if they are already in combat.
    if(bSeen)
    {
        if(GetIsPC(oLastPerceived))
        {
            if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION))
            {
                SpeakOneLinerConversation();
            }
            else if(GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION))
            {
                // The NPC will speak their one-liner conversation
                // This should probably be: SpeakOneLinerConversation(oPercep);
                // instead, but leaving it as is for now.
                ActionStartConversation(oCreature);
            }
        }
        if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) ai_DetermineSpecialBehavior(oCreature);
    }
    if(!GetIsEnemy(oLastPerceived)) return;
    // All code below assumes the perceived creature is an enemy and is alive!
    // **************************** ENEMY SEEN *********************************
    if(bSeen)
    {
        // If the creature we are perceiving was our invisible creature then
        // remove that they are invisible.
        if(oLastPerceived == GetLocalObject(oCreature, AI_IS_INVISIBLE))
        {
            DeleteLocalObject(oCreature, AI_IS_INVISIBLE);
        }
        ai_MonsterEvaluateNewThreat(oCreature, oLastPerceived);
        return;
    }
    // **************************** ENEMY HEARD ********************************
    else if(GetLastPerceptionHeard())
    {
        ai_MonsterEvaluateNewThreat(oCreature, oLastPerceived);
        return;
    }
    // **************************** ENEMY VANISHED *****************************
    else if(GetLastPerceptionVanished())
    {
        if(ai_Disabled(oCreature)) return;
        // Lets keep a mental note of the invisible creature.
        SetLocalObject(oCreature, AI_IS_INVISIBLE, oLastPerceived);
        //ai_Debug("0e_c2_2_percept", "101", " We saw " + GetName(oLastPerceived) + " disappear!");
        if(ai_GetIsBusy(oCreature)) return;
        // If in combat check to see if our target disappeared.
        // If they have and we are not in melee with them then reevaluate combat
        // since we lost our target.
        if(ai_GetIsInCombat(oCreature))
        {
            //ai_Debug("0e_c2_2_percept", "107", "Is this our target? " +
            //        IntToString(ai_GetAttackedTarget(oCreature, TRUE, TRUE) == oLastPerceived));
            if(ai_GetAttackedTarget(oCreature, TRUE, TRUE) == oLastPerceived)
            {
                ai_DoMonsterCombatRound(oCreature);
            }
            return;
        }
        // If they are not invisible then that means they left our perception
        // range and we need follow them.
        ActionMoveToObject(oLastPerceived, TRUE, AI_RANGE_CLOSE);
    }
    // **************************** ENEMY INAUDIBLE*****************************
    // Not used.
}
