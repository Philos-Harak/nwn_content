/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_useplaceable
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnUse event to use a placeable.
 Variable:
 0_USE_SOUND - The sound file to play when used.
 al_cv_pump - Make water sound for water pump.
 as_cv_smithhamrl - Make hammer sound on an anvil.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    object oCreature = GetLastUsedBy ();
    // Play animation on creature.
    ActionPlayAnimation (ANIMATION_LOOPING_GET_MID);
    // Is the object on?
    if (GetLocalInt(OBJECT_SELF,"NW_L_AMION") == FALSE)
    {
        // Turn on.
        PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",TRUE);
    }
    // Animiation is on...
    else
    {
        // Turn animation off.
        PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",FALSE);
    }
    string sUse = GetLocalString (OBJECT_SELF, "0_USE_SOUND");
    if (sUse != "") PlaySound (sUse);
}

