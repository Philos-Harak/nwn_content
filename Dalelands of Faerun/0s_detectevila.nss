/*////////////////////////////////////////////////
 Detect Evil: On Enter
 Created By: Philos
////////////////////////////////////////////////
    Creatures entering the zone if evil are checked
    to see if they are evil and if so they get
    a highlight.
/*///////////////////////////////////////////////
#include "nwnx_player"

void main()
{
    object oTarget = GetEnteringObject();
    if (GetAlignmentGoodEvil (oTarget) == ALIGNMENT_EVIL && !GetLocalInt (oTarget, "0_EvilGlow"))
    {
        //Declare major variables
        object oCaster = GetAreaOfEffectCreator();
        if (oTarget != oCaster)
        {
            int nVFX;
            // Get level of creature and change effect based on CR.
            float fCR = GetChallengeRating (oTarget);
            if (fCR > 16.0f) nVFX = VFX_DUR_GLOW_RED;
            else if (fCR > 12.0f) nVFX = VFX_DUR_GLOW_LIGHT_RED;
            else if (fCR > 8.0f) nVFX = VFX_DUR_AURA_RED_DARK;
            else if (fCR > 4.0f) nVFX = VFX_DUR_AURA_RED;
            else nVFX = VFX_DUR_AURA_RED_LIGHT;
            NWNX_Player_ApplyLoopingVisualEffectToObject (oCaster, oTarget, nVFX);
            SetLocalInt (oTarget, "0_EvilGlow", TRUE);
        }
    }
}
