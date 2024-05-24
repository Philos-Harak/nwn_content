/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_2_battle
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiars, Companions) on perception script when in combat.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    /*if(GetLastPerceptionSeen ())
    {
        ai_Debug("0e_ch_battle_2", "13", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionHeard ())
    {
        ai_Debug("0e_ch_battle_2", "18", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(ai_Disabled(oCreature)) return;
    if (!ai_GetIsBusy (oCreature) && ai_CanIAttack(oCreature))
    {
        ai_DoAssociateCombatRound(oCreature);
        return;
    } */
    object oLastPerceived = GetLastPerceived();
    if(!GetIsEnemy(oLastPerceived) || GetIsDead(oLastPerceived)) return;
    // All code below assumes the perceived creature is an enemy and is alive!
    // **************************** ENEMY SEEN *********************************
    if(GetLastPerceptionSeen())
    {
        // If we are moving in combat we may need to reevaluate with new enemies!
        if(GetCurrentAction(oCreature) == ACTION_MOVETOPOINT &&
           ai_CanIAttack(oCreature)) ai_DoAssociateCombatRound(oCreature);
    }
    // **************************** ENEMY VANISHED *****************************
    if(GetLastPerceptionVanished())
    {
        if(ai_CanIAttack(oCreature))
        {
            if(ai_GetIsInvisible(oCreature) && ai_SearchForInvisibleCreature(oCreature)) return;
            // If they are not invisible then that means they left our perception
            // range and we need to go towards them.
            ActionMoveToObject(oLastPerceived, TRUE, AI_RANGE_CLOSE);
        }
    }
}





