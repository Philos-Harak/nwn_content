//::///////////////////////////////////////////////
//:: Language Feat
//:: 0s_l_mulhorandi
//:://////////////////////////////////////////////
/*
    Sets up a language to be used.
*/
//:://////////////////////////////////////////////
//:: Created By: Kevin Curtis
//:: Created On: 2016-14-6
//:://////////////////////////////////////////////

#include "0i_s_message"

void main()
{
    object oUser = OBJECT_SELF;
    SetLocalInt (oUser, "0_Language", 1191);
    SendMessages ("You have changed your language to Mulhorandi", COLOR_GRAY, oUser, FALSE, FALSE);
    SendMessages ("Any text in [] will be in Mulhorandi.", COLOR_GRAY, oUser, FALSE, FALSE);
}
