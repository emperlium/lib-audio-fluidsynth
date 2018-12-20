use strict;
use warnings;

use Test::More tests => 3;

use_ok( 'Nick::Audio::FluidSynth' );

my $buffer;
my $fluidsynth = Nick::Audio::FluidSynth -> new(
    'buffer_out'    => \$buffer,
    'soundfont'     => '/usr/share/sounds/sf2/FluidR3_GM.sf2',
    'sample_rate'   => 11050,
    'audio_bytes'   => 500,
    'gain'          => 1
);

ok( defined( $fluidsynth ), 'new()' );

$fluidsynth -> setting_string( 'synth.reverb.active', 'no' );
$fluidsynth -> setting_string( 'synth.chorus.active', 'no' );

$fluidsynth -> send_note( 9, 62, 127, 10 );
$fluidsynth -> process();
is(
    join( ' ', length( $buffer ), unpack 's*', $buffer ),
    '500 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 -1 0 0 -1 0 0 1 0 -1 1 0 -1 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 -1 -1 0 0 1 0 -1 0 1 0 -1 0 0 -1 0 0 0 0 0 0 0 -1 1 1 0 0 -1 0 1 0 0 0 0 0 0 -1 0 0 -1 0 0 0 0 0 0 0 0 1 0 0 -1 0 0 -1 1 0 -1 0 0 0 0 -1 -1 0 0 0 0 -1 -1 0 -1 0 1 0 -1 -1 0 -1 0 0 -1 -1 0 -1 0 0 -1 -1 0 0 -2 0 -1 0 0 -1 0 -1 -2 -1 -1 -2 -2 -3 -3 -5 -5 -8 -8 -7 -7 -4 -6 -5 -1 -237 -197 -844 -783 -1470 -1439 -1977 -2023 -2178 -2178 -1739 -1784 64 13 1110 1130 1365 1334 2284 2359 2050 2122 3046 2990 5008 5052 6406 6457 7072 7099 5627 5790 -2134 -3117 -4746 -4892 -5236 -4846 -10275 -10309 -9935 -9481 -7373 -7548 -3465 -3885 2580 2109 10175 10508 6131 6279 6004 6358 10119 10381 10750 10827 9486 9906',
    'Processed PCM'
);
