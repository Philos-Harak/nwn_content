/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_change_cloak
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script that sets the script to run on conversation select.
 Used to set a color model text.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
int StartingConditional()
{
    int iModel;
    object oPC = GetPCSpeaker ();
    object oItem = GetLocalObject (oPC, "0_Item_To_Change");
    int bNotLinked = GetLocalInt (oPC, "0_Armor_Appr_Not_Linked");
    // Get the selections.
    int iModelType = GetLocalInt (oPC, "ITEM_APPR_MODEL");
    if (iModelType == ITEM_APPR_ARMOR_MODEL_NECK) SetCustomToken (14422, "Neck");
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_LSHOULDER)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Shoulder");
        else SetCustomToken (14422, "Left Shoulder");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RSHOULDER)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Shoulder");
        else SetCustomToken (14422, "Right Shoulder");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RSHOULDER)
    {
        iModelType = ITEM_APPR_ARMOR_MODEL_LBICEP;
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Bicep");
        else SetCustomToken (14422, "Left Bicep");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RBICEP)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Bicep");
        else SetCustomToken (14422, "Right Bicep");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_LFOREARM)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Forearm");
        else SetCustomToken (14422, "Left Forearm");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RFOREARM)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Forearm");
        else SetCustomToken (14422, "Right Forearm");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_LHAND)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Hand");
        else SetCustomToken (14422, "Left Hand");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RHAND)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Hand");
        else SetCustomToken (14422, "Right Hand");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_TORSO) SetCustomToken (14422, "Torso");
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_BELT) SetCustomToken (14422, "Belt");
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_PELVIS) SetCustomToken (14422, "Pelvis");
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_LTHIGH)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Thigh");
        else SetCustomToken (14422, "Left Thigh");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RTHIGH)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Thigh");
        else SetCustomToken (14422, "Right Thigh");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_LSHIN)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Shin");
        else SetCustomToken (14422, "Left Shin");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RSHIN)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Shin");
        else SetCustomToken (14422, "Right Shin");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_LFOOT)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Foot");
        else SetCustomToken (14422, "Foot");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_RFOOT)
    {
        if (!bNotLinked) SetCustomToken (14422, "Right/Left Foot");
        else SetCustomToken (14422, "Right Foot");
    }
    else if (iModelType == ITEM_APPR_ARMOR_MODEL_ROBE) SetCustomToken (14422, "Robe");
    // Set the model number.
    iModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, iModelType);
    SetCustomToken (14424, IntToString (iModel));
    return TRUE;
}
