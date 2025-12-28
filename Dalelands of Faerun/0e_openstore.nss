/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_openstore
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script for opening a store near the placeable.
 Use in onclick
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_s_message"

void WaitToOpen (object oClicker, object oObject, object oStore, int iCounter = 0)
{
    //Debug ("0e_openstore", "13", GetName (oClicker) + " to " + GetName (oObject) + " (" + IntToString (iCounter) + ")");
    float fDistance;
    // if we have run this script more than 10 times then exit.
    if (iCounter < 10)
    {
        // Get the distance from the transition
        fDistance = GetDistanceBetween (oClicker, oObject);
        // if its more than 2.5 meters then move them closer and wait.
        if (fDistance > 2.5f)
        {
            // Increase counter and wait another cycle.
            DelayCommand (1.0, WaitToOpen (oClicker, oObject, oStore, ++ iCounter));
        }
        // We are close enough so lets transition.
        else
        {
            if (GetIsObjectValid(oStore) == TRUE) OpenStore (oStore, oClicker);
            else SetModuleError ("STORE", "0e_openstore", "33", GetName (OBJECT_SELF) + " does not have a store near it!");
        }
    }
}

void main()
{
    object oStore = GetNearestObject (OBJECT_TYPE_STORE);
    float fDistance;
    object oClicker = GetPlaceableLastClickedBy ();
    fDistance = GetDistanceBetween (oClicker, OBJECT_SELF);
    if (fDistance > 2.5f)
    {
        // Only move them closer on the first script run.
        ActionMoveToObject (OBJECT_SELF, TRUE, 15.0f);
        WaitToOpen (oClicker, OBJECT_SELF, oStore);
    }
    else
    {
        if (GetIsObjectValid(oStore) == TRUE) OpenStore (oStore, oClicker);
        else SetModuleError ("STORE", "0e_openstore", "56", GetName (OBJECT_SELF) + " does not have a store near it!");
    }
}

