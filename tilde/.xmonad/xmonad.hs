import XMonad
import XMonad.Actions.NoBorders(toggleBorder)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.IndependentScreens(countScreens, withScreens, onCurrentScreen)
import XMonad.Layout.NoBorders(smartBorders)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import System.IO

import qualified XMonad.StackSet as W

mModMask = mod4Mask
mWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

main = do
  xmproc <- spawnPipe "xmobar"
  mScreens <- countScreens
  xmonad $ ewmh def
    { manageHook = manageDocks <+> manageHook def
    , layoutHook = avoidStruts $ smartBorders $ layoutHook def
    , handleEventHook = handleEventHook def <+> fullscreenEventHook <+> docksEventHook <+> ewmhDesktopsEventHook
    , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppCurrent = xmobarColor "grey" "#1B5E20" . wrap " " " "
      , ppVisible = xmobarColor "grey" "#0d47a1" . wrap " " " "
      , ppTitle = (\str -> "")
      , ppLayout = (\str -> "")
      }
    , modMask = mModMask
    , terminal = "xterm"
    , normalBorderColor = "#0d47a1"
    , focusedBorderColor = "#1B5E20"
    , borderWidth = 1
    , workspaces = if mScreens > 1 then withScreens mScreens mWorkspaces else mWorkspaces
    } `additionalKeys`
    [ ((mModMask, xK_p), spawn "dmenu_run -fn 'Ubuntu Mono-14' -nb 'black' -nf 'grey' -sb '#1B5E20' -sf 'grey' -h 24")
    , ((mModMask, xK_f), sendMessage ToggleStruts)
    , ((mModMask, xK_b), withFocused toggleBorder)
    , ((0, xK_Print), spawn "scrot -e 'mv $f ~/.scrot/'")
    ] `additionalKeys`
    if mScreens > 1 then
      [ ((m .|. mModMask, k), windows $ onCurrentScreen f i)
           | (i, k) <- zip (mWorkspaces) [xK_1 .. xK_9]
           , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
    else []
