/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_trans_bypass
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that transitions a player to the target location
 automatically.
 Param:
 TransitionTag - the tag of the object to transition to (Must be unique).
 Variables on OBJECT_SELF:
 0_TransitionTag: Will use this variable if Param is "".
*///////////////////////////////////////////////////////////////////////////////
#include "0i_area"
void main()
{
   object oPC = GetPlaceableLastClickedBy ();
   string sTag = GetScriptParam ("sTransitionTag");
   // If the conversation didn't pass a transition tag then it must be on the object.
   if (sTag == "") sTag = GetLocalString (OBJECT_SELF, "0_TransitionTag");
   // If it did pass a transition tag lets put it on the object for the Transition function.
   else SetLocalString (OBJECT_SELF, "0_TransitionTag", sTag);
   // Transition function uses Move_Tran to get the transitioning object.
   SetLocalObject (oPC, "Move_Tran", OBJECT_SELF);
   Transition (oPC);
}
