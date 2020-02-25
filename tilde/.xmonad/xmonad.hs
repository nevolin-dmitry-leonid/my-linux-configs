import XMonad
import XMonad.Actions.CopyWindow(copyToAll, killAllOtherCopies)
import XMonad.Actions.NoBorders(toggleBorder)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.IndependentScreens(countScreens, withScreens, onCurrentScreen)
import XMonad.Layout.NoBorders(smartBorders)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import System.IO

import qualified XMonad.StackSet as W


mGreen = "#1B5E20"
mBlue = "#0D47A1"

mModMask = mod4Mask
mWorkspaces = (\n -> map show [1..n]) 9
mManageHook = composeAll
  [ className =? "TeamViewer" --> doCenterFloat
  , className =? "Matplotlib" --> doCenterFloat
  , className =? "Sxiv" --> doFullFloat
  ]

main = do
  xmproc <- spawnPipe "xmobar"
  mScreens <- countScreens
  xmonad $ ewmh def
    { manageHook = manageDocks <+> mManageHook <+> manageHook def
    , layoutHook = avoidStruts $ smartBorders $ layoutHook def
    , handleEventHook = handleEventHook def <+> fullscreenEventHook <+> docksEventHook <+> ewmhDesktopsEventHook
    , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppCurrent = xmobarColor "grey" mGreen . wrap " " " "
      , ppVisible = xmobarColor "grey" mBlue . wrap " " " "
      , ppTitle = (\str -> "")
      , ppLayout = (\str -> "")
      }
    , modMask = mModMask
    , terminal = "xterm"
    , normalBorderColor = mBlue
    , focusedBorderColor = mGreen
    , borderWidth = 1
    , workspaces = if mScreens > 1 then withScreens mScreens mWorkspaces else mWorkspaces
    } `additionalKeys`
    [ ((mModMask, xK_p), spawn $ "dmenu_run -fn 'Ubuntu Mono-14' -nb 'black' -nf 'grey' -sb '" ++ mGreen ++ "' -sf 'grey' -h 24")
    , ((mModMask, xK_f), sendMessage ToggleStruts)
    , ((mModMask, xK_g), withFocused toggleBorder)
    , ((mModMask, xK_v), windows copyToAll)
    , ((mModMask .|. shiftMask, xK_v), killAllOtherCopies)
    , ((0, xK_Print), spawn "scrot -e 'mv $f ~/.scrot/'")
    ] `additionalKeys`
    if mScreens > 1 then
      [ ((m .|. mModMask, k), windows $ onCurrentScreen f i)
           | (i, k) <- zip (mWorkspaces) [xK_1 .. xK_9]
           , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
    else []
