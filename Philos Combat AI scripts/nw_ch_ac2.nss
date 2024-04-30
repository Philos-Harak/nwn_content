/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac2
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
void main()
{
    object oCreature = OBJECT_SELF;
    /*if(GetLastPerceptionSeen ())
    {
        ai_Debug("nw_ch_ac2", "19", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionHeard ())
    {
        ai_Debug("nw_ch_ac2", "24", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionVanished ())
    {
        ai_Debug("nw_ch_ac2", "29", GetName(oCreature) + " lost sight of " +
                 GetName(GetLastPerceived ()) + ".");
    } */
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    object oLastPerceived = GetLastPerceived();
    if(!GetIsEnemy(oLastPerceived) || GetIsDead(oLastPerceived)) return;
    // All code below assumes the perceived creature is an enemy and is alive!
    // **************************** ENEMY SEEN *********************************
    if(GetLastPerceptionSeen())
    {
        ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
        //ai_Debug("nw_c2_default2", "40", GetName(oCreature) + " is starting combat!");
        SetLocalObject (oCreature, AI_MY_TARGET, oLastPerceived);
        SpeakString(AI_I_SEE_AN_ENEMY, TALKVOLUME_SILENT_TALK);
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
        if(!GetObjectSeen(oLastPerceived))
        {
            SetLocalObject(oCreature, AI_MY_TARGET, oLastPerceived);
            SpeakString(AI_I_HEARD_AN_ENEMY, TALKVOLUME_SILENT_TALK);
            ai_SearchForInvisibleCreature(oCreature);
        }
    }
    // **************************** ENEMY VANISHED *****************************
    else if(GetLastPerceptionVanished())
    {
        // If in combat then let the combat system decide our action.
        if(ai_GetIsInCombat(oCreature)) ai_DoMonsterCombatRound(oCreature);
    }
    // **************************** ENEMY INAUDIBLE*****************************
    // Not used.
}





