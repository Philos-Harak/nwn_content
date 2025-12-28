/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pclvlupbefore
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs before the character levels up but just after hitting the level up button.
 Used to allow special requirements for Prestige classes.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void main()
{
    // Remove Tenser's Transformation before leveling as it will affect feats
    // and class requirements.
    ExecuteScript("0s_tenstrans_r", OBJECT_SELF);
    SetPrestigeClassesForLevelUp (OBJECT_SELF);
}

