/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_gui_events
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnPlayerGUIEvent event script
    Used to allow PEPS to gain control of specific GUI events.

/*//////////////////////////////////////////////////////////////////////////////
#include "0i_gui_events"
#include "0i_menus"
void main()
{
    object oPC = GetLastGuiEventPlayer();
    int nEventType = GetLastGuiEventType();
    int nEventInt = GetLastGuiEventInteger();
    //object oEventObject = GetLastGuiEventObject();
    switch(nEventType)
    {
        case GUIEVENT_EFFECTICON_CLICK:
        {
            if(ai_GetMagicMode(oPC, AI_MAGIC_EFFECT_ICON_REPORT))
            {
                ai_CreateEffectChatReport(oPC, nEventInt);
                return;
            }
            int nToken = NuiFindWindow(oPC, AI_EFFECT_ICON_NUI);
            json jData;
            if(nToken)
            {
                jData = NuiGetUserData(oPC, nToken);
                int nOldEffectIcon = JsonGetInt(JsonArrayGet(jData, 1));
                DelayCommand(0.0, NuiDestroy(oPC, nToken));
                if(nOldEffectIcon == nEventInt) return;
            }
            ai_CreateEffectIconMenu(oPC, nEventInt);
        }
        case GUIEVENT_PARTYBAR_PORTRAIT_CLICK:
        {
            object oAssociate = GetLastGuiEventObject();
            if(GetMaster(oAssociate) == oPC)
            {
                // If all the Command buttons are blocked then don't load the menu.
                if(GetLocalInt(GetModule(), sDMWidgetAccessVarname) != 7340028)
                {
                    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
                    if(IsWindowClosed(oPC, sAssociateType + AI_COMMAND_NUI))
                    {
                        ai_CreateAssociateCommandNUI(oPC, oAssociate);
                    }
                    IsWindowClosed(oPC, sAssociateType + AI_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_LOOTFILTER_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_COPY_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_SPELL_MEMORIZE_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_SPELL_KNOWN_NUI);
                }
            }
        }
    }
}
