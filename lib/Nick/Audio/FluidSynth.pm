package Nick::Audio::FluidSynth;

use strict;
use warnings;

use XSLoader;
use Carp;

our $VERSION;

BEGIN {
    $VERSION = '0.01';
    XSLoader::load 'Nick::Audio::FluidSynth' => $VERSION;
}

=pod

=head1 NAME

Nick::Audio::FluidSynth - Wrapper for libfluidsynth

=head1 SYNOPSIS

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
        $fluidsynth -> set_pan( 0, 127 * $i / $#notes );
        $fluidsynth -> send_note( 0, $notes[$i], 127, 200 );
        sleep .05;
    }
    sleep 2;

=head1 METHODS

=head2 new()

Instantiates a new Nick::Audio::FluidSynth object.

Arguments are interpreted as a hash.

All arguments are optional.

=over 2

=item buffer_out

Scalar that'll be used to push PCM data to.

=item audio_bytes

Number of bytes of PCM generated on each call to B<process()>.

=item gain

Output gain (0.0 to 10.0)

=back

=head2 load_soundfont()

Loads a SoundFont file.

Takes two arguments, the path to the SoundFont file and (optionally) whether to re-assign presets for all MIDI channels (default 1).

Returns the SoundFont ID.

=head2 setting_string()

Set key with string value.

=head2 setting_int()

Set key with int value.

=head2 setting_num()

Set key with double value.

=head2 add_audio_driver()

Adds an audio driver to the instance.

Takes no arguments, set a driver type with B<setting_string()> and B<'audio.driver'> key.

=head2 del_audio_driver()

Removes the audio driver.

=head2 process()

Populates B<buffer_out> with B<audio_bytes> of PCM data.

=head2 get_buffer_out_ref()

Gets a reference to the scalar that B<process()> will fill with PCM data.

=head2 set_preset()

Takes a channel, SoundFont ID, bank and preset as arguments.

=head2 set_program()

Takes a channel and program number as arguments.

=head2 set_channel_type()

Takes a channel and a value (0=melodic, 1=drum).

=head2 set_controller()

Takes a channel, controller number and value as arguments.

=head2 set_pan()

Takes a channel and a value (0-127, 63=centre).

=head2 set_pitch_bend

Takes a channel and a value (0-16383, 8192=centre).

=head2 send_note()

Takes a channel, key, velocity (0-127) and duration (ms) as arguments.

=head2 active_voices()

Returns the number of currently active voices.

=head2 system_reset()

Sends MIDI system reset command.

=cut

sub new {
    my( $class, %settings ) = @_;
    $settings{'buffer_out'} ||= do{ my $x = '' };
    $settings{'sample_rate'} ||= 44100;
    $settings{'audio_bytes'} ||= 4096;
    $settings{'gain'} ||= .8;
    my $self = Nick::Audio::FluidSynth -> new_xs(
        @settings{ qw( buffer_out sample_rate audio_bytes gain ) }
    );
    $self -> setting_int(
        'audio.period-size' => $settings{'audio_bytes'}
    );
    return $self;
}

sub set_pan {
    $_[0] -> set_controller( $_[1], 10, $_[2] );
}

1;
