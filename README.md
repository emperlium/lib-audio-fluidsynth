# lib-audio-fluidsynth

Wrapper for libfluidsynth.

## Dependencies

You'll need the [libfluidsynth library](http://www.fluidsynth.org/api/index.html).

On Ubuntu distributions;

    sudo apt install libfluidsynth-dev fluid-soundfont-gm

## Note

## Installation

    perl Makefile.PL
    make test
    sudo make install

### Testing using SoundFont other than "/usr/share/sounds/sf2/FluidR3_GM.sf2"

    TEST_SOUNDFONT=/path/soundfont.sf2

## Example

    use Nick::Audio::FluidSynth;

    use Time::HiRes 'sleep';

    my $fluidsynth = Nick::Audio::FluidSynth -> new();

    my $sf_id = $fluidsynth -> load_soundfont(
        '/usr/share/sounds/sf2/FluidR3_GM.sf2'
    );
    $fluidsynth -> setting_string( 'audio.driver', 'pulseaudio' );
    $fluidsynth -> add_audio_driver();
    $fluidsynth -> set_preset( 0, $sf_id, 0, 46 );

    my @notes = map 60 + ( $_ * 2 ), 1 .. 20;

    for ( my $i = 0; $i <= $#notes; $i++ ) {
        $fluidsynth -> set_pan( 0, 127 * ( $i / $#notes ) );
        $fluidsynth -> send_note( 0, $notes[$i], 127, 200 );
        sleep .05;
    }
    sleep 2;

## Methods

### new()

Instantiates a new Nick::Audio::FluidSynth object.

All arguments are optional.

- buffer\_out

    Scalar that'll be used to push PCM data to.

- audio_bytes

    Number of bytes of PCM generated on each call to **process()**.

- gain

    Output gain (0.0 to 10.0)

### load\_soundfont()

Loads a SoundFont file.

Takes two arguments, the path to the SoundFont file and (optionally) whether to re-assign presets for all MIDI channels (default 1).

Returns the SoundFont ID.

### setting\_string()

Set key with string value.

### setting\_int()

Set key with int value.

### setting\_num()

Set key with double value.

### add\_audio\_driver()

Adds an audio driver to the instance.

Takes no arguments, set a driver type with **setting\_string()** and **'audio.driver'** key.

### del\_audio\_driver()

Removes the audio driver.

### process()

Populates **buffer\_out** with **bytes** of PCM data.

### get\_buffer\_out\_ref()

Gets a reference to the scalar that **process()** will fill with PCM data.

### set\_preset()

Takes a channel, SoundFont ID, bank and preset as arguments.

### set\_channel\_type()

Takes a channel and a value (0=melodic, 1=drum).

### set\_controller()

Takes a channel, controller number and value as arguments.

### set\_pan()

Takes a channel and a value (0-127, 63=centre).

### set\_pitch\_bend()

Takes a channel and a value (0-16383, 8192=centre).

### send\_note()

Takes a channel, key, velocity (0-127) and duration (ms) as arguments.

### active\_voices()

Returns the number of currently active voices.

### system\_reset()

Sends MIDI system reset command.
