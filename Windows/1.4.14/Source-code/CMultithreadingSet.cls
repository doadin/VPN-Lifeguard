VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CMultithreadingSet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

'-----------------------------------------------------
'    VPN Lifeguard - Reconnecter son VPN tout en bloquant ses logiciels
'    Copyright 2010 philippe734
'    http://sourceforge.net/projects/vpnlifeguard/
'
'    VPN Lifeguard is free software; you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation; either version 2 of the License, or
'    (at your option) any later version.
'
'    VPN Lifeguard is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program. If not, write to the
'    Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
'-----------------------------------------------------

' ------------------------------------------
' Titre : cr�ation d'une thread en multithreading activeX
' Auteur : philippe734
' Date : mai 2010
'
' Deux classes sont n�cessaires (+ une pour la proc�dure � ex�cuter)
' La classe multiuse pour d�finir la proc�dure � ex�cuter en thread
' et la form callback pour effectuer un court d�lai.
'
' But :
' On souhaite ex�cuter une proc�dure
' dans une thread via le multithreading.
' Principe :
' 1- Cr�er et tester un atom afin de ne pas lancer plusieurs instance
' du programme principale.
' 2- Cr�ation de la thread en d�finissant la class, sa proc�dure
' et ses variables � ex�cuter dans la thread.
' 3- Cr�ation d'un d�lai (callback) entre la cr�ation
' et l'ex�cution de la proc�dure dans la thread.
' 4- Une fois l'ex�cution de la proc�dure termin�e,
' les r�sultats doivent �tre imp�rativement envoy�s
' par RaiseEvent.
' C'est donc indispensable que la proc�dure de la thread puisse
' g�n�rer des events via RaiseEvent.
' La proc�dure � ex�cuter dans une thread doit �tre dans une
' class multiuse.
' ------------------------------------------


' Cette pr�sente class est utilis�e pour deux usages
' 1- cr�er et tester un atom
' 2- d�clancher la cr�ation d'une thread


Option Explicit



' 1er usage : cr�e un atom afin de ne pas instanci� la fenetre principale
' un atom est une sorte de variable globale windows

' API de gestion d'atom
Private Declare Function FindAtom Lib "kernel32" Alias "FindAtomA" (ByVal atomName As String) As Integer
Private Declare Function AddAtom Lib "kernel32" Alias "AddAtomA" (ByVal atomName As String) As Integer
Private Declare Function DeleteAtom Lib "kernel32" (ByVal atomName As Integer) As Integer

' l'identifiant de l'atom cr��
Private atomID As Integer
'

' d�s son premier lancement, un atom sera cr��
Private Sub Class_Initialize()
    Dim atomName As String

    ' Build an atom name unique for this instance of the application.
    atomName = App.EXEName & App.hInstance

    ' Create the atom if it doesn't exist already.
    If FindAtom(atomName) = 0 Then atomID = AddAtom(atomName)
End Sub

Private Sub Class_Terminate()

' Delete the atom when this thread terminates.
    If atomID Then DeleteAtom atomID
End Sub

Public Function IsFirstThread() As Boolean

' This is the first thread if it was the one which created the atom.
    IsFirstThread = (atomID <> 0)
End Function


' 2� usage : d�clancher la cr�ation de la thread
' �tape interm�diaire mais obligatoire car
' pour cr�er une thread, il faut une class MultiUse
' or la form CallBack est une class non MultiUse
'-----------------------------------------------------

' d�finit les param�tres de votre classe
Public Sub SetThread(oClass As Object, ByVal MethodeName As String, ByRef ThreadIndex As Long, Optional ByVal Argument_A As Variant, Optional ByVal Argument_B As Variant, Optional ByVal Argument_C As Variant)

' nom de votre class contenant la proc�dure
' � ex�cuter en thread
    Dim l_oClass As Object

    ' class qui va cr�er un d�lai appel� callback
    Dim cbk As CMultithreadingCallBack

    Set cbk = New CMultithreadingCallBack
    Set l_oClass = oClass

    ' appel la class qui va cr�er un d�lai
    ' entre la cr�ation de la thread et l'ex�cution
    ' de votre proc�dure
    Call cbk.DelayedCall(l_oClass, MethodeName, ThreadIndex, Argument_A, Argument_B, Argument_C)

    Set cbk = Nothing
    Set l_oClass = Nothing

End Sub
