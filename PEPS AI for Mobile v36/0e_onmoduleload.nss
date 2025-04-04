/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_onmoduleload
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnModuleLoad script;
  This will fire when the module is loading.

  If you have your own OnModuleLoad event script just take the below
  script lines and add them into your OnModuleLoad script.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
void main()
{
    // This can be moved to the OnModuleLoad script event.
    ai_SetAIRules();
}
