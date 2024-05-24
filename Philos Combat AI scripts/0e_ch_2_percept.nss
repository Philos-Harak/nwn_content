/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_2_percept
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiars, Companions) OnPerception script when not in combat;
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
    object oCreature = OBJECT_SELF;
    /*if(GetLastPerceptionSeen ())
    {
        ai_Debug("0e_ch_2_percept", "20", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionHeard ())
    {
        ai_Debug("0e_ch_2_percept", "25", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionVanished ())
    {
        ai_Debug("0e_ch_2_percept", "30", GetName(oCreature) + " lost sight of " +
                 GetName(GetLastPerceived ()) + ".");
    } */
    object oLastPerceived = GetLastPerceived();
    //ai_Debug("0e_ch_2_percept", "34", "Enemy? " + IntToString(GetIsEnemy(oLastPerceived)) +
    //         " Dead? " + IntToString(GetIsDead(oLastPerceived)));
    if(GetIsDead(oLastPerceived) || !GetIsEnemy(oLastPerceived)) return;
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // All code below assumes the perceived creature is an enemy and is alive!
    // **************************** ENEMY SEEN *********************************
    if(GetLastPerceptionSeen())
    {
        ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
        //ai_Debug("0e_ch_2_percept", "41", GetName(oCreature) + " is starting combat!");
        SetLocalObject (oCreature, AI_MY_TARGET, oLastPerceived);
        SpeakString(AI_I_SEE_AN_ENEMY, TALKVOLUME_SILENT_SHOUT);
        DeleteLocalInt(oCreature, AI_AM_I_SEARCHING);
        if(ai_CanIAttack(oCreature))
        {
            ai_SetAssociateCombatEventScripts(oCreature);
            ai_SetCreatureTalents(oCreature, FALSE);
            ai_DoAssociateCombatRound(oCreature);
        }
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
            SpeakString(AI_I_HEARD_AN_ENEMY, TALKVOLUME_SILENT_SHOUT);
            ai_HaveCreatureSpeak(oCreature, 3, ":23:27:37:");
            if(ai_CanIAttack(oCreature)) ai_SearchForInvisibleCreature(oCreature);
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





