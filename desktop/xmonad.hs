import XMonad
import XMonad.Actions.Submap
import XMonad.Util.EZConfig (additionalKeysP)

import qualified Data.Map as M 

main = xmonad  defaultConfig { 
    terminal    = "kitty"
    , modMask     = mod4Mask
    , borderWidth = 3
    , keys = \conf@(XConfig {modMask = modMask}) -> M.fromList [
        ((modMask, fst key_combos), snd key_combos)
    ]
}


infixr 6 ===> 
(===>) :: KeySym -> [(KeySym, X ())] -> (KeySym, X ())
k ===> l = (k, submap . M.fromList $ [((0, k'), x) | (k', x) <- l])

infixr 7 --->
(--->):: KeySym -> X () -> (KeySym, X())
k ---> x = (k, x)

key_combos :: (KeySym, X ())
key_combos = xK_b ===> [
                xK_v ===> [ xK_b ---> spawn "vieb"], 
                xK_b ===> [ xK_r ---> spawn "brave" ]
                ]
