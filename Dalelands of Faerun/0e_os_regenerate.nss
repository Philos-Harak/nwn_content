/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_os_regenerate
 Programmer: Lorinton
////////////////////////////////////////////////////////////////////////////////
 Creature OnSpawn script.
    Sets up regeneration on creatures.
/*///////////////////////////////////////////////////////////////////////////////

void main()
{
    // Set the regenerating creature  to immortal so they can live till they
    // take enough permanent damage to actually die (Fire and/or Acid dmg).
    SetImmortal (OBJECT_SELF, TRUE);
    ExecuteScript ("nw_c2_default9", OBJECT_SELF);
}

