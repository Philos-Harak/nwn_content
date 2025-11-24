/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_animations
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster Ambient Animations and Walk Waypoint code.
  This code uses the Bioware systems, but can be rewritten to use what ever you
  want!
  This is called in the nw_c2_default1 - monster heartbeat script.
*///////////////////////////////////////////////////////////////////////////////
#include "x0_i0_anims"
#include "0i_actions"
void main()
{
    if(!IsInConversation (OBJECT_SELF))
    {
        if(GetWalkCondition(NW_WALK_FLAG_CONSTANT)) WalkWayPoints();
        if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)) PlayMobileAmbientAnimations_NonAvian();
        else if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)) PlayMobileAmbientAnimations_Avian();
        else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS)) PlayImmobileAmbientAnimations();
        else if(GetLocalInt(GetModule(), AI_RULE_WANDER) && GetStandardFactionReputation(STANDARD_FACTION_HOSTILE) > 89)
        {
            ai_AmbientAnimations();
        }
    }

}
