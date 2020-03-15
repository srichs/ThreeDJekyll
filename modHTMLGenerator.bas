Attribute VB_Name = "modHTMLGenerator"
'------------------------------------------------------------------------------
' Filename: ThreeDJekyllGenerator.bas
' Date: 14 MAR 2020
'
' Purpose: This Module is used to generate .html files for use with jekyll
'          and they are used to display a 3D object. This Module allows for
'          the automated creation of the .html files by automatically creating
'          the yaml front matter. These .html files are then automatically
'          incorporated into a website using the static site generator jekyll.
'
' Author: srichs
'------------------------------------------------------------------------------

Option Explicit

Private Const WEBGL_JS As String = "/assets/js/webgl.min.js"
Private Const THREE_JS As String = "/assets/js/three.min.js"
Private Const STL_LOADER_JS As String = "/assets/js/stlloader.min.js"
Private Const ORBIT_CONTROL_JS As String = "/assets/js/orbitcontrols.min.js"
Private Const STL_VIEWER_JS As String = "/assets/js/stlviewer.js"


' A type definition for the yaml front matter in the template.html files.
Private Type FrontMatter
    Layout As String
    Permalink As String
    Title As String
    Value As String
    Filepath As String
    Filename As String
    Description As String
    Detail As String
    Cost As String
    Filetypes As String
End Type


' This sub-procedure is used to generate the .html files for use with the
' jekyll static site generator.
Public Sub GenerateHTMLFiles()
    Sheet1.Unprotect
    Dim YAML As FrontMatter
    Dim i As Integer
    Dim LastRow As Integer
    Dim HTMLText As String
    Dim FName As String
    Dim FolderPath As String
    Dim Lines() As String
    Dim Line As Variant
    Dim FSO As Object
    Dim OFile As Object
    LastRow = Sheet1.Cells.SpecialCells(xlCellTypeLastCell).Row
    FolderPath = BrowseFolderPath()
    
    If (FolderPath <> "") Then
        FolderPath = FolderPath & "\html_files\"
    
        If (Dir(FolderPath, vbDirectory) = "") Then
            MkDir FolderPath
        End If
        
        Set FSO = CreateObject("Scripting.FileSystemObject")
        
        For i = 2 To LastRow
            If Not (Sheet1.Range("A" & CStr(i)).Value = "" And Sheet1.Range("B" & CStr(i)).Value = "" And Sheet1.Range("C" & CStr(i)).Value = "" And Sheet1.Range("D" & CStr(i)).Value = "") Then
                YAML.Layout = Sheet1.Range("A" & CStr(i)).Value
                YAML.Permalink = Sheet1.Range("B" & CStr(i)).Value
                YAML.Title = Sheet1.Range("C" & CStr(i)).Value
                YAML.Value = Sheet1.Range("D" & CStr(i)).Value
                YAML.Filepath = Sheet1.Range("E" & CStr(i)).Value
                YAML.Filename = Sheet1.Range("F" & CStr(i)).Value
                YAML.Description = Sheet1.Range("G" & CStr(i)).Value
                YAML.Detail = Sheet1.Range("H" & CStr(i)).Value
                YAML.Cost = Sheet1.Range("I" & CStr(i)).Value
                YAML.Filetypes = Sheet1.Range("J" & CStr(i)).Value
                FName = Sheet1.Range("K" & CStr(i)).Value
                HTMLText = CreateYAMLText(YAML) & CreateHTMLText(GetTypeCount(YAML.Filetypes))
                Lines = Split(HTMLText, Chr(13))
                Set OFile = FSO.CreateTextFile(FolderPath & FName & ".html")
                For Each Line In Lines
                    OFile.WriteLine Line
                Next
                OFile.Close
            Else
                LastRow = i - 2
                Exit For
            End If
        Next i
        
        MsgBox (CStr(LastRow - 1) & " files saved to " & FolderPath)
    End If
    
    Set Line = Nothing
    Set FSO = Nothing
    Set OFile = Nothing
    Sheet1.Protect
End Sub


' This function is used to create the .html text for use in creating the
' .html files
' Parameters:
' Returns - The String that for the .html file
Private Function CreateHTMLText(typeCount As Integer) As String
    Dim i As Integer
    Dim break As String
    Dim str As String
    break = "<br>"
    str = "<!DOCTYPE html>" & Chr(13) & Chr(13)
    str = str & "<head>" & Chr(13)
    str = str & "    <style type=""text/css"">" & Chr(13)
    str = str & "        div.stlviewer {" & Chr(13)
    str = str & "            height: 400px;" & Chr(13)
    str = str & "        }" & Chr(13)
    str = str & "    </style>" & Chr(13)
    str = str & "    <meta charset=""UTF-8"">" & Chr(13)
    str = str & "    <title>{{ page.p_title }}</title>" & Chr(13)
    str = str & "    <script src=""{{ site.url }}" & WEBGL_JS & """></script>" & Chr(13)
    str = str & "    <script src=""{{ site.url }}" & THREE_JS & """></script>" & Chr(13)
    str = str & "    <script src=""{{ site.url }}" & STL_LOADER_JS & """></script>" & Chr(13)
    str = str & "    <script src=""{{ site.url }}" & ORBIT_CONTROL_JS & """></script>" & Chr(13)
    str = str & "    <script src=""{{ site.url }}" & STL_VIEWER_JS & """></script>" & Chr(13)
    str = str & "    <script type=text/javascript>" & Chr(13)
    str = str & "        window.onload = function() {" & Chr(13)
    str = str & "            STLViewerEnable(""stlviewer"");" & Chr(13)
    str = str & "        }" & Chr(13)
    str = str & "    </script>" & Chr(13)
    str = str & "</head>" & Chr(13) & Chr(13)
    str = str & "<body>" & Chr(13)
    str = str & "    <h2>" & Chr(13)
    str = str & "        <label>{{ page.p_title }}</label>" & Chr(13)
    str = str & "        <span style=""float:right;"">" & Chr(13)
    str = str & "            <label style=""margin-left: 40px""> </label>" & Chr(13)
    str = str & "            <input type=""checkbox"" id=""c1"" name=""cntrl"">orbit</input>" & Chr(13)
    str = str & "            <label style=""margin-left: 40px""> </label>" & Chr(13)
    str = str & "            <input type=""radio"" id=""r1"" name=""model"">wire</input>" & Chr(13)
    str = str & "            <label style=""margin-left: 20px""> </label>" & Chr(13)
    str = str & "            <input type=""radio"" id=""r2"" name=""model"">shaded</input>" & Chr(13)
    str = str & "        </span>" & Chr(13)
    str = str & "    </h2>" & Chr(13) & Chr(13)
    str = str & "    <div class=stlviewer data-src=""{{ site.url }}{{ page.m_filepath }}{{ page.m_filename }}.stl"" data-value=""{{ page.d_value }}"">" & Chr(13)
    str = str & "        <canvas id=""glcanvas"" width=""740"" height=""400""></canvas>" & Chr(13)
    str = str & "    </div><br><br>" & Chr(13) & Chr(13)
    str = str & "    <p>" & Chr(13)
    str = str & "        Description: {{ page.m_description }}" & Chr(13)
    str = str & "    </p>" & Chr(13) & Chr(13)
    str = str & "    <p>" & Chr(13)
    str = str & "        {{ page.m_detail }}" & Chr(13)
    str = str & "    </p>" & Chr(13) & Chr(13)
    str = str & "    <p>" & Chr(13)
    str = str & "        Cost of Materials: ~{{ page.m_cost }}" & Chr(13)
    str = str & "    </p>" & Chr(13) & Chr(13)
    str = str & "    <p>" & Chr(13)
    str = str & "        3D Files <br>" & Chr(13)
    For i = 1 To typeCount
        If (i = typeCount) Then
            break = ""
        End If
        str = str & "        <a href=""{{ site.url }}{{ page.m_filepath }}{{ page.m_filename }}{{ page.m_filetype_" & CStr(i) & " }}"">{{ page.m_filename }}{{ page.m_filetype_" & CStr(i) & " }}</a>" & break & Chr(13)
    Next i
    str = str & "    </p>" & Chr(13)
    str = str & "</body>" & Chr(13) & Chr(13)
    str = str & "</html>"
    CreateHTMLText = str
End Function


' This function is used to get the number of filetypes listed in the worksheet
' Parameters:
' Filetypes - the string that has a list of filetypes separated by a comma
' Returns - an integer with the number of filetypes
Private Function GetTypeCount(Filetypes As String) As Integer
    Dim fTypes() As String
    Dim typeCount As Integer
    Dim fileType As Variant
    fTypes = Split(Filetypes, ",")
    typeCount = 0
    For Each fileType In fTypes
        typeCount = typeCount + 1
    Next fileType
    GetTypeCount = typeCount
    Set fileType = Nothing
End Function


' This function is used to create the .html text for use in creating the
' .html files
' Parameters:
' YAML - The front matter that was retrieved from the worksheet
' Returns - The String that for the .html file
Private Function CreateYAMLText(YAML As FrontMatter) As String
    Dim str As String
    Dim fTypes() As String
    Dim typeCount As Integer
    Dim fileType As Variant
    fTypes = Split(YAML.Filetypes, ",")
    typeCount = 0
    str = "---" & Chr(13)
    str = str & "layout: " & YAML.Layout & Chr(13)
    str = str & "permalink: " & YAML.Permalink & Chr(13)
    str = str & "p_title: " & YAML.Title & Chr(13)
    str = str & "d_value: " & YAML.Value & Chr(13)
    str = str & "m_filepath: " & YAML.Filepath & Chr(13)
    str = str & "m_filename: " & YAML.Filename & Chr(13)
    str = str & "m_description: " & YAML.Description & Chr(13)
    str = str & "m_detail: " & YAML.Detail & Chr(13)
    str = str & "m_cost: " & YAML.Cost & Chr(13)
    For Each fileType In fTypes
        typeCount = typeCount + 1
        str = str & "m_filetype_" & CStr(typeCount) & ": " & "." & Trim(fileType) & Chr(13)
    Next fileType
    str = str & "---" & Chr(13) & Chr(13)
    CreateYAMLText = str
    Set fileType = Nothing
End Function


' Opens a folder dialog to select a folder
' Parameters:
' Returns - a string with the path to the selected folder
Private Function BrowseFolderPath() As String
    On Error GoTo err
    Dim fileExplorer As FileDialog
    Set fileExplorer = Application.FileDialog(msoFileDialogFolderPicker)

    'To allow or disable to multi select
    fileExplorer.AllowMultiSelect = False

    With fileExplorer
        If (.Show = -1) Then 'Any folder is selected
            BrowseFolderPath = .SelectedItems.Item(1)
        Else
            BrowseFolderPath = ""
        End If
    End With
err:
    Set fileExplorer = Nothing
    Exit Function
End Function
