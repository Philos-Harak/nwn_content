/*////////////////////////////////////////////////
 Script: 0s_widen_spell
 Programmer: Philos
////////////////////////////////////////////////
Allows a player to change from maximized metamagic
to widened metamagic.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    object oCaster = OBJECT_SELF;
    if(GetLocalInt(oCaster, "0_Widen_Spell"))
    {
        SetLocalInt(oCaster, "0_Widen_Spell", FALSE);
        if(GetIsCharacter(oCaster))
        {
        SendMessages("Maximized metamagic will now be applied to any spells set to Maximized.", COLOR_GRAY, oCaster);
        }
        else SendMessages(GetName(oCaster) + " will now have Maximized metamagic applied to any spells set to Maximized.", COLOR_GRAY, GetMaster(oCaster));
    }
    else
    {
        SetLocalInt(oCaster, "0_Widen_Spell", TRUE);
        if(GetIsCharacter(oCaster))
        {
            SendMessages("Widened metamagic will now be applied to any spells set to Maximized instead.", COLOR_GRAY, oCaster);
        }
        else SendMessages(GetName(oCaster) + " will now have Widened metamagic applied to any spells set to Maximized instead.", COLOR_GRAY, GetMaster(oCaster));
    }
}




