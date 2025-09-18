import Data.Bits
import Data.Char
import Text.Printf

charName :: Int -> String
charName  7 = "BEL"
charName  8 = "BS"
charName  9 = "HT"
charName 10 = "LF"
charName 11 = "VT"
charName 12 = "FF"
charName 13 = "CR"
charName n =
  let s  = show $ chr n
      s' = drop 1 $ take (length s - 1) s
  in if take 1 s' == "\\"
     then drop 1 s'
     else s'

mkTrip :: Int -> [String]
mkTrip n = [show n, printf "%02X" n, charName n]

mkColumn :: Int -> [[String]]
mkColumn col = map mkTrip [n .. m]
  where n = col * 16
        m = n + 15

colWidths :: [[String]] -> [Int]
colWidths = cw1 [0, 0, 0]

cw1 :: [Int] -> [[String]] -> [Int]
cw1 ws []          = ws
cw1 ws (trip:rest) =
  let cw  = map length trip
      ws' = zipWith max ws cw
  in cw1 ws' rest

padTrip :: [Int] -> [String] -> [String]
padTrip ws trip = zipWith3 printf fmts ws trip
  where fmts = ["%*s", " %-*s ", "%-*s"]

sgr :: Int -> String
sgr n = "\27[" ++ show n ++ "m"

fmtTrip :: Bool -> [Int] -> [String] -> String
fmtTrip even ws trip =
  let padded  = padTrip ws trip
      str     = concat $ zipWith (++) fgSgrs padded
      fgSgrs  = map sgr [91, 94, 30]
      bgStart = sgr $ if even then 107 else 47
      bgEnd   = sgr 0
  in concat [bgStart, " ", str, " ", bgEnd]

fmtCol :: Int -> [String]
fmtCol col =
  let column = mkColumn  col
      ws     = colWidths column
      even   = 0 == (col .&. 1)
  in map (fmtTrip even ws) column

columns :: [[String]]
columns = map fmtCol [0..7]

fmtRow :: Int -> String
fmtRow row = concatMap (!! row) columns

main :: IO ()
main = mapM_ (putStrLn . fmtRow) [0..15]
