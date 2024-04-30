/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
#include "nw_i0_generic"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("nw_c2_default1", "14", GetName(oCreature) + " Heartbeat out of combat." +
    //         " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // If we have not set up our talents then we need to check to see if we should.
    if(!GetLocalInt(oCreature, sTalentsSetVarname))
    {
        // We setup our talents when a PC gets withing Battlefield range 40.0 meters.
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
        if(oPC != OBJECT_INVALID && GetDistanceBetween(oCreature, oPC) <= AI_RANGE_BATTLEFIELD)
        {
            SetLocalInt(oCreature, sTalentsSetVarname, TRUE);
            int nCondition = GetLocalInt(oCreature, "NW_GENERIC_MASTER");
            // Should we buff a caster? Added legacy code just in case.
            if((AI_BUFF_MONSTER_CASTERS || nCondition & 0x04000000) &
               !GetLocalInt(oCreature, "AI_DO_NOT_BUFF") &&
               !GetLocalInt(oCreature, AI_CASTER_USED_BUFFS))
            {
                SetLocalInt(oCreature, AI_CASTER_USED_BUFFS, TRUE);
                ai_SetupMonsterBuffTargets(oCreature);
                ai_SetCreatureTalents(oCreature, AI_BUFF_MONSTER_CASTERS);
                ai_ClearBuffTargets(oCreature);
            }
            else ai_SetCreatureTalents(oCreature, FALSE);
        }
    }
    // If we are searching for an invisible enemy stop.
    if(GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    if(IsInConversation (oCreature)) return;
    if(!GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)) return;
    if(GetWalkCondition(NW_WALK_FLAG_CONSTANT))
    {
        WalkWayPoints();
        return;
    }
    if (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN) ||
        GetIsEncounterCreature(oCreature))
    {
        PlayMobileAmbientAnimations();
    }
    else if (GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
    {
        PlayImmobileAmbientAnimations();
    }
}
