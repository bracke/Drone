with Controller_Quit;                  use Controller_Quit;
with Controller_Internet;              use Controller_Internet;
with Controller_Bugz;                  use Controller_Bugz;
with Controller_Choices;               use Controller_Choices;
with Controller_Help;                  use Controller_Help;
with Controller_SaveAs;                use Controller_SaveAs;
with Controller_Error;                 use Controller_Error;
with Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;
with Text_IO;
with Reporter;

with RASCAL.OS;                        use RASCAL.OS;
with RASCAL.Toolbox;                   use RASCAL.Toolbox;
with RASCAL.MessageTrans;              use RASCAL.MessageTrans;
with RASCAL.Error;                     use RASCAL.Error;
with RASCAL.FileExternal;              use RASCAL.FileExternal;
with RASCAL.FileInternal;              use RASCAL.FileInternal;
with RASCAL.Sprite;                    use RASCAL.Sprite;
with RASCAL.Utility;                   use RASCAL.Utility;
with RASCAL.ToolboxDisplayField;       use RASCAL.ToolboxDisplayField;
with RASCAL.TaskManager;               use RASCAL.TaskManager;
with RASCAL.ToolboxProgInfo;
with RASCAL.FileName;
with RASCAL.Time;
with RASCAL.Variable;
with RASCAL.Module;

package body Main is

   --

   package OS                   renames RASCAL.OS;
   package Toolbox              renames RASCAL.Toolbox;            
   package MessageTrans         renames RASCAL.MessageTrans;       
   package Error                renames RASCAL.Error;              
   package FileExternal         renames RASCAL.FileExternal;       
   package FileInternal         renames RASCAL.FileInternal;       
   package Sprite               renames RASCAL.Sprite;             
   package Utility              renames RASCAL.Utility;            
   package ToolboxDisplayField  renames RASCAL.ToolboxDisplayField;
   package TaskManager          renames RASCAL.TaskManager;        
   package ToolboxProgInfo      renames RASCAL.ToolboxProgInfo;    
   package FileName             renames RASCAL.FileName;           
   package Time                 renames RASCAL.Time;               
   package Variable             renames RASCAL.Variable;           
   package Module               renames RASCAL.Module;
   package WimpTask             renames RASCAL.WimpTask;
   
   --

   procedure Report_Error (Token : in String;
                           Info  : in String) is

      E        : Error_Pointer          := Get_Error (Main_Task);
      M        : Error_Message_Pointer  := new Error_Message_Type;
      Result   : Error_Return_Type      := XButton1;
   begin
      M.all.Token(1..Token'Length) := Token;
      M.all.Param1(1..Info'Length) := Info;
      M.all.Category := Warning;
      M.all.Flags    := Error_Flag_OK;
      Result         := Error.Show_Message (E,M);
   end Report_Error;

   --

   procedure Go (Path : in String) is

      E      : Error.Error_Pointer   := Get_Error(Main_Task);
      M      : Error_Message_Pointer := new Error_Message_Type;
      R      : Error_Return_Type;
   begin
      Hide_Object(saveas_objectid);
      Show_Object(Object => status_objectid,Show => Centre);
      Set_Value(status_objectid,2,Lookup("READCHOICES",Get_Message_Block(Main_Task)));
      Single_Poll(Main_Task);
      Read_Choices (Path);
      Set_Value(status_objectid,2,Lookup("DIRSTRUCT",Get_Message_Block(Main_Task)));
      Single_Poll(Main_Task);
      Create_Directory (Path);
      declare
         Source     : String               := "<DroneResources$Dir>.Skeleton";
         Dir_List   : Directory_Type       := FileExternal.Get_Directory_List(Source,True);
         MCB        : Messages_Handle_Type := MessageTrans.Open_File(Choices_Read);
      begin
         for i in Dir_List'Range loop
            Set_Value(status_objectid,2,S(Dir_List(i)));
            Single_Poll(Main_Task);
            declare
               Token    : String := Ada.Characters.Handling.To_Upper(S(Dir_List(i)));
               Chosen   : String := Lookup(Token,MCB);
               File     : String := Lookup(Token & "FILE",MCB);
            begin
               if Chosen'Length > 0 and
                  then File'Length > 0 and
                  then Boolean'Value(Chosen) then

                  Process_Dir (Source & "." & S(Dir_List(i)) & "." & File,Path);
               end if;
            end;
         end loop;
         Close_File(MCB);
      exception
      when ex: others => M.all.Token(1..4) := "OBEY";
                         M.all.Flags := Error_Flag_Ok + Error_Flag_Cancel;
                         M.all.Param1(1..Ada.Exceptions.Exception_Information (ex)'Length)
                         := Ada.Exceptions.Exception_Information (ex);
                         R:=Show_Message (E,M);
                         if R = Cancel then
                            raise;
                         end if;
      end;
      Hide_Object(status_objectid);
   end Go;

   --

   function Process_Line (Line_Str : in String) return String is

      Pre,Post        : UString;
      I1,I2,I3        : Integer;
      Line            : UString := U(Line_Str);
   begin
      for tok in Tokens'range loop
         i1 := Ada.Strings.Unbounded.Index(Line,To_String(Globals(tok).Name));

         while i1>0 loop
            pre := Ada.Strings.Unbounded.Head(Line,i1-1);
            i2 := Ada.Strings.Unbounded.Length(Line);
            i3 := Ada.Strings.Unbounded.Length(Globals(tok).Name);
            i2 := i2 - (i1 - 1 + i3);
            post := Ada.Strings.Unbounded.Tail(Line,i2);
            Line := pre & Globals(tok).Value & post;
            i1 := Ada.Strings.Unbounded.Index(Line,To_String(Globals(tok).Name));
         end loop;
      end loop;

      return S(Line);

   end Process_Line;

   --

   function Process_FileName (Name : in String) return String is

      Path      : String := FileName.Get_Path(Name);
      Leaf_2    : String := FileName.Get_Leaf(Name);
      Leaf      : String(1..Leaf_2'Length) := Leaf_2;
      Temp_Leaf : Unbounded_String := U(Leaf);
      Processed : UString;
      I         : Natural;
   begin
      I := Ada.Strings.Unbounded.Index (Temp_Leaf,"!!");
      while i > 0 loop
         if i > 1 then
            Temp_Leaf := U(Ada.Strings.Unbounded.Slice(Temp_Leaf,1,i-1) & "<" & Ada.Strings.Unbounded.Slice (Temp_Leaf,i+2,Length(Temp_Leaf)));
         else
            Temp_Leaf := U("<" & Ada.Strings.Unbounded.Slice (Temp_Leaf,i+2,Length(Temp_Leaf)));
         end if;
         I := Ada.Strings.Unbounded.Index (Temp_Leaf,"!!");
         if i > 0 then
            Temp_Leaf := U(Ada.Strings.Unbounded.Slice(Temp_Leaf,1,i-1) & ">" & Ada.Strings.Unbounded.Slice (Temp_Leaf,i+2,Length(Temp_Leaf)));
         end if;
         I := Ada.Strings.Unbounded.Index (Temp_Leaf,"!!");
      end loop;
      Processed := U(Process_Line(S(Temp_Leaf)));
      return Path & S(Processed);
   exception
      when others => return Name;
   end Process_Filename;

   --

   procedure Process_Dir (Source : in String;
                          T      : in String) is

      Dir_List   : Directory_Type := FileExternal.Get_Directory_List(Source,True);
      Object     : File_Object_Type;
      Target     : String := Process_Filename (T);
   begin
      for i in Dir_List'Range loop
         declare
            Name : String := S(Dir_List(i));
         begin
            Single_Poll(Main_Task);
            if Name'Length > 0 then
               Object := Get_Object_Type(Source & "." & Name);
               case Object is
               when Dir         => Create_Directory(Process_Filename(Target & "." & Name));
                                   Process_Dir(Source & "." & Name,Process_Filename(Target & "." & Name));
               when Image       => if Variable.Get_Value("StrongHelp$Dir")'Length > 0 and Module.Is_Module("StrongHelp") then
                                      FileExternal.Create_Directory ("<Wimp$ScrapDir>.DroneSH");

                                      Process_Dir(Source & "." & Name,"<Wimp$ScrapDir>.DroneSH");
                                      Call_OS_CLI ("WimpTask <StrongHelp$Dir>.Utilities.CleanCopy <Wimp$ScrapDir>.DroneSH " & Process_Filename(Target & "." & Name));
                                      FileExternal.Wipe ("<Wimp$ScrapDir>.DroneSH");
                                   else
                                      FileExternal.Copy(Source,Process_Filename(Target));
                                   end if;
               when File_Object => Process_File(Source & "." & Name,Process_Filename(Target & "." & Name));
               when Not_Found   => null;
               end case;
            end if;
         end;
      end loop;
   end Process_Dir;


   --

   procedure Process (Source : In String;
                      Target : in String) is

      s    : FileHandle_Type(new UString'(U(Source)),Read);
      t    : FileHandle_Type(new UString'(U(Target)),Write);
      Line : UString;
   begin
      while not Is_EOF(s) loop
         Line := U(Read_Line(s));
         Line := U(Process_Line(To_String(Line)));
         Put_String(t,To_String(Line));
      end loop;
   end Process;

   --

   procedure BASIC2Text (Source : in String;
                         Target : in String) is
      Child : Integer;
   begin
      Child := Start_Task ("<Drone$Dir>.Resources.bastext -t " & Target & " " & Source & "{ > null: }");
   end BASIC2Text;

   --

   procedure Text2BASIC (Source : in String;
                         Target : in String) is
      Child : Integer;
   begin
      FileExternal.Set_File_Type (Source,16#fff#);
      Child := Start_Task ("<Drone$Dir>.Resources.bastext -b " & Target & " " & Source & "{ > null: }");
   end Text2BASIC;

   --

   procedure Process_Sprite (Source : in String;
                             Target : in String) is
                             
      SpriteArea    : Sprite_Area_Type;
      Name,New_Name : UString;
   begin
      Sprite.Add_Sprite(SpriteArea,Source);
      declare
         Sprite_List : Sprite_List_Type:= Get_SpriteList(SpriteArea);
      begin
         for i in Sprite_List'Range loop
            Name     := Sprite_List(i);
            New_Name := U(Process_Line(Ada.Characters.Handling.To_Upper(S(Name))));
            Rename_Sprite(SpriteArea,S(Name),S(New_Name));
         end loop;
      end;
      Save_SpriteArea(SpriteArea,Target);
   end Process_Sprite;

   --


   procedure Process_File (S : in String;
                           T : in String) is

      FType   : Integer;
      Source  : String := S;
      Target  : String := Process_FileName(T);
   begin
      if not FileExternal.Exists(Target) then
         FType := Get_File_Type (Source);
         case FType is
         when 16#FAE# |
              16#FEC# => Call_OS_CLI ("WimpTask Run <CCRes$Dir> " & Source & " <Wimp$ScrapDir>.ResText");
                         Process ("<Wimp$ScrapDir>.ResText","<Wimp$ScrapDir>.ResUpdated");
                         FileExternal.Set_File_Type("<Wimp$ScrapDir>.ResUpdated",16#FFF#);
                         Call_OS_CLI ("WimpTask Run <CCRes$Dir> " & "<Wimp$ScrapDir>.ResUpdated " & Target);
                         FileExternal.Delete_File ("<Wimp$ScrapDir>.ResText");
                         FileExternal.Delete_File ("<Wimp$ScrapDir>.ResUpdated");
                                   
         when 16#FF9# |
              16#3d6# => Process_Sprite (Source,Target);
         
         when 16#FF8# => FileExternal.Copy(Source,Target);
         
         when 16#ffb# => BASIC2Text (Source,"<Wimp$ScrapDir>.tokenless");
                         Process ("<Wimp$ScrapDir>.tokenless","<Wimp$ScrapDir>.tokenless2");
                         Text2BASIC ("<Wimp$ScrapDir>.tokenless2",Target);
                         FileExternal.Delete_File ("<Wimp$ScrapDir>.tokenless");
                         FileExternal.Delete_File ("<Wimp$ScrapDir>.tokenless2");
         
         when others  => Process (Source,Target);
         end case;
         FileExternal.Set_File_Type(Target,FType);
      end if;         
   end Process_File;

   --

   procedure Read_Choices(Path : in String) is

      MCB    : Messages_Handle_Type  := Open_File(Choices_Read);
      E      : Error.Error_Pointer   := Get_Error(Main_Task);
      M      : Error_Message_Pointer := new Error_Message_Type;
      R      : Error_Return_Type;
   begin
      -- Info
      for t in Tokens'Range loop

         Globals(t).Value := U(Lookup(Tokens'image(t),MCB));
         Globals(t).Name  := U("<DRONE_" & Tokens'image(t) & ">");

         if Tokens'image(t) = "APPNAME" then
            if Globals(t).Value = "" then
               Globals(t).Value := U(FileName.Get_Leaf(Path));
               if Ada.Strings.Unbounded.Element(Globals(t).Value,1)= '!' then
                  Globals(t).Value := Ada.Strings.Unbounded.Tail(Globals(t).Value,Ada.Strings.Unbounded.Length(Globals(t).Value)-1);
               end if;
            end if;
         elsif Tokens'image(t) = "DATE" then
            if Globals(t).Value = "" then
               Globals(t).Value := U(Time.Get_Date("%ce%yr-%mn-%dy"));
            end if;
         end if;
      end loop;

      for t in Tokens'Range loop
          Globals(t).Value := U(Process_Line(S(Globals(t).value)));
      end loop;

      --
      Close_File(MCB);

   exception
     when Messages_File_Is_Closed      => M.all.Token(1..9) := "MSGCLOSED";
                                          R := Show_Message(E,M);
     when others => raise;
   end Read_Choices;

   --
   procedure Main is

      ProgInfo_Window : Object_ID;
   begin
      -- Messages
      Add_Listener (Main_Task,new MEL_Message_Bugz_Query);
      Add_Listener (Main_Task,new MEL_Message_Quit);          -- React upon quit from taskmanager

      -- Toolbox Events
      Add_Listener (Main_Task,new TEL_Quit_Quit);
      Add_Listener (Main_Task,new TEL_SaveAs_SaveToFile);
      Add_Listener (Main_Task,new TEL_SaveAs_AboutToBeShown);

      Add_Listener (Main_Task,new TEL_ViewManual_Type);
      Add_Listener (Main_Task,new TEL_ViewSection_Type);
      Add_Listener (Main_Task,new TEL_ViewIHelp_Type);
      Add_Listener (Main_Task,new TEL_ViewHomePage_Type);
      Add_Listener (Main_Task,new TEL_ViewChoices_Type);
      Add_Listener (Main_Task,new TEL_SendEmail_Type);
      Add_Listener (Main_Task,new TEL_CreateReport_Type);
      Add_Listener (Main_Task,new TEL_Toolbox_Error);

      -- Start task
      WimpTask.Set_Resources_Path(Main_Task,"<DroneRes$Dir>");
      WimpTask.Initialise(Main_Task);

      Read_String ("UNTITLED",untitled,Get_Message_Block(Main_Task));
      ProgInfo_Window := Toolbox.Create_Object("ProgInfo",From_Template);
      ToolboxProgInfo.Set_Version(ProgInfo_Window,MessageTrans.Lookup("VERS",Get_Message_Block(Main_Task)));

      if FileExternal.Exists(scrapdir) /=true then
         Create_Directory(scrapdir);
      else
         -- Make sure all files are closed
         FileExternal.Close_AllInPath(Variable.Translate(scrapdir));

         -- Delete files
         Wipe(scrapdir);
         Create_Directory(scrapdir);
      end if;

      if FileExternal.Exists(Choices_Read) then
         Read_Choices(S(untitled));
      end if;

      SaveAs_ObjectID := Toolbox.Create_Object ("SaveAs");
      Status_ObjectID := Toolbox.Create_Object ("Status");

      WimpTask.Poll(Main_Task);
   exception
      when e: others => Report_Error("UNTRAPPED",Ada.Exceptions.Exception_Information (e));
   end Main;

   --

end Main;

