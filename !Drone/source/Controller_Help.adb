with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.Toolbox;             use RASCAL.Toolbox;
with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.UserMessages;
with RASCAL.InteractiveHelp;
with RASCAL.StrongHelp;

with Main;                       use Main;
with Ada.Exceptions;
with Reporter;

package body Controller_Help is

   --

   package Utility         renames RASCAL.Utility;
   package Toolbox         renames RASCAL.Toolbox;        
   package WimpTask        renames RASCAL.WimpTask;       
   package UserMessages    renames RASCAL.UserMessages;   
   package InteractiveHelp renames RASCAL.InteractiveHelp;
   package StrongHelp      renames RASCAL.StrongHelp;     

   --

   procedure Handle (The : TEL_ViewManual_Type) is
   begin
      Call_OS_CLI("Filer_Run <Drone$Dir>.!Help");
   exception
      when e: others => Report_Error("VIEWMANUAL",Ada.Exceptions.Exception_Information (e));
   end Handle;

   --

   procedure Handle (The : TEL_ViewSection_Type) is

      Menu_Entry  : Component_ID := Get_Self_Component(Main_Task);
   begin
      if StrongHelp.Run then
         case Menu_Entry is
         when 16#0# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Intro");
         when 16#1# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Install");
         when 16#2# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Start");
         when 16#3# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Problems");
         when 16#4# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Bugz");
         when 16#5# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Language");
         when 16#6# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone History");
         when 16#7# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Third");
         when 16#8# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone WhatToDo");
         when 16#9# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone Shortcuts");
         when 16#a# => Call_OS_CLI("stronghelp <DroneRes$Dir>.Drone CLIUse");
         when others=> null;
         end case;
      end if;
   exception
      when e: others => Report_Error("VIEWCHAPTER",Ada.Exceptions.Exception_Information (e));
   end Handle;

   --
   
   procedure Handle (The : in TEL_ViewIHelp_Type) is
   begin
      InteractiveHelp.Run;
   exception
      when e: others => Report_Error("VIEWIHELP",Ada.Exceptions.Exception_Information (e));      
   end Handle;

   --

end Controller_Help;
