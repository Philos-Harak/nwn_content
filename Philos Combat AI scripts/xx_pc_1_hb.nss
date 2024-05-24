/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_1_hb
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
    //ai_Debug("xx_pc_1_hb", "15", GetName(oCreature) + " Heartbeat out of combat." +
    //       " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // Lets not interupt conversations.
    if(IsInConversation(oCreature)) return;
    if(ai_TryHealingOutOfCombat(oCreature, oCreature)) return;
    // Seek out and disable traps.
    object oTrap = GetNearestTrapToObject();
    if(oTrap != OBJECT_INVALID && ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
    if(ai_AssociateRetrievingItems(oCreature)) return;
}





