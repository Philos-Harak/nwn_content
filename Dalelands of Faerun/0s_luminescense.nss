/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_luminescense
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Gloamings can glow; dim light, medium light, bright light, no light centered on the Gloaming.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    object oPC = OBJECT_SELF;
    // Get the glowstate.
    int nGlowState = GetLocalInt(oPC, "0_Glow_State");
    // Now change glow state.
    // Set Dim glow.
    if(nGlowState == 0)
    {
        SetLocalInt(oPC, "0_Glow_State", 1);
        CreateFeatEffect(oPC, EffectVisualEffect (VFX_DUR_LIGHT_WHITE_5), "FEAT_GLOW");
        SendMessages("You now have a dim glow.", COLOR_GRAY, oPC);
    }
    // Set Medium glow.
    else if(nGlowState == 1)
    {
        SetLocalInt(oPC, "0_Glow_State", 2);
        CreateFeatEffect(oPC, EffectVisualEffect (VFX_DUR_LIGHT_WHITE_10), "FEAT_GLOW");
        SendMessages("You now have a medium glow.", COLOR_GRAY, oPC);
    }
    // Set Bright glow.
    else if(nGlowState == 2)
    {
        SetLocalInt(oPC, "0_Glow_State", 3);
        CreateFeatEffect(oPC, EffectVisualEffect (VFX_DUR_LIGHT_WHITE_20), "FEAT_GLOW");
        SendMessages("You now have a bright glow.", COLOR_GRAY, oPC);
    }
    // Set Medium glow.
    else if(nGlowState == 3)
    {
        // Set new glow state.
        SetLocalInt (oPC, "0_Glow_State", 0);
        RemoveTagedEffects (oPC, "FEAT_GLOW");
        SendMessages("You now have no glow.", COLOR_GRAY, oPC);
    }
}
