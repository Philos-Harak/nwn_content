/*////////////////////////////////////////////////
 Detect Evil: On Exit
 Created By: Philos
////////////////////////////////////////////////
    Creatures exiting the zone if good have the
    highlight removed.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_player"

void main()
{
    object oTarget = GetExitingObject();
    if (GetLocalInt (oTarget, "0_GoodGlow"))
    {
        //Declare major variables
        object oCaster = GetAreaOfEffectCreator();
        if (oTarget != oCaster)
        {
            int nVFX;
            // Remove any previous effect on this target.
            // Get level of creature and change effect based on CR.
            float fCR = GetChallengeRating (oTarget);
            if (fCR > 16.0f) nVFX = VFX_DUR_GLOW_RED;
            else if (fCR > 12.0f) nVFX = VFX_DUR_GLOW_LIGHT_RED;
            else if (fCR > 8.0f) nVFX = VFX_DUR_AURA_RED_DARK;
            else if (fCR > 4.0f) nVFX = VFX_DUR_AURA_RED;
            else nVFX = VFX_DUR_AURA_RED_LIGHT;
            NWNX_Player_ApplyLoopingVisualEffectToObject (oCaster, oTarget, nVFX);
            DeleteLocalInt (oTarget, "0_GoodGlow");
        }
    }
}
