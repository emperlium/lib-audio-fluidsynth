use strict;
use warnings;

use Test::More tests => 3;

use_ok( 'Nick::Audio::FluidSynth' );

my $buffer;
my $fluidsynth = Nick::Audio::FluidSynth -> new(
    'buffer_out'    => \$buffer,
    'sample_rate'   => 11025,
    'audio_bytes'   => 500,
    'gain'          => 1
);

ok( defined( $fluidsynth ), 'new()' );

$fluidsynth -> load_soundfont(
    $ENV{'TEST_SOUNDFONT'} || '/usr/share/sounds/sf2/FluidR3_GM.sf2'
);
$fluidsynth -> setting_int( 'synth.reverb.active', 0 );
$fluidsynth -> setting_int( 'synth.chorus.active', 0 );

$fluidsynth -> send_note( 9, 62, 127, 10 );
$fluidsynth -> process();
my $rms = 0;
for ( unpack 's*', $buffer ) {
    $rms += $_ ** 2;
}
ok( sqrt( $rms ) > 1000, 'Processed PCM' );
