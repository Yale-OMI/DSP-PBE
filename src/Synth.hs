{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE DataKinds #-}

module Synth where

import Codec.Wav

import FFT
import VividRunner
import Vivid

import Types.Common

-- | generate the Vivid program to turn the in_example to the out_example
synthCode :: (FilePath, AudioFormat) -> (FilePath, AudioFormat) -> IO String
synthCode (in_filepath,in_audio) (out_filepath,out_audio) = do 
  testFilter in_filepath out_audio ((lpFilter 200)) >>= print
  testFilter in_filepath out_audio (lpFilter 1000) >>= print
  return "generated code"

testFilter :: FilePath -> AudioFormat -> (Signal -> SDBody' '[] Signal) -> IO AuralDistance
testFilter in_fp outAudio vividCode = do
  newOutFilepath <- runFilter in_fp vividCode
  newAudio <- importFile newOutFilepath :: IO(Either String AudioFormat)
  case newAudio of
    Left e -> error e
    Right a -> return $ peakResults outAudio a

-- Just one test filter for now, these will be generated by synthesis
lpFilter :: Float -> Signal -> SDBody' x Signal
lpFilter l bufStream =  do
  let myLPF bufs = lpf (freq_ (l::Float), in_ bufs)
  myLPF $ myLPF bufStream
