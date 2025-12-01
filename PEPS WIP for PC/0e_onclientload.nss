/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_onclientload
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnClientLoad script;
  This will fire when the client is loading.

  If you have your own OnClientLoad event script just take the below
  script lines and add them into your OnClientLoad script.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus_dm"
#include "0i_module"
void main()
{
    object oCreature = OBJECT_SELF;
    // This can be moved to the OnClientLoad script event of your module.
    if(ai_GetIsCharacter(oCreature)) ai_CheckPCStart(oCreature);
    else if(ai_GetIsDungeonMaster(oCreature)) ai_CheckDMStart(oCreature);
}
