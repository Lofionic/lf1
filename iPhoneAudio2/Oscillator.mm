//
//  oscillator.m
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator
{
    bool noteOn;
    
    bool noteWaiting;
    
    Waveform nextWaveform;
    float nextFreq;
    
    double phase;
    bool prevResultPositive;

    float prevEnv;
    
    double envelopePosition;
    bool envelopeTriggered;
    float envelopeDecayFrom;

    SInt16 prevResult;
}

-(id)init {
    
    if (self = [super init]) {
        _freq = 0;
        _octave = 1;
        
        _waveform = Sin;
        nextWaveform = Sin;
        phase = 0;
     
        envelopeTriggered = false;
        envelopeDecayFrom = 0;
        prevEnv = 0;
        noteOn = false;
        
        _envelopeAttack = 500;
        _envelopeDecay = 2000;
        _envelopeSustain = 1;
        _envelopeRelease = 2000;
    }
    
    return self;
}

@synthesize waveform = _waveform;

-(void)setWaveform:(Waveform)waveform {
    nextWaveform = waveform;
}

-(Waveform)waveform {
    return _waveform;
}

@synthesize freq = _freq;

-(void)setFreq:(float)freq {
    _freq = freq;
}

-(float)freq {
    return _freq;
}

-(SInt16) getNextSampleForSampleRate:(Float64)sampleRate {

    // Calculate the next sample
    SInt16 result = [self getNextSample];

    // Smooth out result
    
    // phaseIncrement is the amount the phase changes in a single sample
    float phaseIncrement = M_PI * _freq * powf(2, _octave) / sampleRate;
    [self incrementPhase:phaseIncrement];
    
    // timeIncrement is the amount the envelope moves in a single sample
    float timeIncrement = 1000 / sampleRate;
    [self incrementEnvelope:timeIncrement];
    
    // Change waveform on zero crossover
    if ((result > 0) != (prevResult < 0) || result == 0) {
        if (_waveform != nextWaveform) {
            _waveform = nextWaveform;
            phase = 0;
        }
    }

    prevResult = result;
    prevResultPositive = result > 0;
    
    return result;
}

-(SInt16) getNextSample {
    
    float env = [self getEnvelopePoint];
    if (env > 0) {
        switch (_waveform) {
            case Sin:
                // Sin generator
                return (SInt16)(sin(phase) * 32767.0f * env);
                break;
            case Saw: {
                double modPhase = fmod(phase, M_PI * 2.0);
                float a = (modPhase / (M_PI)) - 1.0f;
                return (SInt16)(a * 32767.0f * env);
            }
                break;
            case Square: {
                if (sin(phase) > 0.5) {
                    return (SInt16)(32767.0f * env);
                } else {
                    return (SInt16)(32767.0f * -env);
                }
            }
                break;
            default:
                return 0;
        }
    } else {
        return 0;
    }
}

-(void)trigger {
    noteOn = true;
    
    // Trigger envelope from start
    envelopePosition = 0;
    envelopeDecayFrom = 0;
    envelopeTriggered = true;
}

-(void)noteRelease {
    noteOn = false;
    envelopePosition = 0;
}

-(float)getEnvelopePoint {

    float result = 0;
    
    // Return the current value of the envelope
    if (noteOn) {
        if (envelopePosition <= _envelopeAttack) {
            // Envelope is _envelopeAttacking
            result = envelopePosition / _envelopeAttack;
        } else if (envelopePosition <= _envelopeAttack + _envelopeDecay) {
            // Envelope is decaying
            result = 1 - ((envelopePosition - _envelopeAttack) / (_envelopeDecay) * (1 - _envelopeSustain));
        } else {
            // Envelope is sustaining
            result = envelopeDecayFrom;
        }
    
    envelopeDecayFrom = result;

    } else {
        if (envelopePosition <= _envelopeRelease) {
            // Envelope is releasing
            result = envelopeDecayFrom - (envelopePosition / _envelopeRelease) * envelopeDecayFrom;
        } else {
            
            result = 0;

        }
    }
    
    // Limit the change of envelope amp per sample
    // Reduces clicks
    float delta = result - prevEnv;
    if (fabs(delta) > 0.005) {
        result = prevEnv + (0.005  * ((delta < 0) ? -1 : 1));
    }
    
    prevEnv = result;
    
    if (result <= 0 && envelopePosition > 0) {
        // Envelope has finished
        envelopePosition = 0;
        envelopeDecayFrom = 0;
        envelopeTriggered = false;
        result = 0;
    }
    
    //NSLog(@"Env: %.4f", delta);
    
    return result;
}

-(void)incrementPhase:(float)phaseIncrement {
    // Increment the phase of the oscillator

    phase += (phaseIncrement);
    
}

-(void)incrementEnvelope:(float)milliseconds {
    // Increment the position of the envelope
    if (envelopeTriggered) {
        envelopePosition += milliseconds;
    }
}

-(void)avoidOverflow {
    // Prevent phase from overloading
    phase = fmod(phase, M_PI * 2.0);
}

@end
