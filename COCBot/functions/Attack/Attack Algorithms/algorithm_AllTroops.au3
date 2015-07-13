; #FUNCTION# ====================================================================================================================
; Name ..........: algorith_AllTroops
; Description ...: This file contens all functions to attack algorithm will all Troops , using Barbarians, Archers, Goblins, Giants and Wallbreakers as they are available
; Syntax ........: algorithm_AllTroops()
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: Didipe (May-2015)
; Remarks .......: This file is part of ClashGameBot. Copyright 2015
;                  ClashGameBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================

Func algorithm_AllTroops() ;Attack Algorithm for all existing troops
	$King = -1
	$Queen = -1
	$CC = -1
	For $i = 0 To 8
		If $atkTroops[$i][0] = $eCastle Then
			$CC = $i
		ElseIf $atkTroops[$i][0] = $eKing Then
			$King = $i
		ElseIf $atkTroops[$i][0] = $eQueen Then
			$Queen = $i
		EndIf
	Next

	If _Sleep(2000) Then Return

	If $iMatchMode = $TS Or ($chkATH = 1 And SearchTownHallLoc()) Then
		Switch $AttackTHType
			Case 0
				algorithmTH()
				_CaptureRegion()
				If _ColorCheck(_GetPixelColor($aWonOneStar[0],$aWonOneStar[1], True), Hex($aWonOneStar[2], 6), $aWonOneStar[3]) Then AttackTHNormal() ;if 'no' use another attack mode.
			Case 1
				AttackTHNormal();Good for Masters
			Case 2
				AttackTHXtreme();Good for Champ
		EndSwitch
	EndIf

	;If $OptTrophyMode = 1 And SearchTownHallLoc() Then; Return ;Exit attacking if trophy hunting and not bullymode
	If $iMatchMode = $TS Then; Return ;Exit attacking if trophy hunting and not bullymode
		For $i = 1 To 30
			_CaptureRegion()
			If _ColorCheck(_GetPixelColor($aWonOneStar[0],$aWonOneStar[1], True), Hex($aWonOneStar[2], 6), $aWonOneStar[3]) = True Then ExitLoop ;exit if not 'no star'
			_Sleep(1000)
		Next

		ClickP($aSurrenderButton, 1, 0, "#0030") ;Click Surrender
		If _Sleep(3000) Then Return
		ClickP($aConfirmSurrender, 1, 0, "#0031") ;Click Confirm
		Return
	EndIf

	If ($iChkRedArea[$iMatchMode]) Then
		SetLog("Calculating Smart Attack Strategy", $COLOR_BLUE)
		Local $hTimer = TimerInit()
		_WinAPI_DeleteObject($hBitmapFirst)
		$hBitmapFirst = _CaptureRegion2()
		_GetRedArea()

		SetLog("Calculated  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds) :")
		;SetLog("	[" & UBound($PixelTopLeft) & "] pixels TopLeft")
		;SetLog("	[" & UBound($PixelTopRight) & "] pixels TopRight")
		;SetLog("	[" & UBound($PixelBottomLeft) & "] pixels BottomLeft")
		;SetLog("	[" & UBound($PixelBottomRight) & "] pixels BottomRight")


		If ($iChkSmartAttack[$iMatchMode][0] = 1 Or $iChkSmartAttack[$iMatchMode][1] = 1 Or $iChkSmartAttack[$iMatchMode][2] = 1) Then
			SetLog("Locating Village Pump & Mines", $COLOR_BLUE)
			$hTimer = TimerInit()
			Global $PixelMine[0]
			Global $PixelElixir[0]
			Global $PixelDarkElixir[0]
			Global $PixelNearCollector[0]
			; If drop troop near gold mine
			If ($iChkSmartAttack[$iMatchMode][0] = 1) Then
				$PixelMine = GetLocationMine()
				If (IsArray($PixelMine)) Then
					_ArrayAdd($PixelNearCollector, $PixelMine)
				EndIf
			EndIf
			; If drop troop near elixir collector
			If ($iChkSmartAttack[$iMatchMode][1] = 1) Then
				$PixelElixir = GetLocationElixir()
				If (IsArray($PixelElixir)) Then
					_ArrayAdd($PixelNearCollector, $PixelElixir)
				EndIf
			EndIf
			; If drop troop near dark elixir drill
			If ($iChkSmartAttack[$iMatchMode][2] = 1) Then
				$PixelDarkElixir = GetLocationDarkElixir()
				If (IsArray($PixelDarkElixir)) Then
					_ArrayAdd($PixelNearCollector, $PixelDarkElixir)
				EndIf
			EndIf
			SetLog("Located  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds) :")
			SetLog("[" & UBound($PixelMine) & "] Gold Mines")
			SetLog("[" & UBound($PixelElixir) & "] Elixir Collectors")
			SetLog("[" & UBound($PixelDarkElixir) & "] Dark Elixir Drill/s")
		EndIf

	EndIf

	;############################################# LSpell Attack ############################################################
	; DropLSpell()
	;########################################################################################################################
	Local $nbSides = 0
	Switch $iChkDeploySettings[$iMatchMode]
		Case 0 ;Single sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on a single side", $COLOR_BLUE)
			$nbSides = 1
		Case 1 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on two sides", $COLOR_BLUE)
			$nbSides = 2
		Case 2 ;Three sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on three sides", $COLOR_BLUE)
			$nbSides = 3
		Case 3 ;Two sides ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SetLog("Attacking on all sides", $COLOR_BLUE)
			$nbSides = 4
	EndSwitch
	If ($nbSides = 0) Then Return
	If _Sleep(1000) Then Return

	Local $listInfoDeploy[13][5] = [[$eGiant, $nbSides, 1, 1, 2] _
			, [$eBarb, $nbSides, 1, 2, 0] _
			, [$eWall, $nbSides, 1, 1, 1] _
			, [$eArch, $nbSides, 1, 2, 0] _
			, [$eBarb, $nbSides, 2, 2, 0] _
			, [$eGobl, $nbSides, 1, 2, 0] _
			, ["CC", 1, 1, 1, 1] _
			, [$eHogs, $nbSides, 1, 1, 1] _
			, [$eWiza, $nbSides, 1, 1, 0] _
			, [$eMini, $nbSides, 1, 1, 0] _
			, [$eArch, $nbSides, 2, 2, 0] _
			, [$eGobl, $nbSides, 2, 2, 0] _
			, ["HEROES", 1, 2, 1, 1] _
			]

    ;******* Begin ********
    If ($nbSides = 1) Then
	   algorithm_CustomTroops()
    Else
	   LaunchTroop2($listInfoDeploy, $CC, $King, $Queen)
    EndIf
	;******** END *********

	If _Sleep(100) Then Return
	SetLog("Dropping left over troops", $COLOR_BLUE)
	For $x = 0 To 1
		PrepareAttack($iMatchMode, True) ;Check remaining quantities
		For $i = $eBarb To $eLava ; lauch all remaining troops
			;If $i = $eBarb Or $i = $eArch Then
			;LauchTroop($i, $nbSides, 0, 1)
			;CheckHeroesHealth()
			;Else
			;	 LauchTroop($i, $nbSides, 0, 1, 2)
			;EndIf
			If _Sleep(500) Then Return
		Next
	Next

	;Activate KQ's power
	If ($checkKPower Or $checkQPower) And $iActivateKQCondition = "Manual" Then
		SetLog("Waiting " & $delayActivateKQ / 1000 & " seconds before activating Hero abilities", $COLOR_BLUE)
		_Sleep($delayActivateKQ)
		If $checkKPower Then
			SetLog("Activating King's power", $COLOR_BLUE)
			SelectDropTroop($King)
			$checkKPower = False
		EndIf
		If $checkQPower Then
			SetLog("Activating Queen's power", $COLOR_BLUE)
			SelectDropTroop($Queen)
			$checkQPower = False
		EndIf
	EndIf

	SetLog("Finished Attacking, waiting for the battle to end")
EndFunc   ;==>algorithm_AllTroops

;******* Begin ********
; troop_type:side:delay:trop_number:drop_point
; troop_type: type troop to deploy
; side: which side to drop the troops
; delay: delay after troop deploy completed
; drop_point: number of drop point (0 for line drop)

#include <Array.au3>
#include <File.au3>

Local $aInput
$file = @ScriptDir & "\attack_algo.txt"

Func _IntFromString($s_str)
	if Not(StringRegExp($s_str, '[[:alpha:]]', $STR_REGEXPMATCH)) Then
		Return Int(StringRegExpReplace($s_str, "[^\d\.]", ""))
	Else
		Return "string"
	endif
EndFunc

func ReadFileToArray($file, ByRef $attack_array)
	local $invalid_cmd
	local $array
	local $aData
	local $troop_type
	SetLog("Read user defined attack algorithm file - " & $file, $COLOR_ORANGE)
	_FileReadToArray($file, $array)
	For $i = 1 to UBound($array) -1
		$aData = StringSplit($array[$i], ":")
		if Not ($aData[0] = 5) Then
			SetLog ("line no:" & $i & " invalid trop config")
			ContinueLoop
		Endif
		$invalid_cmd = 0

		Switch $aData[1]
			Case "giant"
				$troop_type = $eGiant
			Case "barb"
				$troop_type = $eBarb
			Case "arch"
				$troop_type = $eArch
			Case "golin"
				$troop_type = $eGobl
			case "wb"
				$troop_type = $eWall
			Case "king"
				$troop_type = $eKing
			Case "queen"
				$troop_type = $eQueen
			Case "cc"
				$troop_type = $eCastle
			Case Else
				SetLog ("line no " & $i & ": invalid trop type")
				$invalid_cmd = 1
				ContinueLoop
		EndSwitch
		;TODO: check valid side

		For $j = 2 to UBound($aData) -1
			if Not(IsNumber(_IntFromString($aData[$j]))) Then
				$invalid_cmd = 1
			Endif
		Next

		if $invalid_cmd == 1 Then
			SetLog ("line no" & $i & ": invalid trop operations")
			continueloop
		endif
		_ArrayAdd($attack_array, $array[$i])
	Next
	SetLog("Finish reading user defined attack algorithm file", $COLOR_ORANGE)
 endfunc

func attack_array(BYref $array)
	local $aData
	local $troop_name
	local $troop
	local $troop_type
	local $edge
	local $delay
	local $troop_no
	local $SlotPerEdge

	For $i = 0 to UBound($array) -1
		;SetLog ("array[" & $i & "]:" & $array[$i], $COLOR_ORANGE)
		$aData = StringSplit($array[$i], ":")
		;for $j = 0 to UBound($aData) -1
		;	SetLog ("aData[" & $j & "]:" & $aData[$j], $COLOR_ORANGE)
		;Next
		; TODO: clean up on troop type checking
		Switch $aData[1]
			Case "giant"
				$troop_type = $eGiant
			Case "barb"
				$troop_type = $eBarb
			Case "arch"
				$troop_type = $eArch
			Case "golin"
				$troop_type = $eGobl
			case "wb"
				$troop_type = $eWall
			Case "king"
				$troop_type = $eKing
			Case "queen"
				$troop_type = $eQueen
			Case "cc"
				$troop_type = $eCastle
			Case Else
				SetLog ("Unsupported troop type: " & $aData[1]])
				ContinueLoop
		EndSwitch
		$troop = -1
		$troop_name = "unknown"
		$edge = $aData[2]
		$delay = $aData[3]
		$troop_no = $aData[4]
		$SlotPerEdge = $aData[5]

		For $k = 0 To 8 ; identify the position of this kind of troop
			If $atkTroops[$k][0] = $troop_type Then
				$troop = $k
				if $troop_no > 1 Then
					$troop_name = NameOfTroop($troop_type, 1)
				EndIf
			endif
		Next

		SetLog ("deploy: "& $troop_no & " " & $troop_name & " - on edge" & $Edges[$edge] & " with " & $SlotPerEdge & "drop points",  $COLOR_BLUE)
		DropOnEdge($troop, $Edges[$edge], $troop_no, $SlotPerEdge)
		If _Sleep($delay) Then Return
	Next
endfunc

Func algorithm_CustomTroops() ;Attack Algorithm for all existing troops

		$King = -1
		$Queen = -1
		$CC = -1
		$Barb = -1
		$Arch = -1
	    For $i = 0 To 8
			If $atkTroops[$i][0] = $eBarb Then
				$Barb = $i
			ElseIf $atkTroops[$i][0] = $eArch Then
				$Arch = $i
			ElseIf $atkTroops[$i][0] = $eCastle Then
				$CC = $i
			ElseIf $atkTroops[$i][0] = $eKing Then
				$King = $i
			ElseIf $atkTroops[$i][0] = $eQueen Then
				$Queen = $i
			EndIf
		 Next

		SetLog("using custom algorithm", $COLOR_ORANGE)
		local $valid_attacks[0] = []
		ReadFileToArray($file, $valid_attacks)
		attack_array($valid_attacks)

		; ================================================================================?

		SetLog("~Finished Attacking, waiting to finish", $COLOR_GREEN)
 EndFunc
;******** END *********
