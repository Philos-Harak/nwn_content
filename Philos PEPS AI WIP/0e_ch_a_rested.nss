/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_a_rested
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate OnRested event script;
  Fires when the creature attempts to rest via ActionRest or a PC rests.
*///////////////////////////////////////////////////////////////////////////////
//******************************  ADDED AI CODE  *******************************
//#include "0i_associates"
#include "0i_assoc_debug"
//******************************  ADDED AI CODE  *******************************
void main()
{
    //******************************  ADDED AI CODE  *******************************
    ai_OnRested(OBJECT_SELF);
    //******************************  ADDED AI CODE  *******************************
}
