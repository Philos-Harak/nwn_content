/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnHeart beat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_ch_1_hb", "17", GetName(oCreature) + " Heartbeat out of combat." +
    //         " MODE_FOLLOW: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW)) +
    //         " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)) +
    //         " Action: " + IntToString(GetCurrentAction(oCreature)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    object oMaster = GetMaster(oCreature);
    // If we don't have a master then we exit.
    if(oMaster == OBJECT_INVALID && !ai_GetIsCharacter(oCreature)) return;
    // Have we gone too far away? Get back to our master.
    if(ai_StayCloseToMaster(oCreature)) return;
    // If follow mode we do not want the NPC doing anything but follow.
    if(!ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW))
    {
        if(ai_GetAssociateMode(oCreature, AI_MODE_STAND_GROUND)) return;
        // Lets not interupt conversations.
        if(IsInConversation(oCreature)) return;
        if(ai_TryHealingOutOfCombat(oCreature, oCreature)) return;
        // Seek out and disable traps.
        object oTrap = GetNearestTrapToObject(oCreature);
        if(oTrap != OBJECT_INVALID &&
           ai_GetAssociateMode(oCreature, AI_MODE_DISARM_TRAPS) &&
           ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
        if(ai_AssociateRetrievingItems(oCreature)) return;
        if(ai_GetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD))
        {
            ai_ScoutAhead(oCreature);
            return;
        }
    }
    // Finally we check to make sure we are following our master.
    if(GetCurrentAction(oCreature) != ACTION_FOLLOW &&
       !GetLocalInt(oCreature, AI_AM_I_SEARCHING))
    {
       // Follow master.
       if(GetDistanceBetween(oCreature, oMaster) > ai_GetFollowDistance(oCreature))
       {
           ai_ClearCreatureActions(oCreature);
           //ai_Debug("0e_ch_1_hb", "62", "Follow master: " +
           //         " Stealth: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
           //         " Search: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
           if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
           {
              //ai_Debug("0e_ch_1_hb", "67", "Going into stealth mode!");
              SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
           }
           else if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
           {
              //ai_Debug("0e_ch_1_hb", "72", "Going into search mode!");
              SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
           }
           ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
       }
    }
}
