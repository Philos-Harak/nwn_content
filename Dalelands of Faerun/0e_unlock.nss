/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_unlock
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event that fires when someone unlocks a door or placeable.
 Gives a small experience bonus for unlocking it.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void main ()
{
   object oUnlocker = GetLastUnlocked ();
   if (GetLocked (OBJECT_SELF) && !GetLockKeyRequired (OBJECT_SELF))
   {
      int nXP = GetLockUnlockDC (OBJECT_SELF);
      int nCR = GetLocalInt (GetArea (OBJECT_SELF), "0_Area_Level");
      object oUnlocker = GetLocalObject (OBJECT_SELF, "0_Unlocker");
      // Lets give the xp out.
      GiveAreaXP (oUnlocker, IntToFloat (nXP) + BASE_UNLOCK_XP, IntToFloat (nCR));
   }
}

