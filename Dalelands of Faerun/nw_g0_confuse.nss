//::///////////////////////////////////////////////
//:: Confusion Heartbeat Support Script
//:: NW_G0_Confuse
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This heartbeat script runs on any creature
    that has been hit with the confusion effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 27, 2001
//:://////////////////////////////////////////////
#include "x0_inc_henai"
void main()
{
    SendForHelp();
    //Make sure the creature is commandable for the round
    SetCommandable(TRUE);
    //Clear all previous actions.
    ClearAllActions(TRUE);
    int nRandom = d10();
    //Roll a random int to determine this rounds effects
    if(nRandom < 3)
    {
        ActionRandomWalk();
    }
    else if(nRandom < 8)
    {
        if(d100() < 76) ActionPlayAnimation(Random(16) + 100);
        if(d100() < 26) PlayVoiceChat(Random(49), OBJECT_SELF);
    }
    else
    {
        int nIndex = 1;
        object oConfused = OBJECT_SELF;
        object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oConfused);
        while(oTarget != OBJECT_INVALID && nIndex < 6)
        {
            if(d100() < 76 && GetObjectSeen(oTarget))
            {
                ActionAttack(GetNearestObject(OBJECT_TYPE_CREATURE));
                break;
            }
            oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oConfused, ++nIndex);
        }
    }
    SetCommandable(FALSE);
}
