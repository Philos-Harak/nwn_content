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
    if(!GetLocalInt(oArea, "0_Populated"))
    {
        object oBloodPortal = GetObjectInAreaByTag(oArea, "bloodportal_to_myrkul", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        vector vPosition = Vector(15.0, 114.5, 2.0);
        NWNX_Object_SetPosition(oBloodPortal, vPosition);
        object oBlood = GetObjectInAreaByTag(oArea, "blood_heart", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oBlood = GetObjectInAreaByTag(oArea, "blood_skull", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oBlood = GetObjectInAreaByTag(oArea, "blood_femur", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oBlood = GetObjectInAreaByTag(oArea, "blood_vial", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        oBlood = GetObjectInAreaByTag(oArea, "blood_center", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR);
        object oContainer = GetObjectInAreaByTag(oArea, "heart_container", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        if(GetCreatureHasItem(oContainer, "monstrous_heart") == OBJECT_INVALID) CreateItemOnObject("monstrous_heart", oContainer);
        oContainer = GetObjectInAreaByTag(oArea, "femur_container", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        if(GetCreatureHasItem(oContainer, "femur_bone") == OBJECT_INVALID) CreateItemOnObject("femur_bone", oContainer);
        oContainer = GetObjectInAreaByTag(oArea, "skull_container", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        if(GetCreatureHasItem(oContainer, "burned_skull") == OBJECT_INVALID) CreateItemOnObject("burned_skull", oContainer);
        oContainer = GetObjectInAreaByTag(oArea, "vial_container", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        if(GetCreatureHasItem(oContainer, "vial_of_blood") == OBJECT_INVALID) CreateItemOnObject("vial_of_blood", oContainer);
    }
}

