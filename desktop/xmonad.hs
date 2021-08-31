import XMonad
import System.Exit
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Dmenu 
import XMonad.Util.Run 
import XMonad.Util.Ungrab 
import XMonad.Actions.Submap
import XMonad.Actions.GroupNavigation
import XMonad.Prompt.XMonad
import XMonad.Layout.Spacing
import XMonad.Layout.GridVariants
import XMonad.Actions.GridSelect
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.WorkspaceHistory
import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W

import qualified Data.Map as M 
import qualified Data.Monoid
import Data.Maybe (listToMaybe, catMaybes)

import qualified Codec.Binary.UTF8.String              as UTF8
import qualified DBus                                  as D
import qualified DBus.Client                           as D

-- official docs:
--      https://hackage.haskell.org/package/xmonad-0.15/docs/src/XMonad.Config.html#defaultConfig
-- xmobar:
--      https://xmobar.org/
-- documented config:
--      https://gitlab.com/dwt1/dotfiles/-/tree/master/.xmonad
--      https://gvolpe.com/blog/xmonad-polybar-nixos/
--      https://github.com/idzardh/dotfiles/blob/master/xmonad.hs
-- super key as button:
    -- https://github.com/xmonad/xmonad/issues/317
-- ungrab:
-- https://xmonad.github.io/xmonad-docs/xmonad-contrib/XMonad-Util-Ungrab.html

-- error:
-- https://github.com/xmonad/xmonad/issues/313
--
-- TODO: multiple files

main = do
    dbus <- mkDbusClient
    let conf' = conf { 
        logHook = workspaceHistoryHook <+> dynamicLogWithPP (polybarHook dbus)
    }
    xmonad conf'

mkDbusClient :: IO D.Client
mkDbusClient = do
  dbus <- D.connectSession
  D.requestName dbus (D.busName_ "org.xmonad.log") opts
  return dbus
 where
  opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

             -- _       _                
 -- _ __   ___ | |_   _| |__   __ _ _ __ 
-- | '_ \ / _ \| | | | | '_ \ / _` | '__|
-- | |_) | (_) | | |_| | |_) | (_| | |   
-- | .__/ \___/|_|\__, |_.__/ \__,_|_|   
-- |_|            |___/                  
--
-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str =
  let opath  = D.objectPath_ "/org/xmonad/Log"
      iname  = D.interfaceName_ "org.xmonad.Log"
      mname  = D.memberName_ "Update"
      signal = (D.signal opath iname mname)
      body   = [D.toVariant $ UTF8.decodeString str]
  in  D.emit dbus $ signal { D.signalBody = body }

polybarHook :: D.Client -> PP
polybarHook dbus =
  let wrapper c s | s /= "NSP" = wrap ("%{F" <> c <> "} ") " %{F-}" s
                  | otherwise  = mempty
      blue   = "#2E9AFE"
      gray   = "#7F7F7F"
      orange = "#ea4300"
      purple = "#9058c7"
      red    = "#722222"
  in  def { ppOutput          = dbusOutput dbus
          , ppCurrent         = wrapper blue
          , ppVisible         = wrapper gray
          , ppUrgent          = wrapper orange
          , ppHidden          = wrapper gray
          , ppHiddenNoWindows = wrapper red
          , ppLayout          = const ""
          , ppTitle           = const ""
          }


-- docks is for the status bar.
-- ewmh is for rofi and so on
conf = docks . ewmh $ def {
    terminal    = "kitty"
        , modMask     = mod4Mask
        , borderWidth = 3
        , layoutHook = avoidStruts $ my_layouts
        , manageHook = myManageHook
        , keys = \c -> M.fromList $ my_keys c
}


my_layouts = tall ||| grid ||| full
    where
        tall = spacingRaw True (Border 1 1 1 1) True (Border 6 6 6 6) True $ (Tall 1 (3/100) (0.5)) 
        grid = spacingRaw True (Border 1 1 1 1) True (Border 6 6 6 6) True $ (Grid (3/2)) 
        full = Full


my_keys _ = [ 
    -- DEFAULTS
    ((mod1Mask, xK_Return), spawn $ XMonad.terminal conf) -- %! Launch terminal
    , ((modm .|. shiftMask, xK_q     ), kill) -- %! Close the focused window
    , ((modm, xK_p), spawn "/bin/rofi -show run")

    , ((modm,               xK_space ), sendMessage NextLayout) -- %! Rotate through the available layout algorithms
    --, ((modm .|. shiftMask, xK_space ), setLayout $ layoutHook conf) -- %!  Reset the layouts on the current workspace to default

    -- move focus up or down the window stack
    , ((mod1Mask,               xK_space   ), windows W.focusDown) -- %! Move focus to the next window
    --, ((modm .|. shiftMask, xK_Tab   ), windows W.focusUp  ) -- %! Move focus to the previous window
    --, ((modm,               xK_j     ), windows W.focusDown) -- %! Move focus to the next window
    --, ((modm,               xK_k     ), windows W.focusUp  ) -- %! Move focus to the previous window
    , ((modm,               xK_m     ), windows W.focusMaster  ) -- %! Move focus to the master window

    -- modifying the window order
    , ((modm,               xK_Return), windows W.swapMaster) -- %! Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  ) -- %! Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    ) -- %! Swap the focused window with the previous window

    -- resizing the master/slave ratio
    , ((modm,               xK_h     ), sendMessage Shrink) -- %! Shrink the master area
    , ((modm,               xK_l     ), sendMessage Expand) -- %! Expand the master area

    -- floating layer support
    , ((modm,               xK_t     ), withFocused $ windows . W.sink) -- %! Push window back into tiling

    -- increase or decrease number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1))) -- %! Deincrement the number of windows in the master area

    -- quit, or restart
    , ((modm .|. shiftMask, xK_Escape     ), io (exitWith ExitSuccess)) -- %! Quit xmonad
    , ((modm .|. shiftMask, xK_c  ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad

    , ((modm .|. shiftMask, xK_slash ), helpCommand) -- %! Run xmessage with a summary of the default keybindings (useful for beginners)
    -- repeat the binding for non-American layout keyboards
    , ((modm              , xK_question), helpCommand) -- %! Run xmessage with a summary of the default keybindings (useful for beginners)



    -- personal keys
    -- switch to most recent workspace with a window
        , ((mod1Mask, xK_Tab) , lastWorkspace)
        , ((mod1Mask, xK_Escape), key_combos)
         
        -- volume
        , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
        , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
        , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    ]
        ++ -- change workspace with alt + shift + number
        [((shiftMask .|. mod1Mask, k), windows $ W.greedyView i)
        | (i, k) <- zip (workspaces conf) azerty_top_row]
        ++ -- swap workspace with super + shift + number
        [((shiftMask .|. mod4Mask, k), windows $ W.shift i)
        | (i, k) <- zip (workspaces conf) azerty_top_row]
          

          where
            modm :: KeyMask
            modm = XMonad.modMask conf
            help :: String
            help = "TODO"
            helpCommand :: X ()
            helpCommand = spawn ("echo " ++ show help ++ " | xmessage -file -")
            azerty_top_row = [0x26,0xe9,0x22,0x27,0x28,0x2d,0xe8,0x5f,0xe7,0xe0]


infixr 6 ===> 
(===>) :: KeySym -> [((KeyMask, KeySym), X ())] -> ((KeyMask, KeySym), X ())
k ===> l = ((0, k), submap . M.fromList $ [(k', x) | (k', x) <- l])

(--->):: KeySym -> X() -> ((KeyMask, KeySym), X())
k ---> x = ((0, k), x)

key_combos :: X ()
key_combos = submap $ M.fromList $ [
                -- launch apps with combinations of keys
                xK_b ===> [ xK_r ---> spawn "brave"
                          ]
                ,xK_c ===> [ xK_a ---> spawn "kitty clac"
                           ,xK_f ---> config_selector
                          ]
                ,xK_d ===> [xK_s ---> spawn "discord"
                           ,xK_r ---> spawn "dmenu_run"
                          ]
                ,xK_f ===> [ xK_i ---> spawn "pcmanfm"
                          ]
                ,xK_g ===> [ xK_i ---> spawn "gimp"
                           ,xK_v ---> spawn "gvim" 
                          ]
                ,xK_h ===> [ xK_m ---> reload_home_manager 
                          ]
                ,xK_k ---> kill
                ,xK_n ===> [ xK_x ---> spawn "nextcloud"
                          ]
                ,xK_r ===> [ xK_b ---> spawn "/usr/bin/reboot"
                           ,xK_r ---> spawn "/bin/rofi -show run"
                           ,xK_w ---> spawn "random_wallpaper && killall polybar && polybar top"
                          ]
                ,xK_o ===> [ xK_f ---> spawn "/usr/bin/poweroff"
                          ]
                ,xK_p ===> [ xK_v ---> spawn "pavucontrol"
                           ]
                ,xK_t ===> [ xK_x ---> spawn "texmacs"
                          ]
                ,xK_v ===> [ xK_b ---> spawn "vieb"
                          ]
                ,xK_w ---> spawn "/bin/rofi -show window"
                ]

reload_home_manager :: X ()
reload_home_manager = do
      alert <- spawn "notify-send start_updating_config"
      spawn "home-manager switch | xargs -0 notify-send"

rmenu :: MonadIO m => [String] -> m String
rmenu = menuArgs "/bin/rofi" ["-dmenu"]     

config_selector :: X ()
config_selector = do
        let options = [ "file1"
                        , "file2"
                        , "file3"
                        , "file4"
                    ] 
        file <- rmenu options
        spawn $ "gvim " ++ file


-- switch to last visited workspace
lastWorkspace :: X ()
lastWorkspace = do
     history <- workspaceHistory
     let ws = listToMaybe . tail $ history
     case ws of {
         Just i ->  windows . W.greedyView $ i;
         Nothing -> return ();
     }

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     --, className =? "Yad"             --> doCenterFloat
     , className =? "vieb" <||> className =? "brave-browser" 
         --> doShift " 3 "
     --, isFullscreen -->  doFullFloat
     ]
