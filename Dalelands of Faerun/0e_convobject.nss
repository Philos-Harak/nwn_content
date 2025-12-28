/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_convobject
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event that fires when a player clicks on the object to use it
 Place this script in the OnClick of an object.
 This will start a conversation for the object.
 Variables:
 0_Conversation will define which group from the conversation is used.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_s_message"

void WaitForConversation (object oClicker, object oObject, int iCounter = 0)
{
    //Debug ("0e_convobject", "16", GetName (oClicker) + " to " + GetName (oObject) + " (" + IntToString (iCounter) + ")");
    float fDistance;
    // if we have run this script more than 10 times then exit.
    if (iCounter < 10)
    {
        // Get the distance from the transition
        fDistance = GetDistanceBetween (oClicker, oObject);
        // if its more than 2.5 meters then wait.
        if (fDistance > TOUCH_DISTANCE)
        {
            // Increase counter and wait another cycle.
            DelayCommand (3.0, WaitForConversation (oClicker, oObject, ++ iCounter));
        }
        // We are close enough so lets transition.
        else
        {
            // Check to see if this object is in a conversation.
            if (!IsInConversation (oObject)) ActionStartConversation (oClicker, "", TRUE, FALSE);
            else SendMessages ("This object is already being used. Please wait until someone else is done.", COLOR_GRAY, oClicker, FALSE, FALSE);
        }
    }
}

void main ()
{
    object oPC = GetPlaceableLastClickedBy ();
    // Check to see if they are close enough.
    if (GetDistanceBetween (oPC, OBJECT_SELF) < TOUCH_DISTANCE)
    {
        // Check to see if this object is in a conversation.
        if (!IsInConversation (OBJECT_SELF)) ActionStartConversation (oPC, "", TRUE, FALSE);
        else SendMessages ("This object is already being used. Please wait until someone else is done.", COLOR_GRAY, oPC, FALSE, FALSE);
    }
    else
    {
            // Only move them closer on the first script run.
            ActionMoveToObject (OBJECT_SELF, TRUE);
            WaitForConversation (oPC, OBJECT_SELF);
    }
}

