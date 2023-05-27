module Main (main) where

import Colour.Text.CssRgb (readHex, showDecTransparent, showHex)
import Data.Colour.RGBSpace (RGB (RGB))
import Data.Word (Word8)
import Hedgehog (Gen, forAll, (===))
import qualified Hedgehog.Gen as Gen
import Test.Hspec (describe, hspec, shouldBe, specify)
import Test.Hspec.Hedgehog (hedgehog)

main :: IO ()
main = hspec $ do
  describe "showHex" $ do
    let colour ~> text = showHex colour `shouldBe` text

    specify "black" $ RGB 0 0 0 ~> "#000000"
    specify "white" $ RGB 255 255 255 ~> "#ffffff"
    specify "off-black" $ RGB 1 1 1 ~> "#010101"
    specify "red" $ RGB 255 0 0 ~> "#ff0000"
    specify "green" $ RGB 0 255 0 ~> "#00ff00"
    specify "blue" $ RGB 0 0 255 ~> "#0000ff"

  describe "showDecTransparent" $ do
    let colour ~> text = showDecTransparent colour `shouldBe` text

    specify "black" $ RGB 0 0 0 ~> "rgba(0, 0, 0, 0)"
    specify "white" $ RGB 255 255 255 ~> "rgba(255, 255, 255, 0)"
    specify "red" $ RGB 255 0 0 ~> "rgba(255, 0, 0, 0)"
    specify "green" $ RGB 0 255 0 ~> "rgba(0, 255, 0, 0)"
    specify "blue" $ RGB 0 0 255 ~> "rgba(0, 0, 255, 0)"

  describe "readHex" $ do
    specify "is showHex's inverse" $ hedgehog do
      colour <- forAll genColour
      readHex (showHex colour) === Just colour

genColour :: Gen (RGB Word8)
genColour = RGB <$> Gen.enumBounded <*> Gen.enumBounded <*> Gen.enumBounded
