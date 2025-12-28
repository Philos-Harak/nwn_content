/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_del_placeable
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Add to on_use in a placeable to have it remove the placeable.
*///////////////////////////////////////////////////////////////////////////////
void main()
{
    location lLocation = GetLocation (OBJECT_SELF);
    ActionMoveToLocation (lLocation);
    AssignCommand (GetLastUsedBy (), ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW));
    ActionDoCommand (DestroyObject (OBJECT_SELF, 1.0f));
}
