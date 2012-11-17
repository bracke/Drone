with RASCAL.Toolbox;              use RASCAL.Toolbox;
with RASCAL.OS;                   use RASCAL.OS;
with RASCAL.ToolboxSaveAs;        use RASCAL.ToolboxSaveAs;

package Controller_SaveAs is

   type TEL_SaveAs_SaveToFile           is new ATEL_Toolbox_SaveAs_SaveToFile              with null record;
   type TEL_SaveAs_AboutToBeShown       is new ATEL_Toolbox_SaveAs_AboutToBeShown          with null record;

   procedure Handle (The : in TEL_SaveAs_SaveToFile);
   procedure Handle (The : in TEL_SaveAs_AboutToBeShown);

end Controller_SaveAs;
