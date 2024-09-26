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
                 GetName(GetLastPerceived()) + " Distance: " +
                 FloatToString(GetDistanceBetween(GetLastPerceived(), oCreature), 0, 2) + ".");
    }
    if(GetLastPerceptionHeard ())
    {
        ai_Debug("0e_ch_2_percept", "26", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived()) + " Distance: " +
                 FloatToString(GetDistanceBetween(GetLastPerceived(), oCreature), 0, 2) + ".");
    }
    if(GetLastPerceptionVanished ())
    {
        ai_Debug("0e_ch_2_percept", "32", GetName(oCreature) + " lost sight of " +
                 GetName(GetLastPerceived()) + ".");
    }
    // We do nothing on Inaudibles so drop out early!
    if(GetLastPerceptionInaudible())
    {
        ai_Debug("0e_ch_2_percept", "38", GetName(oCreature) + " lost sound of " +
                 GetName(GetLastPerceived()) + ".");
        return;
    } */
    object oLastPerceived = GetLastPerceived();
    //ai_Debug("0e_ch_2_percept", "43", "Dead? " + IntToString(GetIsDead(oLastPerceived)) +
    //         " Enemy? " + IntToString(GetIsEnemy(oLastPerceived)));
    if(GetIsDead(oLastPerceived) || !GetIsEnemy(oLastPerceived)) return;
    // All code below assumes the perceived creature is an enemy and is alive!
    // **************************** ENEMY SEEN *********************************
    if(GetLastPerceptionSeen())
    {
        // If the creature we are perceiving was our invisible creature then
        // remove that they are invisible.
        if(oLastPerceived == GetLocalObject(oCreature, AI_IS_INVISIBLE))
        {
            DeleteLocalObject(oCreature, AI_IS_INVISIBLE);
        }
        ai_AssociateEvaluateNewThreat(oCreature, oLastPerceived);
        return;
    }
    // **************************** ENEMY HEARD ********************************
    if(GetLastPerceptionHeard())
    {
        ai_AssociateEvaluateNewThreat(oCreature, oLastPerceived);
        return;
    }
    // **************************** ENEMY VANISHED *****************************
    if(GetLastPerceptionVanished())
    {
        if(ai_Disabled(oCreature)) return;
        // Lets keep a mental note of the invisible creature.
        SetLocalObject(oCreature, AI_IS_INVISIBLE, oLastPerceived);
        //ai_Debug("0e_ch_2_percept", "71", " We saw " + GetName(oLastPerceived) + " disappear!");
        if(ai_GetIsBusy(oCreature)) return;
        // If in combat check to see if our target disappeared.
        // If they have and we are not in melee with them then reevaluate combat
        // since we lost our target.
        if(ai_GetIsInCombat(oCreature))
        {
            //ai_Debug("0e_ch_2_percept", "78", "Is this our target? " +
            //        IntToString(ai_GetAttackedTarget(oCreature, TRUE, TRUE) == oLastPerceived));
            if(ai_GetAttackedTarget(oCreature, TRUE, TRUE) == oLastPerceived)
            {
                ai_DoAssociateCombatRound(oCreature);
            }
            return;
        }
        // If they are not invisible then that means they left our perception
        // range and we need follow them.
        if(ai_CanIAttack(oCreature)) ActionMoveToObject(oLastPerceived, TRUE, AI_RANGE_CLOSE);
    }
    // **************************** ENEMY INAUDIBLE*****************************
    // Not used.
}
