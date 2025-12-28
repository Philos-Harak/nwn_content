/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_elem_trans
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Feat that allows the caster to make any elemental spells use that players
 choosen element.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
void main()
{
    object oCaster = GetLastSpellCaster ();
    // Check to see if we are turning on elemental transferance or turning it off.
    int iTransferance = GetLocalInt (oCaster, "0_Elem_Transferance");
    // If on
    if (iTransferance)
    {
        // turn off
        SetLocalInt (oCaster, "0_Elem_Transferance", FALSE);
        // Send message.
        SendMessages ("Elemental Transferance mode OFF!", COLOR_YELLOW, oCaster);
    }
    // If off
    else
    {
        // turn on
        SetLocalInt (oCaster, "0_Elem_Transferance", TRUE);
        // Send message.
        SendMessages ("Elemental Transferance mode ON!", COLOR_YELLOW, oCaster);
    }
}
