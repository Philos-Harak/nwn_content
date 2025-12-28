/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_gui_events
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a player interacts with the GUI.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_win_layout_pc"
void main()
{
    object oPC = GetLastGuiEventPlayer ();
    int nEventType = GetLastGuiEventType ();
    int nEventInteger = GetLastGuiEventInteger ();
    object oEventObject = GetLastGuiEventObject ();
    switch (nEventType)
    {
        case GUIEVENT_DISABLED_PANEL_ATTEMPT_OPEN :
        {
            switch (nEventInteger)
            {
                case GUI_PANEL_PLAYERLIST :
                {
                    PopUpPlayerListGUIPanel (oPC);
                }
            }
        }
    }

}

