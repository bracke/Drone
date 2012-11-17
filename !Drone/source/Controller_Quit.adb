with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.TaskManager;

with Main;                       use Main;
with Ada.Exceptions;
with Reporter;

package body Controller_Quit is

   --

   package Utility      renames RASCAL.Utility;
   package WimpTask     renames RASCAL.WimpTask;   
   package TaskManager  renames RASCAL.TaskManager;

   --

   procedure Handle (The : in TEL_Quit_Quit) is
   begin
      Set_Status(Main_Task,false);
   exception
      when e: others => Report_Error("TQUIT",Ada.Exceptions.Exception_Information (e));
   end Handle;
   
   --

   procedure Handle (The : in MEL_Message_Quit) is
   begin
      Set_Status(Main_Task,false);
   exception
      when e: others => Report_Error("MQUIT",Ada.Exceptions.Exception_Information (e));            
   end Handle;

   --
        
end Controller_Quit;
