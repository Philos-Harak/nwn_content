/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ae_097_098_01
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs on_enter for area 097_098_01 (Wet Cavern of Blight).
 - Creates poisonous clouds on enemies.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
void main()
{
    object oArea = OBJECT_SELF;
    object oCreature = GetLocalObject(oArea, "0_ENTERING_CREATURE");
    if(GetIsCharacter(oCreature) && NWNX_Area_GetNumberOfPlayersInArea(oArea) == 1)
    {
        effect eEffect = EffectAreaOfEffect(AOE_PER_FOGSTINK, "0s_poisoncloud_a", "0s_poisoncloud_c", "");
        // Cycle through all the cloud waypoints and see if a cloud spawns.
        object oCloud = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
        while(oCloud != OBJECT_INVALID)
        {
            if(GetTag(oCloud) == "Cloud" && d100() > 25)
            {
                DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eEffect, GetLocation(oCloud), 6000.0));
            }
            oCloud = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
        }
    }
    // This is a monster so lets see if they get a stench!
    else if(!GetLocalInt(oCreature, PC_ASSOCIATE_TYPE) &&
            !GetIsDungeonMaster(oCreature))
    {
        if (d100() > 75 && !HasSpellAbility(oCreature, SPELLABILITY_TROGLODYTE_STENCH))
        {
            AssignCommand(oCreature, ActionCastSpellAtObject(SPELLABILITY_TROGLODYTE_STENCH, oCreature, 255, TRUE));
        }
    }
}

