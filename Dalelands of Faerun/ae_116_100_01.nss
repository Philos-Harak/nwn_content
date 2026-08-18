/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ae_myrkuls_realm
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs on_enter for area myrkuls_realm (Deathless Castle).
 - Resets the Blood portal if area is clear.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"
#include "nwnx_object"
void main()
{
    object oArea = OBJECT_SELF;
    object oCreature = GetEnteringObject();
    if(!GetLocalInt(oArea, "0_Populated") && GetIsCharacter(oCreature))
    {
        DeleteLocalInt(oArea, "0_WATER_LEVEL");
        object oWater = GetNearestObjectByTag("sewage_1", oCreature);
        SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oWater = GetNearestObjectByTag("sewage_2", oCreature);
        SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oWater = GetNearestObjectByTag("sewage_3", oCreature);
        SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oWater = GetNearestObjectByTag("sewage_4", oCreature);
        SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oWater = GetNearestObjectByTag("sewage_5", oCreature);
        SetObjectVisualTransform(oWater, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        object oWaypoint = GetNearestObjectByTag("WP_invisible_barrier_1", oCreature);
        location lWPLocation = GetLocation(oWaypoint);
        CreateObject(OBJECT_TYPE_PLACEABLE, "0_invisible_wall", lWPLocation, FALSE, "0_invisible_barrier_1");
        int nIndex = 0;
        object oLever;
        while(nIndex < 6)
        {
            oLever = GetNearestObjectByTag("aquaduct_lever", oCreature, nIndex);
            DeleteLocalInt(oLever, "Lever_is_on");
            nIndex++;
        }
    }
}

