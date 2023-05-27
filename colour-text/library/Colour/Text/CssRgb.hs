module Colour.Text.CssRgb
  ( readHex,
    showHex,
    showDecTransparent,
  )
where

import Data.Colour.RGBSpace (RGB (..))
import Data.Text (Text)
import qualified Data.Text as Text
import Data.Word (Word8)
import qualified Numeric
import qualified Text.Show as Show

readHex :: forall m. MonadFail m => Text -> m (RGB Word8)
readHex text = case Text.unpack text of
  ['#', a, b, c, d, e, f] -> pure RGB <*> w a b <*> w c d <*> w e f
    where
      w :: Char -> Char -> m Word8
      w c1 c2 = (maybe (fail ("Invalid characters in CSS RGB value: " <> Text.unpack text)) pure) $ hexWord8Maybe c1 c2
  '#' : _ -> fail $ "Invalid CSS RGB value: Must be six hex characters, but is " <> Text.unpack text
  [] -> fail "Invalid CSS RGB value: Empty string"
  _ -> fail $ "Invalid CSS RGB value: Only hex format is supported (must start with #), but got: " <> Text.unpack text

hexWord8Maybe :: Char -> Char -> Maybe Word8
hexWord8Maybe a b = case Numeric.readHex [a, b] of [(x, "")] -> Just x; _ -> Nothing

showHex :: RGB Word8 -> Text
showHex (RGB r g b) =
  Text.singleton '#' <> foldMap (\x -> Text.pack (pad (Numeric.showHex x ""))) [r, g, b]

showDecTransparent :: RGB Word8 -> Text
showDecTransparent (RGB r g b) =
  function "rgba" $
    (Text.pack . Show.show <$> [r, g, b]) <> ["0"]

function :: Text -> [Text] -> Text
function name args = name <> paren (commaSep args)

paren :: Text -> Text
paren x = Text.singleton '(' <> x <> Text.singleton ')'

commaSep :: [Text] -> Text
commaSep = Text.intercalate (Text.pack ", ")

pad :: String -> String
pad cs = case cs of [] -> "00"; [x] -> ['0', x]; x -> x
