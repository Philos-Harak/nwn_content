/*///////////////////////////////////////////////////////////////////////////////
 Script: 0e_water_lever
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnUse event to switch levers on and off.
 This allows a character to reduce the water in the aquaducts of Harrowport.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spawn"
void UseLever(object oCreature, object oLever)
{
    AssignCommand(oLever, PlayAnimation (ANIMATION_PLACEABLE_ACTIVATE));
    AssignCommand(oLever, PlaySound("as_sw_lever1"));
    SetLocalInt (OBJECT_SELF,"Lever_is_on", TRUE);
    // Get and set the new water level.
    object oArea = GetArea(oCreature);
    int nWaterLevel = GetLocalInt(oArea, "0_WATER_LEVEL") + 1;
    // Remove the invisible barriers.
    if(nWaterLevel >= 5)
    {
        object oBarrier = GetNearestObjectByTag("0_invisible_barrier_1", oCreature);
        DestroyObject(oBarrier);
    }
    SetLocalInt(oArea, "0_WATER_LEVEL", nWaterLevel);
    // Lower the water one more level.
    object oWater = GetNearestObjectByTag("sewage_1", oCreature);
    float fWaterLevel = IntToFloat(nWaterLevel) * -0.23;
    SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fWaterLevel, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 15.0);
    oWater = GetNearestObjectByTag("sewage_2", oCreature);
    SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fWaterLevel, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 15.0);
    oWater = GetNearestObjectByTag("sewage_3", oCreature);
    SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fWaterLevel, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 15.0);
    oWater = GetNearestObjectByTag("sewage_4", oCreature);
    SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fWaterLevel, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 15.0);
    oWater = GetNearestObjectByTag("sewage_5", oCreature);
    SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fWaterLevel, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 15.0);
    // Open any doors based upon the Lever.
    int nLever = GetLocalInt(oLever, "Lever");
    if(nLever > 0)
    {
        object oDoor = GetNearestObjectByTag("door_" + IntToString(nLever), oCreature);
        AssignCommand(oDoor, ActionUnlockObject(oDoor));
        AssignCommand(oDoor, ActionOpenDoor(oDoor));
    }
    // Spawn monsters based on the lever.
    int nIndex = 1;
    // Get the area's encounter waypoint used for all encounters in area.
    object oWPEncounter = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
    int bNoDifficulty = GetLocalInt (oWPEncounter, "0_No_Difficulty");
    int nLevel = GetLocalInt (oArea, "0_Area_Level");
    object oObject = GetObjectInArea (oArea, nIndex);
    while (oObject != OBJECT_INVALID)
    {
        int nObjectType = GetObjectType(oObject);
        if (nObjectType == OBJECT_TYPE_WAYPOINT) CheckWaypoints (oCreature, oObject, bNoDifficulty, nLevel, "_wave_" + IntToString(nLever), "");
        nIndex ++;
        oObject = GetObjectInArea (oArea, nIndex);
    }
}
void main()
{
    object oPC = GetLastUsedBy();
    if(GetLocalInt(OBJECT_SELF, "Lever_is_on")) return;
    UseLever(oPC, OBJECT_SELF);

}
