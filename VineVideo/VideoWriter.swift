//
//  VideoWriter.swift
//  naruhodo
//
//  Created by FUJIKI TAKESHI on 2014/11/11.
//  Copyright (c) 2014年 Takeshi Fujiki. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary

class VideoWriter : NSObject{
    var fileWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    
    init(fileUrl:NSURL!, height:Int, width:Int, channels:Int, samples:Float64){
        self.fileWriter = try? AVAssetWriter(URL: fileUrl, fileType: AVFileTypeQuickTimeMovie)
        
        let videoOutputSettings: Dictionary<String, AnyObject> = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : width,
            AVVideoHeightKey : height
        ];
        self.videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoOutputSettings)
        self.videoInput.expectsMediaDataInRealTime = true
        self.fileWriter.addInput(self.videoInput)
        
        let audioOutputSettings: Dictionary<String, AnyObject> = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey : channels,
            AVSampleRateKey : samples,
            AVEncoderBitRateKey : 128000
        ]
        self.audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
        self.audioInput.expectsMediaDataInRealTime = true
        self.fileWriter.addInput(self.audioInput)
    }
    
    func write(sample: CMSampleBufferRef, isVideo: Bool){
        if CMSampleBufferDataIsReady(sample) {
            if self.fileWriter.status == AVAssetWriterStatus.Unknown {
                Logger.log("Start writing, isVideo = \(isVideo), status = \(self.fileWriter.status.rawValue)")
                let startTime = CMSampleBufferGetPresentationTimeStamp(sample)
                self.fileWriter.startWriting()
                self.fileWriter.startSessionAtSourceTime(startTime)
            }
            if self.fileWriter.status == AVAssetWriterStatus.Failed {
                Logger.log("Error occured, isVideo = \(isVideo), status = \(self.fileWriter.status.rawValue), \(self.fileWriter.error!.localizedDescription)")
                return
            }
            if isVideo {
                if self.videoInput.readyForMoreMediaData {
                    self.videoInput.appendSampleBuffer(sample)
                }
            }else{
                if self.audioInput.readyForMoreMediaData {
                    self.audioInput.appendSampleBuffer(sample)
                }
            }
        }
    }
    
    func finish(callback: Void -> Void){
        self.fileWriter.finishWritingWithCompletionHandler(callback)
    }
}