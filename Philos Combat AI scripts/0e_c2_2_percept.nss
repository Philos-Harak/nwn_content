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
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    // * if not runnning normal or better Ai then exit for performance reasons
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;
    object oCreature = OBJECT_SELF;
    /*if(GetLastPerceptionSeen())
    {
        ai_Debug("0e_c2_2_percept", "22", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived()) + ".");
    }
    if(GetLastPerceptionHeard())
    {
        ai_Debug("0e_c2_2_percept", "27", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived()) + ".");
    }
    if(GetLastPerceptionVanished ())
    {
        ai_Debug("0e_c2_2_percept", "32", GetName(oCreature) + " lost sight of " +
                 GetName(GetLastPerceived ()) + ".");
    } */
    object oLastPerceived = GetLastPerceived();
    //ai_Debug("0e_ch_2_percept", "34", "Enemy? " + IntToString(GetIsEnemy(oLastPerceived)) +
    //         " Dead? " + IntToString(GetIsDead(oLastPerceived)));
    if(GetIsDead(oLastPerceived)) return;
    // No need to look or hear things if we are busy or disabled.
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
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
        // Does this creature speak a random battlecry? Make sure its a PC.
        if(GetLocalInt(oCreature, "AI_BATTLECRY") && ai_GetIsCharacter(oLastPerceived))
        {
            ai_HaveCreatureSpeak(oCreature, 7, ":0:1:2:3:6:8:48:");
        }
        //ai_Debug("0e_c2_2_percept", "46", GetName(oCreature) + " is starting combat!");
        // Let my faction know about the new enemy!
        SetLocalObject(oCreature, AI_MY_TARGET, oLastPerceived);
        SpeakString(AI_I_SEE_AN_ENEMY, TALKVOLUME_SILENT_TALK);
        SetLocalInt(oCreature, AI_AM_I_SEARCHING, FALSE);
        ai_SetMonsterCombatEventScripts(oCreature);
        ai_DoMonsterCombatRound(oCreature);
    }
    // **************************** ENEMY HEARD ********************************
    else if(GetLastPerceptionHeard())
    {
        // If we hear them but cannot see them lets let the others know
        // and go into search mode.
        // Note: When a creature is first heard and seen it will set both the
        // heard and seen state while running the heard event first and then the
        // seen event. The heard event will still show them as seen even tho we
        // have not run the seen event!
        if(!GetObjectSeen(oLastPerceived))
        {
            SetLocalObject(oCreature, AI_MY_TARGET, oLastPerceived);
            SpeakString(AI_I_HEARD_AN_ENEMY, TALKVOLUME_SILENT_TALK);
            if(!ai_GetIsInCombat(oCreature)) ai_HaveCreatureSpeak(oCreature, 3, ":23:27:37:");
            ai_SearchForInvisibleCreature(oCreature);
        }
    }
    // **************************** ENEMY VANISHED *****************************
    else if(GetLastPerceptionVanished())
    {
        if(ai_GetIsInvisible(oCreature) && ai_SearchForInvisibleCreature(oCreature)) return;
        // If they are not invisible then that means they left our perception
        // range and we need to go towards them.
        ActionMoveToObject(oLastPerceived, TRUE, AI_RANGE_CLOSE);
    }
    // **************************** ENEMY INAUDIBLE*****************************
    // Not used.
}
