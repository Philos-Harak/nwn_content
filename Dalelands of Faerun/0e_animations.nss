/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_animations
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster Ambient Animations and Walk Waypoint code.
  This hooks into PEPS AI and uses the servers animations instead!
  This is called in the nw_c2_default1 - monster heartbeat script.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_animate"
void main()
{
    if(!IsInConversation (OBJECT_SELF))
    {
         // They are not talking to someone lets check for animations.
         CheckCreatureAI ();
    }
}

