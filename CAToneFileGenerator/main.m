//
//  main.m
//  CAToneFileGenerator
//
//  Created by 三虎 on 2023/3/9.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100
#define DURATION 5.0
#define FILENAME_FORMAT @"%0.3f-square.aif"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        if (argc < 2) {
            printf("Usage: CAToolFileGeneratio n\n(where n is tone in HZ)");
            return -1;
        }
        //atof convert string to float
        double hz = atof(argv[1]);
        assert(hz > 0);
        NSLog(@"generation %f hz tone", hz);
        
        NSString *fileName = [NSString stringWithFormat:FILENAME_FORMAT,hz];
        NSString *filePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:fileName];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        AudioStreamBasicDescription asbd;
        memset(&asbd, 0, sizeof(asbd));
        
        
        asbd.mSampleRate = SAMPLE_RATE;
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kAudioFormatFlagIsBigEndian|kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
        asbd.mBitsPerChannel = 16;
        asbd.mChannelsPerFrame = 1;
        asbd.mFramesPerPacket = 1;
        asbd.mBytesPerFrame = 2;
        asbd.mBytesPerPacket = 2;
        
        //set up the file
        AudioFileID audioFile;
        OSStatus audioErr =noErr;
        
        audioErr = AudioFileCreateWithURL((__bridge CFURLRef)(fileUrl), kAudioFileAIFFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
        assert(audioErr == noErr);
        
        long maxSampleCount = SAMPLE_RATE * DURATION;
        long sampleCount = 2;
        UInt32 bytesToWrite = 2;
        double waveLengthInSamples = SAMPLE_RATE / hz;
        
        while (sampleCount < maxSampleCount) {
            for (int i = 0; i < waveLengthInSamples; i++) {
                //Square wave
                SInt16 sample;
//                if (i < waveLengthInSamples / 2) {
//                    sample = CFSwapInt16HostToBig(SHRT_MAX);
//                } else {
//                    sample = CFSwapInt16HostToBig(SHRT_MIN);
//                }
                
                sample = CFSwapInt16HostToBig(((i / waveLengthInSamples) * SHRT_MAX * 2) - SHRT_MAX);
                
                audioErr = AudioFileWriteBytes(audioFile, false, sampleCount * 2, &bytesToWrite, &sample);
                assert(audioErr == noErr);
                sampleCount ++;
            }
        }
        
        audioErr = AudioFileClose(audioFile);
        assert(audioErr == noErr);
        NSLog(@"wrote %d samples", sampleCount);
    }
    return 0;
}
