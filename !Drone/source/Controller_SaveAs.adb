with RASCAL.OS;                  use RASCAL.OS;
with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.FileName;            use RASCAL.FileName;
with RASCAL.FileExternal;        use RASCAL.FileExternal;
with RASCAL.MessageTrans;        use RASCAL.MessageTrans;
with RASCAL.Error;               use RASCAL.Error;

with Main;                       use Main;
with Interfaces.C;               use Interfaces.C;
with Reporter;

package body Controller_SaveAs is

   --

   package OS           renames RASCAL.OS;
   package Utility      renames RASCAL.Utility;     
   package WimpTask     renames RASCAL.WimpTask;    
   package FileName     renames RASCAL.FileName;    
   package FileExternal renames RASCAL.FileExternal;
   package MessageTrans renames RASCAL.MessageTrans;
   package Error        renames RASCAL.Error;       

   --
   
   procedure Handle (The : in TEL_SaveAs_AboutToBeShown) is

      Object : Object_ID := Get_Self_Id(Main_Task);
      Name   : string    := Get_FileName(Object);
   begin
      Read_Choices(S(untitled));
      if Name'Length = 0 then
         Set_FileName(Object,S(Globals(APPNAME).Value));
      else
         Set_FileName(Object,Get_Path(Convert_Path(Name)) & S(Globals(APPNAME).Value));
      end if;
   end Handle;

   --     

   procedure Handle (The : in TEL_SaveAs_SaveToFile) is

     Object  : Object_ID             := Get_Self_Id(Main_Task);
     File    : String                := To_Ada(The.Event.all.Filename);
     Path    : String                := Get_Path(File);
     Name    : String                := Get_Leaf(File);
     Target  : UString;
     E       : Error.Error_Pointer   := Get_Error(Main_Task);
     M       : Error_Message_Pointer := new Error_Message_Type;
     R       : Error_Return_Type;
   begin
     if Name'Length = 0 or else (Name(Name'First)/='!') then
        Target := U(Path & "!" & Name);
     else
        Target := U(Path & Name);
     end if;
     Set_FileName(Object,S(Target));
     Hide_Object(Object);

     if Exists(S(Target)) then
        -- Error application exists already.
        M.all.Token(1..6) := "EXISTS";
        R := Show_Message(E,M);
     else
        Go(S(Target));
     end if;
   end Handle;

   --
   
        
end Controller_SaveAs;
