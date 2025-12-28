/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_eyeglow
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script that sets the script to run on conversation select.
 Used to run various functions from one conversation.
 Sets up eye glow for a PC.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_effects"

void main()
{
    // Get the selections.
    string sGroup = GetLocalString (OBJECT_SELF, "0_Conv_Group");
    string sSelect = GetLocalString (OBJECT_SELF, "0_Conv_Select");
    int nSelect = StringToInt (sSelect);
    // The selection number is the same as the eye number.
    SetLocalInt (OBJECT_SELF, "EYES", nSelect);
    ApplyGlowingEyes (nSelect, OBJECT_SELF);
}

