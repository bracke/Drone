with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;

with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.Variable;            use RASCAL.Variable;
with RASCAL.Toolbox;             use RASCAL.Toolbox;
with RASCAL.OS;                  use RASCAL.OS;

package Main is   

   -- Constants
   app_name       : constant String := "Drone";
   Choices_Write  : constant String := "<Choices$Write>." & app_name;
   Choices_Read   : constant String := "Choices:" & app_name & ".Choices";
   scrapdir       : constant String := "<Wimp$ScrapDir>." & app_name;

   -- Types
   type Tokens is (APPNAME,PURPOSE,AUTHOR,LICENCE,APPPAGE,HOMEPAGE,EMAIL,DATE,VERSION,RELEASETARGET,WIMPSLOT,NAME);

   type Global is
   record
   Value : UString;
   Name  : UString;
   end record;

   type Global_Array is array(Tokens) of Global;

   --
   Main_Task           : ToolBox_Task_Class;
   main_objectid       : Object_ID             := -1;
   main_winid          : Wimp_Handle_Type      := -1;
   status_objectid     : Object_ID;
   saveas_objectid     : Object_ID;

   --

   Globals             : Global_Array;
   untitled            : ustring;

   --

   procedure Report_Error (Token : in String;
                           Info  : in String);

   --

   procedure Main;

   --

   procedure Go (Path : in String);

   --

   procedure Process_File (S : in String;
                           T : in String);

   --

   procedure Process_Dir (Source : in String;
                          T      : in String);

   --

   procedure Read_Choices (Path : in String);

   --

 end Main;


