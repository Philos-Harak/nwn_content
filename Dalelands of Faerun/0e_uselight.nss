/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_uselight
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse event of a light placeable.
 This is useable by Players and NPC's.
 Turns the placeables light on and off.

 Variables on the placeable:
 0_LightColor is the color the light will be when the placeable is turned on.
 Blue, Green, Orange, Purple, Red, White, Yellow.
 0_LightVolume is the size of the area the light will be.
 5, 10, 15, 20. If none of these values are used then it defaults to 5.
*/////////////////////////////////////////////////////////////////////////////////////////////////////


void main()
{
    int iLightVolume, iEffect;
    string sLightColor, sSound;
    effect eEffect;
    object oSound;
    // See if the placeable is on.
    if (GetLocalInt (OBJECT_SELF, "0_Placeable_On"))
    {
        // Delete variable stating its on.
        DeleteLocalInt (OBJECT_SELF, "0_Placeable_On");
        // Deactivate it.
        PlayAnimation (ANIMATION_PLACEABLE_DEACTIVATE);
        // Turn off the ambient light by removing light effect.
        eEffect = GetFirstEffect (OBJECT_SELF);
        while (GetIsEffectValid (eEffect))
        {
            if (GetEffectType (eEffect) == EFFECT_TYPE_VISUALEFFECT) RemoveEffect (OBJECT_SELF, eEffect);
            eEffect = GetNextEffect (OBJECT_SELF);
        }
        oSound = GetNearestObjectByTag ("0_torch_sound");
        SoundObjectStop (oSound);
    }
    else
    {
        // Set variable stating its on.
        SetLocalInt (OBJECT_SELF, "0_Placeable_On", TRUE);
        // Activate it.
        PlayAnimation (ANIMATION_PLACEABLE_ACTIVATE);
        // Turn on the ambient light.
        // Get the objects color and volume.
        sLightColor = GetLocalString (OBJECT_SELF, "0_LightColor");
        if (sLightColor == "Blue") iEffect = 153;
        else if (sLightColor == "Green") iEffect = 177;
        else if (sLightColor == "Orange") iEffect = 169;
        else if (sLightColor == "Purple") iEffect = 161;
        else if (sLightColor == "Red") iEffect = 165;
        else if (sLightColor == "White") iEffect = 173;
        else iEffect = 157; // Defaults to Yellow.
        iLightVolume = GetLocalInt (OBJECT_SELF, "0_LightVolume");
        if (iLightVolume == 10) iEffect = iEffect + 1;
        else if (iLightVolume == 15) iEffect = iEffect + 2;
        else if (iLightVolume == 20) iEffect = iEffect + 3;
        else iEffect = iEffect + 2; // Defaults to 15 Volume.
        // Generate the correct effect number.
        eEffect = EffectVisualEffect (iEffect);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, OBJECT_SELF);
        oSound = GetNearestObjectByTag ("0_torch_sound");
        SoundObjectPlay (oSound);
    }
}
