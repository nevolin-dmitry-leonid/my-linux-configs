import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.NoBorders(smartBorders)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ ewmh def
    { manageHook = manageDocks <+> manageHook def
    , layoutHook = avoidStruts $ smartBorders $ layoutHook def
    , handleEventHook = handleEventHook def <+> fullscreenEventHook <+> docksEventHook <+> ewmhDesktopsEventHook
    , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppCurrent = xmobarColor "grey" "#1B5E20" . wrap " " " "
      , ppTitle = (\str -> "")
      , ppLayout = (\str -> "")
      }
    , modMask = mod4Mask
    , terminal = "xterm"
    , normalBorderColor = "#5C6BC0"
    , focusedBorderColor = "#1B5E20"
    , borderWidth = 1
    } `additionalKeys`
    [ ((mod4Mask, xK_p), spawn "dmenu_run -fn 'Ubuntu Mono-14' -nb 'black' -nf 'grey' -sb '#1B5E20' -sf 'grey' -h 24")
    , ((mod4Mask .|. shiftMask, xK_f), sendMessage ToggleStruts)
    , ((0, xK_Print), spawn "scrot -e 'mv $f ~/.scrot/'")
    ]
