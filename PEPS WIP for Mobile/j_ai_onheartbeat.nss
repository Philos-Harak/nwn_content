/*//////////////////////////////////////////////////////////////////////////////
 Script: j_ai_onheartbeat
////////////////////////////////////////////////////////////////////////////////
  Jasperre's AI OnHeart beat script for monsters.
  This will usually fire every 6 seconds (1 game round).
  We use this to change the creatures event scripts to the new AI event scripts.
*///////////////////////////////////////////////////////////////////////////////
//#include "J_INC_HEARTBEAT"
#include "0i_module"

void main()
{
    // Here is the code to redirect the monsters AI to Philos' AI.
    ai_OnAssociateSpawn(OBJECT_SELF);

    /********** Everything below is the original code unchanged. **********

    WriteTimestampedLogEntry(GetName(OBJECT_SELF) + " OnHeartbeat!");

    // Perform special action if needed (e.g., shouting, fleeing, door bashing).
    //if (PerformSpecialAction()) return;

    // Trigger the pre-heartbeat user event. Exit if the event interrupts this script call.
    //if (FirePreUserEvent(AI_FLAG_UDE_HEARTBEAT_PRE_EVENT, EVENT_HEARTBEAT_PRE_EVENT)) return;

    // Check if AI is disabled or if we should skip this heartbeat due to lag optimization.
    if (GetAIOff() || GetSpawnInCondition(AI_FLAG_OTHER_LAG_IGNORE_HEARTBEAT, AI_OTHER_MASTER)) return;

    // Define the enemy and player to use.
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    object oPlayer = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);

    // Skip further processing if we should jump out or if we are not in combat.
    if (!JumpOutOfHeartBeat() && !GetIsInCombat() &&
        !GetIsObjectValid(GetAttackTarget()) && !GetObjectSeen(oEnemy))
    {
        // Fast buff logic if the appropriate spawn condition is set.
        if (GetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER) &&
            GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= 40.0)
        {
            // Execute the buff script and disable future calls for fast buffing.
            ExecuteScript(FILE_HEARTBEAT_TALENT_BUFF, OBJECT_SELF);
            DeleteSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER);
            return; // Stop further processing for this heartbeat.
        }

        // Handle waypoint movement if the walk condition is set.
        if (GetWalkCondition(NW_WALK_FLAG_CONSTANT))
        {
            ExecuteScript("nw_walk_wp", OBJECT_SELF);
        }
        else
        {
            // Optional: You can add other non-waypoint actions or behaviors here.
        }
    }

    // Fire the end-heartbeat user event.
    FireUserEvent(AI_FLAG_UDE_HEARTBEAT_EVENT, EVENT_HEARTBEAT_EVENT);
    */
}

