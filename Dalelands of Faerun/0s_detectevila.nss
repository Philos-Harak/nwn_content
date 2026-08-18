/*////////////////////////////////////////////////
 Detect Evil: On Enter
 Created By: Philos
////////////////////////////////////////////////
    Creatures entering the zone if evil are checked
    to see if they are evil and if so they get
    a highlight.
/*///////////////////////////////////////////////
#include "0i_s_message"
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
            string sLevel;
            // Get level of creature and change effect based on CR.
            float fCR = GetChallengeRating(oTarget);
            if(fCR > 16.0f) { nVFX = VFX_DUR_GLOW_RED; sLevel = "overwhelming";}
            else if(fCR > 12.0f) { nVFX = VFX_DUR_GLOW_LIGHT_RED; sLevel = "strong";}
            else if(fCR > 8.0f) { nVFX = VFX_DUR_AURA_RED_DARK; sLevel = "strong";}
            else if(fCR > 4.0f) { nVFX = VFX_DUR_AURA_RED; sLevel = "faint";}
            else { nVFX = VFX_DUR_AURA_RED_LIGHT; sLevel = "faint";}
            NWNX_Player_ApplyLoopingVisualEffectToObject (oCaster, oTarget, nVFX);
            SetLocalInt (oTarget, "0_EvilGlow", TRUE);
            if(GetHasFeat(1565/*AURA_OF_ALIGNMENT*/, oTarget) || GetRacialType(oTarget) == RACIAL_TYPE_OUTSIDER)
            {
                SendMessages(GetName(oTarget) + " has a " + sLevel + " aura of Evil!", COLOR_RED, oCaster);
            }
        }
    }
}
